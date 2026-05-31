@echo off
setlocal EnableExtensions EnableDelayedExpansion
rem Quick Launcher v1.0
rem Last updated: 2025:09:03

rem --- anchor paths
set "QL_ROOT=C:\Users\ephar\QL"
set "QL_MOD=%QL_ROOT%\_MODIFIERS"
set "QL_LINKS=%QL_ROOT%\_ADMIN\_links.txt"
set "QL_SCRIPTS=%QL_ROOT%\_SCRIPTS"

rem --- optional: load prefs/colors/banner here
rem call "%QL_ROOT%_MODIFIERS\prefs.bat"

:repl
echo.
set "LINE="
set /p "LINE=> "  || goto :bye   rem Ctrl+Z/EOF exits

rem ---- trim leading/trailing spaces from LINE
for /f "tokens=* delims= " %%A in ("!LINE!") do set "LINE=%%A"
:trimtail
for /l %%# in (1,1,1) do if "!LINE:~-1!"==" " set "LINE=!LINE:~0,-1!" & goto :trimtail

if not defined LINE echo No command entered & goto :repl

rem ---- built-ins (no lookup)
if "!LINE!"=="exit"  goto :bye
if "!LINE!"=="quit"  goto :bye
if /i "!LINE!"=="help"  goto :help
if /i "!LINE!"=="clear" cls & goto :repl
if /i "!LINE!"=="list"  goto :do_list

if /i "!LINE!"=="new" goto :new

rem ---- split NAME and the rest
set "NAME=" & set "REST="
for /f "tokens=1* delims= " %%A in ("!LINE!") do (
  set "NAME=%%A"
  set "REST=%%B"
)

set "FLAG=" & set "QL_FWD="

if not "!REST!"=="" (
	if "!REST:~0,2!"=="--" if not "!REST:~2!"=="" (
		set "QL_FWD=!REST:~2!"
		for /f "tokens=* delims= " %%x in ("!QL_FWD!") do set "QL_FWD=%%x"
		goto :dispatch
	) else if "!REST:~0,1!"=="-" if "!REST:~2!"=="" (
		goto :validate_flag
	) else ( goto :invalid_flag )
) else ( goto :dispatch )

:validate_flag
for %%a in (p i d u D) do (
	if "%%a"=="!REST:~1,1!" set "FLAG=!REST!"
)
if defined FLAG goto :dispatch
goto :invalid_flag

:invalid_flag
echo [ql] invalid flag (got "!REST!"; valid flags: -p, -i, -d, -u, -D, -- *ARGS)
goto :repl

:new
call %QL_MOD%\new
goto :repl

:dispatch
set "QL_PATH=" & set "QL_INIT=" & set "QL_DESC=" & set "QL_LINKFILE="
call :lookup_in_links "%NAME%"
if errorlevel 1 (
  echo [ql] Not found: "%NAME%"
  goto :repl
)

if "%FLAG%"=="" call "%QL_MOD%\execute.bat" "%NAME%" "%QL_PATH%" "%QL_DESC%" "%QL_FWD%" & goto :repl
if "%FLAG%"=="-p"  (echo %QL_PATH% & goto :repl)
if "%FLAG%"=="-d"  (echo %QL_DESC% & goto :repl)
if "%FLAG%"=="-i"  (call "%QL_MOD%\info.bat"   "%NAME%" "%QL_PATH%" "%QL_DESC%" & goto :repl)
if "%FLAG%"=="-D"  (call "%QL_MOD%\delete.bat" "%NAME%" "%QL_PATH%" "%QL_DESC%" & goto :repl)
if "%FLAG%"=="-u"  (call "%QL_MOD%\update.bat" "%NAME%" "%QL_PATH%" "%QL_DESC%" & goto :repl)

:help
echo.
echo Quick Launcher
echo   TYPE:  NAME            execute NAME
echo          NAME -p         print path
echo 	 NAME -d	 print description
echo          NAME -i         show info
echo          NAME -D         delete line from matching _links.txt
echo          NAME -u         update line in matching _links.txt
echo          NAME -- ARGS..  pass ARGS to the target
echo   ALSO:  list, clear, help, exit
goto :repl

:do_list
rem list all defined names
call %QL_SCRIPTS%\pretty_print.bat
goto :repl

:bye
echo Bye.
exit /b 0


:: ===========================================================
:: Recursive lookup (case-sensitive, first match wins)
:: Sets: QL_PATH, QL_DESC, QL_LINK
:: ===========================================================
:lookup_in_links
setlocal EnableExtensions EnableDelayedExpansion
set "want=%~1"
set "hitPath=" & set "hitDesc=" & set "hitLink="

for /f "usebackq tokens=1-3 delims=| eol=#" %%A in ("%QL_LINKS%") do (
	rem capture fields
	set "A=%%~A"
	set "B=%%~B"
	set "C=%%~C"

	rem trim leading spaces from each field (right-trim not needed for our parse)
	for /f "tokens=* delims= " %%x in ("!A!") do set "A=%%x"
	for /f "tokens=* delims= " %%x in ("!B!") do set "B=%%x"
	for /f "tokens=* delims= " %%x in ("!C!") do set "C=%%x"

	rem normalize '-' placeholders to empty
	if "!B!"=="-" set "B="
	if "!C!"=="-" set "C="

	rem match name (case-sensitive; switch to /i compare if you want CI)
	if "!A!"=="%want%" (
	  set "hitPath=!B!"
	  set "hitDesc=!C!"
	  goto :_lookup_found
	)
)

endlocal & exit /b 1

:_lookup_found
endlocal & (
  set "QL_PATH=%hitPath%"
  set "QL_DESC=%hitDesc%"
)
exit /b 0
