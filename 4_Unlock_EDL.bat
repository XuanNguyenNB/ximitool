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
echo  Xiaomi Fastboot Unlock (Giai doan hau EDL)
echo  Dung de hoan thanh Unlock sau khi da Flash abl.elf qua che do EDL.
echo  Ho tro rieng cho chip Snapdragon 8 Elite, 8 Gen 2 va 8s Gen 4.
echo %CYN%=================================================================%RST%
echo %RED%Yeu cau: Ban da nap thanh cong file abl.elf ky thuat qua EDL.%RST%
echo %RED%Canh bao: Qua trinh nay se xoa toan bo du lieu.%RST%
echo.

set /p confirm="Dien thoai dang o che do Fastboot? (Y de bat dau, N de thoat): "
if /i "%confirm%" neq "Y" exit /B 1

:main_menu
cls
echo %CYN%==========================================%RST%
echo  %GRN%CHON NEN TANG CHIP (SoC)%RST%
echo %CYN%==========================================%RST%
echo  1. Snapdragon 8 Elite (Xiaomi 15, Redmi K80...)
echo  2. Snapdragon 8 Gen 2 (Xiaomi 13, Redmi K60 Pro...)
echo  3. Snapdragon 8s Gen 4 (Turbo 4 Pro, Civi 5 Pro, Pad 8)
echo  0. Thoat
echo %CYN%==========================================%RST%
set /p soc_choice="Chon (0-3): "

if "%soc_choice%"=="1" goto menu_8e
if "%soc_choice%"=="2" goto menu_8g2
if "%soc_choice%"=="3" goto menu_8sg4
if "%soc_choice%"=="0" exit /b
goto main_menu

:: ===================== MENU 8 ELITE =====================
:menu_8e
set "ennea_img=payloads\ennea\8750-Ennea.img"
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
if "%dev_choice%"=="1" ( set "factoryImages=Redmik80pro" & set "unlockGPT=else8elite" )
if "%dev_choice%"=="2" ( set "factoryImages=Redmik90" & set "unlockGPT=else8elite" )
if "%dev_choice%"=="3" ( set "factoryImages=Xiaomi15" & set "unlockGPT=else8elite" )
if "%dev_choice%"=="4" ( set "factoryImages=Xiaomi15pro" & set "unlockGPT=else8elite" )
if "%dev_choice%"=="5" ( set "factoryImages=Xiaomi15ultra" & set "unlockGPT=else8elite" )
if "%dev_choice%"=="6" ( set "factoryImages=Xiaomipad8pro" & set "unlockGPT=Xiaomipad8pro" )
if "%dev_choice%"=="0" goto main_menu
if defined factoryImages goto pre_unlock
goto menu_8e

:: ===================== MENU 8 GEN 2 =====================
:menu_8g2
set "ennea_img=payloads\ennea\8550-Ennea.img"
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
if "%dev_choice%"=="1" ( set "factoryImages=Redmik60pro" & set "unlockGPT=Redmik60pro" )
if "%dev_choice%"=="2" ( set "factoryImages=Redmik70" & set "unlockGPT=Redmik70" )
if "%dev_choice%"=="3" ( set "factoryImages=Xiaomi13" & set "unlockGPT=Xiaomi13" )
if "%dev_choice%"=="4" ( set "factoryImages=Xiaomi13pro" & set "unlockGPT=Xiaomi13pro" )
if "%dev_choice%"=="5" ( set "factoryImages=Xiaomi13ultra" & set "unlockGPT=Xiaomi13ultra" )
if "%dev_choice%"=="6" ( set "factoryImages=Xiaomipad6spro" & set "unlockGPT=Xiaomipad6spro" )
if "%dev_choice%"=="0" goto main_menu
if defined factoryImages goto pre_unlock
goto menu_8g2

:: ===================== MENU 8s GEN 4 =====================
:menu_8sg4
set "ennea_img=payloads\ennea\8735-Ennea.img"
cls
echo %CYN%=== SNAPDRAGON 8s GEN 4 ===%RST%
echo  1. Redmi Turbo 4 Pro
echo  2. Xiaomi Civi 5 Pro
echo  3. Xiaomi Pad 8
echo  0. Quay lai
set /p dev_choice="Chon: "
if "%dev_choice%"=="1" ( set "factoryImages=Redmiturbo4pro" & set "unlockGPT=Redmiturbo4pro" )
if "%dev_choice%"=="2" ( set "factoryImages=Xiaomicivi5pro" & set "unlockGPT=Xiaomicivi5pro" )
if "%dev_choice%"=="3" ( set "factoryImages=Xiaomipad8" & set "unlockGPT=Xiaomipad8" )
if "%dev_choice%"=="0" goto main_menu
if defined factoryImages goto pre_unlock
goto menu_8sg4

:: ===================== XAC NHAN + HIEN THI THONG TIN =====================
:pre_unlock
echo %RED%=================================================================%RST%
echo                      CANH BAO CUOI CUNG
echo %RED%=================================================================%RST%
echo  THONG TIN DA CHON:
echo  - Thiet bi: %factoryImages%
echo  - Unlock GPT: %~dp0payloads\unlockGPT\%unlockGPT%\unlockgpt_both4.bin
echo %RED%=================================================================%RST%
echo.
set /p final_confirm="Xac nhan bat dau? (Y de tiep tuc, phim khac de thoat): "
if /i "%final_confirm%" neq "Y" (
    echo %YEL%[DUNG AN TOAN] Script da thoat.%RST%
    pause
    exit /B 1
)

:: ===================== BUOC 1: KIEM TRA FASTBOOT =====================
echo %CYN%==========================================%RST%
echo  %GRN%Dang kiem tra ket noi Fastboot%RST%
echo %CYN%==========================================%RST%

:check_fastboot
set "count=0"

:loop_check
fastboot devices 2>nul | findstr /i "." >nul
if %errorlevel% equ 0 goto do_flash_all
set /a count+=1
timeout /t 2 /nobreak >nul
echo Fastboot thu ket noi[%count%/10]...
if %count% lss 10 goto loop_check
echo.
echo %RED%[!] Chua phat hien thiet bi o che do Fastboot.%RST%
echo %RED%    1. Hay chac chan dien thoai da vao Fastboot%RST%
echo %RED%    2. Kiem tra driver Fastboot da duoc cai chua%RST%
echo.
echo %YEL%Nhan Enter de thu phat hien lai.%RST%
set /p "_dummy="
goto check_fastboot

:: ===================== BUOC 2: FLASH_ALL + FLASH GPT + ENNEA =====================
:do_flash_all
if exist "%~dp0payloads\factoryImages\%factoryImages%\flash_all.bat" (
    echo %YEL%Dang chay Flash All baseband firmware cho %factoryImages%...%RST%
    cmd /c "%~dp0payloads\factoryImages\%factoryImages%\flash_all.bat"
    timeout /t 1 >nul
)

:check_fastboot_1
set "count=0"

:loop_check_1
fastboot devices 2>nul | findstr /i "." >nul
if %errorlevel% equ 0 goto flash_gpt
set /a count+=1
timeout /t 2 /nobreak >nul
echo Fastboot thu ket noi[%count%/10]...
if %count% lss 10 goto loop_check_1
echo.
echo %YEL%Nhan Enter de thu phat hien lai Fastboot.%RST%
set /p "_dummy="
goto check_fastboot_1

:flash_gpt
fastboot flash partition:4 "%~dp0payloads\unlockGPT\%unlockGPT%\unlockgpt_both4.bin"
timeout /t 1 /nobreak >nul
fastboot boot "%~dp0%ennea_img%"
timeout /t 1 /nobreak >nul
echo %YEL%[QUAN TRONG] Dang cho thiet bi vao lai Fastboot sau khi boot Ennea...%RST%
echo %YEL%Khi thiet bi da vao lai Fastboot, nhan Enter de tiep tuc.%RST%
set /p "_dummy="
goto check_fastboot_2

:: ===================== BUOC 3: RESTORE GPT GOC =====================
:check_fastboot_2
set "count=0"

:loop_check_2
fastboot devices 2>nul | findstr /i "." >nul
if %errorlevel% equ 0 goto restore_gpt
set /a count+=1
timeout /t 2 /nobreak >nul
echo Fastboot thu ket noi[%count%/10]...
if %count% lss 10 goto loop_check_2
echo.
echo %YEL%Nhan Enter de thu phat hien lai Fastboot.%RST%
set /p "_dummy="
goto check_fastboot_2

:restore_gpt
if exist "%~dp0payloads\factoryImages\%factoryImages%\images\gpt_both4.bin" (
    fastboot flash partition:4 "%~dp0payloads\factoryImages\%factoryImages%\images\gpt_both4.bin"
    timeout /t 1 /nobreak >nul
) else (
    echo %YEL%Khong tim thay file gpt_both4.bin (co the khong can cho model nay).%RST%
)

:: ===================== BUOC 4: KIEM TRA KET QUA =====================
:check_bl
set "bl_status=0"
fastboot oem device-info > temp_bl.txt 2>&1
type temp_bl.txt
findstr /ic:"Device unlocked: true" temp_bl.txt >nul
if not errorlevel 1 (
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
if errorlevel 1 (
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
    echo %YEL%[CANH BAO] BL chua mo nhung FRP da xoa duoc. ABL co the chua flash dung qua EDL.%RST%
    echo %YEL%Vui long flash lai abl.elf qua EDL roi thu lai. Nhan Enter.%RST%
    set /p "_dummy="
    goto check_fastboot
)
if "!bl_status!"=="0" if "!frp_success!"=="0" (
    echo %RED%[LOI NANG] BL chua mo va khong the xoa FRP. ABL hoan toan sai.%RST%
    echo %RED%Vui long lien he ho tro ky thuat.%RST%
    pause
    exit /B 1
)
if "!bl_status!"=="1" if "!frp_success!"=="0" (
    echo %YEL%[CANH BAO] BL da mo nhung FRP chua xoa. Thu lai...%RST%
    set /p "_dummy="
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
