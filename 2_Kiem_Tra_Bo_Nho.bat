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

for /F %%a in ('echo prompt $E ^| cmd 2^>nul') do set "ESC=%%a"
if not defined ESC set "ESC= "
set "RED=%ESC%[31m"
set "GRN=%ESC%[32m"
set "YEL=%ESC%[33m"
set "CYN=%ESC%[36m"
set "RST=%ESC%[0m"

set "ROOT=%~dp0"
set "ADB=%ROOT%tools\bin\adb.exe"
set "SEVEN=%ROOT%tools\bin\7za.exe"
set "REPORT_DIR=%ROOT%reports"
set "ERROR_CODE=0"
set "ERROR_MSG="

if not exist "%REPORT_DIR%" mkdir "%REPORT_DIR%" >nul 2>nul

call :RequireFiles
if errorlevel 1 (
    set "ERROR_CODE=2"
    set "ERROR_MSG=Thieu file can thiet (adb.exe hoac 7za.exe)."
    goto :End
)
call :GetDevice
if errorlevel 1 (
    set "ERROR_CODE=2"
    set "ERROR_MSG=Khong tim thay thiet bi ADB."
    goto :End
)
call :ReadProps
goto :Menu

:Mode1
call :PullLatestPhoneBugreport
if errorlevel 1 (
    set "ERROR_CODE=3"
    set "ERROR_MSG=Khong lay duoc bugreport tu dien thoai."
    goto :End
)
call :ParseZip "%LOCAL_ZIP%"
goto :End

:Mode2
call :CreateXiaomiBugreport
if errorlevel 1 (
    set "ERROR_CODE=3"
    set "ERROR_MSG=Khong tao duoc bugreport Xiaomi."
    goto :End
)
call :ParseZip "%LOCAL_ZIP%"
goto :End

:Mode3
call :ChooseLocalZip
if errorlevel 1 (
    set "ERROR_CODE=3"
    set "ERROR_MSG=Khong chon duoc file zip."
    goto :End
)
call :ParseZip "%LOCAL_ZIP%"
goto :End

:Mode4
call :ShowStartScreen
call :RunAdbBugreport
if errorlevel 1 (
    call :ShowBugreportError
    set "ERROR_CODE=3"
    set "ERROR_MSG=ADB bugreport that bai."
    goto :End
)
call :ParseZip "%LOCAL_ZIP%"
goto :End

:Menu
cls
echo %CYN%Xiaomi UFS Checker by XuanNguyen%RST%
echo Momo: 0899813596
echo Telegram: t.me/mitomtreem
echo %CYN%=================================%RST%
echo.
echo %YEL%THIET BI DA KET NOI%RST%
echo -------------------
echo Device Serial : %GRN%%SERIAL%%RST%
echo Model         : %GRN%%MODEL%%RST%
echo Codename      : %GRN%%DEVICE%%RST%
echo.
echo %YEL%CHON CHE DO KIEM TRA%RST%
echo --------------------
echo 1. Kiem tra tu bugreport Xiaomi moi nhat tren dien thoai
echo 2. Mo My device, cho ban tao bugreport Xiaomi moi roi kiem tra
echo 3. Parse bugreport .zip co san trong reports
echo %GRN%4. Tao bang adb bugreport roi kiem tra - Khuyen dung%RST%
echo.
echo %CYN%(Enter de mac dinh chay che do 4)%RST%
set "CHOICE="
set /p "CHOICE=Nhap 1/2/3/4: "

if not defined CHOICE goto :Mode4
if "%CHOICE%"=="1" goto :Mode1
if "%CHOICE%"=="2" goto :Mode2
if "%CHOICE%"=="3" goto :Mode3
if "%CHOICE%"=="4" goto :Mode4

echo.
echo %RED%Lua chon khong hop le.%RST%
echo An phim bat ki de chon lai.
pause >nul
goto :Menu

:RequireFiles
if not exist "%ADB%" (
    echo %RED%Loi: khong tim thay adb.exe tai "%ADB%"%RST%
    exit /b 1
)
if not exist "%SEVEN%" (
    echo %RED%Loi: khong tim thay 7za.exe tai "%SEVEN%"%RST%
    echo Hay giu thu muc bin nam canh file BAT.
    exit /b 1
)
exit /b 0

:ShowStartScreen
cls
echo %CYN%Xiaomi UFS Checker by XuanNguyen%RST%
echo Momo: 0899813596
echo Telegram: t.me/mitomtreem
echo %CYN%================================%RST%
echo.
echo %YEL%THIET BI DA KET NOI%RST%
echo -------------------
echo Device Serial : %GRN%%SERIAL%%RST%
echo Model         : %GRN%%MODEL%%RST%
echo Codename      : %GRN%%DEVICE%%RST%
echo.
echo %YEL%CHE DO KIEM TRA%RST%
echo ---------------
echo Tool se tu dong tao bugreport bang ADB va doc thong tin UFS/RAM.
echo Qua trinh nay co the mat 1-5 phut, vui long khong rut cap.
echo.
echo(Enter hoac an phim bat ki de bat dau kiem tra^!
pause >nul
exit /b 0

:ShowBugreportError
cls
echo %RED%KHONG THE TAO BUGREPORT%RST%
echo.
echo ADB bugreport bi loi hoac bi ngat ket noi.
echo.
echo Ban co the thu:
echo 1. Kiem tra lai cap USB
echo 2. Dam bao dien thoai van dang mo khoa
echo 3. Rut cap va cam lai
echo 4. Chay lai tool
exit /b 0

:GetDevice
:GetDeviceRetry
call :ScanDevice
if defined SERIAL exit /b 0

cls
if /i "%ADB_PROBLEM_STATE%"=="unauthorized" (
    call :ShowUnauthorizedGuide
) else (
    call :ShowUsbDebugGuide
)

echo.
echo(An enter hoac phim bat ki de thu phat hien lai^!
pause >nul
goto :GetDeviceRetry

:ScanDevice
set "SERIAL="
set "ADB_PROBLEM_SERIAL="
set "ADB_PROBLEM_STATE="
for /f "skip=1 tokens=1,2" %%A in ('"%ADB%" devices 2^>nul') do (
    if "%%B"=="device" if not defined SERIAL set "SERIAL=%%A"
    if not "%%B"=="" if not defined ADB_PROBLEM_STATE (
        set "ADB_PROBLEM_SERIAL=%%A"
        set "ADB_PROBLEM_STATE=%%B"
    )
)
exit /b 0

:ShowUsbDebugGuide
echo %RED%CHUA TIM THAY DIEN THOAI ADB%RST%
echo.
echo Tool chua thay may Xiaomi o trang thai "device".
echo Co the do chua cam cap, chua bat USB debugging, hoac chua bam Cho phep tren dien thoai.
echo.
echo CACH BAT GO LOI USB TREN XIAOMI
echo --------------------------------
echo.
echo Buoc 1: Vao Settings / Cai dat tren dien thoai
echo.
echo Buoc 2: Chon "My device" / "Thiet bi cua toi"
echo.
echo Buoc 3: Tim dong "OS version" / "MIUI version" / "HyperOS version"
echo         roi bam lien tuc 7-10 lan
echo.
echo         Co the may se yeu cau nhap mat khau man hinh.
echo.
echo         Khi hien thong bao "You are now a developer"
echo         hoac "Da bat che do nha phat trien" la thanh cong.
echo.
echo Buoc 4: Quay lai Settings / Cai dat
echo.
echo Buoc 5: Vao "Additional settings" / "Cai dat bo sung"
echo.
echo Buoc 6: Vao "Developer options" / "Tuy chon nha phat trien"
echo.
echo Buoc 7: Bat "USB debugging" / "Go loi USB" / "Doi 10 giay roi OK de xac nhan"
echo.
echo Buoc 8: Cam cap USB vao may tinh.
echo         Tren dien thoai se hien hop thoai RSA/USB debugging.
echo.
echo         Hay bam "OK" / "Allow" / "Cho phep"
echo.
echo --------------------------------
exit /b 0

:ShowUnauthorizedGuide
echo %RED%DA THAY DIEN THOAI NHUNG CHUA DUOC CAP QUYEN ADB%RST%
echo.
echo Trang thai hien tai: %YEL%unauthorized%RST%
if defined ADB_PROBLEM_SERIAL echo Serial: %ADB_PROBLEM_SERIAL%
echo.
echo Hay mo man hinh dien thoai va tim hop thoai:
echo "Allow USB debugging?"
echo hoac
echo "Cho phep go loi USB?"
echo.
echo Sau do bam "OK" / "Allow" / "Cho phep"
echo.
echo Neu khong thay hop thoai:
echo 1. Rut cap USB va cam lai
echo 2. Doi cong USB/cap USB
echo 3. Vao Developer options - Revoke USB debugging authorizations
echo 4. Cam lai cap va chap nhan hop thoai moi
echo.
echo --------------------------------
exit /b 0

:ReadProps
set "MODEL="
set "DEVICE="
set "ANDROID="
set "BUILD="
call :ReadOneProp ro.product.model MODEL
call :ReadOneProp ro.product.device DEVICE
call :ReadOneProp ro.build.version.release ANDROID
call :ReadOneProp ro.build.display.id BUILD
exit /b 0

:ReadOneProp
set "PROP_TMP=%TEMP%\ximi_prop_%RANDOM%%RANDOM%.txt"
"%ADB%" -s "%SERIAL%" shell getprop %~1 > "%PROP_TMP%" 2>nul
for /f "usebackq delims=" %%A in ("%PROP_TMP%") do (
    if not defined %~2 set "%~2=%%A"
)
del "%PROP_TMP%" >nul 2>nul
exit /b 0

:PullLatestPhoneBugreport
echo.
echo Dang tim bugreport Xiaomi tren dien thoai...
call :FindLatestRemoteBugreport
if not defined REMOTE_ZIP (
    echo %RED%Loi: khong tim thay bugreport*.zip trong /sdcard/MIUI/debug_log, Download, Documents.%RST%
    exit /b 1
)
call :MakeStamp
set "LOCAL_ZIP=%REPORT_DIR%\phone_bugreport_%STAMP%.zip"
echo Pull: %REMOTE_ZIP%
"%ADB%" -s "%SERIAL%" pull "%REMOTE_ZIP%" "%LOCAL_ZIP%"
if errorlevel 1 (
    echo %RED%Loi: adb pull that bai.%RST%
    exit /b 1
)
exit /b 0

:FindLatestRemoteBugreport
set "REMOTE_ZIP="
set "REMOTE_LIST=%TEMP%\ximi_remote_%RANDOM%%RANDOM%.txt"
for %%D in (/sdcard/MIUI/debug_log /sdcard/Download /sdcard/Documents) do (
    if not defined REMOTE_ZIP (
        "%ADB%" -s "%SERIAL%" shell ls -t %%D/bugreport*.zip > "%REMOTE_LIST%" 2>nul
        for /f "usebackq delims=" %%R in ("%REMOTE_LIST%") do (
            if not defined REMOTE_ZIP set "REMOTE_ZIP=%%R"
        )
    )
)
del "%REMOTE_LIST%" >nul 2>nul
exit /b 0

:CreateXiaomiBugreport
call :FindLatestRemoteBugreport
set "BASELINE_REMOTE=%REMOTE_ZIP%"
echo.
echo Dang mo man hinh My device tren dien thoai...
"%ADB%" -s "%SERIAL%" shell am start -a android.settings.DEVICE_INFO_SETTINGS >nul 2>nul
echo.
echo Hay thao tac tren dien thoai:
echo   1. Cham lien tuc vao ten chipset/CPU trong My device.
echo   2. Khi hop thoai bugreport hien ra, bam dong y/tao bao cao.
echo   3. Tool se cho file zip moi, pull ve va kiem tra.
echo.
echo Dang cho bugreport moi, toi da khoang 10 phut...
set /a WAIT_LEFT=120
:WaitBugreportLoop
timeout /t 5 /nobreak >nul
set "REMOTE_ZIP="
call :FindLatestRemoteBugreport
if defined REMOTE_ZIP (
    if not "%REMOTE_ZIP%"=="%BASELINE_REMOTE%" goto :PullLatestPhoneBugreport
)
set /a WAIT_LEFT-=1
if %WAIT_LEFT% GTR 0 goto :WaitBugreportLoop
echo %RED%Loi: het thoi gian cho bugreport moi.%RST%
exit /b 1

:ChooseLocalZip
echo.
echo Zip trong reports:
set /a ZIP_COUNT=0
for /f "delims=" %%F in ('dir /b /a-d /o-d "%REPORT_DIR%\*.zip" 2^>nul') do (
    set /a ZIP_COUNT+=1
    set "ZIP_!ZIP_COUNT!=%REPORT_DIR%\%%F"
    echo   !ZIP_COUNT!. %%F
)
echo   0. Nhap duong dan khac
echo.
set "PICK="
set /p "PICK=Chon file: "
if "%PICK%"=="0" (
    set "LOCAL_ZIP="
    set /p "LOCAL_ZIP=Nhap duong dan bugreport .zip: "
    if not exist "!LOCAL_ZIP!" (
        echo %RED%Loi: file khong ton tai.%RST%
        exit /b 1
    )
    exit /b 0
)
call set "LOCAL_ZIP=%%ZIP_%PICK%%%"
if not defined LOCAL_ZIP (
    echo %RED%Loi: lua chon khong hop le.%RST%
    exit /b 1
)
exit /b 0

:RunAdbBugreport
cls
echo %YEL%DANG KIEM TRA%RST%
echo -------------
echo.
echo %CYN%[1/3]%RST% Dang tao bugreport bang ADB...
echo       Vui long giu ket noi cap USB.
echo.
call :MakeStamp
set "BEFORE="
for /f "delims=" %%F in ('dir /b /a-d /o-d "%REPORT_DIR%\bugreport*.zip" 2^>nul') do if not defined BEFORE set "BEFORE=%%F"
"%ADB%" -s "%SERIAL%" bugreport "%REPORT_DIR%"
if errorlevel 1 (
    exit /b 1
)
set "LOCAL_ZIP="
for /f "delims=" %%F in ('dir /b /a-d /o-d "%REPORT_DIR%\bugreport*.zip" 2^>nul') do if not defined LOCAL_ZIP set "LOCAL_ZIP=%REPORT_DIR%\%%F"
if not defined LOCAL_ZIP (
    exit /b 1
)
exit /b 0

:ParseZip
set "INPUT_ZIP=%~1"
if not exist "%INPUT_ZIP%" (
    echo %RED%Loi: khong tim thay zip "%INPUT_ZIP%"%RST%
    exit /b 1
)

call :ResetParsedData
call :MakeStamp
set "WORK=%TEMP%\ximi_mem_%RANDOM%%RANDOM%"
set "OUTER=%WORK%\outer"
set "CORE=%WORK%\core"
mkdir "%OUTER%" "%CORE%" >nul 2>nul

echo.
echo %CYN%[2/3]%RST% Dang giai nen bugreport...
echo       Dang tim du lieu RAM / UFS trong file bugreport.
"%SEVEN%" x -y -bd -bso0 -bsp0 "-o%OUTER%" "%INPUT_ZIP%" "bugreport-*.zip" >nul 2>nul

set "CORE_ZIP=%INPUT_ZIP%"
set "NESTED_ZIP="
for /r "%OUTER%" %%F in (bugreport-*.zip) do (
    if not defined NESTED_ZIP (
        set "NESTED_ZIP=%%F"
        set "CORE_ZIP=%%F"
    )
)

"%SEVEN%" x -y -bd -bso0 -bsp0 "-o%CORE%" "%CORE_ZIP%" "bugreport-*.txt" "dumpstate_board.txt" "dumpstate_log.txt" "FS\proc\meminfo" >nul 2>nul

echo.
echo %CYN%[3/3]%RST% Dang phan tich thong tin bo nho...
for /r "%CORE%" %%F in (*.txt) do call :ScanFile "%%F"
for /r "%CORE%" %%F in (meminfo) do call :ScanFile "%%F"

if not defined ROM_CODE if not defined RAM_CODE (
    echo %RED%Loi: khong doc duoc thong tin RAM/ROM trong bugreport.%RST%
    rd /s /q "%WORK%" >nul 2>nul
    exit /b 1
)

call :MapRamVendor "%RAM_CODE%" RAM_VENDOR
call :MapRomVendor "%ROM_CODE%" ROM_VENDOR
call :PreEolText "%PRE_EOL_RAW%" PRE_EOL_TEXT
call :LifeText "%LIFE_A_RAW%" LIFE_A_TEXT
call :LifeText "%LIFE_B_RAW%" LIFE_B_TEXT

if not defined RAM_SIZE if defined MEM_GB set "RAM_SIZE=%MEM_GB%"

call :WriteReport
rd /s /q "%WORK%" >nul 2>nul
exit /b 0

:ResetParsedData
set "RAM_CODE="
set "RAM_VENDOR="
set "RAM_SIZE="
set "ROM_CODE="
set "ROM_VENDOR="
set "ROM_SIZE="
set "ROM_MODEL="
set "ROM_FW="
set "PRE_EOL_RAW="
set "PRE_EOL_TEXT="
set "LIFE_A_RAW="
set "LIFE_A_TEXT="
set "LIFE_B_RAW="
set "LIFE_B_TEXT="
set "UFS_HBA="
set "MEM_GB="
exit /b 0

:ScanFile
set "SCAN_FILE=%~1"

if not defined ROM_CODE (
    for /f "usebackq tokens=1-5" %%A in (`findstr /c:"U: " "%SCAN_FILE%" 2^>nul`) do (
        if /i "%%A"=="U:" if not defined ROM_CODE (
            set "ROM_CODE=%%B"
            set "ROM_SIZE=%%C"
            set "ROM_MODEL=%%D"
            set "ROM_FW=%%E"
        )
    )
)

if not defined RAM_CODE (
    for /f "usebackq tokens=1-3" %%A in (`findstr /c:"D: " "%SCAN_FILE%" 2^>nul`) do (
        if /i "%%A"=="D:" if not defined RAM_CODE (
            set "RAM_CODE=%%B"
            set "RAM_SIZE=%%C"
        )
    )
)

if not defined PRE_EOL_RAW (
    for /f "usebackq tokens=2 delims==" %%A in (`findstr /c:"bPreEOLInfo" "%SCAN_FILE%" 2^>nul`) do (
        if not defined PRE_EOL_RAW for /f "tokens=1" %%V in ("%%A") do set "PRE_EOL_RAW=%%V"
    )
)

if not defined LIFE_A_RAW (
    for /f "usebackq tokens=2 delims==" %%A in (`findstr /c:"bDeviceLifeTimeEstA" "%SCAN_FILE%" 2^>nul`) do (
        if not defined LIFE_A_RAW for /f "tokens=1" %%V in ("%%A") do set "LIFE_A_RAW=%%V"
    )
)

if not defined LIFE_B_RAW (
    for /f "usebackq tokens=2 delims==" %%A in (`findstr /c:"bDeviceLifeTimeEstB" "%SCAN_FILE%" 2^>nul`) do (
        if not defined LIFE_B_RAW for /f "tokens=1" %%V in ("%%A") do set "LIFE_B_RAW=%%V"
    )
)

if not defined UFS_HBA (
    for /f "usebackq tokens=2 delims==" %%A in (`findstr /c:"hba->ufs_version" "%SCAN_FILE%" 2^>nul`) do (
        if not defined UFS_HBA for /f "tokens=1" %%V in ("%%A") do set "UFS_HBA=%%V"
    )
)

if not defined MEM_GB (
    for /f "usebackq tokens=2" %%A in (`findstr /b /c:"MemTotal:" "%SCAN_FILE%" 2^>nul`) do (
        if not defined MEM_GB (
            set /a "MEM_GB=(%%A + 1048575) / 1048576"
        )
    )
)
exit /b 0

:MapRamVendor
set "V=Unknown"
if /i "%~1"=="0x01" set "V=Samsung"
if /i "%~1"=="0x03" set "V=Micron"
if /i "%~1"=="0x06" set "V=SK Hynix"
if /i "%~1"=="0xff" set "V=Micron"
set "%~2=%V%"
exit /b 0

:MapRomVendor
set "V=Unknown"
if /i "%~1"=="0x01ce" set "V=Samsung"
if /i "%~1"=="0x00ec" set "V=Samsung"
if /i "%~1"=="0x01ad" set "V=SK Hynix"
if /i "%~1"=="0x00ad" set "V=SK Hynix"
if /i "%~1"=="0x0198" set "V=Toshiba/Kioxia"
if /i "%~1"=="0x0098" set "V=Toshiba/Kioxia"
if /i "%~1"=="0x012c" set "V=Micron"
if /i "%~1"=="0x002c" set "V=Micron"
if /i "%~1"=="0x0145" set "V=SanDisk/Western Digital"
if /i "%~1"=="0x0045" set "V=SanDisk/Western Digital"
if /i "%~1"=="0x0f86" set "V=XBSTOR"
set "%~2=%V%"
exit /b 0

:PreEolText
set "V=Unknown"
if /i "%~1"=="0x1" set "V=Normal"
if /i "%~1"=="0x2" set "V=Warning"
if /i "%~1"=="0x3" set "V=Critical"
set "%~2=%V%"
exit /b 0

:LifeText
set "V=Unknown"
if /i "%~1"=="0x0" set "V=Not defined"
if /i "%~1"=="0x1" set "V=0%% - 10%% used"
if /i "%~1"=="0x2" set "V=10%% - 20%% used"
if /i "%~1"=="0x3" set "V=20%% - 30%% used"
if /i "%~1"=="0x4" set "V=30%% - 40%% used"
if /i "%~1"=="0x5" set "V=40%% - 50%% used"
if /i "%~1"=="0x6" set "V=50%% - 60%% used"
if /i "%~1"=="0x7" set "V=60%% - 70%% used"
if /i "%~1"=="0x8" set "V=70%% - 80%% used"
if /i "%~1"=="0x9" set "V=80%% - 90%% used"
if /i "%~1"=="0xa" set "V=90%% - 100%% used"
if /i "%~1"=="0xb" set "V=Exceeded estimated lifetime"
set "%~2=%V%"
exit /b 0

:WriteReport
set "REPORT_TXT=%REPORT_DIR%\memory_report_%STAMP%.txt"
> "%REPORT_TXT%" echo KET QUA KIEM TRA
>> "%REPORT_TXT%" echo ================
>> "%REPORT_TXT%" echo.
>> "%REPORT_TXT%" echo THIET BI
>> "%REPORT_TXT%" echo --------
>> "%REPORT_TXT%" echo Device Serial : %SERIAL%
>> "%REPORT_TXT%" echo Model         : %MODEL%
>> "%REPORT_TXT%" echo Codename      : %DEVICE%
>> "%REPORT_TXT%" echo Android       : %ANDROID%
>> "%REPORT_TXT%" echo Build         : %BUILD%
>> "%REPORT_TXT%" echo.
>> "%REPORT_TXT%" echo UFS / ROM
>> "%REPORT_TXT%" echo ---------
>> "%REPORT_TXT%" echo Hang          : %ROM_VENDOR%
>> "%REPORT_TXT%" echo Ma hang       : %ROM_CODE%
>> "%REPORT_TXT%" echo Dung luong    : %ROM_SIZE% GB
>> "%REPORT_TXT%" echo Model         : %ROM_MODEL%
>> "%REPORT_TXT%" echo Firmware      : %ROM_FW%
>> "%REPORT_TXT%" echo UFS version   : %UFS_HBA%
>> "%REPORT_TXT%" echo.
>> "%REPORT_TXT%" echo RAM
>> "%REPORT_TXT%" echo ---
>> "%REPORT_TXT%" echo Hang          : %RAM_VENDOR%
>> "%REPORT_TXT%" echo Ma hang       : %RAM_CODE%
>> "%REPORT_TXT%" echo Dung luong    : %RAM_SIZE% GB
>> "%REPORT_TXT%" echo.
>> "%REPORT_TXT%" echo TINH TRANG UFS
>> "%REPORT_TXT%" echo --------------
>> "%REPORT_TXT%" echo Pre-EOL       : %PRE_EOL_TEXT% (%PRE_EOL_RAW%^)
>> "%REPORT_TXT%" echo LifeTime A    : %LIFE_A_TEXT% (%LIFE_A_RAW%^)
>> "%REPORT_TXT%" echo LifeTime B    : %LIFE_B_TEXT% (%LIFE_B_RAW%^)
>> "%REPORT_TXT%" echo.
>> "%REPORT_TXT%" echo FILE BAO CAO
>> "%REPORT_TXT%" echo ------------
>> "%REPORT_TXT%" echo Da luu tai:
>> "%REPORT_TXT%" echo %REPORT_TXT%
>> "%REPORT_TXT%" echo.
>> "%REPORT_TXT%" echo NGUON DU LIEU
>> "%REPORT_TXT%" echo ------------
>> "%REPORT_TXT%" echo Bugreport     : %INPUT_ZIP%
if defined NESTED_ZIP >> "%REPORT_TXT%" echo Zip long nhau : %NESTED_ZIP%
>> "%REPORT_TXT%" echo.
>> "%REPORT_TXT%" echo Xiaomi UFS Checker by XuanNguyen
>> "%REPORT_TXT%" echo Momo: 0899813596
>> "%REPORT_TXT%" echo Telegram: t.me/mitomtreem

call :ShowResult
exit /b 0

:ShowResult
cls
echo %CYN%KET QUA KIEM TRA%RST%
echo %CYN%================%RST%
echo.
echo %YEL%THIET BI%RST%
echo --------
echo Device Serial : %GRN%%SERIAL%%RST%
echo Model         : %GRN%%MODEL%%RST%
echo Codename      : %GRN%%DEVICE%%RST%
echo Android       : %GRN%%ANDROID%%RST%
echo Build         : %GRN%%BUILD%%RST%
echo.
echo %YEL%UFS / ROM%RST%
echo ---------
echo Hang          : %GRN%%ROM_VENDOR%%RST%
echo Ma hang       : %ROM_CODE%
echo Dung luong    : %GRN%%ROM_SIZE% GB%RST%
echo Model         : %ROM_MODEL%
echo Firmware      : %ROM_FW%
echo UFS version   : %UFS_HBA%
echo.
echo %YEL%RAM%RST%
echo ---
echo Hang          : %GRN%%RAM_VENDOR%%RST%
echo Ma hang       : %RAM_CODE%
echo Dung luong    : %GRN%%RAM_SIZE% GB%RST%
echo.
echo %YEL%TINH TRANG UFS%RST%
echo --------------
echo Pre-EOL       : %PRE_EOL_TEXT% (%PRE_EOL_RAW%^)
echo LifeTime A    : %LIFE_A_TEXT% (%LIFE_A_RAW%^)
echo LifeTime B    : %LIFE_B_TEXT% (%LIFE_B_RAW%^)
echo.
echo %ROM_VENDOR% | findstr /i "Kioxia Toshiba" >nul && (
    echo %RED%--------------------------------%RST%
    echo %RED%CANH BAO: UFS hang Toshiba/Kioxia%RST%
    echo %RED%Loai UFS nay thuong de chai/hong nhanh hon.%RST%
    echo %RED%Hay kiem tra ky LifeTime va Pre-EOL o tren.%RST%
    echo %RED%--------------------------------%RST%
    echo.
)
echo %YEL%FILE BAO CAO%RST%
echo ------------
echo Da luu tai:
echo %GRN%%REPORT_TXT%%RST%
echo.
echo %CYN%Xiaomi UFS Checker by XuanNguyen%RST%
echo Momo: 0899813596
echo Telegram: t.me/mitomtreem
echo.
echo %CYN%--------------------------------%RST%
echo %YEL%REBOOT TO BOOTLOADER%RST%
echo %CYN%--------------------------------%RST%
echo Ban co muon reboot may vao Bootloader khong?
set "REBOOT_CHOICE="
set /p "REBOOT_CHOICE=Gop Y de reboot, phim bat ki de thoat: "
if /i "!REBOOT_CHOICE!"=="Y" (
    echo.
    echo Dang reboot to bootloader...
    "%ADB%" -s "%SERIAL%" reboot bootloader
    echo Lenh da gui. May se reboot vao Bootloader.
)
exit /b 0

:MakeStamp
set "STAMP=%DATE%_%TIME%_%RANDOM%"
set "STAMP=%STAMP:/=-%"
set "STAMP=%STAMP:\=-%"
set "STAMP=%STAMP::=-%"
set "STAMP=%STAMP:.=-%"
set "STAMP=%STAMP:,=-%"
set "STAMP=%STAMP: =0%"
exit /b 0

:: ===================== EXIT CHUNG =====================
:End
echo.
if "!ERROR_CODE!" neq "0" if "!ERROR_CODE!" neq "" (
    echo =================================================================
    echo   SCRIPT KET THUC VOI LOI [code: !ERROR_CODE!]
    if defined ERROR_MSG echo   Ly do: !ERROR_MSG!
    echo =================================================================
)
echo.
echo Nhan Enter de dong cua so nay.
pause >nul
endlocal
exit /b 0
