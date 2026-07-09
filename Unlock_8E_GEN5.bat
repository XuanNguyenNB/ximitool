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
set "EFI=%~dp0payloads\efi\gbl_efi_unlock.efi"

title Ximi Unlock BL - Snapdragon 8 Elite Gen 5 (Xiaomi 17 Series / K90 Pro Max)

echo %CYN%=================================================================%RST%
echo  Ximi Tool Lite - Unlock BL Snapdragon 8 Elite Gen 5
echo  Ho tro: Xiaomi 17 / 17 Pro / 17 Pro Max / 17 Ultra
echo          Redmi K90 Pro Max / POCO F8 Ultra
echo.
echo %RED%[Mien tru trach nhiem] Script chi dung de trao doi ky thuat.%RST%
echo %RED%Unlock BL se xoa sach du lieu va mat bao hanh chinh hang.%RST%
echo %RED%Tac gia khong chiu trach nhiem cho bat ky loi hoac mat du lieu nao.%RST%
echo.
echo %YEL%[TUONG THICH] Chi hoat dong voi FW thang 02/2026 tro ve truoc.%RST%
echo %YEL%              FW moi hon co the da va lo hong, unlock se khong thanh cong.%RST%
echo %CYN%=================================================================%RST%

if not exist "%EFI%" (
    echo %RED%[LOI] Khong tim thay file gbl_efi_unlock.efi tai:%RST%
    echo %RED%      %EFI%%RST%
    echo %YEL%Vui long dat file vao thu muc payloads\efi\ roi chay lai.%RST%
    pause
    exit /B 1
)

set /p confirm="Xac nhan rui ro va tiep tuc thuc thi? (Y de tiep tuc, phim khac de thoat): "
if /i "%confirm%" neq "Y" (
    echo Nguoi dung huy thao tac, script thoat.
    pause
    exit /B 1
)

echo %CYN%==========================================%RST%
echo  %GRN%KIEM TRA TRANG THAI KET NOI THIET BI%RST%
echo %CYN%==========================================%RST%

set "INIT_ADB=0"
for /f "skip=1 tokens=2" %%a in ('"%ADB%" devices 2^>nul') do (
    if "%%a"=="device" set "INIT_ADB=1"
)
if "!INIT_ADB!"=="1" (
    echo %YEL%[Phat hien] Thiet bi dang o che do ADB, dang reboot vao Bootloader...%RST%
    "%ADB%" reboot bootloader
    timeout /t 3 /nobreak >nul
    goto wait_fb_1
)

set "INIT_FB=0"
for /f "tokens=2" %%a in ('"%FASTBOOT%" devices 2^>nul') do (
    if "%%a"=="fastboot" set "INIT_FB=1"
)
if "!INIT_FB!"=="1" (
    echo %GRN%[Phat hien] Thiet bi dang o che do Fastboot.%RST%
    goto detect_codename
)

echo %YEL%[Thong bao] Chua phat hien thiet bi. Vui long ket noi qua USB.%RST%

:wait_fb_1
set count=0
:loop_fb_1
"%FASTBOOT%" devices 2>nul | findstr /i "." >nul
if %errorlevel% equ 0 goto detect_codename
set /a count+=1
timeout /t 2 /nobreak >nul
echo Fastboot dang thu ket noi[%count%/10]...
if %count% lss 10 goto loop_fb_1
echo.
echo %YEL%Vui long dua thiet bi vao Fastboot roi an Enter de thu lai%RST%
set /p "="
goto wait_fb_1

:detect_codename
echo.
echo %YEL%Dang kiem tra dong may (Codename)...%RST%
set "DEVICE_CODENAME=unknown"
set "SUPPORTED=0"
for /f "tokens=2" %%a in ('"%FASTBOOT%" getvar product 2^>^&1 ^| findstr /i "product:"') do (
    set "DEVICE_CODENAME=%%a"
)

echo %CYN%=======================================%RST%
echo Ma thiet bi phat hien: %DEVICE_CODENAME%
echo %CYN%=======================================%RST%

if "%DEVICE_CODENAME%"=="nezha"    ( echo %GRN%[OK] Xiaomi 17 Ultra - SD 8 Elite Gen 5%RST%    & set "SUPPORTED=1" )
if "%DEVICE_CODENAME%"=="pandora"  ( echo %GRN%[OK] Xiaomi 17 Pro - SD 8 Elite Gen 5%RST%      & set "SUPPORTED=1" )
if "%DEVICE_CODENAME%"=="popsicle" ( echo %GRN%[OK] Xiaomi 17 Pro Max - SD 8 Elite Gen 5%RST%  & set "SUPPORTED=1" )
if "%DEVICE_CODENAME%"=="pudding"  ( echo %GRN%[OK] Xiaomi 17 - SD 8 Elite Gen 5%RST%          & set "SUPPORTED=1" )
if "%DEVICE_CODENAME%"=="myron"    ( echo %GRN%[OK] Redmi K90 Pro Max / POCO F8 Ultra%RST%     & set "SUPPORTED=1" )

if "%SUPPORTED%"=="0" (
    echo.
    echo %RED%[CANH BAO] Codename "%DEVICE_CODENAME%" khong nam trong danh sach ho tro!%RST%
    echo %RED%Tiep tuc co the lam brick may vinh vien.%RST%
    set /p bypass="Ban co CHAC CHAN muon tiep tuc? (Y de tiep, phim khac de thoat): "
    if /i "!bypass!" neq "Y" (
        echo Nguoi dung huy thao tac, script thoat.
        pause
        exit /B 1
    )
)

echo.
echo %YEL%Dang cap quyen SELinux Permissive qua Fastboot...%RST%
"%FASTBOOT%" oem set-gpu-preemption-value 0 androidboot.selinux=permissive
timeout /t 2 /nobreak >nul
"%FASTBOOT%" continue
timeout /t 3 /nobreak >nul
echo %YEL%Luu y: Man hinh co the den, thu tuc van chay ngam.%RST%

echo.
echo %CYN%==========================================%RST%
echo  %GRN%CHO ADB - GHI FILE UNLOCK.EFI%RST%
echo %CYN%==========================================%RST%
echo %YEL%Luu y: Neu may hoi "Cho phep go loi USB", tick "Luon cho phep" roi bam OK.%RST%

:check_adb
set count=0
:wait_adb
"%ADB%" devices 2>nul | findstr /v /i "List" | findstr /i "device" >nul
if %errorlevel% equ 0 goto push_efi
set /a count+=1
timeout /t 2 /nobreak >nul
echo ADB dang thu ket noi[%count%/10]...
if %count% lss 10 goto wait_adb
echo.
echo %YEL%Ket noi lai thiet bi roi an Enter de thu lai%RST%
set /p "="
goto check_adb

:push_efi
echo %YEL%Dang day file gbl_efi_unlock.efi vao /data/local/tmp/...%RST%
"%ADB%" push "%EFI%" /data/local/tmp/gbl_efi_unlock.efi
if %errorlevel% neq 0 (
    echo %YEL%Day file that bai. An Enter de thu lai%RST%
    set /p "="
    goto push_efi
)
timeout /t 2 /nobreak >nul

echo %YEL%Ghi de file unlock vao phan vung efisp (leo thang quyen)...%RST%
"%ADB%" shell "service call miui.mqsas.IMQSNative 21 i32 1 s16 'dd' i32 1 s16 'if=/data/local/tmp/gbl_efi_unlock.efi of=/dev/block/by-name/efisp' s16 '/data/mqsas/log.txt' i32 60"
timeout /t 3 /nobreak >nul

echo.
echo %YEL%Neu phia tren xuat hien "Result..." la thanh cong.%RST%
echo %RED%Neu bao "Permission denied", ban chua co quyen SELinux, chay lai script.%RST%
echo.
pause

echo %CYN%==========================================%RST%
echo  %GRN%KIEM TRA TRANG THAI UNLOCK%RST%
echo %CYN%==========================================%RST%
echo %YEL%Dang khoi dong lai vao Bootloader...%RST%
"%ADB%" reboot bootloader
timeout /t 3 /nobreak >nul

:wait_fb_2
set count=0
:loop_fb_2
"%FASTBOOT%" devices 2>nul | findstr /i "." >nul
if %errorlevel% equ 0 goto verify_unlocked
set /a count+=1
timeout /t 2 /nobreak >nul
echo Fastboot dang thu ket noi[%count%/10]...
if %count% lss 10 goto loop_fb_2
echo.
echo %YEL%Vui long dua thiet bi vao Fastboot roi an Enter de thu lai%RST%
set /p "="
goto wait_fb_2

:verify_unlocked
echo.
echo %YEL%Kiem tra trang thai Bootloader...%RST%
"%FASTBOOT%" getvar unlocked

echo.
echo %YEL%Dang xoa phan vung efisp...%RST%
"%FASTBOOT%" erase efisp
timeout /t 2 /nobreak >nul

echo %YEL%Dang xoa phan vung metadata...%RST%
"%FASTBOOT%" erase metadata
timeout /t 2 /nobreak >nul

echo %YEL%Dang xoa phan vung userdata...%RST%
"%FASTBOOT%" erase userdata
timeout /t 2 /nobreak >nul

echo.
echo %CYN%=================================================================%RST%
echo  %GRN%Neu dong "unlocked: yes" xuat hien phia tren, UNLOCK THANH CONG!%RST%
echo %CYN%=================================================================%RST%
echo.
set /p REBOOT_CHOICE="Ban co muon khoi dong lai dien thoai ngay bay gio? (Y/N): "
if /i "%REBOOT_CHOICE%"=="Y" (
    echo %YEL%Dang khoi dong lai dien thoai...%RST%
    "%FASTBOOT%" reboot
    echo %GRN%[OK] Dien thoai dang khoi dong lai.%RST%
) else (
    echo %YEL%Ban co the tu khoi dong lai bang lenh: fastboot reboot%RST%
)
echo.
if not defined IN_LOG_MODE cmd /k
