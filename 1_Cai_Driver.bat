@echo off
chcp 65001 >nul 2>&1
if errorlevel 1 chcp 437 >nul 2>&1

setlocal DisableDelayedExpansion
set "SCRIPT_DIR=%~dp0"
set "SCRIPT_DIR=%SCRIPT_DIR:~0,-1%"
set "BAD_PATH="
echo("%SCRIPT_DIR%" | findstr /c:"!" >nul && set "BAD_PATH=1"
echo("%SCRIPT_DIR%" | findstr /c:"%%" >nul && set "BAD_PATH=1"
if "%SCRIPT_DIR:~0,2%"=="\\" set "BAD_PATH=2"
if defined BAD_PATH (
    echo.
    echo [LOI] Duong dan thu muc khong duoc chua ky tu dac biet hoac la UNC.
    echo       Duong dan hien tai: "%SCRIPT_DIR%"
    if "%BAD_PATH%"=="2" echo       Ly do: phat hien UNC path "\\server\share\..." - khong duoc ho tro.
    if "%BAD_PATH%"=="1" echo       Ly do: phat hien ky tu "!" hoac "%%" trong duong dan.
    echo       Hay di chuyen thu muc ra cho khac, vi du C:\Ximi_tool_Lite\
    echo.
    pause
    exit /B 1
)
if not exist "%~dp0" (
    echo [LOI] Khong xac dinh duoc thu muc script.
    pause
    exit /B 1
)
cd /d "%~dp0" 2>nul
if errorlevel 1 (
    echo [LOI] Khong the chuyen vao thu muc "%~dp0".
    echo       Co the do thieu quyen truy cap.
    pause
    exit /B 1
)
endlocal

setlocal EnableExtensions EnableDelayedExpansion
set "ERROR_CODE=0"
set "ERROR_MSG="

set "ROOT=%~dp0"
set "DRIVER_DIR=%ROOT%drivers"
set "LOG=%ROOT%driver_install_log.txt"

:: ===================== KIEM TRA QUYEN ADMIN =====================
net session >nul 2>&1
if not "%ERRORLEVEL%"=="0" (
    echo Dang yeu cau quyen Administrator...
    powershell -NoProfile -ExecutionPolicy Bypass -Command "Start-Process -FilePath \"%~f0\" -Verb RunAs"
    exit /b
)

:: ===================== ANSI COLORS =====================
for /F %%a in ('echo prompt $E ^| cmd 2^>nul') do set "ESC=%%a"
if not defined ESC set "ESC= "
set "RED=%ESC%[31m"
set "GRN=%ESC%[32m"
set "YEL=%ESC%[33m"
set "CYN=%ESC%[36m"
set "RST=%ESC%[0m"

:: ===================== HEADER =====================
cls
echo %CYN%Xiaomi Driver Installer%RST%
echo %CYN%=======================%RST%
echo.
echo Driver folder:
echo %GRN%%DRIVER_DIR%%RST%
echo.

:: ===================== PRE-FLIGHT =====================
if not exist "%DRIVER_DIR%" (
    set "ERROR_CODE=2"
    set "ERROR_MSG=Khong tim thay thu muc drivers tai '%DRIVER_DIR%'."
    echo %RED%Loi: khong tim thay thu muc drivers.%RST%
    echo Hay dat thu muc drivers canh file bat.
    goto :End
)

where pnputil >nul 2>&1
if errorlevel 1 (
    set "ERROR_CODE=2"
    set "ERROR_MSG=Khong tim thay pnputil tren Windows nay."
    echo %RED%Loi: khong tim thay pnputil tren Windows nay.%RST%
    goto :End
)

:: ===================== LOG INIT =====================
> "%LOG%" echo Xiaomi Driver Installer Log 2>nul
if errorlevel 1 (
    set "LOG=%TEMP%\ximi_driver_install_log.txt"
    > "!LOG!" echo Xiaomi Driver Installer Log
    echo %YEL%[CANH BAO] Khong ghi duoc log vao thu muc goc, dung %TEMP%%RST%
)
>> "%LOG%" echo ==========================
>> "%LOG%" echo Time: %DATE% %TIME%
>> "%LOG%" echo Driver folder: %DRIVER_DIR%
>> "%LOG%" echo.

:: ===================== CAI DAT DRIVER =====================
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
    set "PNP_EC=!ERRORLEVEL!"
    type "!PNP_OUT!" >> "%LOG%"

    if "!PNP_EC!"=="3010" (
        set /a REBOOT+=1
        echo      %YEL%OK - can restart de hoan tat.%RST%
        >> "%LOG%" echo Result: OK_REBOOT_REQUIRED ^(exit code 3010^)
    ) else if "!PNP_EC!"=="0" (
        set /a OK+=1
        echo      %GRN%OK%RST%
        >> "%LOG%" echo Result: OK ^(exit code 0^)
    ) else (
        REM Fallback: parse output text for older pnputil that always returns 0
        findstr /i /c:"System reboot is needed" "!PNP_OUT!" >nul
        if not errorlevel 1 (
            set /a REBOOT+=1
            echo      %YEL%OK - can restart de hoan tat.%RST%
            >> "%LOG%" echo Result: OK_REBOOT_REQUIRED ^(text match^)
        ) else (
            findstr /i /c:"Driver package added successfully" /c:"Driver package installed" "!PNP_OUT!" >nul
            if not errorlevel 1 (
                set /a OK+=1
                echo      %GRN%OK%RST%
                >> "%LOG%" echo Result: OK ^(text match^)
            ) else (
                set /a FAIL+=1
                echo      %RED%LOI - driver khong cai duoc hoac khong phu hop.%RST%
                >> "%LOG%" echo Result: FAIL ^(exit code !PNP_EC!^)
            )
        )
    )

    del "!PNP_OUT!" >nul 2>nul
    >> "%LOG%" echo(
)

:: ===================== KET QUA =====================
echo.
echo %CYN%Hoan tat.%RST%
echo Tong INF          : %GRN%!COUNT!%RST%
echo Thanh cong/da them: %GRN%!OK!%RST%
echo Can restart       : %YEL%!REBOOT!%RST%
echo Loi/khong phu hop : %RED%!FAIL!%RST%
echo.
echo Log da luu tai:
echo %GRN%%LOG%%RST%
echo.
if !REBOOT! GTR 0 (
    echo %YEL%Mot so driver da cai thanh cong nhung Windows yeu cau restart de hoan tat.%RST%
    echo %YEL%Day khong phai loi cai dat.%RST%
    echo.
)
if !FAIL! GTR 0 (
    echo %RED%Mot so driver khong cai duoc. Xem log de biet chi tiet.%RST%
    echo.
)
echo Co the rut/cam lai dien thoai sau khi cai driver.
echo Neu Windows yeu cau, hay restart may tinh.

set "ERROR_CODE=0"
set "ERROR_MSG="
goto :End

:: ===================== EXIT CHUNG =====================
:End
echo.
set "HAS_ERROR=0"
if "!ERROR_CODE!" neq "0" if "!ERROR_CODE!" neq "" set "HAS_ERROR=1"
if defined FAIL if !FAIL! GTR 0 set "HAS_ERROR=1"

if "!HAS_ERROR!"=="1" (
    echo =================================================================
    if "!ERROR_CODE!" neq "0" if "!ERROR_CODE!" neq "" (
        echo   SCRIPT KET THUC VOI LOI [code: !ERROR_CODE!]
        if defined ERROR_MSG echo   Ly do: !ERROR_MSG!
    ) else (
        echo   SCRIPT HOAN TAT NHUNG CO DRIVER CAI LOI - xem log de biet chi tiet.
    )
    echo =================================================================
    echo.
    echo Nhan Enter de dong cua so nay.
    pause >nul
) else (
    echo %GRN%Cai driver hoan tat khong loi. Cua so se tu dong dong sau 3 giay...%RST%
    timeout /t 3 /nobreak >nul 2>&1
)
endlocal
exit /B 0
