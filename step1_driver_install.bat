@echo off
chcp 65001 >nul
setlocal EnableExtensions EnableDelayedExpansion

set "ROOT=%~dp0"
set "DRIVER_DIR=%ROOT%drivers"
set "LOG=%ROOT%driver_install_log.txt"

net session >nul 2>&1
if not "%ERRORLEVEL%"=="0" (
    echo Dang yeu cau quyen Administrator...
    powershell -NoProfile -ExecutionPolicy Bypass -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
    exit /b
)

cls
echo Xiaomi Driver Installer
echo =======================
echo.
echo Driver folder:
echo %DRIVER_DIR%
echo.

if not exist "%DRIVER_DIR%" (
    echo Loi: khong tim thay thu muc drivers.
    echo Hay dat thu muc drivers canh file Driver_install.bat.
    echo.
    pause
    exit /b 1
)

where pnputil >nul 2>&1
if errorlevel 1 (
    echo Loi: khong tim thay pnputil tren Windows nay.
    echo.
    pause
    exit /b 1
)

> "%LOG%" echo Xiaomi Driver Installer Log
>> "%LOG%" echo ==========================
>> "%LOG%" echo Time: %DATE% %TIME%
>> "%LOG%" echo Driver folder: %DRIVER_DIR%
>> "%LOG%" echo.

set /a COUNT=0
set /a OK=0
set /a REBOOT=0
set /a FAIL=0

for /r "%DRIVER_DIR%" %%F in (*.inf) do (
    set /a COUNT+=1
    set "PNP_OUT=%TEMP%\ximi_driver_!RANDOM!!RANDOM!.txt"
    echo [!COUNT!] Dang cai: %%F
    >> "%LOG%" echo [!COUNT!] %%F

    pnputil /add-driver "%%F" /install > "!PNP_OUT!" 2>&1
    type "!PNP_OUT!" >> "%LOG%"

    findstr /i /c:"System reboot is needed" "!PNP_OUT!" >nul
    if not errorlevel 1 (
        set /a REBOOT+=1
        echo      OK - can restart de hoan tat.
        >> "%LOG%" echo Result: OK_REBOOT_REQUIRED
    ) else (
        findstr /i /c:"Driver package added successfully" /c:"Driver package installed" "!PNP_OUT!" >nul
        if not errorlevel 1 (
            set /a OK+=1
            echo      OK
            >> "%LOG%" echo Result: OK
        ) else (
            set /a FAIL+=1
            echo      LOI - driver khong cai duoc hoac khong phu hop.
            >> "%LOG%" echo Result: FAIL
        )
    )

    del "!PNP_OUT!" >nul 2>nul
    >> "%LOG%" echo(
)

echo.
echo Hoan tat.
echo Tong INF : %COUNT%
echo Thanh cong/da them : %OK%
echo Can restart de xong : %REBOOT%
echo Loi/khong phu hop  : %FAIL%
echo.
echo Log da luu tai:
echo %LOG%
echo.
if %REBOOT% GTR 0 (
    echo Mot so driver da cai thanh cong nhung Windows yeu cau restart de hoan tat.
    echo Day khong phai loi cai dat.
    echo.
)
echo Co the rut/cam lai dien thoai sau khi cai driver. Neu Windows yeu cau, hay restart may tinh.
echo.
pause
exit /b 0
