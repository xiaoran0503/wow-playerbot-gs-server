@echo off
chcp 65001 >nul
setlocal EnableDelayedExpansion
cd /d "%~dp0"

rem ============================================================
rem  WOW 自维护版服务器端 - 停止服务器
rem  顺序：worldserver -> authserver -> MySQL
rem ============================================================

echo.
echo [1/3] 关闭 worldserver ...
rem 先尝试走正常的 .server shutdown 命令，失败再强杀
taskkill /IM worldserver.exe >nul 2>&1
if errorlevel 1 (
    echo       worldserver 未在运行。
) else (
    echo       worldserver 已结束。
)
timeout /t 3 /nobreak >nul

echo [2/3] 关闭 authserver ...
taskkill /IM authserver.exe >nul 2>&1
if errorlevel 1 (
    echo       authserver 未在运行。
) else (
    echo       authserver 已结束。
)
timeout /t 2 /nobreak >nul

echo [3/3] 关闭 MySQL ...
"%~dp0mysql\bin\mysqladmin.exe" --user=root --host=127.0.0.1 --port=3306 shutdown >nul 2>&1
if errorlevel 1 (
    echo       用 mysqladmin 关闭失败，改为直接结束 mysqld 进程。
    taskkill /IM mysqld.exe >nul 2>&1
) else (
    echo       MySQL 已正常关闭。
)

echo.
echo 服务器已停止。
timeout /t 2 /nobreak >nul
