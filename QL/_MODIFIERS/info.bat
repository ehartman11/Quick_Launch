@echo off
setlocal EnableExtensions
rem info.bat  NAME PATH DESC LINK

set "NAME=%~1"
set "PATH=%~2"
set "DESC=%~3"

if not defined NAME  (echo [info] missing NAME & exit /b 1)

echo.
echo Name   : %NAME%
echo Path   : %PATH%
echo Desc   : %DESC%
exit /b 0
