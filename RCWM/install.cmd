@echo off
title RCWM Install Script
color 3


REM Get Admin Privileges
REM Taken from: https://stackoverflow.com/questions/11525056/how-to-create-a-batch-file-to-run-cmd-as-administrator
    IF "%PROCESSOR_ARCHITECTURE%" EQU "amd64" (
>nul 2>&1 "%SYSTEMROOT%\SysWOW64\cacls.exe" "%SYSTEMROOT%\SysWOW64\config\system"
) ELSE (
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"
)

if '%errorlevel%' NEQ '0' (
    title GetAdmin
    echo Requesting admin privileges ...
    goto UACPrompt
) else ( goto gotAdmin )

:UACPrompt
    echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
    set params= %*
    echo UAC.ShellExecute "cmd.exe", "/c ""%~s0"" %params:"=""%", "", "runas", 1 >> "%temp%\getadmin.vbs"

    "%temp%\getadmin.vbs"
    del "%temp%\getadmin.vbs"
    exit /B

:gotAdmin
    pushd "%CD%"
    CD /D "%~dp0"



echo(
echo *********************************
echo ****** RCWM Install Script ******
echo *********************************
echo ************************v1.1*****
echo *********************************
echo(
echo(

rem Fun Fact: 'echo(' is faster and safer than 'echo.'

rem If folder already exist ask if user wants to overwrite files.
IF EXIST "%SystemRoot%\System32\RCWM" ( echo RCWM folder already exists! && choice /C yn /M "Overwrite existing files " ) else ( goto install )

if %errorlevel% == 1 ( goto update ) else ( echo Keeping old files and copying possible new ones. && robocopy *.bat *.lnk . "%SystemRoot%\System32\RCWM" /XC /XN /XO 1>nul )


:start

echo(
echo Choose the options that you want to apply to your right-click menu.
echo You will be asked separately for each option (divided into Add and Remove sections).
echo(

choice /C yn /M "Do you want to Add right-click menu options "
if %errorlevel% == 1 ( goto Add ) else ( goto RemoveOptions )


:install

md %SystemRoot%\System32\RCWM
attrib +h +s %SystemRoot%\System32\RCWM
echo Created hidden folder at %SystemRoot%\System32\RCWM

xcopy /f *.bat %SystemRoot%\System32\RCWM 1>nul
xcopy /f rcwmimg.dll %SystemRoot%\System32 /y 1>nul

rem take ownership of that folder for administrators & users
takeown /F %SystemRoot%\System32\RCWM /R /D Y 1>nul
icacls %SystemRoot%\System32\RCWM /grant administrators:F /T /C 1>nul
icacls %SystemRoot%\System32\RCWM /grant users:F /T /C 1>nul

echo Copied all files.
echo Pre-setup complete.
goto start


:update

xcopy /f *.bat %SystemRoot%\System32\RCWM /y 1>nul
xcopy /f *.lnk %SystemRoot%\System32\RCWM /y 1>nul
xcopy /f rcwmimg.dll %SystemRoot%\System32 /y 1>nul
echo Copied new files.
echo Pre-setup complete.
goto start


:Add

echo(

color 9
choice /C yn /M "* Do you want to add RoboCopy "
if %errorlevel% == 1 ( goto RCopySingle ) else ( goto MvDir )


:RCopySingle
choice /C yn /M "** Do you want to add RoboCopy for single directories (recommended) "
if %errorlevel% == 1 ( start /w regedit /s RCopy.reg && goto MvDir ) else ( goto RCopyBeta )

:RCopyBeta
choice /C yn /M "** Do you want to add RoboCopy for multiple directories (in beta - check readme) "
if %errorlevel% == 1 ( start /w regedit /s RCopyMultiple.reg )


:MvDir
color c
choice /C yn /M "* Do you want to add Move Directory "
if %errorlevel% == 1 ( goto MvDirSingle ) else ( goto Other )

:MvDirSingle
choice /C yn /M "** Do you want to add Move Directory for single directories (recommended) "
if %errorlevel% == 1 ( start /w regedit /s MvDir.reg && goto Other ) else ( goto MvDirBeta )

:MvDirBeta
choice /C yn /M "** Do you want to add Move Directory for multiple directories (in beta - check readme) "
if %errorlevel% == 1 ( start /w regedit /s MvDirMultiple.reg )


:Other

color a
choice /C yn /M "* Do you want to add Take Ownership "
if %errorlevel% == 1 ( start /w regedit /s TakeOwn.reg )

color 9
choice /C yn /M "* Do you want to add Safe Mode "
if %errorlevel% == 1 ( start /w regedit /s SafeMode.reg )

color c
choice /C yn /M "* Do you want to add open CMD to background/folders/drives "
if %errorlevel% == 1 ( start /w regedit /s CMD.reg )

color 9
choice /C yn /M "* Do you want to add open PowerShell to background "
if %errorlevel% == 1 ( start /w regedit /s PWSHbackground.reg )

color c
choice /C yn /M "* Do you want to add open PowerShell to folders "
if %errorlevel% == 1 ( start /w regedit /s PWSHfolders.reg )

color a
choice /C yn /M "* Do you want to add Run with Priority "
if %errorlevel% == 1 ( start /w regedit /s RunWithPriority.reg )

color 9
choice /C yn /M "* Do you want to add Remove Directory (this deletes symlink contents, not symlinks!) "
if %errorlevel% == 1 ( start /w regedit /s RmDir.reg )

color c
choice /C yn /M "* Do you want to increase right-click menu item limit from 15 to 256? "
if %errorlevel% == 1 ( start /w regedit /s MultipleInvokeMinimum.reg )


rem color c
rem choice /C yn /M "* Do you want to add Control Panel "
rem if %errorlevel% == 1 ( start /w regedit /s ControlPanel.reg )


:RemoveOptions

echo(

color 3
choice /C yn /M "Do you want to Remove right-click menu options "
if %errorlevel% == 1 ( goto Remove ) else ( goto End )


:Remove

echo(

color c
choice /C yn /M "* Do you want to delete Share "
if %errorlevel% == 1 ( start /w regedit /s DeleteShare.reg )

color a
choice /C yn /M "* Do you want to delete Pin to quick access "
if %errorlevel% == 1 ( start /w regedit /s DeletePinQuick.reg )

color 9
choice /C yn /M "* Do you want to delete Pin to Start "
if %errorlevel% == 1 ( start /w regedit /s DeletePinStartScreen.reg )

color c
choice /C yn /M "* Do you want to delete Send To "
if %errorlevel% == 1 ( start /w regedit /s DeleteSendTo.reg )

color a
choice /C yn /M "* Do you want to delete Include in Library "
if %errorlevel% == 1 ( start /w regedit /s DeleteLibrary.reg )

color 9
choice /C yn /M "* Do you want to delete Add to Windows Media Player "
if %errorlevel% == 1 ( start /w regedit /s DeleteWinPlayer.reg )

rem color 9
rem choice /C yn /M "* Do you want to delete Print "

rem color c
rem choice /C yn /M "* Do you want to delete Win Defender "

rem color a
rem choice /C yn /M "* Do you want to delete Cast to Device "



:End

color d
echo(
echo(
echo Finished!
echo(
echo You can delete all downloaded files now.
echo The batch files are located inside %SystemRoot%\System32\RCWM.
rem if you want to change batch files inside RCWM, give your users all necessary permissions.
echo(
timeout /t 1 > nul

pause
