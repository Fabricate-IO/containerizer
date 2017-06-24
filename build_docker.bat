@ECHO OFF
IF NOT EXIST "C:\Program Files\Git\bin\sh.exe" GOTO NOBASH
"C:\Program Files\Git\bin\sh.exe" -i -c "build_docker.sh %1"
GOTO :EOF


:NOBASH
echo On Windows, Containerizer uses git-bash to execute shell scripts.
echo Please install it at https://git-scm.com/download/win
GOTO :EOF
