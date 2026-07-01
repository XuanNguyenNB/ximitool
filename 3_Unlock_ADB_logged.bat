@echo off
title Ximi Unlock ADB - Log Mode
cd /d "%~dp0"
if not exist "%~dp0reports\" mkdir "%~dp0reports\" >nul 2>nul

echo [LOG] Che do log da bat.
echo [LOG] Trace log se duoc luu tai: %~dp0reports\adb_trace_YYYYMMDD_HHMMSS.log
echo.
echo Sau khi script ket thuc, hay tim file trace log moi nhat trong thu muc reports\
echo va gui kem khi bao loi.
echo.
pause

call "%~dp03_Unlock_ADB.bat"
set "_INNER_EC=%errorlevel%"

echo.
echo =================================================================
echo [LOG] Script chinh da ket thuc voi exit code: %_INNER_EC%
echo [LOG] Cac file trace log gan day:
powershell -NoProfile -Command "Get-ChildItem '%~dp0reports\adb_trace_*.log' -ErrorAction SilentlyContinue | Sort-Object LastWriteTime -Descending | Select-Object -First 3 | ForEach-Object { $_.FullName }"
echo =================================================================
echo.
echo Nhan Enter de dong cua so log.
pause >nul
