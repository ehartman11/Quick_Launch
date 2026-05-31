@echo off
setlocal EnableExtensions EnableDelayedExpansion

rem ============================================================
rem logging.bat  —  simple logging helper
rem Location: QL\_QL_ADMIN\logging.bat
rem Usage from callers (examples):
rem   call "%LOG_LIB%" init "QL_Execute" "%ROOT%_QL_ADMIN\logs"
rem   call "%LOG_LIB%" info  "Starting up"
rem   call "%LOG_LIB%" warn  "Low disk space"
rem   call "%LOG_LIB%" error "Step failed code=!errorlevel!"
rem   call "%LOG_LIB%" log   "DEBUG" "Some detail message"
rem ============================================================

if "%~1"=="" (
  echo logging.bat usage:
  echo   init  ^<appName^> [logDir]
  echo   info  ^<message^>
  echo   warn  ^<message^>
  echo   error ^<message^>
  echo   log   ^<LEVEL^> ^<message^>
  exit /b 2
)

set "LB__CMD=%~1"
shift

if /I "%LB__CMD%"=="init"  goto :LB__INIT
if /I "%LB__CMD%"=="info"  goto :LB__INFO
if /I "%LB__CMD%"=="warn"  goto :LB__WARN
if /I "%LB__CMD%"=="error" goto :LB__ERROR
if /I "%LB__CMD%"=="log"   goto :LB__LOG
echo [logging.bat] Unknown command "%LB__CMD%".
exit /b 1

:LB__INIT
rem Args: %1=AppName, %2(optional)=LogDir
set "LB__APP=%~1"
if "%~1"=="" set "LB__APP=QL_App"

if "%~2"=="" (
  rem Default to a "logs" folder next to logging.bat
  set "LB__DIR=%~dp0logs"
) else (
  set "LB__DIR=%~2"
)

if not exist "%LB__DIR%" mkdir "%LB__DIR%" >nul 2>&1

set "LB__FILE=%LB__DIR%\%LB__APP%.log"

rem Persist LOG_* vars to the caller's environment:
endlocal & (
  set "LOG_APP=%LB__APP%"
  set "LOG_DIR=%LB__DIR%"
  set "LOG_FILE=%LB__FILE%"
)
(
  echo ----------------------------------------------------------------------
  echo [SESSION START] %DATE% %TIME%  App=!LOG_APP!
) >> "%LOG_FILE%"
exit /b 0

:LB__INFO
set "LB__LEVEL=INFO"
set "LB__MSG=%*"
goto :LB__WRITE

:LB__WARN
set "LB__LEVEL=WARN"
set "LB__MSG=%*"
goto :LB__WRITE

:LB__ERROR
set "LB__LEVEL=ERROR"
set "LB__MSG=%*"
goto :LB__WRITE

:LB__LOG
rem Args: %1=LEVEL, %2..=message
set "LB__LEVEL=%~1"
shift
set "LB__MSG=%*"
goto :LB__WRITE

:LB__WRITE
rem If LOG_FILE is not set (init not called), fall back to a local file
if not defined LOG_FILE (
  set "LB__FALLBACK=%~dp0logs\default.log"
  if not exist "%~dp0logs" mkdir "%~dp0logs" >nul 2>&1
  set "LOG_FILE=%LB__FALLBACK%"
)
>> "%LOG_FILE%" echo [%DATE% %TIME%] [%LB__LEVEL%] %LB__MSG%
exit /b 0
