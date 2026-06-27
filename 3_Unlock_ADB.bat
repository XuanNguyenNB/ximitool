@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion
cd /d "%~dp0"
for /F %%a in ('echo prompt $E ^| cmd') do set "ESC=%%a"
set "RED=%ESC%[31m"
set "GRN=%ESC%[32m"
set "YEL=%ESC%[33m"
set "CYN=%ESC%[36m"
set "RST=%ESC%[0m"

set "PATH=%~dp0tools\bin;%PATH%"

echo %CYN%=================================================================%RST%
echo  Xiaomi All-In-One Bootloader Unlock Tool
echo  Gom nhom tu nhieu phien ban chip: 8 Elite, 8 Gen 3, 8 Gen 2, v.v.
echo  Ho tro tu dong chuyen doi phuong thuc khai thac (Binder ^& Local Root)
echo %CYN%=================================================================%RST%
echo %RED%[CANH BAO] Viec mo khoa se XOA TOAN BO DU LIEU vinh vien!%RST%
echo.

set /p confirm="Ban da hieu rui ro va muon tiep tuc? (Y/N): "
if /i "%confirm%" neq "Y" (
    echo Huy bo.
    pause
    exit /B 1
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
set /p soc_choice="Chon (0-5): "

if "%soc_choice%"=="1" goto menu_8e
if "%soc_choice%"=="2" goto menu_8g3
if "%soc_choice%"=="3" goto menu_8g2
if "%soc_choice%"=="4" goto menu_8sg3
if "%soc_choice%"=="5" goto menu_8sg4
if "%soc_choice%"=="0" exit /b
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
set /p dev_choice="Chon: "
if "%dev_choice%"=="1" ( set factoryImages=Redmik80pro & set unlockGPT=else8elite )
if "%dev_choice%"=="2" ( set factoryImages=Redmik90 & set unlockGPT=else8elite )
if "%dev_choice%"=="3" ( set factoryImages=Xiaomi15 & set unlockGPT=else8elite )
if "%dev_choice%"=="4" ( set factoryImages=Xiaomi15pro & set unlockGPT=else8elite )
if "%dev_choice%"=="5" ( set factoryImages=Xiaomi15ultra & set unlockGPT=else8elite )
if "%dev_choice%"=="6" ( set factoryImages=Xiaomipad8pro & set unlockGPT=Xiaomipad8pro )
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
set /p dev_choice="Chon: "
if "%dev_choice%"=="1" ( set factoryImages=Redmik70pro & set unlockGPT=Redmik70pro & set UnlockMethod=1 )
if "%dev_choice%"=="2" ( set factoryImages=Xiaomi14 & set unlockGPT=Xiaomi14 & set UnlockMethod=1 )
if "%dev_choice%"=="3" ( set factoryImages=Xiaomi14pro & set unlockGPT=Xiaomi14pro & set UnlockMethod=1 )
if "%dev_choice%"=="4" ( set factoryImages=Xiaomi14ultra & set unlockGPT=Xiaomi14ultra & set UnlockMethod=1 )
if "%dev_choice%"=="5" ( set factoryImages=Redmik70pro & set unlockGPT=Redmik70pro & set UnlockMethod=2 & set bin_name=8g3 )
if "%dev_choice%"=="6" ( set factoryImages=Xiaomi14 & set unlockGPT=Xiaomi14 & set UnlockMethod=2 & set bin_name=8g3 )
if "%dev_choice%"=="7" ( set factoryImages=Xiaomi14pro & set unlockGPT=Xiaomi14pro & set UnlockMethod=2 & set bin_name=8g3 )
if "%dev_choice%"=="8" ( set factoryImages=Xiaomi14ultra & set unlockGPT=Xiaomi14ultra & set UnlockMethod=2 & set bin_name=8g3 )
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
echo  3. Xiaomi 13
echo  4. Xiaomi 13 Pro
echo  5. Xiaomi 13 Ultra
echo  6. Xiaomi Pad 6s Pro
echo  0. Quay lai
set /p dev_choice="Chon: "
if "%dev_choice%"=="1" ( set factoryImages=Redmik60pro & set unlockGPT=Redmik60pro )
if "%dev_choice%"=="2" ( set factoryImages=Redmik70 & set unlockGPT=Redmik70 )
if "%dev_choice%"=="3" ( set factoryImages=Xiaomi13 & set unlockGPT=Xiaomi13 )
if "%dev_choice%"=="4" ( set factoryImages=Xiaomi13pro & set unlockGPT=Xiaomi13pro )
if "%dev_choice%"=="5" ( set factoryImages=Xiaomi13ultra & set unlockGPT=Xiaomi13ultra )
if "%dev_choice%"=="6" ( set factoryImages=Xiaomipad6spro & set unlockGPT=Xiaomipad6spro )
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
echo  3. Redmi K70E (Thuong)
echo  -------------------------------
echo  4. Redmi Turbo 3 (High Version)
echo  5. Xiaomi Civi 4 Pro (High Version)
echo  6. Redmi K70E (High Version)
echo  0. Quay lai
set /p dev_choice="Chon: "
if "%dev_choice%"=="1" ( set factoryImages=Redmiturbo3 & set unlockGPT=Redmiturbo3 & set UnlockMethod=1 )
if "%dev_choice%"=="2" ( set factoryImages=Xiaomicivi4pro & set unlockGPT=Xiaomicivi4pro & set UnlockMethod=1 )
if "%dev_choice%"=="3" ( set factoryImages=Redmik70e & set unlockGPT=Redmik70e & set UnlockMethod=1 )
if "%dev_choice%"=="4" ( set factoryImages=Redmiturbo3 & set unlockGPT=Redmiturbo3 & set UnlockMethod=2 & set bin_name=8sg3or7pg3 )
if "%dev_choice%"=="5" ( set factoryImages=Xiaomicivi4pro & set unlockGPT=Xiaomicivi4pro & set UnlockMethod=2 & set bin_name=8sg3or7pg3 )
if "%dev_choice%"=="6" ( set factoryImages=Redmik70e & set unlockGPT=Redmik70e & set UnlockMethod=2 & set bin_name=8sg3or7pg3 )
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
set /p dev_choice="Chon: "
if "%dev_choice%"=="1" ( set factoryImages=Redmiturbo4pro & set unlockGPT=Redmiturbo4pro )
if "%dev_choice%"=="2" ( set factoryImages=Xiaomicivi5pro & set unlockGPT=Xiaomicivi5pro )
if "%dev_choice%"=="3" ( set factoryImages=Xiaomipad8 & set unlockGPT=Xiaomipad8 )
if "%dev_choice%"=="0" goto main_menu
if defined factoryImages goto pre_unlock
goto menu_8sg4

:: ===================== XAC NHAN CUOI CUNG =====================
:pre_unlock
set abl_path=%~dp0payloads\factoryImages\%factoryImages%\images\abl.elf

echo %RED%=================================================================%RST%
echo                      CANH BAO CUOI CUNG
echo %RED%=================================================================%RST%
echo  THONG TIN DA CHON:
echo  - Thiet bi: %factoryImages%
echo  - ABL Path: %abl_path%
echo  - Unlock GPT: %~dp0payloads\unlockGPT\%unlockGPT%\unlockgpt_both4.bin
if "%UnlockMethod%"=="1" echo  - Phuong thuc: BINDER EXPLOIT (Old)
if "%UnlockMethod%"=="2" echo  - Phuong thuc: LOCAL ROOT EXPLOIT (High Version)
echo %RED%=================================================================%RST%
echo.
set /p final_confirm="Xac nhan bat dau? (Y de tiep tuc, phim khac de thoat): "
if /i "%final_confirm%" neq "Y" (
    echo %YEL%[DUNG AN TOAN] Script da thoat.%RST%
    pause
    exit /B 1
)

:: ===================== BUOC 1: KIEM TRA ADB =====================
echo %CYN%==========================================%RST%
echo  %GRN%Dang kiem tra ket noi ADB%RST%
echo %CYN%==========================================%RST%

:check_adb
set count=0

:wait_adb
adb devices 2>nul | findstr /v /i "List" | findstr /i "device" >nul
if %errorlevel% equ 0 goto adb_reboot
set /a count+=1
timeout /t 2 /nobreak >nul
echo ADB thu ket noi[%count%/10]
if %count% lss 10 goto wait_adb
echo.
echo %RED%[!] Chua phat hien thiet bi ADB:%RST%
echo %RED%    1. Da bat USB debugging chua?%RST%
echo %RED%    2. Da cai driver va cam cap du lieu chua?%RST%
echo.
echo %YEL%Nhan Enter de thu phat hien lai.%RST%
set /p "="
goto check_adb

:: ===================== BUOC 2: REBOOT FASTBOOT =====================
:adb_reboot
adb reboot bootloader
timeout /t 1 /nobreak >nul

echo %CYN%==========================================%RST%
echo  %GRN%Dang kiem tra ket noi Fastboot%RST%
echo %CYN%==========================================%RST%

:check_fastboot
set "count=0"

:loop_check
fastboot devices 2>nul | findstr /i "." >nul
if %errorlevel% equ 0 goto selinux_permissive
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
set /p "="
goto check_fastboot

:: ===================== BUOC 3: SELINUX PERMISSIVE =====================
:selinux_permissive
fastboot oem set-gpu-preemption 0 androidboot.selinux=permissive
fastboot continue || fastboot reboot
timeout /t 1 >nul

:check_adb_2
set count=0

:wait_adb_2
adb devices 2>nul | findstr /v /i "List" | findstr /i "device" >nul
if %errorlevel% equ 0 goto check_selinux
set /a count+=1
timeout /t 2 /nobreak >nul
echo ADB thu ket noi[%count%/10]
if %count% lss 10 goto wait_adb_2
echo.
echo Vui long kiem tra cap du lieu hoac cong USB co bi long khong.
echo Nhan Enter de thu ket noi lai.
echo.
set /p "="
goto check_adb_2

:: ===================== BUOC 4: KIEM TRA SELINUX =====================
:check_selinux
adb shell getenforce | findstr /i "Permissive" >nul || (
    echo %RED%[!] SELinux van dang Enforcing! Khong the tiep tuc.%RST%
    echo %RED%    Hay kiem tra phien ban firmware hoac lien he ho tro.%RST%
    pause
    exit /B 1
)

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
:flash_abl_binder
adb push "%abl_path%" !abl_dest! && (
    adb shell service call miui.mqsas.IMQSNative 21 i32 1 s16 "dd" i32 1 s16 'if=!abl_dest! of=/dev/block/by-name/abl_a' s16 '/data/mqsas/log.txt' i32 60
    timeout /t 1 /nobreak >nul
    adb shell service call miui.mqsas.IMQSNative 21 i32 1 s16 "dd" i32 1 s16 'if=!abl_dest! of=/dev/block/by-name/abl_b' s16 '/data/mqsas/log.txt' i32 60
    timeout /t 1 /nobreak >nul
) || (
    echo %YEL%Push ABL that bai. Hay giu ket noi on dinh roi nhan Enter de thu lai.%RST%
    set /p "="
    goto flash_abl_binder
)
goto after_flash_abl

:method_localroot
echo %YEL%Dang su dung phuong thuc LOCAL EXPLOIT (Method 2)%RST%
:flash_bin
adb push "%~dp0payloads\root\!bin_name!\exploit" /data/local/tmp/exploit
timeout /t 1 /nobreak >nul
adb push "%~dp0payloads\root\!bin_name!\su" /data/local/tmp/su
timeout /t 1 /nobreak >nul

:get_root
adb shell chmod 755 /data/local/tmp/exploit /data/local/tmp/su
adb shell /data/local/tmp/exploit

:check_root
for /f "delims=" %%i in ('adb shell "/data/local/tmp/su -c 'id'" 2^>^&1') do (
    echo Ket qua: %%i
    echo %%i | findstr "uid=0(root)" >nul
    if !errorlevel! equ 0 goto selinux_check_root
)
echo %RED%[!] Chua co quyen root. Dang thu lai...%RST%
adb shell /data/local/tmp/exploit
goto check_root

:selinux_check_root
adb shell "/data/local/tmp/su -c 'getenforce'" | findstr /i "Permissive" >nul
if %errorlevel% equ 0 goto flash_abl_root
echo %YEL%SELinux chua Permissive, dang thu lai...%RST%
adb shell /data/local/tmp/exploit
goto selinux_check_root

:flash_abl_root
adb push "%abl_path%" /data/local/tmp/abl.elf && (
    adb shell "/data/local/tmp/su -c 'dd if=/data/local/tmp/abl.elf of=/dev/block/by-name/abl_a'"
    timeout /t 1 /nobreak >nul
    adb shell "/data/local/tmp/su -c 'dd if=/data/local/tmp/abl.elf of=/dev/block/by-name/abl_b'"
    timeout /t 1 /nobreak >nul
) || (
    echo %YEL%Push ABL that bai. Hay giu ket noi on dinh roi nhan Enter de thu lai.%RST%
    set /p "="
    goto flash_abl_root
)
goto after_flash_abl

:: ===================== BUOC 6: REBOOT + FLASH_ALL + FLASH GPT + ENNEA =====================
:after_flash_abl
adb reboot bootloader
timeout /t 1 /nobreak >nul

echo %CYN%==========================================%RST%
echo  %GRN%Dang cho thiet bi vao lai Fastboot%RST%
echo %CYN%==========================================%RST%

:check_fastboot_1
set "count=0"

:loop_check_1
fastboot devices 2>nul | findstr /i "." >nul
if %errorlevel% equ 0 goto do_flash_all
set /a count+=1
timeout /t 2 /nobreak >nul
echo Fastboot thu ket noi[%count%/10]...
if %count% lss 10 goto loop_check_1
echo.
echo %YEL%Nhan Enter de thu phat hien lai Fastboot.%RST%
set /p "="
goto check_fastboot_1

:do_flash_all
if exist "%~dp0payloads\factoryImages\%factoryImages%\flash_all.bat" (
    echo %YEL%Dang chay Flash All baseband firmware cho %factoryImages%...%RST%
    cmd /c "%~dp0payloads\factoryImages\%factoryImages%\flash_all.bat"
    timeout /t 1 >nul
)

:check_fastboot_2
set "count=0"

:loop_check_2
fastboot devices 2>nul | findstr /i "." >nul
if %errorlevel% equ 0 goto flash_gpt
set /a count+=1
timeout /t 2 /nobreak >nul
echo Fastboot thu ket noi[%count%/10]...
if %count% lss 10 goto loop_check_2
echo.
echo %YEL%Nhan Enter de thu phat hien lai Fastboot.%RST%
set /p "="
goto check_fastboot_2

:flash_gpt
fastboot flash partition:4 "%~dp0payloads\unlockGPT\%unlockGPT%\unlockgpt_both4.bin"
timeout /t 1 /nobreak >nul
fastboot boot "%~dp0%ennea_img%"
timeout /t 1 /nobreak >nul
echo %YEL%[QUAN TRONG] Dang cho thiet bi vao lai Fastboot sau khi boot Ennea...%RST%
set /p "="

:: ===================== BUOC 7: RESTORE GPT GOC =====================
:check_fastboot_3
set "count=0"

:loop_check_3
fastboot devices 2>nul | findstr /i "." >nul
if %errorlevel% equ 0 goto restore_gpt
set /a count+=1
timeout /t 2 /nobreak >nul
echo Fastboot thu ket noi[%count%/10]...
if %count% lss 10 goto loop_check_3
echo.
echo %YEL%Nhan Enter de thu phat hien lai Fastboot.%RST%
set /p "="
goto check_fastboot_3

:restore_gpt
if exist "%~dp0payloads\factoryImages\%factoryImages%\images\gpt_both4.bin" (
    fastboot flash partition:4 "%~dp0payloads\factoryImages\%factoryImages%\images\gpt_both4.bin"
    timeout /t 1 /nobreak >nul
) else (
    echo %YEL%Khong tim thay file gpt_both4.bin (co the khong can cho model nay).%RST%
)

:: ===================== BUOC 8: KIEM TRA KET QUA =====================
:check_bl
set "bl_status=0"
fastboot oem device-info > temp_bl.txt 2>&1
type temp_bl.txt
findstr /ic:"Device unlocked: true" temp_bl.txt >nul
if !errorlevel! equ 0 (
    set "bl_status=1"
    echo %GRN%[OK] Bootloader da duoc mo khoa thanh cong!%RST%
) else (
    set "bl_status=0"
    echo %YEL%[CHUA] Bootloader chua duoc mo khoa.%RST%
)
del temp_bl.txt 2>nul
echo.

:check_frp
set "frp_success=0"
fastboot erase frp > temp_frp.txt 2>&1
type temp_frp.txt
findstr /ic:"FAILED" temp_frp.txt >nul
if !errorlevel! neq 0 (
    set "frp_success=1"
    echo %GRN%[OK] FRP da xoa thanh cong.%RST%
) else (
    set "frp_success=0"
)
del temp_frp.txt 2>nul

:check_result
if "!bl_status!"=="1" if "!frp_success!"=="1" (
    echo %GRN%Mo khoa thanh cong!%RST%
    goto unlock_done
)
if "!bl_status!"=="0" if "!frp_success!"=="1" (
    echo %YEL%[CANH BAO] BL chua mo nhung FRP da xoa duoc. ABL co the chua flash dung.%RST%
    echo %YEL%Quay lai flash tu dau... Nhan Enter.%RST%
    set /p "="
    goto check_fastboot_1
)
if "!bl_status!"=="0" if "!frp_success!"=="0" (
    echo %RED%[LOI NANG] BL chua mo va khong the xoa FRP. ABL hoan toan sai.%RST%
    echo %RED%Vui long lien he ho tro ky thuat.%RST%
    pause
    exit /B 1
)
if "!bl_status!"=="1" if "!frp_success!"=="0" (
    echo %YEL%[CANH BAO] BL da mo nhung FRP chua xoa. Thu lai...%RST%
    set /p "="
    goto check_frp
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
if not defined IN_LOG_MODE cmd /k
