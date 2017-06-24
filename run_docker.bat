@ECHO OFF

:BEGINNING

IF [%2] == [] (GOTO :AUTOPORT) ELSE (GOTO :CMDPORT)

:CMDPORT
SET PORT=%2
IF [%3] == [] (SET PORT2=0) ELSE (SET PORT2=%3)
GOTO :RUNDOCKER

:AUTOPORT
CALL :findFirstAvailablePort 8080 PORT
SET /a "NEXTRANGE=1+PORT"
CALL :findFirstAvailablePort %NEXTRANGE% PORT2
ECHO Publishing on %PORT% and %PORT2%
GOTO :RUNDOCKER


:RUNDOCKER
SET ROOT=%1
CALL :RESOLVE "%ROOT%" RESOLVED_ROOT

:: Ensure that docker_context exists and index.sh/run.sh are the same as in the root.
IF NOT EXIST %RESOLVED_ROOT%\docker_context GOTO CONTEXTDIFF
fc /b %RESOLVED_ROOT%\install.sh %RESOLVED_ROOT%\docker_context\install.sh > nul
if errorlevel 1 goto CONTEXTDIFF
fc /b %RESOLVED_ROOT%\run.sh %RESOLVED_ROOT%\docker_context\run.sh > nul
if errorlevel 1 goto CONTEXTDIFF

FOR %%a in ("%RESOLVED_ROOT%") DO SET BASENAME=%%~na
ECHO docker run -e DOCKER_PORT=%PORT% -e DOCKER_PORT2=%PORT2% -e WATCH_POLL=1 -v %RESOLVED_ROOT%:/volume -p %PORT%:%PORT% -p %PORT2%:%PORT2% -it %BASENAME%/dev:latest
docker run -e DOCKER_PORT=%PORT% -e DOCKER_PORT2=%PORT2% -e WATCH_POLL=1 -v %RESOLVED_ROOT%:/volume -p %PORT%:%PORT% -p %PORT2%:%PORT2% -it %BASENAME%/dev:latest

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

:CONTEXTDIFF
ECHO No docker_context folder, or diff between context and repository index.sh/run.sh. re-running build_docker.
START /wait build_docker.bat %1
GOTO :BEGINNING
