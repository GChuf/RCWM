@echo off

rem 65000: UTF-7
rem 65001: UTF-8 does not work on Win7
chcp 65001 > nul

FOR /F "tokens=*" %%g IN ('powershell "((Get-ItemProperty HKCU:\RCWM\rc | out-string -stream) | ? {$_.trim() -ne \"\" }).length"') do (SET E=%%g)

IF %E% == 0 (
echo Source folder not specified!
echo Right-Click and 'RoboCopy' a folder.
timeout /t 3 > nul
exit
) ELSE (
goto start )

:start

wmic process where name="cmd.exe" CALL setpriority 128 2>nul 1>nul
wmic process where name="conhost.exe" CALL setpriority 128 2>nul 1>nul

set curdir=%cd%

FOR /F "tokens=*" %%g IN ('powershell "((Get-ItemProperty HKCU:\RCWM\rc | out-string -stream) | ? {$_.trim() -ne \"\" } | select -first 1) -replace \".{3}$\""') do (SET folder=%%g)

IF NOT EXIST "%folder%" (echo Source folder does not exist: %folder% && timeout /t 1 >nul && echo Exiting . . . && timeout /t 2 > nul && exit )
cd /d %folder%
for %%I in (.) do set fname=%%~nxI
cd /d "%curdir%"

IF EXIST "%fname%" (
goto :f1
) ELSE (
goto :f2
)

:f1
IF EXIST "%fname%\" (
echo Folder with the same name already exists: %fname%
goto :choice
) ELSE (
echo File with the same name already exists!
echo Cannot continue!
pause
exit
)

:f2
echo.
echo Copying . . .
echo.
md "%fname%"
robocopy "%folder%" "%fname%" /E /NP /NJH /NJS /NC /NS /MT:16
reg delete "HKCU\RCWM\rc" /f >NUL
reg add "HKCU\RCWM\rc" /f >NUL
echo Finished!
timeout /t 1 1>NUL
exit

:choice
choice /C moc /M "Merge/Overwrite/Cancel?"
goto option%errorlevel%

:option1
echo.
echo Merging . . .
echo.
robocopy "%folder%" "%fname%" /E /NP /NJH /NJS /NC /NS /XC /XN /XO /MT:16
reg delete "HKCU\RCWM\rc" /f >NUL
reg add "HKCU\RCWM\rc" /f >NUL
exit

:option2
echo.
echo Overwriting . . .
echo.
robocopy "%folder%" "%fname%" /E /NP /NJH /NJS /NC /NS /MT:16
reg delete "HKCU\RCWM\rc" /f >NUL
reg add "HKCU\RCWM\rc" /f >NUL
exit

:option3
echo Exiting . . .
timeout /t 1 1>NUL
exit
