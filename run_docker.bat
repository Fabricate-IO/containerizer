@ECHO OFF
SET ROOT=%~dp0/%1

CALL :RESOLVE "%ROOT%" RESOLVED_ROOT

echo %RESOLVED_ROOT%

:: search for available port
call :findFirstAvailablePort 8080 PORT

ECHO Publishing on %PORT%

ECHO docker run -e DOCKER_PORT=%PORT% -e WATCH_POLL=1 -v %RESOLVED_ROOT%:/volume -p %PORT%:%PORT% -it %1/dev:latest
docker run -e DOCKER_PORT=%PORT% -e WATCH_POLL=1 -v %RESOLVED_ROOT%:/volume -p %PORT%:%PORT% -it %1/dev:latest

GOTO :EOF

:RESOLVE
SET %2=%~f1
GOTO :EOF

:findFirstAvailablePort startingPort returnVariable
    setlocal enableextensions
    :: Generate a list of the open ports and save in temporary file
    set "tempFile=%temp%\%~nx0.tmp"
    ((@for /f "tokens=2" %%a in ('netstat -an -p tcp'
     ) do @for /f "tokens=1,2 delims=]" %%b in ("%%a"
     ) do @if "%%c"=="" (@echo(x%%b) else (@echo(%%c)
    )|@for /f "tokens=2 delims=: " %%d in ('more') do @echo($%%d$) > "%tempFile%"

    :: Test temporary file for next available port
    (break|@for /l %%p in (%~1 1 65535) do @(
        find "$%%p$" "%tempFile%" >nul || exit %%p
        if %%p==65535 exit 0
    ))
    set "port=%errorlevel%"

    :: clean and exit returning port
    endlocal & del /q "%tempFile%" 2>nul & set "%~2=%port%" & exit /b
GOTO :EOF