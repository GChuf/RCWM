@echo off
FOR /F "tokens=*" %%g IN ('powershell "((Get-ItemProperty HKCU:\rc | out-string -stream) | ? {$_.trim() -ne \"\" }).length"') do (SET E=%%g)

IF %E% == 0 (
echo Source folder not specified!
echo Right-Click and 'RoboCopy' a folder.
timeout /t 3 > nul

exit
) ELSE (
goto start )

:start

rem wmic process where name="cmd.exe" CALL setpriority 256 1>NUL
rem wmic process where name="conhost.exe" CALL setpriority 256 1>NUL

set curdir=%cd%


FOR /F "tokens=*" %%g IN ('powershell "((Get-ItemProperty HKCU:\rc | out-string -stream) | ? {$_.trim() -ne \"\" } | select -first 1) -replace \".{3}$\""') do (SET folder=%%g)

IF NOT EXIST "%folder%" (echo Source folder does not exist! %folder% && timeout /t 1 >nul && echo Exiting . . . && timeout /t 1 > nul && exit)
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
echo Folder with the same name already exists {"%fname%"}!
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
reg delete "HKCU\rc" /f >NUL
reg add "HKCU\rc" /f >NUL
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
reg delete "HKCU\rc" /f >NUL
reg add "HKCU\rc" /f >NUL
exit

:option2
echo.
echo Overwriting . . .
echo.
robocopy "%folder%" "%fname%" /E /NP /NJH /NJS /NC /NS /MT:16
reg delete "HKCU\rc" /f >NUL
reg add "HKCU\rc" /f >NUL
exit

:option3
echo Exiting . . .
timeout /t 1 1>NUL
exit
