@echo off
:: ===================================================================
:: tools\common.cmd - Helper chung
::
:: Su dung:
::   call "%~dp0tools\common.cmd" Trace "STEP N: message"
::   call "%~dp0tools\common.cmd" SafePause label_name
::   call "%~dp0tools\common.cmd" InitTrace edl
::       -> se set bien TRACE_FILE trong caller.
::
:: Yeu cau caller da co: setlocal enabledelayedexpansion
:: ===================================================================

if "%~1"=="" (
    echo [common.cmd] Loi: khong co sub-command.
    exit /b 2
)

if /i "%~1"=="Trace" goto :DoTrace
if /i "%~1"=="SafePause" goto :DoSafePause
if /i "%~1"=="InitTrace" goto :DoInitTrace

echo [common.cmd] Loi: sub-command khong hop le: %~1
exit /b 2

:: ============================== Trace ==============================
:: %2 = message
:DoTrace
if not defined TRACE_FILE exit /b 0
>>"%TRACE_FILE%" echo [%date% %time%] %~2
exit /b 0

:: ============================== SafePause ==========================
:: %2 = label (chi de trace, khong bat buoc)
:: Dung "set /p" thay cho "pause >nul" de tranh mot so tinh huong
:: stdin bi dong khien pause return ngay lap tuc.
:DoSafePause
if defined TRACE_FILE >>"%TRACE_FILE%" echo [%date% %time%] SafePause: waiting (label=%~2)
set "_SP_INPUT="
set /p "_SP_INPUT=Nhan Enter de tiep tuc..."
if defined TRACE_FILE >>"%TRACE_FILE%" echo [%date% %time%] SafePause: resumed (label=%~2, input=[%_SP_INPUT%])
exit /b 0

:: ============================== InitTrace ==========================
:: %2 = prefix (edl / adb / driver / memory)
:: Yeu cau caller da co bien SCRIPT_DIR (voi trailing backslash).
:: Ket qua: set bien TRACE_FILE trong caller.
:DoInitTrace
set "_PREFIX=%~2"
if not defined _PREFIX set "_PREFIX=trace"
if not defined SCRIPT_DIR set "SCRIPT_DIR=%~dp0..\"
if not exist "%SCRIPT_DIR%reports\" mkdir "%SCRIPT_DIR%reports\" >nul 2>nul
set "_TS="
for /f "usebackq delims=" %%a in (`powershell -NoProfile -Command "Get-Date -Format yyyyMMdd_HHmmss"`) do set "_TS=%%a"
if not defined _TS set "_TS=%RANDOM%%RANDOM%"
set "TRACE_FILE=%SCRIPT_DIR%reports\%_PREFIX%_trace_%_TS%.log"
exit /b 0
