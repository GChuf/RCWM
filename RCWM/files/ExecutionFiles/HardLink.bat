@echo off

rem 65000: UTF-7
rem 65001: UTF-8 does not work on Win7
chcp 65001 > nul

FOR /F "tokens=*" %%g IN ('powershell "$a='(default)'; if ( (Get-Item -Path Registry::HKCU\RCWM\fl).property -eq $a) { echo 0 } else { echo (Get-Item -Path Registry::HKCU\RCWM\fl).property }"') do (SET file=%%g)

IF "%file%" == 0 (
echo Source file not specified!
echo Right-Click on a file and select a Link Source.
timeout /t 3 > nul
exit
) ELSE (
goto start )

:start

set curdir=%cd%

IF NOT EXIST "%file%" (echo Link Source does not exist: %file% && timeout /t 1 >nul && echo Exiting . . . && timeout /t 1 > nul && exit )

for %%F in ("%file%") do set f=%%~nxF

IF EXIST "%f%" (
goto :f1
) ELSE (
goto :f2
)

:f1
IF EXIST "%f%\" (
echo Folder with the same name already exists: %f%
echo Cannot continue!
timeout /t 3
exit
) ELSE (
echo File with the same name already exists: %f%
echo Cannot continue!
timeout /t 3
exit
)

:f2

IF %curdir:~0,1% == %file:~0,1% (

echo.
echo Creating hard link . . .
echo.
mklink /H "%curdir%\%f%" "%file%"
reg delete "HKCU\RCWM\fl" /f >NUL
reg add "HKCU\RCWM\fl" /f >NUL
echo Finished!
timeout /t 1 1>NUL
exit

) ELSE (

echo Cannot make hard link on separate drives!
echo Exiting . . .
timeout /t 1 1>NUL
exit
)