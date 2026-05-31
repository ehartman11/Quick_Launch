@echo off
setlocal EnableExtensions EnableDelayedExpansion
rem update.bat  NAME PATH DESC LINK 

set "NAME=%~1"
set "PATH=%~2"
set "DESC=%~3"

if not defined NAME (echo [update] missing NAME & exit /b 1)

echo.
echo   1) Name   = %NAME%
echo   2) Path   = %PATH%
echo   3) Desc   = %DESC%
echo.

set "FIELD="
set /p "FIELD=Which field to change (1-3)? " || exit /b 1
if "%FIELD%"=="1" set "LABEL=Name" & set "OLD=%NAME%"
if "%FIELD%"=="2" set "LABEL=Path" & set "OLD=%PATH%"
if "%FIELD%"=="3" set "LABEL=Desc" & set "OLD=%DESC%"
if not defined LABEL (echo [update] invalid choice & exit /b 1)

echo Current %LABEL%: %OLD%
set "NEW="
set /p "NEW=New %LABEL%: " || exit /b 1


set "N_NAME=%NAME%" & set "N_PATH=%PATH%" & set "N_DESC=%DESC%"
if "%FIELD%"=="1" set "N_NAME=%NEW%"
if "%FIELD%"=="2" set "N_PATH=%NEW%"
if "%FIELD%"=="3" set "N_DESC=%NEW%"

echo.
echo Proposed change:
echo   OLD: %NAME%^|%PATH%^|%DESC%
echo   NEW: %N_NAME%^|%N_PATH%^|%N_DESC%
echo.
set "OK="
set /p "OK=Apply change? (y/N) " || exit /b 1
if /i not "%OK%"=="y" (echo [update] cancelled. & exit /b 2)

rem ---- backup + rewrite
set "TMP=%f%.tmp"
set "BAK=%QL_LINKS%.bak"
>nul copy /y "%QL_LINKS%" "%BAK%" >nul

break > "%TMP%"
for /f "usebackq delims=" %%L in ("%BAK%") do (
  set "line=%%L"
  setlocal EnableDelayedExpansion
  set "raw=!line!"
  for /f "tokens=1 delims=|" %%A in ("!raw!") do set "first=%%~A"
  if defined first if "!first!"=="%NAME%" (
    >>"%TMP%" echo %N_NAME%^|%N_PATH%^|%N_DESC%
  ) else (
    >>"%TMP%" echo(!raw!
  )
  endlocal
)

>nul move /y "%TMP%" "%QL_LINKS%%" >nul
echo [update] Updated Complete
exit /b 0
