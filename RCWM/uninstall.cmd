@echo off
title RCWM Uninstall Script

SETLOCAL EnableDelayedExpansion

FOR /F "tokens=* USEBACKQ" %%F IN (`powershell $psversiontable.psversion.major`) DO ( SET pwsh=%%F )
IF !pwsh! EQU 4 ( mode con: cols=110 )

color 0b

IF "%PROCESSOR_ARCHITECTURE%" EQU "amd64" (
>nul 2>&1 "%SYSTEMROOT%\SysWOW64\cacls.exe" "%SYSTEMROOT%\SysWOW64\config\system"
) ELSE (
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"
)

if '%errorlevel%' NEQ '0' (
    echo You need to run this script with administrator privileges!
    pause
    exit
)

pushd "%CD%"
cd /d "%~dp0"

echo(
echo ***********************************
echo ****** RCWM Uninstall Script ******
echo ***********************************
echo *************************v3.0******
echo ** https://github.com/GChuf/RCWM **
echo ***********************************
echo(
echo(

cd files

powershell Set-ExecutionPolicy Bypass -Scope Process; ..\InstallerFiles\PrepareUsers.ps1 -install $false

echo(
echo(
echo Finished!
echo(
echo(

pause
