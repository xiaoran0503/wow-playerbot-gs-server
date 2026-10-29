@echo off
chcp 65001 >nul
setlocal EnableDelayedExpansion
cd /d "%~dp0"

rem ============================================================
rem  WOW 自维护版服务器端 - 一键启动（推荐用这个）
rem
rem  启动顺序很关键：
rem    1) MySQL
rem    2) authserver  先起，它要把 realmlist 的 realm 放出来
rem    3) worldserver 后起，它启动时会把 realm 标记为
rem       OFFLINE|VERSION_MISMATCH(=3)，并在自己完全就绪后
rem       再把 VERSION_MISMATCH 清掉。
rem
rem  所以不要在 worldserver 还在跑的时候重启 authserver，
rem  否则 authserver 会看到 flag=3 而拒绝启动
rem  （日志里是 "No valid realms specified"）。
rem ============================================================

echo.
echo ============================================
echo   WOW 自维护版服务器端 - 一键启动
echo ============================================
echo.

rem ---- 0) 清掉代理环境变量 ----
rem 游戏服务器不需要访问外网。留着 shell 里的 http_proxy 会让 Lua 引擎
rem 内置的 HTTP 客户端走代理隧道，其 TLS 握手在静态链接的 OpenSSL 下
rem 会让 worldserver 以访问违例崩溃（Crashes\*.dmp）。
set "http_proxy="
set "https_proxy="
set "HTTP_PROXY="
set "HTTPS_PROXY="
set "ALL_PROXY="
set "all_proxy="

rem ---- 1) MySQL ----
if not exist "%~dp0mysql\bin\mysqld.exe" (
    echo [错误] 找不到 mysql\bin\mysqld.exe
    pause
    exit /b 1
)

rem MySQL 8.4 不接受含非 ASCII 字符的 basedir/datadir 路径，
rem 这里统一映射一个纯 ASCII 盘符来启动，两种情况都稳。
set "SUBST_DRIVE=Y:"
for %%D in (Q R S T U V W X Y) do (
    if not exist %%D:\ (
        subst %%D: "%~dp0"
        set "SUBST_DRIVE=%%D:"
        goto :launch
    )
)

:launch
echo [1/3] 启动 MySQL (映射盘符 %SUBST_DRIVE%) ...
start "" /min "%SUBST_DRIVE%mysql\bin\mysqld.exe" ^
    --defaults-file="%SUBST_DRIVE%mysql\my.ini" ^
    --basedir="%SUBST_DRIVE%mysql" ^
    --datadir="%SUBST_DRIVE%mysql\data" ^
    --console

rem 等 MySQL 真正起来
set /a WAIT=0
:waitmysql
timeout /t 2 /nobreak >nul
set /a WAIT+=2
"%~dp0mysql\bin\mysqladmin.exe" --user=root --host=127.0.0.1 --port=3306 ping >nul 2>&1
if errorlevel 1 (
    if !WAIT! lss 60 (
        echo       等待 MySQL 就绪 ... !WAIT! 秒
        goto :waitmysql
    )
    echo [错误] MySQL 未能启动，请检查 logs 或手动运行 start-mysql.bat
    pause
    exit /b 1
)
echo       MySQL 已就绪。

rem ---- 2) authserver ----
echo [2/3] 启动 authserver ...
start "wow-auth" "%~dp0authserver.exe"
timeout /t 5 /nobreak >nul

rem ---- 3) worldserver ----
echo [3/3] 启动 worldserver ...
start "wow-world" "%~dp0worldserver.exe"

echo.
echo ============================================
echo   启动完成。
echo   worldserver 首次初始化需要约 1-3 分钟，
echo   看到 "World initialized" 后即可用客户端登录。
echo   停止服务：双击 stop-server.bat
echo ============================================
echo.
pause
