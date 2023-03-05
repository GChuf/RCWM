@echo off
title RCWM Uninstall Script

SETLOCAL EnableDelayedExpansion

rem Set window size for pwsh 2 and 4
FOR /F "tokens=* USEBACKQ" %%F IN (`powershell $psversiontable.psversion.major`) DO ( SET pwsh=%%F )
IF !pwsh! LEQ 4 ( mode con: cols=110 lines=35 )

color 0b


REM Get Admin Privileges
REM Taken from: https://stackoverflow.com/questions/11525056/how-to-create-a-batch-file-to-run-cmd-as-administrator
IF "%PROCESSOR_ARCHITECTURE%" EQU "amd64" (
>nul 2>&1 "%SYSTEMROOT%\SysWOW64\cacls.exe" "%SYSTEMROOT%\SysWOW64\config\system"
) ELSE (
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"
)

if '%errorlevel%' NEQ '0' (
    echo You need to run this script with administrator privileges
    pause
    exit
)


pushd "%CD%"
cd /d "%~dp0"

cd UninstallerFiles

powershell Set-ExecutionPolicy Bypass -Scope Process; .\Uninstall.ps1 -verb runas


pause
