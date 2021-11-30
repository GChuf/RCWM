@echo off

rem 65000: UTF-7
rem 65001: UTF-8 does not work on Win7
chcp 65000 > nul

FOR /F "tokens=*" %%g IN ('powershell "(Get-Item -Path Registry::HKCU\RCWM\mv).Property.length"') do (SET E=%%g)

IF %E% == 0 (
echo Source folder not specified!
echo Right-Click and select 'Move Directory'.
timeout /t 3 > nul
exit
) ELSE (
goto start )

:start

wmic process where name="cmd.exe" CALL setpriority 128 2>nul 1>nul
wmic process where name="conhost.exe" CALL setpriority 128 2>nul 1>nul

set curdir=%cd%


FOR /F "tokens=*" %%g IN ('powershell "(Get-Item -Path Registry::HKCU\RCWM\mv).Property"') do (SET folder=%%g)

IF NOT EXIST "%folder%" (echo Source folder does not exist! && timeout /t 1 >nul && echo Exiting . . . && timeout /t 1 > nul && exit )
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
echo Folder with the same name already exists!
echo Cannot continue!
timeout /t 2 1>NUL
exit
) ELSE (
echo File with the same name already exists!
echo Cannot continue!
pause
exit
)

:f2
echo.
echo Moving . . .
echo.
md "%fname%"
robocopy "%folder%" "%fname%" /MOV /E /NP /NJH /NJS /NC /NS /MT:16
rd /s /q "%folder%"
reg delete "HKCU\RCWM\mv" /f >NUL
reg add "HKCU\RCWM\mv" /f >NUL
echo Finished!
timeout /t 1 1>NUL
exit
