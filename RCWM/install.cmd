@echo off
title RCWM Install Script
color 0

rem https://stackoverflow.com/questions/8610597/batch-file-choice-commands-errorlevel-returns-0
SETLOCAL EnableDelayedExpansion


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

if '%errorlevel%' NEQ '0' (
    echo You need to run this script with administrator privileges
    pause
    exit
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

rem after v1.5
reg delete "HKCU\RCWM" /f >NUL
reg add "HKCU\RCWM" /f >NUL
reg add "HKCU\RCWM\rc" /f >NUL
reg add "HKCU\RCWM\rcs" /f >NUL
reg add "HKCU\RCWM\mv" /f >NUL
reg add "HKCU\RCWM\mir" /f >NUL
reg add "HKCU\RCWM\dl" /f >NUL
reg add "HKCU\RCWM\fl" /f >NUL

cd files




powershell Set-ExecutionPolicy Bypass -Scope Process; ..\InstallerFiles\InitialSetup.ps1

powershell Set-ExecutionPolicy Bypass -Scope Process; ..\InstallerFiles\PrepareUsers.ps1



echo(
echo Choose the options that you want to apply to your right-click menu.
echo There are 3 sections: Add options, Remove options, and Miscellaneous.
echo(

powershell Set-ExecutionPolicy Bypass -Scope Process; ..\InstallerFiles\Options.ps1


rem choice /C yn /M "Do you want to revert right-click menu item limit back to default (15) "
rem if %errorlevel% == 2 ( reg delete HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer /v MultipleInvokePromptMinimum /f >NUL)
rem )



echo(

color d
echo(
echo(
echo Finished!
echo(
echo You can delete all downloaded files now.
echo(
timeout /t 1 > nul

pause
