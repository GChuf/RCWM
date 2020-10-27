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
    echo You need to run this script with administrator privileges!!!
    echo You can continue anyway, but some functionalities might not work.
    pause
)

pushd "%CD%"
cd /d "%~dp0"


echo(
echo *********************************
echo ****** RCWM Install Script ******
echo *********************************
echo ************************v1.1*****
echo *********************************
echo(
echo(


rem Fun Fact: 'echo(' is faster and safer than 'echo.'


cd files

rem If folder already exist ask if user wants to overwrite files.
IF EXIST "%SystemRoot%\System32\RCWM" ( echo RCWM folder already exists! && choice /C yn /M "Overwrite existing files " ) else ( goto install )

if %errorlevel% == 1 ( goto update ) else ( echo Keeping old files and copying possible new ones. && robocopy *.bat *.lnk *.ps1 . "%SystemRoot%\System32\RCWM" /XC /XN /XO 1>nul )


:start

echo(
echo Choose the options that you want to apply to your right-click menu.
echo You will be asked separately for each option (divided into Add and Remove sections).
echo(

choice /C yn /M "Do you want to Add right-click menu options "
if %errorlevel% == 1 ( goto Add ) else ( goto RemoveOptions )


:install

md %SystemRoot%\System32\RCWM
md %SystemRoot%\System32\RCWM\rc
md %SystemRoot%\System32\RCWM\mv
attrib +h +s %SystemRoot%\System32\RCWM
echo Created hidden folder at %SystemRoot%\System32\RCWM

xcopy /f *.bat %SystemRoot%\System32\RCWM /y 1>nul
xcopy /f *.ps1 %SystemRoot%\System32\RCWM /y 1>nul
xcopy /f *.lnk %SystemRoot%\System32\RCWM /y 1>nul

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
xcopy /f *.ps1 %SystemRoot%\System32\RCWM /y 1>nul
xcopy /f *.lnk %SystemRoot%\System32\RCWM /y 1>nul
xcopy /f rcwmimg.dll %SystemRoot%\System32 /y 1>nul
echo Copied new files.
echo Pre-setup complete.
goto start


:Add

echo(

color a
choice /C yn /M "* Do you want to add RoboCopy "
if %errorlevel% == 1 ( goto RCopy ) else ( goto MvDir )

color 9
:RCopy
choice /C sm /M "** Do you want to add RoboCopy for single or multiple directories "
if %errorlevel% == 1 ( start /w regedit /s RCopy.reg && goto MvDir ) else ( start /w regedit /s RCopyMultiple.reg && goto MvDir )

color c
:MvDir
choice /C yn /M "* Do you want to add Move Directory "
if %errorlevel% == 1 ( goto MvDirC ) else ( goto Other )

color a
:MvDirC
choice /C sm /M "** Do you want to add Move Directory for single or multiple directories "
if %errorlevel% == 1 ( start /w regedit /s MvDir.reg && goto Other ) else ( start /w regedit /s MvDirMultiple.reg && goto Other )



:Other

color 9
choice /C yn /M "* Do you want to add open CMD to background/folders/drives "
if %errorlevel% == 1 ( start /w regedit /s CMD.reg )

color c
choice /C yn /M "* Do you want to add open PowerShell to background/folders/drives "
if %errorlevel% == 1 ( start /w regedit /s pwrshell.reg )

color a
choice /C yn /M "* Do you want to add Take Ownership to files and directories"
if %errorlevel% == 1 ( start /w regedit /s TakeOwn.reg )

color 9
choice /C yn /M "* Do you want to add Take Ownership to drives (All but C:\ drive)"
if %errorlevel% == 1 ( start /w regedit /s TakeOwnDrive.reg )

color c
choice /C yn /M "* Do you want to add Safe Mode "
if %errorlevel% == 1 ( start /w regedit /s SafeMode.reg )

color a
choice /C yn /M "* Do you want to add Run with Priority "
if %errorlevel% == 1 ( start /w regedit /s RunWithPriority.reg )

color 9
choice /C yn /M "* Do you want to add Remove Directory (this deletes symlink contents, not symlinks!) "
if %errorlevel% == 1 ( start /w regedit /s RmDir.reg )

color c
choice /C yn /M "* Do you want to increase right-click menu item limit from 15 to 31? "
if %errorlevel% == 1 ( 
start /w regedit /s MultipleInvokeMinimum.reg
echo(
echo Right-click menu options will now appear for any number of selected files, but will only work correctly up until 31!!
echo If you select more than 31, only one folder will be actually selected. )
echo(

color a
choice /C yn /M "* Do you want to add Control Panel "
if %errorlevel% == 1 ( start /w regedit /s ControlPanel.reg )


:RemoveOptions

echo(

color 3
choice /C yn /M "Do you want to Remove right-click menu options "
if %errorlevel% == 1 ( goto Remove ) else ( goto End )


:Remove

echo(

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

color c
choice /C yn /M "* Do you want to delete Share "
if %errorlevel% == 1 ( start /w regedit /s DeleteShare.reg )

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
