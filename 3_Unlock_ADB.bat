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

setlocal enabledelayedexpansion
set "SCRIPT_DIR=%~dp0"
set "ERROR_CODE=0"
set "ERROR_MSG="

for /F %%a in ('echo prompt $E ^| cmd 2^>nul') do set "ESC=%%a"
if not defined ESC set "ESC= "
set "RED=%ESC%[31m"
set "GRN=%ESC%[32m"
set "YEL=%ESC%[33m"
set "CYN=%ESC%[36m"
set "RST=%ESC%[0m"

set "PATH=%~dp0tools\bin;%PATH%"

set "ADB_BIN=%~dp0tools\bin\adb.exe"
set "FASTBOOT_BIN=%~dp0tools\bin\fastboot.exe"
set "TMP_BL="
set "TMP_FRP="
set "TMP_DEV="
set "TMP_GE="

call :RequireTools
if errorlevel 1 (
    set "ERROR_CODE=2"
    set "ERROR_MSG=Pre-flight that bai: thieu file/thu muc bat buoc."
    goto :End
)

echo %CYN%=================================================================%RST%
echo  Xiaomi All-In-One Bootloader Unlock Tool
echo  Gom nhom tu nhieu phien ban chip: 8 Elite, 8 Gen 3, 8 Gen 2, v.v.
echo  Ho tro tu dong chuyen doi phuong thuc khai thac (Binder ^& Local Root)
echo %CYN%=================================================================%RST%
echo %RED%[CANH BAO] Viec mo khoa se XOA TOAN BO DU LIEU vinh vien!%RST%
echo.

set "confirm="
set /p confirm="Ban da hieu rui ro va muon tiep tuc? (Y/N): "
if /i "%confirm%" neq "Y" (
    set "ERROR_CODE=1"
    set "ERROR_MSG=Nguoi dung huy bo."
    goto :End
)

:main_menu
cls
echo %CYN%==========================================%RST%
echo  %GRN%CHON NEN TANG CHIP (SoC)%RST%
echo %CYN%==========================================%RST%
echo  1. Snapdragon 8 Elite (Xiaomi 15, Redmi K80...)
echo  2. Snapdragon 8 Gen 3 (Xiaomi 14, Redmi K70 Pro...)
echo  3. Snapdragon 8 Gen 2 (Xiaomi 13, Redmi K60 Pro...)
echo  4. Snapdragon 8s/7+ Gen 3 (Civi 4 Pro, K70E, Turbo 3...)
echo  5. Snapdragon 8s Gen 4 (Turbo 4 Pro, Civi 5 Pro, Pad 8)
echo  0. Thoat
echo %CYN%==========================================%RST%
set "soc_choice="
set /p soc_choice="Chon (0-5): "

if "%soc_choice%"=="1" goto menu_8e
if "%soc_choice%"=="2" goto menu_8g3
if "%soc_choice%"=="3" goto menu_8g2
if "%soc_choice%"=="4" goto menu_8sg3
if "%soc_choice%"=="5" goto menu_8sg4
if "%soc_choice%"=="0" (
    set "ERROR_CODE=0"
    goto :End
)
goto main_menu

:: ===================== MENU 8 ELITE =====================
:menu_8e
set "ennea_img=payloads\ennea\8750-Ennea.img"
set "UnlockMethod=1"
cls
echo %CYN%=== SNAPDRAGON 8 ELITE ===%RST%
echo  1. Redmi K80 Pro
echo  2. Redmi K90
echo  3. Xiaomi 15
echo  4. Xiaomi 15 Pro
echo  5. Xiaomi 15 Ultra
echo  6. Xiaomi Pad 8 Pro
echo  0. Quay lai
set "dev_choice="
set /p dev_choice="Chon: "
if "%dev_choice%"=="1" ( set "factoryImages=Redmik80pro" & set "unlockGPT=else8elite" )
if "%dev_choice%"=="2" ( set "factoryImages=Redmik90" & set "unlockGPT=else8elite" )
if "%dev_choice%"=="3" ( set "factoryImages=Xiaomi15" & set "unlockGPT=else8elite" )
if "%dev_choice%"=="4" ( set "factoryImages=Xiaomi15pro" & set "unlockGPT=else8elite" )
if "%dev_choice%"=="5" ( set "factoryImages=Xiaomi15ultra" & set "unlockGPT=else8elite" )
if "%dev_choice%"=="6" ( set "factoryImages=Xiaomipad8pro" & set "unlockGPT=Xiaomipad8pro" )
if "%dev_choice%"=="0" goto main_menu
if defined factoryImages goto pre_unlock
goto menu_8e

:: ===================== MENU 8 GEN 3 =====================
:menu_8g3
set "ennea_img=payloads\ennea\8650-Ennea.img"
cls
echo %CYN%=== SNAPDRAGON 8 GEN 3 ===%RST%
echo  1. Redmi K70 Pro (Thuong)
echo  2. Xiaomi 14 (Thuong)
echo  3. Xiaomi 14 Pro (Thuong)
echo  4. Xiaomi 14 Ultra (Thuong)
echo  -------------------------------
echo  5. Redmi K70 Pro (High Version - HyperOS Moi)
echo  6. Xiaomi 14 (High Version - HyperOS Moi)
echo  7. Xiaomi 14 Pro (High Version - HyperOS Moi)
echo  8. Xiaomi 14 Ultra (High Version - HyperOS Moi)
echo  0. Quay lai
set "dev_choice="
set /p dev_choice="Chon: "
if "%dev_choice%"=="1" ( set "factoryImages=Redmik70pro" & set "unlockGPT=Redmik70pro" & set "UnlockMethod=1" )
if "%dev_choice%"=="2" ( set "factoryImages=Xiaomi14" & set "unlockGPT=Xiaomi14" & set "UnlockMethod=1" )
if "%dev_choice%"=="3" ( set "factoryImages=Xiaomi14pro" & set "unlockGPT=Xiaomi14pro" & set "UnlockMethod=1" )
if "%dev_choice%"=="4" ( set "factoryImages=Xiaomi14ultra" & set "unlockGPT=Xiaomi14ultra" & set "UnlockMethod=1" )
if "%dev_choice%"=="5" ( set "factoryImages=Redmik70pro" & set "unlockGPT=Redmik70pro" & set "UnlockMethod=2" & set "bin_name=8g3" )
if "%dev_choice%"=="6" ( set "factoryImages=Xiaomi14" & set "unlockGPT=Xiaomi14" & set "UnlockMethod=2" & set "bin_name=8g3" )
if "%dev_choice%"=="7" ( set "factoryImages=Xiaomi14pro" & set "unlockGPT=Xiaomi14pro" & set "UnlockMethod=2" & set "bin_name=8g3" )
if "%dev_choice%"=="8" ( set "factoryImages=Xiaomi14ultra" & set "unlockGPT=Xiaomi14ultra" & set "UnlockMethod=2" & set "bin_name=8g3" )
if "%dev_choice%"=="0" goto main_menu
if defined factoryImages goto pre_unlock
goto menu_8g3

:: ===================== MENU 8 GEN 2 =====================
:menu_8g2
set "ennea_img=payloads\ennea\8550-Ennea.img"
set "UnlockMethod=1"
cls
echo %CYN%=== SNAPDRAGON 8 GEN 2 ===%RST%
echo  1. Redmi K60 Pro
echo  2. Redmi K70
echo  3. Redmi K80
echo  4. Xiaomi 13
echo  5. Xiaomi 13 Pro
echo  6. Xiaomi 13 Ultra
echo  7. Xiaomi Pad 6s Pro
echo  0. Quay lai
set "dev_choice="
set /p dev_choice="Chon: "
if "%dev_choice%"=="1" ( set "factoryImages=Redmik60pro" & set "unlockGPT=Redmik60pro" )
if "%dev_choice%"=="2" ( set "factoryImages=Redmik70" & set "unlockGPT=Redmik70" )
if "%dev_choice%"=="3" ( set "factoryImages=Redmik80" & set "unlockGPT=Redmik80" )
if "%dev_choice%"=="4" ( set "factoryImages=Xiaomi13" & set "unlockGPT=Xiaomi13" )
if "%dev_choice%"=="5" ( set "factoryImages=Xiaomi13pro" & set "unlockGPT=Xiaomi13pro" )
if "%dev_choice%"=="6" ( set "factoryImages=Xiaomi13ultra" & set "unlockGPT=Xiaomi13ultra" )
if "%dev_choice%"=="7" ( set "factoryImages=Xiaomipad6spro" & set "unlockGPT=Xiaomipad6spro" )
if "%dev_choice%"=="0" goto main_menu
if defined factoryImages goto pre_unlock
goto menu_8g2

:: ===================== MENU 8s/7+ GEN 3 =====================
:menu_8sg3
set "ennea_img=payloads\ennea\8635-Ennea.img"
cls
echo %CYN%=== SNAPDRAGON 8s/7+ GEN 3 ===%RST%
echo  1. Redmi Turbo 3 (Thuong)
echo  2. Xiaomi Civi 4 Pro (Thuong)
echo  3. Xiaomi Pad 7 Pro (Thuong)
echo  -------------------------------
echo  4. Redmi Turbo 3 (High Version)
echo  5. Xiaomi Civi 4 Pro (High Version)
echo  6. Xiaomi Pad 7 Pro (High Version)
echo  0. Quay lai
set "dev_choice="
set /p dev_choice="Chon: "
if "%dev_choice%"=="1" ( set "factoryImages=Redmiturbo3" & set "unlockGPT=Redmiturbo3" & set "UnlockMethod=1" )
if "%dev_choice%"=="2" ( set "factoryImages=Xiaomicivi4pro" & set "unlockGPT=Xiaomicivi4pro" & set "UnlockMethod=1" )
if "%dev_choice%"=="3" ( set "factoryImages=Xiaomipad7pro" & set "unlockGPT=Xiaomipad7pro" & set "UnlockMethod=1" )
if "%dev_choice%"=="4" ( set "factoryImages=Redmiturbo3" & set "unlockGPT=Redmiturbo3" & set "UnlockMethod=2" & set "bin_name=8sg3or7pg3" )
if "%dev_choice%"=="5" ( set "factoryImages=Xiaomicivi4pro" & set "unlockGPT=Xiaomicivi4pro" & set "UnlockMethod=2" & set "bin_name=8sg3or7pg3" )
if "%dev_choice%"=="6" ( set "factoryImages=Xiaomipad7pro" & set "unlockGPT=Xiaomipad7pro" & set "UnlockMethod=2" & set "bin_name=Xiaomipad7pro" )
if "%dev_choice%"=="0" goto main_menu
if defined factoryImages goto pre_unlock
goto menu_8sg3

:: ===================== MENU 8s GEN 4 =====================
:menu_8sg4
set "ennea_img=payloads\ennea\8735-Ennea.img"
set "UnlockMethod=1"
cls
echo %CYN%=== SNAPDRAGON 8s GEN 4 ===%RST%
echo  1. Redmi Turbo 4 Pro
echo  2. Xiaomi Civi 5 Pro
echo  3. Xiaomi Pad 8
echo  0. Quay lai
set "dev_choice="
set /p dev_choice="Chon: "
if "%dev_choice%"=="1" ( set "factoryImages=Redmiturbo4pro" & set "unlockGPT=Redmiturbo4pro" )
if "%dev_choice%"=="2" ( set "factoryImages=Xiaomicivi5pro" & set "unlockGPT=Xiaomicivi5pro" )
if "%dev_choice%"=="3" ( set "factoryImages=Xiaomipad8" & set "unlockGPT=Xiaomipad8" )
if "%dev_choice%"=="0" goto main_menu
if defined factoryImages goto pre_unlock
goto menu_8sg4

:: ===================== XAC NHAN CUOI CUNG =====================
:pre_unlock
call :ResolveAblPath "%factoryImages%"
call :ResolveGptPath "%factoryImages%"
set "unlock_gpt_path=%~dp0payloads\unlockGPT\%unlockGPT%\unlockgpt_both4.bin"
set "ennea_full=%~dp0%ennea_img%"

call :CheckPayloads
if errorlevel 1 (
    set "ERROR_CODE=3"
    set "ERROR_MSG=Thieu payload can thiet cho thiet bi nay."
    goto :End
)

echo %RED%=================================================================%RST%
echo                      CANH BAO CUOI CUNG
echo %RED%=================================================================%RST%
echo  THONG TIN DA CHON:
echo  - Thiet bi: %factoryImages%
echo  - ABL Path: %abl_path%
echo  - Unlock GPT: %unlock_gpt_path%
if "%UnlockMethod%"=="1" echo  - Phuong thuc: BINDER EXPLOIT (Old)
if "%UnlockMethod%"=="2" echo  - Phuong thuc: LOCAL ROOT EXPLOIT (High Version)
echo %RED%=================================================================%RST%
echo.
set "final_confirm="
set /p final_confirm="Xac nhan bat dau? (Y de tiep tuc, phim khac de thoat): "
if /i "%final_confirm%" neq "Y" (
    set "ERROR_CODE=1"
    set "ERROR_MSG=Nguoi dung huy bo o buoc xac nhan cuoi."
    goto :End
)

:: ===================== BUOC 1: KIEM TRA ADB =====================
echo %CYN%==========================================%RST%
echo  %GRN%Dang kiem tra ket noi ADB%RST%
echo %CYN%==========================================%RST%

:check_adb
set "count=0"

:wait_adb
call :ScanAdbState
if "%ADB_STATE%"=="device" goto adb_reboot
set /a count+=1
timeout /t 2 /nobreak >nul
echo ADB thu ket noi[%count%/10] - trang thai: %ADB_STATE%
if %count% lss 10 goto wait_adb
echo.
if /i "%ADB_STATE%"=="unauthorized" (
    echo %RED%[!] Dien thoai dang o trang thai UNAUTHORIZED.%RST%
    echo %RED%    Hay bam OK/Allow tren dien thoai de cap quyen USB debugging.%RST%
) else if /i "%ADB_STATE%"=="offline" (
    echo %RED%[!] Dien thoai dang OFFLINE - rut cap va cam lai.%RST%
) else if /i "%ADB_STATE%"=="recovery" (
    echo %RED%[!] Dien thoai dang o che do Recovery, can boot binh thuong truoc.%RST%
) else if /i "%ADB_STATE%"=="sideload" (
    echo %RED%[!] Dien thoai dang o Sideload, can boot binh thuong truoc.%RST%
) else (
    echo %RED%[!] Chua phat hien thiet bi ADB:%RST%
    echo %RED%    1. Da bat USB debugging chua?%RST%
    echo %RED%    2. Da cai driver va cam cap du lieu chua?%RST%
)
echo.
echo %YEL%Nhan Enter de thu phat hien lai.%RST%
pause >nul
goto check_adb

:: ===================== BUOC 2: REBOOT FASTBOOT =====================
:adb_reboot
"%ADB_BIN%" reboot bootloader
timeout /t 5 /nobreak >nul

echo %CYN%==========================================%RST%
echo  %GRN%Dang kiem tra ket noi Fastboot%RST%
echo %CYN%==========================================%RST%

:check_fastboot
set "count=0"

:loop_check
call :ScanFastboot
if "%FASTBOOT_OK%"=="1" goto selinux_permissive
set /a count+=1
timeout /t 2 /nobreak >nul
echo Fastboot thu ket noi[%count%/10]...
if %count% lss 10 goto loop_check
echo.
echo %RED%[!] Chua phat hien thiet bi o che do Fastboot.%RST%
echo %RED%    1. Hay chac chan dien thoai da vao Fastboot%RST%
echo %RED%    2. Kiem tra driver Fastboot da duoc cai chua%RST%
echo %RED%    3. Thu doi cap du lieu hoac cong USB%RST%
echo.
echo %YEL%Nhan Enter de thu phat hien lai.%RST%
pause >nul
goto check_fastboot

:: ===================== BUOC 3: SELINUX PERMISSIVE =====================
:selinux_permissive
"%FASTBOOT_BIN%" oem set-gpu-preemption 0 androidboot.selinux=permissive
"%FASTBOOT_BIN%" continue
if errorlevel 1 "%FASTBOOT_BIN%" reboot
timeout /t 5 /nobreak >nul

:check_adb_2
set "count=0"

:wait_adb_2
call :ScanAdbState
if "%ADB_STATE%"=="device" goto check_selinux
set /a count+=1
timeout /t 2 /nobreak >nul
echo ADB thu ket noi[%count%/10] - trang thai: %ADB_STATE%
if %count% lss 10 goto wait_adb_2
echo.
echo Vui long kiem tra cap du lieu hoac cong USB co bi long khong.
echo Nhan Enter de thu ket noi lai.
echo.
pause >nul
goto check_adb_2

:: ===================== BUOC 4: KIEM TRA SELINUX =====================
:check_selinux
call :MakeTmp TMP_GE
"%ADB_BIN%" shell getenforce > "%TMP_GE%" 2>&1
if errorlevel 1 (
    echo %RED%[!] Khong chay duoc 'adb shell getenforce' - thiet bi co the bi ngat ket noi.%RST%
    echo %YEL%Nhan Enter de thu lai.%RST%
    pause >nul
    goto check_adb_2
)
findstr /i "Permissive" "%TMP_GE%" >nul
if errorlevel 1 (
    echo %RED%[!] SELinux van dang Enforcing! Khong the tiep tuc.%RST%
    echo %RED%    Hay kiem tra phien ban firmware hoac lien he ho tro.%RST%
    type "%TMP_GE%"
    set "ERROR_CODE=4"
    set "ERROR_MSG=SELinux dang Enforcing, khong the flash ABL."
    goto :End
)
call :CleanupTemp

:: ===================== BUOC 5: FLASH ABL =====================
if "%UnlockMethod%"=="1" goto method_binder
if "%UnlockMethod%"=="2" goto method_localroot

:method_binder
echo %YEL%Dang su dung phuong thuc BINDER IMQSNative (Method 1)%RST%
if "%factoryImages%"=="Xiaomipad8pro" (
    set "abl_dest=/data/local/tmp/abl/abl.elf"
) else (
    set "abl_dest=/data/local/tmp/abl"
)
set "push_retry=0"
:flash_abl_binder
"%ADB_BIN%" push "%abl_path%" !abl_dest!
if errorlevel 1 (
    set /a push_retry+=1
    if !push_retry! geq 5 (
        echo %RED%[LOI] Push ABL that bai 5 lan lien tiep. Hay kiem tra ket noi va chay lai.%RST%
        set "ERROR_CODE=5"
        set "ERROR_MSG=Push ABL that bai 5 lan o BINDER method."
        goto :End
    )
    echo %YEL%Push ABL that bai (lan !push_retry!/5). Hay giu ket noi on dinh roi nhan Enter de thu lai.%RST%
    pause >nul
    goto flash_abl_binder
)
"%ADB_BIN%" shell service call miui.mqsas.IMQSNative 21 i32 1 s16 "dd" i32 1 s16 'if=!abl_dest! of=/dev/block/by-name/abl_a' s16 '/data/mqsas/log.txt' i32 60
timeout /t 1 /nobreak >nul
"%ADB_BIN%" shell service call miui.mqsas.IMQSNative 21 i32 1 s16 "dd" i32 1 s16 'if=!abl_dest! of=/dev/block/by-name/abl_b' s16 '/data/mqsas/log.txt' i32 60
timeout /t 1 /nobreak >nul
goto after_flash_abl

:method_localroot
echo %YEL%Dang su dung phuong thuc LOCAL EXPLOIT (Method 2)%RST%
:flash_bin
if not exist "%~dp0payloads\root\%bin_name%\exploit" (
    echo %RED%[LOI] Thieu payloads\root\%bin_name%\exploit%RST%
    set "ERROR_CODE=6"
    set "ERROR_MSG=Thieu file exploit cho LOCAL ROOT method."
    goto :End
)
if not exist "%~dp0payloads\root\%bin_name%\su" (
    echo %RED%[LOI] Thieu payloads\root\%bin_name%\su%RST%
    set "ERROR_CODE=6"
    set "ERROR_MSG=Thieu file su cho LOCAL ROOT method."
    goto :End
)
"%ADB_BIN%" push "%~dp0payloads\root\%bin_name%\exploit" /data/local/tmp/exploit
timeout /t 1 /nobreak >nul
"%ADB_BIN%" push "%~dp0payloads\root\%bin_name%\su" /data/local/tmp/su
timeout /t 1 /nobreak >nul

:get_root
"%ADB_BIN%" shell chmod 755 /data/local/tmp/exploit /data/local/tmp/su
"%ADB_BIN%" shell /data/local/tmp/exploit
set "root_retry=0"

:check_root
for /f "delims=" %%i in ('"%ADB_BIN%" shell "/data/local/tmp/su -c 'id'" 2^>^&1') do (
    echo Ket qua: %%i
    echo %%i | findstr "uid=0(root)" >nul
    if !errorlevel! equ 0 goto selinux_check_root
)
set /a root_retry+=1
if !root_retry! geq 5 (
    echo %RED%[LOI] Khong dat duoc quyen root sau 5 lan thu. Da bo cuoc.%RST%
    set "ERROR_CODE=7"
    set "ERROR_MSG=Khong dat duoc root sau 5 lan."
    goto :End
)
echo %RED%[!] Chua co quyen root. Dang thu lai (!root_retry!/5)...%RST%
"%ADB_BIN%" shell /data/local/tmp/exploit
goto check_root

:selinux_check_root
set "selinux_retry=0"
:selinux_check_root_loop
"%ADB_BIN%" shell "/data/local/tmp/su -c 'getenforce'" | findstr /i "Permissive" >nul
if %errorlevel% equ 0 goto flash_abl_root
set /a selinux_retry+=1
if !selinux_retry! geq 5 (
    echo %RED%[LOI] Khong dua duoc SELinux ve Permissive sau 5 lan. Da bo cuoc.%RST%
    set "ERROR_CODE=8"
    set "ERROR_MSG=SELinux khong chuyen sang Permissive duoc."
    goto :End
)
echo %YEL%SELinux chua Permissive, dang thu lai (!selinux_retry!/5)...%RST%
"%ADB_BIN%" shell /data/local/tmp/exploit
goto selinux_check_root_loop

:flash_abl_root
set "push_retry=0"
:flash_abl_root_loop
"%ADB_BIN%" push "%abl_path%" /data/local/tmp/abl.elf
if errorlevel 1 (
    set /a push_retry+=1
    if !push_retry! geq 5 (
        echo %RED%[LOI] Push ABL that bai 5 lan lien tiep. Hay kiem tra ket noi va chay lai.%RST%
        set "ERROR_CODE=5"
        set "ERROR_MSG=Push ABL that bai 5 lan o LOCAL ROOT method."
        goto :End
    )
    echo %YEL%Push ABL that bai (lan !push_retry!/5). Hay giu ket noi on dinh roi nhan Enter de thu lai.%RST%
    pause >nul
    goto flash_abl_root_loop
)
"%ADB_BIN%" shell "/data/local/tmp/su -c 'dd if=/data/local/tmp/abl.elf of=/dev/block/by-name/abl_a'"
timeout /t 1 /nobreak >nul
"%ADB_BIN%" shell "/data/local/tmp/su -c 'dd if=/data/local/tmp/abl.elf of=/dev/block/by-name/abl_b'"
timeout /t 1 /nobreak >nul
goto after_flash_abl

:: ===================== BUOC 6: REBOOT + FLASH_ALL + FLASH GPT + ENNEA =====================
:after_flash_abl
"%ADB_BIN%" reboot bootloader
timeout /t 5 /nobreak >nul

echo %CYN%==========================================%RST%
echo  %GRN%Dang cho thiet bi vao lai Fastboot%RST%
echo %CYN%==========================================%RST%

:check_fastboot_1
set "count=0"

:loop_check_1
call :ScanFastboot
if "%FASTBOOT_OK%"=="1" goto do_flash_all
set /a count+=1
timeout /t 2 /nobreak >nul
echo Fastboot thu ket noi[%count%/10]...
if %count% lss 10 goto loop_check_1
echo.
echo %YEL%Nhan Enter de thu phat hien lai Fastboot.%RST%
pause >nul
goto check_fastboot_1

:do_flash_all
if exist "%~dp0payloads\factoryImages\%factoryImages%\flash_all.bat" (
    echo %YEL%Dang chay Flash All baseband firmware cho %factoryImages%...%RST%
    setlocal
    call "%~dp0payloads\factoryImages\%factoryImages%\flash_all.bat"
    endlocal
    timeout /t 1 >nul
)

:check_fastboot_2
set "count=0"

:loop_check_2
call :ScanFastboot
if "%FASTBOOT_OK%"=="1" goto flash_gpt
set /a count+=1
timeout /t 2 /nobreak >nul
echo Fastboot thu ket noi[%count%/10]...
if %count% lss 10 goto loop_check_2
echo.
echo %YEL%Nhan Enter de thu phat hien lai Fastboot.%RST%
pause >nul
goto check_fastboot_2

:flash_gpt
"%FASTBOOT_BIN%" flash partition:4 "%unlock_gpt_path%"
timeout /t 1 /nobreak >nul
"%FASTBOOT_BIN%" boot "%ennea_full%"
timeout /t 1 /nobreak >nul
echo %YEL%[QUAN TRONG] Dang cho thiet bi vao lai Fastboot sau khi boot Ennea...%RST%
echo %YEL%Khi thiet bi da vao lai Fastboot, nhan phim bat ky de tiep tuc.%RST%
pause >nul

:: ===================== BUOC 7: RESTORE GPT GOC =====================
:check_fastboot_3
set "count=0"

:loop_check_3
call :ScanFastboot
if "%FASTBOOT_OK%"=="1" goto restore_gpt
set /a count+=1
timeout /t 2 /nobreak >nul
echo Fastboot thu ket noi[%count%/10]...
if %count% lss 10 goto loop_check_3
echo.
echo %YEL%Nhan Enter de thu phat hien lai Fastboot.%RST%
pause >nul
goto check_fastboot_3

:restore_gpt
if defined gpt_path (
    "%FASTBOOT_BIN%" flash partition:4 "%gpt_path%"
    timeout /t 1 /nobreak >nul
) else (
    echo %YEL%Khong tim thay file gpt_both4.bin (co the khong can cho model nay).%RST%
)

:: ===================== BUOC 8: KIEM TRA KET QUA =====================
:check_bl
set "bl_status=0"
call :MakeTmp TMP_BL
"%FASTBOOT_BIN%" oem device-info > "%TMP_BL%" 2>&1
type "%TMP_BL%"
findstr /ic:"Device unlocked: true" "%TMP_BL%" >nul
if !errorlevel! equ 0 (
    set "bl_status=1"
    echo %GRN%[OK] Bootloader da duoc mo khoa thanh cong!%RST%
) else (
    set "bl_status=0"
    echo %YEL%[CHUA] Bootloader chua duoc mo khoa.%RST%
)
echo.

:check_frp
set "frp_success=0"
set "frp_retry=0"
:check_frp_loop
call :MakeTmp TMP_FRP
"%FASTBOOT_BIN%" erase frp > "%TMP_FRP%" 2>&1
type "%TMP_FRP%"
findstr /ic:"FAILED" "%TMP_FRP%" >nul
if !errorlevel! neq 0 (
    set "frp_success=1"
    echo %GRN%[OK] FRP da xoa thanh cong.%RST%
) else (
    set "frp_success=0"
)

:check_result
if "!bl_status!"=="1" if "!frp_success!"=="1" (
    echo %GRN%Mo khoa thanh cong!%RST%
    goto unlock_done
)
if "!bl_status!"=="0" if "!frp_success!"=="1" (
    echo %YEL%[CANH BAO] BL chua mo nhung FRP da xoa duoc. ABL co the chua flash dung.%RST%
    echo %YEL%Quay lai flash tu dau... Nhan Enter.%RST%
    pause >nul
    goto check_fastboot_1
)
if "!bl_status!"=="0" if "!frp_success!"=="0" (
    echo %RED%[LOI NANG] BL chua mo va khong the xoa FRP. ABL hoan toan sai.%RST%
    echo %RED%Vui long lien he ho tro ky thuat.%RST%
    set "ERROR_CODE=9"
    set "ERROR_MSG=BL chua mo va FRP khong xoa duoc."
    goto :End
)
if "!bl_status!"=="1" if "!frp_success!"=="0" (
    set /a frp_retry+=1
    if !frp_retry! geq 5 (
        echo %RED%[LOI] FRP khong xoa duoc sau 5 lan thu. Vui long lien he ho tro.%RST%
        set "ERROR_CODE=10"
        set "ERROR_MSG=FRP khong xoa duoc sau 5 lan."
        goto :End
    )
    echo %YEL%[CANH BAO] BL da mo nhung FRP chua xoa. Thu lai (!frp_retry!/5)...%RST%
    pause >nul
    goto check_frp_loop
)

:: ===================== HOAN TAT =====================
:unlock_done
echo.
echo %CYN%-----------------------------------------------------------------%RST%
echo %GRN%=== MO KHOA THANH CONG ===%RST%
echo.
echo %YEL%  [ GHI CHU ]%RST%
echo    Truy cap %GRN%xiaomirom.com%RST% de tai ROM chinh hang.
echo    Giai nen va chay %GRN%flash_all.bat%RST% de flash ROM goc len may.
echo %CYN%-----------------------------------------------------------------%RST%
echo.
set "ERROR_CODE=0"
set "ERROR_MSG="
goto :End

:: ===================== EXIT CHUNG =====================
:End
call :CleanupTemp
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
set "_EC=!ERROR_CODE!"
endlocal & set "_EC=%_EC%"
if "%_EC%" neq "0" if "%_EC%" neq "" exit /B 1
exit /B 0

:: ===================== HELPERS =====================
:RequireTools
if not exist "%~dp0tools\bin\" (
    echo %RED%[LOI] Khong tim thay thu muc tools\bin tai "%~dp0tools\bin\"%RST%
    exit /b 1
)
if not exist "%ADB_BIN%" (
    echo %RED%[LOI] Khong tim thay adb.exe tai "%ADB_BIN%"%RST%
    exit /b 1
)
if not exist "%FASTBOOT_BIN%" (
    echo %RED%[LOI] Khong tim thay fastboot.exe tai "%FASTBOOT_BIN%"%RST%
    exit /b 1
)
if not exist "%~dp0payloads\" (
    echo %RED%[LOI] Khong tim thay thu muc payloads tai "%~dp0payloads\"%RST%
    exit /b 1
)
exit /b 0

:ResolveAblPath
set "abl_path="
if exist "%~dp0payloads\factoryImages\%~1\images\abl.elf" (
    set "abl_path=%~dp0payloads\factoryImages\%~1\images\abl.elf"
) else if exist "%~dp0payloads\factoryImages\%~1\abl.elf" (
    set "abl_path=%~dp0payloads\factoryImages\%~1\abl.elf"
)
exit /b 0

:ResolveGptPath
set "gpt_path="
if exist "%~dp0payloads\factoryImages\%~1\images\gpt_both4.bin" (
    set "gpt_path=%~dp0payloads\factoryImages\%~1\images\gpt_both4.bin"
) else if exist "%~dp0payloads\factoryImages\%~1\gpt_both4.bin" (
    set "gpt_path=%~dp0payloads\factoryImages\%~1\gpt_both4.bin"
)
exit /b 0

:CheckPayloads
if not defined abl_path (
    echo %RED%[LOI] Khong tim thay abl.elf cho %factoryImages%.%RST%
    echo %RED%      Da kiem tra: payloads\factoryImages\%factoryImages%\images\abl.elf%RST%
    echo %RED%      Va:          payloads\factoryImages\%factoryImages%\abl.elf%RST%
    exit /b 1
)
if not exist "%unlock_gpt_path%" (
    echo %RED%[LOI] Khong tim thay unlockgpt_both4.bin tai "%unlock_gpt_path%"%RST%
    exit /b 1
)
if not exist "%ennea_full%" (
    echo %RED%[LOI] Khong tim thay file Ennea tai "%ennea_full%"%RST%
    exit /b 1
)
if "%UnlockMethod%"=="2" (
    if not defined bin_name (
        echo %RED%[LOI] Phuong thuc 2 nhung khong xac dinh duoc bin_name.%RST%
        exit /b 1
    )
)
:: --- Canh bao payload kich thuoc bat thuong (chua duoc xac nhan) ---
if /i "%factoryImages%"=="Xiaomimixfold4" (
    echo %YEL%[CANH BAO] File abl.elf cua Mix Fold 4 co kich thuoc ~8MB, lon bat thuong%RST%
    echo %YEL%           so voi cac model khac ^(~200-335KB^). Chua duoc xac nhan.%RST%
    echo.
)
if /i "%factoryImages%"=="Xiaomipad6spro" (
    echo %YEL%[CANH BAO] File unlockgpt_both4.bin cua Pad 6s Pro co kich thuoc 24KB,%RST%
    echo %YEL%           khac voi tat ca model khac ^(45KB^). Chua duoc xac nhan.%RST%
    echo.
)
exit /b 0

:ScanAdbState
set "ADB_STATE=none"
call :MakeTmp TMP_DEV
"%ADB_BIN%" devices > "%TMP_DEV%" 2>&1
if errorlevel 1 (
    set "ADB_STATE=adb_error"
    del "%TMP_DEV%" >nul 2>nul
    set "TMP_DEV="
    exit /b 0
)
for /f "usebackq skip=1 tokens=1,2" %%A in ("%TMP_DEV%") do (
    if not "%%B"=="" if "!ADB_STATE!"=="none" set "ADB_STATE=%%B"
)
del "%TMP_DEV%" >nul 2>nul
set "TMP_DEV="
exit /b 0

:ScanFastboot
set "FASTBOOT_OK=0"
call :MakeTmp TMP_DEV
"%FASTBOOT_BIN%" devices > "%TMP_DEV%" 2>&1
if errorlevel 1 (
    del "%TMP_DEV%" >nul 2>nul
    set "TMP_DEV="
    exit /b 0
)
for /f "usebackq tokens=1,2" %%A in ("%TMP_DEV%") do (
    if not "%%A"=="" if not "%%B"=="" set "FASTBOOT_OK=1"
)
del "%TMP_DEV%" >nul 2>nul
set "TMP_DEV="
exit /b 0

:MakeTmp
set "%~1=%TEMP%\ximi_%~1_%RANDOM%%RANDOM%.txt"
exit /b 0

:CleanupTemp
if defined TMP_BL ( del "%TMP_BL%" >nul 2>nul & set "TMP_BL=" )
if defined TMP_FRP ( del "%TMP_FRP%" >nul 2>nul & set "TMP_FRP=" )
if defined TMP_DEV ( del "%TMP_DEV%" >nul 2>nul & set "TMP_DEV=" )
if defined TMP_GE ( del "%TMP_GE%" >nul 2>nul & set "TMP_GE=" )
del "%~dp0temp_bl.txt" >nul 2>nul
del "%~dp0temp_frp.txt" >nul 2>nul
exit /b 0
