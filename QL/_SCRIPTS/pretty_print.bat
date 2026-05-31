@echo off
setlocal EnableDelayedExpansion

set /a max_length=0

rem Pass 1: find the longest string length
for /f "usebackq skip=1 tokens=1 delims=| eol=#" %%A in ("%QL_LINKS%") do (
    call :strlen "%%A" len
    if !len! gtr !max_length! set /a max_length=len
)

set "line="
set /a num=0

rem Pass 2: print 4 columns per line, padded to max_length
for /f "usebackq skip=1 tokens=1 delims=| eol=#" %%A in ("%QL_LINKS%") do (
    set /a num+=1
    set "item=%%A"
    set "line=!line!!item!"

    call :strlen "%%A" len
    set /a diff=max_length-len

    for /L %%P in (1,1,!diff!) do (
        set "line=!line! "
    )

    rem pad between columns
    set "line=!line!   "

    if !num! equ 4 (
        echo !line!
        set "line="
        set /a num=0
    )
)

if defined line echo !line!
exit /b


:strlen
setlocal EnableDelayedExpansion
set "s=%~1"
set /a len=0
:strlen_loop
if defined s (
    set "s=!s:~1!"
    set /a len+=1
    goto strlen_loop
)
endlocal & set "%~2=%len%"
exit /b