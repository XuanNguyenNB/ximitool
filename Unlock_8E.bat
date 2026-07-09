@echo off
setlocal enabledelayedexpansion
cd /d "%~dp0"
for /F %%a in ('echo prompt $E ^| cmd') do set "ESC=%%a"
set "RED=%ESC%[31m"
set "GRN=%ESC%[32m"
set "YEL=%ESC%[33m"
set "CYN=%ESC%[36m"
set "RST=%ESC%[0m"

set "ADB=%~dp0tools\adb.exe"
set "FASTBOOT=%~dp0tools\fastboot.exe"
set "PAYLOADS=%~dp0payloads"
set "ENNEA=%PAYLOADS%\ennea\8750-Ennea.img"

title Ximi Unlock BL - Snapdragon 8 Elite (SM8750)

echo %CYN%=================================================================%RST%
echo  Ximi Tool Lite - Unlock Bootloader Snapdragon 8 Elite (SM8750)
echo  Ho tro: Redmi K80 Pro / K90 / Xiaomi 15 / 15 Pro / 15 Ultra / Pad 8 Pro
echo.
echo %RED%[Mien tru trach nhiem] Script chi dung de trao doi ky thuat.%RST%
echo %RED%Unlock BL se xoa sach du lieu va mat bao hanh chinh hang.%RST%
echo %RED%Tac gia khong chiu trach nhiem cho bat ky loi hoac mat du lieu nao.%RST%
echo %CYN%=================================================================%RST%

set /p confirm="Xac nhan rui ro va tiep tuc thuc thi? (Y de tiep tuc, phim khac de thoat): "
if /i "%confirm%" neq "Y" (
    echo Nguoi dung huy thao tac, script thoat.
    pause
    exit /B 1
)

:menu
set "factoryImages="
set "unlockGPT="
set "abl_dest=/data/local/tmp/abl"
set "abl_mkdir=0"
echo %CYN%==========================================%RST%
echo       %GRN%CHON DONG MAY UNLOCK%RST%
echo %CYN%==========================================%RST%
echo  1. Redmi K80 Pro
echo  2. Redmi K90
echo  3. Xiaomi 15
echo  4. Xiaomi 15 Pro
echo  5. Xiaomi 15 Ultra
echo  6. Xiaomi Pad 8 Pro
echo  %RED%0. Thoat%RST%
echo %CYN%==========================================%RST%

set /p choice=Nhap so tuong ung roi an Enter:
if "%choice%"=="1" ( set "factoryImages=Redmik80pro" & set "unlockGPT=else8elite" )
if "%choice%"=="2" ( set "factoryImages=Redmik90"    & set "unlockGPT=else8elite" )
if "%choice%"=="3" ( set "factoryImages=Xiaomi15"    & set "unlockGPT=else8elite" )
if "%choice%"=="4" ( set "factoryImages=Xiaomi15pro" & set "unlockGPT=else8elite" )
if "%choice%"=="5" ( set "factoryImages=Xiaomi15ultra" & set "unlockGPT=else8elite" )
if "%choice%"=="6" (
    set "factoryImages=Xiaomipad8pro"
    set "unlockGPT=Xiaomipad8pro"
    set "abl_dest=/data/local/tmp/abl/abl.elf"
    set "abl_mkdir=1"
)
if "%choice%"=="0" exit /B 1
if "%factoryImages%"=="" goto menu

set "abl_path=%PAYLOADS%\factoryImages\%factoryImages%\images\abl.elf"
if not exist "%abl_path%" set "abl_path=%PAYLOADS%\factoryImages\%factoryImages%\abl.elf"
set "gpt_path=%PAYLOADS%\factoryImages\%factoryImages%\images\gpt_both4.bin"
if not exist "%gpt_path%" set "gpt_path=%PAYLOADS%\factoryImages\%factoryImages%\gpt_both4.bin"
set "unlock_gpt_path=%PAYLOADS%\unlockGPT\%unlockGPT%\unlockgpt_both4.bin"

echo %RED%=================================================================%RST%
echo                      !!! CANH BAO CUOI CUNG !!!
echo %RED%=================================================================%RST%
echo  %RED%Unlock BL se [XOA SACH DU LIEU] va [MAT BAO HANH CHINH HANG]!%RST%
echo  %RED%Mot khi nhan Y, thao tac se khong the hoan tac.%RST%
echo %RED%=================================================================%RST%
echo.
echo %CYN%------------------------------------------%RST%
echo Duong dan file se dung:
echo %YEL%%abl_path%%RST%
echo %YEL%%unlock_gpt_path%%RST%
echo %YEL%%gpt_path%%RST%
echo %YEL%%ENNEA%%RST%
echo %CYN%------------------------------------------%RST%
echo.

set /p final_confirm="Tiep tuc chay script khong? (Y de xac nhan, phim khac de thoat): "
if /i "%final_confirm%" neq "Y" (
    echo %YEL%[Dung an toan] Thoat script%RST%
    pause
    exit /B 1
)

echo %CYN%==========================================%RST%
echo  %GRN%Dang kiem tra ket noi ADB%RST%
echo %CYN%==========================================%RST%

:check_adb
set count=0

:wait_adb
"%ADB%" devices 2>nul | findstr /v /i "List" | findstr /i "device" >nul
if %errorlevel% equ 0 goto adb_ok
set /a count+=1
timeout /t 2 /nobreak >nul
echo ADB dang thu ket noi[%count%/10]
if %count% lss 10 goto wait_adb
echo.
echo %RED%[!] Khong phat hien thiet bi, vui long xac nhan:%RST%
echo %RED%    1. Da bat USB Debugging (Go loi USB)%RST%
echo %RED%    2. Da cai dat driver va ket noi cap USB%RST%
echo.
echo %YEL%Ket noi lai thiet bi roi an Enter de thu lai%RST%
set /p "="
goto check_adb

:adb_ok
echo %YEL%Dang reboot vao Bootloader...%RST%
"%ADB%" reboot bootloader
timeout /t 3 /nobreak >nul

:check_fastboot_1
set count=0
:loop_fb_1
"%FASTBOOT%" devices 2>nul | findstr /i "." >nul
if %errorlevel% equ 0 goto set_permissive
set /a count+=1
timeout /t 2 /nobreak >nul
echo Fastboot dang thu ket noi[%count%/10]...
if %count% lss 10 goto loop_fb_1
echo.
echo %YEL%Vui long dua thiet bi vao Fastboot roi an Enter de thu lai%RST%
set /p "="
goto check_fastboot_1

:set_permissive
echo %YEL%Dang cap quyen SELinux Permissive qua Fastboot...%RST%
"%FASTBOOT%" oem set-gpu-preemption-value 0 androidboot.selinux=permissive
timeout /t 1 /nobreak >nul
"%FASTBOOT%" continue
timeout /t 3 /nobreak >nul

:check_adb_2
set count=0
:wait_adb_2
"%ADB%" devices 2>nul | findstr /v /i "List" | findstr /i "device" >nul
if %errorlevel% equ 0 goto verify_selinux
set /a count+=1
timeout /t 2 /nobreak >nul
echo ADB dang cho khoi dong lai[%count%/10]...
if %count% lss 10 goto wait_adb_2
echo.
echo %YEL%Cho ADB tro lai. An Enter de thu tiep%RST%
set /p "="
goto check_adb_2

:verify_selinux
"%ADB%" shell getenforce | findstr /i "Permissive" >nul
if %errorlevel% neq 0 (
    echo %RED%[!] SELinux van Enforcing. Vui long thu lai tu dau.%RST%
    pause
    exit /B 1
)
echo %GRN%[OK] SELinux o trang thai Permissive.%RST%

:flash_abl
echo %YEL%Dang day file abl.elf va ghi de phan vung...%RST%
if "%abl_mkdir%"=="1" "%ADB%" shell mkdir -p /data/local/tmp/abl
"%ADB%" push "%abl_path%" "%abl_dest%"
if %errorlevel% neq 0 (
    echo %YEL%Day file abl that bai. An Enter de thu lai%RST%
    set /p "="
    goto flash_abl
)
timeout /t 1 /nobreak >nul
"%ADB%" shell "service call miui.mqsas.IMQSNative 21 i32 1 s16 'dd' i32 1 s16 'if=%abl_dest% of=/dev/block/by-name/abl_a' s16 '/data/mqsas/log.txt' i32 60"
timeout /t 1 /nobreak >nul
"%ADB%" shell "service call miui.mqsas.IMQSNative 21 i32 1 s16 'dd' i32 1 s16 'if=%abl_dest% of=/dev/block/by-name/abl_b' s16 '/data/mqsas/log.txt' i32 60"
timeout /t 1 /nobreak >nul

echo %YEL%Dang khoi dong lai vao Bootloader...%RST%
"%ADB%" reboot bootloader
timeout /t 3 /nobreak >nul

:check_fastboot_2
set count=0
:loop_fb_2
"%FASTBOOT%" devices 2>nul | findstr /i "." >nul
if %errorlevel% equ 0 goto flash_gpt
set /a count+=1
timeout /t 2 /nobreak >nul
echo Fastboot dang thu ket noi[%count%/10]...
if %count% lss 10 goto loop_fb_2
echo.
echo %YEL%Vui long dua thiet bi vao Fastboot roi an Enter de thu lai%RST%
set /p "="
goto check_fastboot_2

:flash_gpt
"%FASTBOOT%" flash partition:4 "%unlock_gpt_path%"
timeout /t 1 /nobreak >nul
"%FASTBOOT%" boot "%ENNEA%"
timeout /t 1 /nobreak >nul
echo %YEL%[Goi y] Vui long dua thiet bi vao Fastboot thu cong roi an Enter de kiem tra%RST%
set /p "="

:check_fastboot_4
set count=0
:loop_fb_4
"%FASTBOOT%" devices 2>nul | findstr /i "." >nul
if %errorlevel% equ 0 goto restore_gpt
set /a count+=1
timeout /t 2 /nobreak >nul
echo Fastboot dang thu ket noi[%count%/10]...
if %count% lss 10 goto loop_fb_4
echo.
echo %YEL%Vui long dua thiet bi vao Fastboot roi an Enter de thu lai%RST%
set /p "="
goto check_fastboot_4

:restore_gpt
if exist "%gpt_path%" (
    "%FASTBOOT%" flash partition:4 "%gpt_path%"
    timeout /t 1 /nobreak >nul
) else (
    echo %YEL%Khong tim thay gpt_both4.bin goc, bo qua khoi phuc GPT.%RST%
)

:check_bl
set "bl_status=0"
"%FASTBOOT%" oem device-info > temp_bl.txt 2>&1
type temp_bl.txt
findstr /ic:"Device unlocked: true" temp_bl.txt >nul
if !errorlevel! equ 0 (
    set "bl_status=1"
    echo %GRN%[Goi y] BL DA UNLOCK%RST%
) else (
    echo %YEL%[Goi y] BL CHUA UNLOCK%RST%
)
del temp_bl.txt
echo.

:check_frp
set "frp_success=0"
"%FASTBOOT%" erase frp > temp_frp.txt 2>&1
type temp_frp.txt
findstr /ic:"FAILED" temp_frp.txt >nul
if !errorlevel! neq 0 (
    set "frp_success=1"
    echo %GRN%[Goi y] Da xoa FRP Google Lock%RST%
)
del temp_frp.txt

:check_status
if "!bl_status!"=="1" if "!frp_success!"=="1" (
    echo %GRN%UNLOCK THANH CONG%RST%
    goto flash_official
)
if "!bl_status!"=="0" if "!frp_success!"=="1" (
    echo %YEL%[CANH BAO] abl ky thuat chua bi ghi de. An Enter de thu unlock lai%RST%
    set /p "="
    goto check_fastboot_1
)
if "!bl_status!"=="0" if "!frp_success!"=="0" (
    echo %RED%[CANH BAO NGHIEM TRONG] BL chua unlock va abl da bi ghi de.%RST%
    pause
    exit /B 1
)
if "!bl_status!"=="1" if "!frp_success!"=="0" (
    echo %RED%[Lenh khong hop le] An Enter de kiem tra lai%RST%
    set /p "="
    goto check_bl
)

:flash_official
echo.
echo %CYN%-----------------------------------------------------------------%RST%
echo %YEL%  [ GOI Y ]%RST%
echo    Vui long vao %GRN%xiaomirom.com%RST% tai ROM Fastboot goc
echo    Keo tha %GRN%flash_all.bat%RST% trong thu muc ROM vao cua so nay de flash
echo %CYN%-----------------------------------------------------------------%RST%
echo %CYN%  Nhiem vu ket thuc, dang vao che do dong lenh thu cong...%RST%
echo.
if not defined IN_LOG_MODE cmd /k
