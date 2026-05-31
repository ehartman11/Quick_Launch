@echo off
setlocal EnableExtensions EnableDelayedExpansion
rem delete.bat  NAME PATH DESC LINK 

set "NAME=%~1"
set "PATH=%~2"
set "DESC=%~3"

if not defined NAME (echo [delete] missing NAME & exit /b 1)

echo.
echo You are about to DELETE:
echo   %NAME%^|%PATH%^|%DESC%
set "OK="
set /p "OK=Confirm delete? (y/N) " || exit /b 1
if /i not "%OK%"=="y" (echo [delete] cancelled. & exit /b 2)

set "TMP=%QL_LINKS%.tmp"
set "BAK=%QL_LINKS%.bak"
>nul copy /y "%QL_LINKS%" "%BAK%" >nul

break > "%TMP%"
for /f "usebackq delims=" %%L in ("%BAK%") do (
  set "line=%%L"
  setlocal EnableDelayedExpansion
  set "raw=!line!"
  for /f "tokens=1 delims=|" %%A in ("!raw!") do set "first=%%~A"
  if defined first if "!first!"=="%NAME%" (
    rem skip
  ) else (
    >>"%TMP%" echo !raw!
  )
  endlocal
)

>nul move /y "%TMP%" "%QL_LINKS%" >nul
echo [delete] Deleted: %NAME%
exit /b 0
