@echo off
title RCWM Install Script
color 3

rem https://stackoverflow.com/questions/8610597/batch-file-choice-commands-errorlevel-returns-0
SETLOCAL EnableDelayedExpansion



rem ps v2 = win7
rem ps v3 = win8, also can be on win7 but not the same
rem ps v4 win8.1
rem ps v5 win10

rem after v1.5
reg delete "HKCU\RCWM" /f >NUL
reg add "HKCU\RCWM" /f >NUL
reg add "HKCU\RCWM\rc" /f >NUL
reg add "HKCU\RCWM\mv" /f >NUL
reg add "HKCU\RCWM\mir" /f >NUL
reg add "HKCU\RCWM\dl" /f >NUL
reg add "HKCU\RCWM\fl" /f >NUL

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
    echo You need to run this script with administrator privileges!!!
    pause
    exit
)

pushd "%CD%"
cd /d "%~dp0"

rem Fun Fact: 'echo(' is faster and safer than 'echo.'
echo(
echo *********************************
echo ****** RCWM Install Script ******
echo *********************************
echo ************************v1.5*****
echo * https://github.com/GChuf/RCWM *
echo *********************************
echo(
echo(


cd files

IF EXIST "C:\Program Files\PowerShell\7" (
    FOR /F "tokens=* USEBACKQ" %%F IN (`pwsh -command $psversiontable.psversion.major`) DO ( SET pwsh7=%%F )
	goto pwsh7
) ELSE (
	goto pwsh
)
	
:pwsh7
IF %pwsh7% LEQ 7 (
	IF "%PROCESSOR_ARCHITECTURE%" EQU "amd64" ( echo Using powershell version 7 on 32bit CPU. ) else ( echo Using powershell version 7 on 64bit CPU. )
	
) ELSE (
	IF "%PROCESSOR_ARCHITECTURE%" EQU "amd64" ( echo Using unknown powershell version greater than 7 on 32bit CPU. ) else ( echo Using unknown powershell version greater than 7 on 64bit CPU. )
)

goto pwshdone

:pwsh
rem powershell version check
FOR /F "tokens=* USEBACKQ" %%F IN (`powershell $psversiontable.psversion.major`) DO ( SET pwsh=%%F )


IF %pwsh% LSS 5 (
    IF "%PROCESSOR_ARCHITECTURE%" EQU "amd64" ( echo Using powershell version older than 5 on 32bit CPU. ) else ( echo Using powershell version older than 5 on 64bit CPU. )
) ELSE (
    IF "%PROCESSOR_ARCHITECTURE%" EQU "amd64" ( echo Using powershell version 5 or newer on 32bit CPU. ) else ( echo Using powershell version 5 or newer on 64bit CPU. )
)


:pwshdone

rem Unblock ps1 files (not entirely necessary)
rem Won't work on older powershell versions, so output error message to NUL
powershell Unblock-File *.ps1 > NUL; exit


rem If folder already exist ask if user wants to overwrite files.
IF EXIST "%SystemRoot%\System32\RCWM" ( echo RCWM folder already exists! && choice /C yn /M "Overwrite existing files " ) else ( goto install )

if %errorlevel% == 1 ( goto update ) else ( echo Keeping old files and copying possible new ones. && robocopy *.bat *.lnk *.ps1 . "%SystemRoot%\System32\RCWM" /XC /XN /XO 1>nul )


:start


echo(
echo Choose the options that you want to apply to your right-click menu.
echo You will be asked separately for each option (divided into Add and Remove sections).
echo(


FOR /F "tokens=*" %%g IN ('powershell "([Environment]::OSVersion).Version.Major"') do (SET WinVer=%%g)
echo(

IF %WinVer% == 11 (
    choice /C yn /M "Do you want to enable old context menu in Windows 11 "
	if !errorlevel! == 1 (
	    start /w regedit /s Win11AddOldContextMenu.reg
	)
)

echo(
color c

choice /C yn /M "Do you want to Add right-click menu options "
if %errorlevel% == 1 ( goto Add ) else ( goto RemoveOptions )


:install

md %SystemRoot%\System32\RCWM
md %SystemRoot%\System32\RCWM\rc
md %SystemRoot%\System32\RCWM\mv
md %SystemRoot%\RCWM
attrib +h +s %SystemRoot%\System32\RCWM
echo Created hidden folder at %SystemRoot%\System32\RCWM

xcopy /f *.bat %SystemRoot%\System32\RCWM /y 1>nul
xcopy /f *.ps1 %SystemRoot%\System32\RCWM /y 1>nul
xcopy /f *.lnk %SystemRoot%\System32\RCWM /y 1>nul
xcopy /f .\bin\*.exe %SystemRoot%\RCWM /y 1>nul
xcopy /f rcwmimg.dll %SystemRoot%\System32 /y 1>nul

rem if powershell version less than 5, overwrite some files with 'windows7' version
IF %pwsh% LSS 5 (
    xcopy /f .\Win7\*.bat %SystemRoot%\System32\RCWM /y 1>nul
	xcopy /f .\Win7\*.reg . /y 1>nul
)

rem take ownership of that folder for administrators & users
takeown /F %SystemRoot%\System32\RCWM /R /D Y 1>nul
icacls %SystemRoot%\System32\RCWM /grant administrators:F /T /C 1>nul
icacls %SystemRoot%\System32\RCWM /grant users:F /T /C 1>nul

takeown /F %SystemRoot%\RCWM /R /D Y 1>nul
icacls %SystemRoot%\RCWM /grant administrators:F /T /C 1>nul
icacls %SystemRoot%\RCWM /grant users:F /T /C 1>nul

echo Copied all files.
echo Pre-setup complete.
goto start


:update

md %SystemRoot%\System32\RCWM\rc 2>nul
md %SystemRoot%\System32\RCWM\mv 2>nul
md %SystemRoot%\RCWM 2>nul
xcopy /f *.bat %SystemRoot%\System32\RCWM /y 1>nul
xcopy /f *.ps1 %SystemRoot%\System32\RCWM /y 1>nul
xcopy /f *.lnk %SystemRoot%\System32\RCWM /y 1>nul
xcopy /f .\bin\*.exe %SystemRoot%\RCWM /y 1>nul
xcopy /f rcwmimg.dll %SystemRoot%\System32 /y 1>nul

rem if powershell version less than 5, overwrite some files with 'windows7' version
IF %pwsh% LSS 5 (
    xcopy /f .\Win7\* %SystemRoot%\System32\RCWM /y 1>nul
	xcopy /f .\Win7\*.reg . /y 1>nul
)

echo Copied new files.
echo Pre-setup complete.
goto start


:Add

echo(

color a
choice /C yn /M "* Do you want to add RoboCopy "
if %errorlevel% == 1 ( goto RCopy ) else ( goto MvDir )

color b
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

color b
choice /C yn /M "* Do you want to add open CMD to background/folders/drives "
if %errorlevel% == 1 ( start /w regedit /s CMD.reg )

color b
choice /C yn /M "* Do you want to add open CMD to (shift! + right click) "
if %errorlevel% == 1 ( start /w regedit /s CMDshift.reg )

color c
choice /C yn /M "* Do you want to add open PowerShell to background/folders/drives "
if %errorlevel% == 1 ( 

IF %pwsh% LSS 5 ( 
    IF "%PROCESSOR_ARCHITECTURE%" EQU "amd64" ( start /w regedit /s pwrshell32.reg ) else ( start /w regedit /s pwrshell64.reg )
) ELSE ( start /w regedit /s pwrshell.reg )
)

color a
choice /C yn /M "* Do you want to add God Mode "
if %errorlevel% == 1 ( start /w regedit /s GodMode.reg && md C:\windows\system32\RCWM\GodMode.{ED7BA470-8E54-465E-825C-99712043E01C} >NUL)

color a
choice /C yn /M "* Do you want to add Take Ownership to files and directories"
if %errorlevel% == 1 ( start /w regedit /s TakeOwn.reg )

color b
choice /C yn /M "* Do you want to add Take Ownership to drives (All but C:\ drive) "
if %errorlevel% == 1 ( start /w regedit /s TakeOwnDrive.reg )

color c
choice /C yn /M "* Do you want to add Run with Priority "
if %errorlevel% == 1 ( start /w regedit /s RunWithPriority.reg )

color a
choice /C yn /M "* Do you want to add Remove Directory (fastest option - but careful - using this will delete symlink contents, not symlinks!) "
if %errorlevel% == 1 ( start /w regedit /s RmDir.reg
) else (
if %errorlevel% == 2 ( choice /C yn /M "* Do you want to add Remove Directory without symlink content deletion (slower than the previous option) " )
if %errorlevel% == 1 ( start /w regedit /s RmDirS.reg )
)

color b
choice /C yn /M "* Do you want to add Control Panel "
if %errorlevel% == 1 ( start /w regedit /s ControlPanel.reg )

color c
choice /C yn /M "* Do you want to add symbolic/hard links "
if %errorlevel% == 1 ( start /w regedit /s Links.reg )

color a
choice /C yn /M "* Do you want to add Reboot to Recovery to 'This PC' "
if %errorlevel% == 1 ( start /w regedit /s RebootToRecovery.reg )

color a
choice /C yn /M "* Do you want to add Reboot to Recovery to Desktop "
if %errorlevel% == 1 ( start /w regedit /s RebootToRecoveryDesktop.reg )

color b
choice /C yn /M "* Do you want to add Safe Mode to 'This PC' "
if %errorlevel% == 1 ( start /w regedit /s SafeMode.reg )

choice /C yn /M "* Do you want to add Safe Mode to Desktop "
if %errorlevel% == 1 ( start /w regedit /s SafeModeDesktop.reg )

color c
choice /C yn /M "* Do you want to add Copy To Folder "
if %errorlevel% == 1 ( start /w regedit /s CopyToFolder.reg )

color a
choice /C yn /M "* Do you want to add Move To Folder "
if %errorlevel% == 1 ( start /w regedit /s MoveToFolder.reg )

color b
choice /C yn /M "* Do you want to add Sign Off to desktop background "
if %errorlevel% == 1 ( start /w regedit /s Logoff.reg )

echo(

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

color b
choice /C yn /M "* Do you want to delete Pin to Start "
if %errorlevel% == 1 ( start /w regedit /s DeletePinStartScreen.reg )

color c
choice /C yn /M "* Do you want to delete Send To "
if %errorlevel% == 1 ( start /w regedit /s DeleteSendTo.reg )

color a
choice /C yn /M "* Do you want to delete Include in Library "
if %errorlevel% == 1 ( start /w regedit /s DeleteLibrary.reg )

color b
choice /C yn /M "* Do you want to delete Add to Windows Media Player "
if %errorlevel% == 1 ( start /w regedit /s DeleteWinPlayer.reg )

color c
choice /C yn /M "* Do you want to delete Share "
if %errorlevel% == 1 ( start /w regedit /s DeleteShare.reg )

color a
choice /C yn /M "* Do you want to delete Previous Versions tab in explorer "
if %errorlevel% == 1 ( start /w regedit /s DeletePrevVersons.reg)

color b
choice /C yn /M "* Do you want to delete Scan with Windows Defender "
if %errorlevel% == 1 ( start /w regedit /s DeleteScanDefender.reg )


rem color b
rem choice /C yn /M "* Do you want to delete Print "

rem color a
rem choice /C yn /M "* Do you want to delete Cast to Device "

rem color b
rem choice /C yn /M "* Do you want to delete Give access to "

rem color b
rem choice /C yn /M "* Do you want to delete Restore previous versions "


:End

echo(
color a
choice /C yn /M "Do you want to add 'This PC' shortcut to Desktop "
if %errorlevel% == 1 ( start /w regedit /s ThisPC.reg ) 

echo(
color b
choice /C yn /M "Do you want to increase right-click menu item limit (default is 15) "
if %errorlevel% == 1 (

choice /C 123 /M "* Increase to 32[1], 64[2] or 128[3] "
if %errorlevel% == 1 ( start /w regedit /s MultipleInvokeMinimum.reg )
if %errorlevel% == 2 ( start /w regedit /s MultipleInvokeMinimum64.reg )
if %errorlevel% == 3 ( start /w regedit /s MultipleInvokeMinimum128.reg )
echo(
echo Right-click menu options will now appear for any number of selected files, but will only work correctly up until whatever number you selected!!
echo If you select more than that, only one folder will be actually selected. 
) else (
choice /C yn /M "Do you want to revert right-click menu item limit back to default (15) "
if %errorlevel% == 2 ( reg delete HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer /v MultipleInvokePromptMinimum /f >NUL)
)

echo(
color c
choice /C yn /M "Do you want to cmd.exe to always be opened as admin "
if %errorlevel% == 1 ( start /w regedit /s CMDadmin.reg ) 


echo(

color d
echo(
echo(
echo Finished!
echo(
echo You can delete all downloaded files now.
echo(
echo The batch files are located inside %SystemRoot%\System32\RCWM.
echo You can play with them if you want.
rem if you want to change batch files inside RCWM, give your users all necessary permissions.
echo(
timeout /t 1 > nul

pause
