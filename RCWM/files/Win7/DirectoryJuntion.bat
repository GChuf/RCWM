@echo off

rem 65000: UTF-7
rem 65001: UTF-8 does not work on Win7
chcp 65000 > nul

FOR /F "tokens=*" %%g IN ('powershell "(Get-Item -Path Registry::HKCU\RCWM\dl).Property.length"') do (SET E=%%g)

IF "%E%" == 0 (
echo Source folder not specified!
echo Right-Click on a directory and select a Link Source.
timeout /t 3 > nul
exit
) ELSE (
goto start )

:start

set curdir=%cd%

FOR /F "tokens=*" %%g IN ('powershell "(Get-Item -Path Registry::HKCU\RCWM\dl).Property"') do (SET folder=%%g)

IF NOT EXIST "%folder%" (echo Link Source does not exist! && timeout /t 1 >nul && echo Exiting . . . && timeout /t 1 > nul && exit )

cd /d "%folder%"
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
timeout /t 4
exit
) ELSE (
echo File with the same name already exists!
echo Cannot continue!
timeout /t 4
exit

)

:f2
echo.
echo Creating directory juntion . . .
echo.

mklink /J "%curdir%\%fname%" "%folder%"

reg delete "HKCU\RCWM\dl" /f >NUL
reg add "HKCU\RCWM\dl" /f >NUL
echo Finished!
timeout /t 1 1>NUL
exit
