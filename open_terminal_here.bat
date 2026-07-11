@echo off
chcp 65001 >nul 2>&1
if errorlevel 1 chcp 437 >nul 2>&1

setlocal EnableExtensions

:: ============================================================
:: open_terminal_here.bat
:: Mo Command Prompt tai thu muc chua adb.exe / fastboot.exe
:: (tools\) va them tools\ vao PATH de goi truc tiep:
::     adb devices
::     fastboot devices
:: ============================================================

set "ROOT=%~dp0"
set "TOOLS_DIR=%ROOT%tools"

if not exist "%TOOLS_DIR%\adb.exe" (
    echo [LOI] Khong tim thay adb.exe tai "%TOOLS_DIR%\adb.exe"
    echo       Hay giu thu muc tools nam canh file BAT.
    pause
    exit /b 1
)
if not exist "%TOOLS_DIR%\fastboot.exe" (
    echo [LOI] Khong tim thay fastboot.exe tai "%TOOLS_DIR%\fastboot.exe"
    echo       Hay giu thu muc tools nam canh file BAT.
    pause
    exit /b 1
)

echo Mo terminal tai: %TOOLS_DIR%
echo Da them tools\ vao PATH cho phien nay.
echo.
echo Vi du lenh:
echo     adb devices
echo     fastboot devices
echo     adb reboot bootloader
echo.

:: Mo cua so cmd moi, cd vao tools va prepend PATH
start "ADB/Fastboot Terminal" cmd /K "cd /d "%TOOLS_DIR%" && set "PATH=%TOOLS_DIR%;%PATH%" && echo [%CD%] && adb version"

endlocal
exit /b 0
