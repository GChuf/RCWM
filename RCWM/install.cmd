@echo off
title RCWM Install Script

rem https://stackoverflow.com/questions/8610597/batch-file-choice-commands-errorlevel-returns-0
SETLOCAL EnableDelayedExpansion

rem Set window size for pwsh 4 and older
FOR /F "tokens=* USEBACKQ" %%F IN (`powershell $psversiontable.psversion.major`) DO ( SET pwsh=%%F )
IF !pwsh! LEQ 4 ( mode con: cols=110 lines=35 )

color 0b


rem ps v2 = win7
rem ps v3 = win8, also can be on win7 but not the same
rem ps v4 win8.1
rem ps v5 win10


rem encoding
rem powershell.exe ([System.Text.Encoding]::Default).CodePage)
rem cmd.exe chcp

REM Get Admin Privileges
REM Taken from: https://stackoverflow.com/questions/11525056/how-to-create-a-batch-file-to-run-cmd-as-administrator
IF "%PROCESSOR_ARCHITECTURE%" EQU "amd64" (
>nul 2>&1 "%SYSTEMROOT%\SysWOW64\cacls.exe" "%SYSTEMROOT%\SysWOW64\config\system"
) ELSE (
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"
)



pushd "%CD%"
cd /d "%~dp0"

rem Fun Fact: 'echo(' is faster and "safer" than 'echo.'
echo(
echo ***********************************
echo ******* RCWM Install Script *******
echo ***********************************
echo *************************v2.0******
echo ** https://github.com/GChuf/RCWM **
echo ***********************************
echo(
echo(


cd files

echo You need administrator privileges to run this script
echo You will be asked to enter your admin credentials in case
echo you are not logged in as an admin user.
echo(


rem powershell Start-Process powershell -ArgumentList '-file X:\git\rcwm\rcwm\InstallerFiles\InitialSetup.ps1' -Verb RunAs

powershell Set-ExecutionPolicy Bypass -Scope Process; ..\InstallerFiles\InitialSetup.ps1

rem this needs admin in order to delete all old rcwm reg entries
rem powershell start-process powershell -verb runas

rem powershell Start-Process powershell -verb runas -ArgumentList '-file X:\git\rcwm\rcwm\InstallerFiles\InitialSetup.ps1'

powershell Set-ExecutionPolicy Bypass -Scope Process; ..\InstallerFiles\PrepareUsers.ps1



rem choice /C yn /M "Do you want to revert right-click menu item limit back to default (15) "
rem if %errorlevel% == 2 ( reg delete HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer /v MultipleInvokePromptMinimum /f >NUL)
rem )


echo(
echo(
echo Finished!
echo(
echo You can delete all downloaded files now.
echo(
timeout /t 1 > nul

pause
