/*
 * This file is part of the AzerothCore Project. See AUTHORS file for Copyright information
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
 * FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for
 * more details.
 *
 * You should have received a copy of the GNU General Public License along
 * with this program. If not, see <http://www.gnu.org/licenses/>.
 */

#include "DBUpdater.h"
#include "BuiltInConfig.h"
#include "Config.h"
#include "DatabaseEnv.h"
#include "DatabaseLoader.h"
#include "DatabaseWorkerPoolAdapter.h"
#include "Log.h"
#include "StartProcess.h"
#include "UpdateFetcher.h"
#include "QueryResult.h"
#include <filesystem>
#include <fstream>
#include <iostream>
#include <vector>

std::string DBUpdaterUtil::GetCorrectedMySQLExecutable()
{
    if (!corrected_path().empty())
        return corrected_path();
    else
        return BuiltInConfig::GetMySQLExecutable();
}

bool DBUpdaterUtil::CheckExecutable()
{
    // absolute() without an error_code throws (an empty path, a missing working directory),
    // and nothing up to main() catches filesystem_error
    std::error_code ec;
    std::filesystem::path const configured(GetCorrectedMySQLExecutable());
    if (!is_regular_file(configured, ec))
    {
        std::filesystem::path const found(Acore::SearchExecutableInPath("mysql"));
        if (!found.empty() && is_regular_file(found, ec))
        {
            std::filesystem::path const absoluteFound = absolute(found, ec);
            if (!ec)
            {
                // Correct the path to the cli
                corrected_path() = absoluteFound.generic_string();
                return true;
            }
        }

        LOG_FATAL("sql.updates", "Didn't find any executable MySQL binary at \'{}\' or in path, correct the path in the *.conf (\"MySQLExecutable\").",
            configured.generic_string());

        return false;
    }
    return true;
}

std::string& DBUpdaterUtil::corrected_path()
{
    static std::string path;
    return path;
}

uint32& DBUpdaterUtil::failed_updates()
{
    static uint32 count = 0;
    return count;
}

void DBUpdaterUtil::MarkUpdateFailed()
{
    ++failed_updates();
}

uint32 DBUpdaterUtil::GetFailedUpdateCount()
{
    return failed_updates();
}

// Auth Database
template<>
std::string DBUpdater<LoginDatabaseConnection>::GetConfigEntry()
{
    return "Updates.Auth";
}

template<>
std::string DBUpdater<LoginDatabaseConnection>::GetTableName()
{
    return "Auth";
}

template<>
std::string DBUpdater<LoginDatabaseConnection>::GetSourceDirectory()
{
    return BuiltInConfig::GetSourceDirectory();
}

template<>
std::string DBUpdater<LoginDatabaseConnection>::GetBaseFilesDirectory()
{
    return DBUpdater<LoginDatabaseConnection>::GetSourceDirectory() + "/data/sql/base/db_auth/";
}

template<>
bool DBUpdater<LoginDatabaseConnection>::IsEnabled(uint32 const updateMask)
{
    // This way silences warnings under msvc
    return (updateMask & DatabaseLoader::DATABASE_LOGIN) ? true : false;
}

template<>
std::string DBUpdater<LoginDatabaseConnection>::GetDBModuleName()
{
    // must be lowercase
    return "auth";
}

// World Database
template<>
std::string DBUpdater<WorldDatabaseConnection>::GetConfigEntry()
{
    return "Updates.World";
}

template<>
std::string DBUpdater<WorldDatabaseConnection>::GetTableName()
{
    return "World";
}

template<>
std::string DBUpdater<WorldDatabaseConnection>::GetSourceDirectory()
{
    return BuiltInConfig::GetSourceDirectory();
}

template<>
std::string DBUpdater<WorldDatabaseConnection>::GetBaseFilesDirectory()
{
    return DBUpdater<WorldDatabaseConnection>::GetSourceDirectory() + "/data/sql/base/db_world/";
}

template<>
bool DBUpdater<WorldDatabaseConnection>::IsEnabled(uint32 const updateMask)
{
    // This way silences warnings under msvc
    return (updateMask & DatabaseLoader::DATABASE_WORLD) ? true : false;
}

template<>
std::string DBUpdater<WorldDatabaseConnection>::GetDBModuleName()
{
    // must be lowercase
    return "world";
}

// Character Database
template<>
std::string DBUpdater<CharacterDatabaseConnection>::GetConfigEntry()
{
    return "Updates.Character";
}

template<>
std::string DBUpdater<CharacterDatabaseConnection>::GetTableName()
{
    return "Character";
}

template<>
std::string DBUpdater<CharacterDatabaseConnection>::GetSourceDirectory()
{
    return BuiltInConfig::GetSourceDirectory();
}

template<>
std::string DBUpdater<CharacterDatabaseConnection>::GetBaseFilesDirectory()
{
    return DBUpdater<CharacterDatabaseConnection>::GetSourceDirectory() + "/data/sql/base/db_characters/";
}

template<>
bool DBUpdater<CharacterDatabaseConnection>::IsEnabled(uint32 const updateMask)
{
    // This way silences warnings under msvc
    return (updateMask & DatabaseLoader::DATABASE_CHARACTER) ? true : false;
}

template<>
std::string DBUpdater<CharacterDatabaseConnection>::GetDBModuleName()
{
    // must be lowercase
    return "characters";
}

// All
template<class T>
BaseLocation DBUpdater<T>::GetBaseLocationType()
{
    return LOCATION_REPOSITORY;
}

namespace
{

using Path = std::filesystem::path;

QueryResult Retrieve(DatabaseUpdatePool& pool, std::string const& query);
void Apply(DatabaseUpdatePool& pool, std::string const& query);
void ApplyFile(DatabaseUpdatePool& pool, Path const& path);
void ApplyFile(DatabaseUpdatePool& pool, std::string const& host, std::string const& user,
               std::string const& password, std::string const& port_or_socket, std::string const& database,
               std::string const& ssl, Path const& path);

bool CreateDatabase(DatabaseUpdatePool& pool)
{
    LOG_WARN("sql.updates", "Database \"{}\" does not exist", pool.GetConnectionInfo()->database);

    if (!DBUpdaterUtil::CheckExecutable())
        return false;

    char const* disableInteractive = std::getenv("AC_DISABLE_INTERACTIVE");

    if (!sConfigMgr->isDryRun() && (disableInteractive == nullptr || std::strcmp(disableInteractive, "1") != 0))
    {
        std::cout << "Do you want to create it? [yes (default) / no]:" << std::endl;
        std::string answer;
        std::getline(std::cin, answer);
        if (!answer.empty() && !(answer.substr(0, 1) == "y"))
            return false;
    }

    LOG_INFO("sql.updates", "Creating database \"{}\"...", pool.GetConnectionInfo()->database);

    // Path of temp file
    static Path const temp("create_table.sql");

    // Create temporary query to use external MySQL CLi
    std::ofstream file(temp.generic_string());
    if (!file.is_open())
    {
        LOG_FATAL("sql.updates", "Failed to create temporary query file \"{}\"!", temp.generic_string());
        return false;
    }

    file << "CREATE DATABASE `" << pool.GetConnectionInfo()->database << "` DEFAULT CHARACTER SET UTF8MB4 COLLATE utf8mb4_general_ci;\n\n";
    file.close();

    try
    {
        ApplyFile(pool, pool.GetConnectionInfo()->host, pool.GetConnectionInfo()->user,
                  pool.GetConnectionInfo()->password, pool.GetConnectionInfo()->port_or_socket, "",
                  pool.GetConnectionInfo()->ssl, temp);
    }
    catch (UpdateException&)
    {
        LOG_FATAL("sql.updates", "Failed to create database {}! Does the user (named in *.conf) have `CREATE`, `ALTER`, `DROP`, `INSERT` and `DELETE` privileges on the MySQL server?", pool.GetConnectionInfo()->database);
        std::filesystem::remove(temp);
        return false;
    }

    LOG_INFO("sql.updates", "Done.");
    LOG_INFO("sql.updates", " ");
    std::filesystem::remove(temp);
    return true;
}

bool UpdateDatabase(DatabaseUpdatePool& pool, DBUpdaterInfo const& info, std::string_view modulesList)
{
    if (!DBUpdaterUtil::CheckExecutable())
        return false;

    LOG_INFO("sql.updates", "Updating {} database...", info.displayName);

    Path const sourceDirectory(info.sourceDirectory);

    std::error_code sourceEc;
    if (!is_directory(sourceDirectory, sourceEc))
    {
        LOG_ERROR("sql.updates", "DBUpdater: The given source directory {} does not exist, change the path to the directory where your sql directory exists (for example c:\\source\\azerothcore). Shutting down.",
                  sourceDirectory.generic_string());
        return false;
    }

    auto CheckUpdateTable = [&](std::string const& tableName)
    {
        auto checkTable = Retrieve(pool, Acore::StringFormat("SHOW TABLES LIKE '{}'", tableName));
        if (!checkTable)
        {
            LOG_WARN("sql.updates", "> Table '{}' not exist! Try add based table", tableName);

            Path const temp = Path(info.baseFilesDirectory) / (tableName + ".sql");

            try
            {
                ApplyFile(pool, temp);
            }
            catch (UpdateException&)
            {
                LOG_FATAL("sql.updates", "Failed apply file to database {}! Does the user (named in *.conf) have `INSERT` and `DELETE` privileges on the MySQL server?", pool.GetConnectionInfo()->database);
                return false;
            }

            return true;
        }

        return true;
    };

    if (!CheckUpdateTable("updates") || !CheckUpdateTable("updates_include"))
        return false;

    UpdateFetcher updateFetcher(sourceDirectory, [&](std::string const & query) { Apply(pool, query); },
    [&](Path const & file) { ApplyFile(pool, file); },
    [&](std::string const & query) -> QueryResult { return Retrieve(pool, query); }, info.dbModuleName, modulesList);

    UpdateResult result;
    try
    {
        result = updateFetcher.Update(
                     sConfigMgr->GetOption<bool>("Updates.Redundancy", true),
                     sConfigMgr->GetOption<bool>("Updates.AllowRehash", true),
                     sConfigMgr->GetOption<bool>("Updates.ArchivedRedundancy", false),
                     sConfigMgr->GetOption<int32>("Updates.CleanDeadRefMaxCount", 3));
    }
    catch (UpdateException&)
    {
        return false;
    }
    catch (std::filesystem::filesystem_error const& e)
    {
        // A filesystem error is not an UpdateException, so without this handler it would
        // escape every catch block and terminate the server process.
        LOG_FATAL("sql.updates", "Updating the {} database failed: {}", info.displayName, e.what());
        DBUpdaterUtil::MarkUpdateFailed();
        return false;
    }

    std::string const summary = Acore::StringFormat("Containing {} new and {} archived updates.", result.recent, result.archived);

    if (!result.updated)
        LOG_INFO("sql.updates", ">> {} database is up-to-date! {}", info.displayName, summary);
    else
        LOG_INFO("sql.updates", ">> Applied {} {}. {}", result.updated, result.updated == 1 ? "query" : "queries", summary);

    LOG_INFO("sql.updates", " ");

    return true;
}

bool UpdateDatabase(DatabaseUpdatePool& pool, DBUpdaterInfo const& info,
                    std::vector<std::string> const* setDirectories)
{
    if (!DBUpdaterUtil::CheckExecutable())
    {
        return false;
    }

    Path const sourceDirectory(info.sourceDirectory);

    std::error_code sourceEc;
    if (!is_directory(sourceDirectory, sourceEc))
    {
        return false;
    }

    auto CheckUpdateTable = [&](std::string const& tableName)
    {
        auto checkTable = Retrieve(pool, Acore::StringFormat("SHOW TABLES LIKE '{}'", tableName));
        if (!checkTable)
        {
            Path const temp = Path(info.baseFilesDirectory) / (tableName + ".sql");
            try
            {
                ApplyFile(pool, temp);
            }
            catch (UpdateException&)
            {
                return false;
            }

            return true;
        }

        return true;
    };

    if (!CheckUpdateTable("updates") || !CheckUpdateTable("updates_include"))
    {
        return false;
    }

    UpdateFetcher updateFetcher(sourceDirectory, [&](std::string const & query) { Apply(pool, query); },
    [&](Path const & file) { ApplyFile(pool, file); },
    [&](std::string const & query) -> QueryResult { return Retrieve(pool, query); }, info.dbModuleName, setDirectories);

    UpdateResult result;
    try
    {
        result = updateFetcher.Update(
                     sConfigMgr->GetOption<bool>("Updates.Redundancy", true),
                     sConfigMgr->GetOption<bool>("Updates.AllowRehash", true),
                     sConfigMgr->GetOption<bool>("Updates.ArchivedRedundancy", false),
                     sConfigMgr->GetOption<int32>("Updates.CleanDeadRefMaxCount", 3));
    }
    catch (UpdateException&)
    {
        return false;
    }
    catch (std::filesystem::filesystem_error const& e)
    {
        // A filesystem error is not an UpdateException, so without this handler it would
        // escape every catch block and terminate the server process.
        LOG_FATAL("sql.updates", "Updating the {} database failed: {}", info.displayName, e.what());
        DBUpdaterUtil::MarkUpdateFailed();
        return false;
    }

    return true;
}

bool PopulateDatabase(DatabaseUpdatePool& pool, DBUpdaterInfo const& info)
{
    {
        QueryResult const result = Retrieve(pool, "SHOW TABLES");
        if (result && (result->GetRowCount() > 0))
            return true;
    }

    if (!DBUpdaterUtil::CheckExecutable())
        return false;

    LOG_INFO("sql.updates", "Database {} is empty, auto populating it...", info.displayName);

    std::string const DirPathStr = info.baseFilesDirectory;

    Path const DirPath(DirPathStr);

    // Every std::filesystem call that can fail has to use the error_code overload here.
    // The throwing overloads raise std::filesystem::filesystem_error, which is not an
    // UpdateException, so it would escape every catch block below and terminate the
    // server process instead of failing the update.
    std::error_code dirEc;
    if (!std::filesystem::is_directory(DirPath, dirEc))
    {
        LOG_ERROR("sql.updates", ">> Directory \"{}\" not exist", DirPath.generic_string());
        return false;
    }

    if (DirPath.empty())
    {
        LOG_ERROR("sql.updates", ">> Directory \"{}\" is empty", DirPath.generic_string());
        return false;
    }

    std::vector<std::filesystem::path> sqlFiles;

    std::error_code iterEc;
    std::filesystem::directory_iterator const DirItr;
    std::filesystem::directory_iterator itr(DirPath, iterEc);
    if (iterEc)
    {
        LOG_ERROR("sql.updates", ">> Cannot read directory \"{}\" ({})", DirPath.generic_string(), iterEc.message());
        return false;
    }

    while (itr != DirItr)
    {
        if (itr->path().extension() == ".sql")
            sqlFiles.push_back(itr->path());

        std::error_code incrementEc;
        itr.increment(incrementEc);
        if (incrementEc)
        {
            LOG_ERROR("sql.updates", ">> Cannot finish reading directory \"{}\" ({})", DirPath.generic_string(), incrementEc.message());
            break;
        }
    }

    uint32 FilesCount = sqlFiles.size();

    if (!FilesCount)
    {
        LOG_ERROR("sql.updates", ">> In directory \"{}\" not exist '*.sql' files", DirPath.generic_string());
        return false;
    }

    std::sort(sqlFiles.begin(), sqlFiles.end());

    for (auto const& file : sqlFiles)
    {
        LOG_INFO("sql.updates", ">> Applying \'{}\'...", file.filename().generic_string());

        try
        {
            ApplyFile(pool, file);
        }
        catch (UpdateException&)
        {
            return false;
        }
        catch (std::filesystem::filesystem_error const& e)
        {
            LOG_FATAL("sql.updates", ">> Failed to apply \"{}\": {}", file.generic_string(), e.what());
            return false;
        }
    }

    LOG_INFO("sql.updates", ">> Done!");
    LOG_INFO("sql.updates", " ");
    return true;
}

QueryResult Retrieve(DatabaseUpdatePool& pool, std::string const& query)
{
    return pool.Query(query);
}

void Apply(DatabaseUpdatePool& pool, std::string const& query)
{
    pool.DirectExecute(query);
}

void ApplyFile(DatabaseUpdatePool& pool, Path const& path)
{
    ApplyFile(pool, pool.GetConnectionInfo()->host, pool.GetConnectionInfo()->user,
              pool.GetConnectionInfo()->password, pool.GetConnectionInfo()->port_or_socket,
              pool.GetConnectionInfo()->database, pool.GetConnectionInfo()->ssl, path);
}

void ApplyFile(DatabaseUpdatePool& pool, std::string const& host, std::string const& user,
               std::string const& password, std::string const& port_or_socket, std::string const& database,
               std::string const& ssl, Path const& path)
{
    std::string configTempDir = sConfigMgr->GetOption<std::string>("TempDir", "");

    // temp_directory_path() throws std::filesystem::filesystem_error when no temporary
    // directory can be determined. Resolve it through the error_code overload so a
    // misconfigured environment produces a readable error instead of a dead process.
    std::string tempDir = configTempDir;
    if (tempDir.empty())
    {
        std::error_code tempEc;
        Path const systemTemp = std::filesystem::temp_directory_path(tempEc);
        if (tempEc || systemTemp.empty())
        {
            LOG_FATAL("sql.updates", "Cannot determine a temporary directory to store the MySQL client "
                                     "configuration ({}). Set \"TempDir\" in the *.conf to a writable directory.",
                tempEc ? tempEc.message() : "unknown error");
            throw UpdateException("Cannot determine the temporary directory");
        }
        tempDir = systemTemp.string();
    }

    tempDir = Acore::String::AddSuffixIfNotExists(tempDir, std::filesystem::path::preferred_separator);

    std::string confFileName = "mysql_ac.conf";

    std::ofstream outfile (tempDir + confFileName);

    outfile << "[client]\npassword = \"" << password << '"' << std::endl;

    outfile.close();

    std::vector<std::string> args;
    args.reserve(9);

    args.emplace_back("--defaults-extra-file="+tempDir + confFileName+"");

    // CLI Client connection info
    args.emplace_back("-u" + user);

    // Check if we want to connect through ip or socket (Unix only)
#ifdef _WIN32

    args.emplace_back("-h" + host);

    if (host == ".")
        args.emplace_back("--protocol=PIPE");
    else
        args.emplace_back("-P" + port_or_socket);

#else

    if (host == ".")
    {
        // The client only uses the socket for host localhost, see MySQLConnection::Open()
        args.emplace_back("-hlocalhost");
        args.emplace_back("-P0");
        args.emplace_back("--protocol=SOCKET");
        args.emplace_back("-S" + port_or_socket);
    }
    else
    {
        args.emplace_back("-h" + host);
        args.emplace_back("-P" + port_or_socket);
    }

#endif

    // Set the default charset to utf8
    args.emplace_back("--default-character-set=utf8");

    // Set max allowed packet to 1 GB
    args.emplace_back("--max-allowed-packet=1GB");

    if (ssl == "ssl")
        args.emplace_back("--ssl-mode=REQUIRED");

    // Database
    if (!database.empty())
        args.emplace_back(database);

    // Invokes a mysql process which doesn't leak credentials to logs
    // generic_string() converts the wide path back to a narrow string and raises
    // std::filesystem::filesystem_error when the path cannot be represented in the
    // current code page. Convert once, through the error_code overload, and fail with a
    // readable message instead of terminating the process.
    std::error_code pathEc;
    std::string const pathString = path.generic_string(pathEc);
    if (pathEc)
    {
        LOG_FATAL("sql.updates", "The path of the sql file to apply cannot be converted to a "
                                 "narrow string ({}). Move the server to a path that is representable "
                                 "in the current code page or set \"SourceDirectory\" accordingly.",
            pathEc.message());
        DBUpdaterUtil::MarkUpdateFailed();
        throw UpdateException("update failed");
    }

    int const ret = Acore::StartProcess(DBUpdaterUtil::GetCorrectedMySQLExecutable(), args,
        "sql.updates", pathString, true);

    if (ret != EXIT_SUCCESS)
    {
        LOG_FATAL("sql.updates", "Applying of file \'{}\' to database \'{}\' failed!" \
            " If you are a user, please pull the latest revision from the repository. "
            "Also make sure you have not applied any of the databases with your sql client. "
            "You cannot use auto-update system and import sql files from AzerothCore repository with your sql client. "
            "If you are a developer, please fix your sql query.",
            pathString, pool.GetConnectionInfo()->database);

        // Recorded in both modes. A dry run does not throw below, so it keeps attempting the
        // remaining files and this count is the only thing left to fail the run on.
        DBUpdaterUtil::MarkUpdateFailed();

        if (!sConfigMgr->isDryRun())
        {
            if (uint32 delay = sConfigMgr->GetOption<uint32>("Updates.ExceptionShutdownDelay", 10000))
                std::this_thread::sleep_for(Milliseconds(delay));

            throw UpdateException("update failed");
        }
    }
}

} // anonymous namespace

template<class T>
DBUpdaterInfo DBUpdater<T>::GetUpdaterInfo()
{
    return { GetTableName(), GetSourceDirectory(), GetBaseFilesDirectory(), GetDBModuleName() };
}

template<class T>
bool DBUpdater<T>::Create(DatabaseWorkerPool<T>& pool)
{
    DatabaseWorkerPoolAdapter<T> adapter(pool);
    return CreateDatabase(adapter);
}

template<class T>
bool DBUpdater<T>::Update(DatabaseWorkerPool<T>& pool, std::string_view modulesList /*= {}*/)
{
    DatabaseWorkerPoolAdapter<T> adapter(pool);
    return UpdateDatabase(adapter, GetUpdaterInfo(), modulesList);
}

template<class T>
bool DBUpdater<T>::Update(DatabaseWorkerPool<T>& pool, std::vector<std::string> const* setDirectories)
{
    DatabaseWorkerPoolAdapter<T> adapter(pool);
    return UpdateDatabase(adapter, GetUpdaterInfo(), setDirectories);
}

template<class T>
bool DBUpdater<T>::Populate(DatabaseWorkerPool<T>& pool)
{
    DatabaseWorkerPoolAdapter<T> adapter(pool);
    return PopulateDatabase(adapter, GetUpdaterInfo());
}

bool ModuleDBUpdater::Create(DatabaseUpdatePool& pool)
{
    return CreateDatabase(pool);
}

bool ModuleDBUpdater::Update(DatabaseUpdatePool& pool, DBUpdaterInfo const& info,
                             std::string_view modulesList /*= {}*/)
{
    return UpdateDatabase(pool, info, modulesList);
}

bool ModuleDBUpdater::Populate(DatabaseUpdatePool& pool, DBUpdaterInfo const& info)
{
    return PopulateDatabase(pool, info);
}

template class AC_DATABASE_API DBUpdater<LoginDatabaseConnection>;
template class AC_DATABASE_API DBUpdater<WorldDatabaseConnection>;
template class AC_DATABASE_API DBUpdater<CharacterDatabaseConnection>;
