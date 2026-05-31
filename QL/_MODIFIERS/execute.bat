@echo off
setlocal EnableExtensions EnableDelayedExpansion

rem ------------------------------------------------------------------
rem execute.bat (globals in :main, helpers use them directly)
rem Args:
rem   %1 NAME   %2 TARGET (PATH | URL) %3 DESC  [args...]
rem Returns: 0 OK  | 1 not found | 2 exec failed
rem ------------------------------------------------------------------
goto :main

:exec_file
rem %~1 = file to execute (uses global FWD for args)
setlocal EnableDelayedExpansion
set "FILE=%~1"
set "EXT=%~x1"

if /i "%EXT%"==".exe" ( "%FILE%" %FWD% & endlocal & exit /b !errorlevel! )
if /i "%EXT%"==".bat" ( call "%FILE%" %FWD% & endlocal & exit /b !errorlevel! )
if /i "%EXT%"==".cmd" ( call "%FILE%" %FWD% & endlocal & exit /b !errorlevel! )

start "" "%FILE%" %FWD%
endlocal & exit /b %errorlevel%

:: ----------------- main -----------------
:main
rem ----- arguments & placeholder normalization (as you have) -----
set "NAME=%~1"
if "%~2"=="-" (set "TARGET=") else (set "TARGET=%~2")
if "%~3"=="-" (set "DESC=")   else (set "DESC=%~3")
if "%~4"=="-" (set "FWD=")   else (set "FWD=%~4")

rem ----- pid for log lines
set "PID=%random%%random%"

if not defined TARGET call :die 1 No target for "%NAME%".

rem ----- detect URL (simple & safe)
set "ISURL="
rem Detect protocol style URLs
echo("%TARGET%" | findstr /i "://" >nul && set "ISURL=1"

rem Explicit protocol handlers
if /i "%TARGET:~0,7%"=="mailto:"      set "ISURL=1"
if /i "%TARGET:~0,12%"=="ms-settings:" set "ISURL=1"
if /i "%TARGET:~0,6%"=="shell:"       set "ISURL=1"

rem Handle www without protocol
if /i "%TARGET:~0,4%"=="www." (
    set "TARGET=http://%TARGET%"
    set "ISURL=1"
)

rem Dispatch
if defined ISURL (
    start "" "%TARGET%"
    exit /b 0
)

if exist "%TARGET%" (
  call :exec_file "%TARGET%"
  if errorlevel 1 call :die 3 File execution failed: "%TARGET%"
  exit /b 0
)

call :die 1 Target not found: "%TARGET%"
