@echo off
title RCWM Uninstall Script

SETLOCAL EnableDelayedExpansion

rem Set window size for pwsh 2 and 4
FOR /F "tokens=* USEBACKQ" %%F IN (`powershell $psversiontable.psversion.major`) DO ( SET pwsh=%%F )
IF !pwsh! LEQ 4 ( mode con: cols=110 lines=35 )

color 0b

pushd "%CD%"
cd /d "%~dp0"

cd UninstallerFiles

powershell Set-ExecutionPolicy Bypass -Scope Process; .\Uninstall.ps1 -verb runas


pause
