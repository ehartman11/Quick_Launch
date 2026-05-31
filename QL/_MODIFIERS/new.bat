@echo off
setlocal EnableDelayedExpansion

set /p name=Enter name of command: 
set /p description=Enter a description of what the command accomplishes: 
set /p path=Enter a path for the execution of the command: 

echo %name%^|%path%^|%description% >> %QL_LINKS%
echo [new] Command added %name%