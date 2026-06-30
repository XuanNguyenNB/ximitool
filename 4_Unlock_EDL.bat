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

set "FASTBOOT_BIN=%~dp0tools\bin\fastboot.exe"
set "TMP_BL="
set "TMP_FRP="
set "TMP_DEV="

call :RequireTools
if errorlevel 1 (
    set "ERROR_CODE=2"
    set "ERROR_MSG=Pre-flight that bai: thieu file/thu muc bat buoc."
    goto :End
)

echo %CYN%=================================================================%RST%
echo  Xiaomi Fastboot Unlock (Giai doan hau EDL)
echo  Dung de hoan thanh Unlock sau khi da Flash abl.elf qua che do EDL.
echo  Ho tro rieng cho chip Snapdragon 8 Elite, 8 Gen 2, 8s/7+ Gen 3 va 8s Gen 4.
echo %CYN%=================================================================%RST%
echo %RED%Yeu cau: Ban da nap thanh cong file abl.elf ky thuat qua EDL.%RST%
echo %RED%Canh bao: Qua trinh nay se xoa toan bo du lieu.%RST%
echo.

set "confirm="
set /p confirm="Dien thoai dang o che do Fastboot? (Y de bat dau, N de thoat): "
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
echo  1. Snapdragon 8 Elite (Xiaomi 15, Redmi K80 Pro...)
echo  2. Snapdragon 8 Gen 2 (Xiaomi 13, Redmi K60 Pro...)
echo  3. Snapdragon 8s/7+ Gen 3 (Turbo 3, Civi 4 Pro, Pad 7 Pro)
echo  4. Snapdragon 8s Gen 4 (Turbo 4 Pro, Civi 5 Pro, Pad 8)
echo  0. Thoat
echo %CYN%==========================================%RST%
set "soc_choice="
set /p soc_choice="Chon (0-4): "

if "%soc_choice%"=="1" goto menu_8e
if "%soc_choice%"=="2" goto menu_8g2
if "%soc_choice%"=="3" goto menu_8sg3
if "%soc_choice%"=="4" goto menu_8sg4
if "%soc_choice%"=="0" (
    set "ERROR_CODE=0"
    goto :End
)
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

:: ===================== MENU 8 GEN 2 =====================
:menu_8g2
set "ennea_img=payloads\ennea\8550-Ennea.img"
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
echo  1. Redmi Turbo 3
echo  2. Xiaomi Civi 4 Pro
echo  3. Xiaomi Pad 7 Pro
echo  0. Quay lai
set "dev_choice="
set /p dev_choice="Chon: "
if "%dev_choice%"=="1" ( set "factoryImages=Redmiturbo3" & set "unlockGPT=Redmiturbo3" )
if "%dev_choice%"=="2" ( set "factoryImages=Xiaomicivi4pro" & set "unlockGPT=Xiaomicivi4pro" )
if "%dev_choice%"=="3" ( set "factoryImages=Xiaomipad7pro" & set "unlockGPT=Xiaomipad7pro" )
if "%dev_choice%"=="0" goto main_menu
if defined factoryImages goto pre_unlock
goto menu_8sg3

:: ===================== MENU 8s GEN 4 =====================
:menu_8sg4
set "ennea_img=payloads\ennea\8735-Ennea.img"
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

:: ===================== XAC NHAN + HIEN THI THONG TIN =====================
:pre_unlock
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
echo  - Unlock GPT: %unlock_gpt_path%
echo %RED%=================================================================%RST%
echo.
set "final_confirm="
set /p final_confirm="Xac nhan bat dau? (Y de tiep tuc, phim khac de thoat): "
if /i "%final_confirm%" neq "Y" (
    set "ERROR_CODE=1"
    set "ERROR_MSG=Nguoi dung huy bo o buoc xac nhan cuoi."
    goto :End
)

:: ===================== BUOC 1: KIEM TRA FASTBOOT =====================
echo %CYN%==========================================%RST%
echo  %GRN%Dang kiem tra ket noi Fastboot%RST%
echo %CYN%==========================================%RST%

:check_fastboot
set "count=0"

:loop_check
call :ScanFastboot
if "%FASTBOOT_OK%"=="1" goto do_flash_all
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
pause >nul
goto check_fastboot

:: ===================== BUOC 2: FLASH_ALL + FLASH GPT + ENNEA =====================
:do_flash_all
if exist "%~dp0payloads\factoryImages\%factoryImages%\flash_all.bat" (
    echo %YEL%Dang chay Flash All baseband firmware cho %factoryImages%...%RST%
    setlocal
    call "%~dp0payloads\factoryImages\%factoryImages%\flash_all.bat"
    endlocal
    timeout /t 1 >nul
)

:check_fastboot_1
set "count=0"

:loop_check_1
call :ScanFastboot
if "%FASTBOOT_OK%"=="1" goto flash_gpt
set /a count+=1
timeout /t 2 /nobreak >nul
echo Fastboot thu ket noi[%count%/10]...
if %count% lss 10 goto loop_check_1
echo.
echo %YEL%Nhan Enter de thu phat hien lai Fastboot.%RST%
pause >nul
goto check_fastboot_1

:flash_gpt
"%FASTBOOT_BIN%" flash partition:4 "%unlock_gpt_path%"
if errorlevel 1 (
    echo %RED%[!] Flash unlockGPT co the that bai. Kiem tra output phia tren.%RST%
)
timeout /t 1 /nobreak >nul
"%FASTBOOT_BIN%" boot "%ennea_full%"
if errorlevel 1 (
    echo %RED%[!] Boot Ennea co the that bai. Kiem tra output phia tren.%RST%
)
timeout /t 1 /nobreak >nul
echo %YEL%[QUAN TRONG] Dang cho thiet bi vao lai Fastboot sau khi boot Ennea...%RST%
echo %YEL%Khi thiet bi da vao lai Fastboot, nhan phim bat ky de tiep tuc.%RST%
pause >nul
goto check_fastboot_2

:: ===================== BUOC 3: RESTORE GPT GOC =====================
:check_fastboot_2
set "count=0"

:loop_check_2
call :ScanFastboot
if "%FASTBOOT_OK%"=="1" goto restore_gpt
set /a count+=1
timeout /t 2 /nobreak >nul
echo Fastboot thu ket noi[%count%/10]...
if %count% lss 10 goto loop_check_2
echo.
echo %YEL%Nhan Enter de thu phat hien lai Fastboot.%RST%
pause >nul
goto check_fastboot_2

:restore_gpt
if defined gpt_path (
    "%FASTBOOT_BIN%" flash partition:4 "%gpt_path%"
    timeout /t 1 /nobreak >nul
) else (
    echo %YEL%Khong tim thay file gpt_both4.bin (co the khong can cho model nay).%RST%
)

:: ===================== BUOC 4: KIEM TRA KET QUA =====================
:check_bl
set "bl_status=0"
call :MakeTmp TMP_BL
"%FASTBOOT_BIN%" oem device-info > "%TMP_BL%" 2>&1
type "%TMP_BL%"
findstr /ic:"Device unlocked: true" "%TMP_BL%" >nul
if not errorlevel 1 (
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
if errorlevel 1 (
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
    echo %YEL%[CANH BAO] BL chua mo nhung FRP da xoa duoc. ABL co the chua flash dung qua EDL.%RST%
    echo %YEL%Vui long flash lai abl.elf qua EDL roi thu lai. Nhan Enter.%RST%
    pause >nul
    goto check_fastboot
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
if not exist "%FASTBOOT_BIN%" (
    echo %RED%[LOI] Khong tim thay fastboot.exe tai "%FASTBOOT_BIN%"%RST%
    exit /b 1
)
if not exist "%~dp0payloads\" (
    echo %RED%[LOI] Khong tim thay thu muc payloads tai "%~dp0payloads\"%RST%
    exit /b 1
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
if not exist "%unlock_gpt_path%" (
    echo %RED%[LOI] Khong tim thay unlockgpt_both4.bin tai "%unlock_gpt_path%"%RST%
    exit /b 1
)
if not exist "%ennea_full%" (
    echo %RED%[LOI] Khong tim thay file Ennea tai "%ennea_full%"%RST%
    exit /b 1
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
del "%~dp0temp_bl.txt" >nul 2>nul
del "%~dp0temp_frp.txt" >nul 2>nul
exit /b 0
