@echo off
chcp 65001 >nul
setlocal EnableDelayedExpansion
cd /d "%~dp0"

rem ============================================================
rem  WOW 自维护版服务器端 - 启动 MySQL 8.4.9
rem ============================================================
echo.
echo   正在启动 MySQL 8.4.9 ...
echo.

if not exist "%~dp0mysql\bin\mysqld.exe" (
    echo [错误] 找不到 mysql\bin\mysqld.exe，请确认 mysql 目录完整。
    pause
    exit /b 1
)

rem MySQL 8.4 无法处理含非 ASCII 字符的 basedir/datadir 路径：
rem 路径里有中文时它会截断成 "E:\"，于是报 "Failed to set datadir"。
rem 纯 ASCII 路径（本项目交付目录 D:\wow_server）不受影响。
rem 这里统一用 subst 映射一个纯 ASCII 盘符来启动，两种情况都稳。
set "SUBST_DRIVE=Y:"
for %%D in (Q R S T U V W X Y) do (
    if not exist %%D:\ (
        subst %%D: "%~dp0"
        set "SUBST_DRIVE=%%D:"
        goto :launch
    )
)

:launch
echo [信息] 映射盘符 %SUBST_DRIVE% -> %~dp0
echo [信息] MySQL 数据目录: %SUBST_DRIVE%mysql\data
echo [信息] 端口 3306，按 Ctrl+C 可停止。
echo.

if exist "%~dp0mysql\data\mysqld.pid" del /f "%~dp0mysql\data\mysqld.pid" 2>nul

"%SUBST_DRIVE%mysql\bin\mysqld.exe" ^
    --defaults-file="%SUBST_DRIVE%mysql\my.ini" ^
    --basedir="%SUBST_DRIVE%mysql" ^
    --datadir="%SUBST_DRIVE%mysql\data" ^
    --console

echo.
echo MySQL 已停止。
pause
