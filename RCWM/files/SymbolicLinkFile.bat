@echo off

rem 65000: UTF-7
rem 65001: UTF-8 does not work on Win7
chcp 65001 > nul

FOR /F "tokens=*" %%g IN ('powershell "((Get-ItemProperty HKCU:\RCWM\fl | out-string -stream) | ? {$_.trim() -ne \"\" }).length"') do (SET E=%%g)

IF %E% == 0 (
echo Source file not specified!
echo Right-Click on a file and select a Link Source.
timeout /t 3 > nul
exit
) ELSE (
goto start )

:start

wmic process where name="cmd.exe" CALL setpriority 128 2>nul 1>nul
wmic process where name="conhost.exe" CALL setpriority 128 2>nul 1>nul

set curdir=%cd%

FOR /F "tokens=*" %%g IN ('powershell "((Get-ItemProperty HKCU:\RCWM\fl | out-string -stream) | ? {$_.trim() -ne \"\" } | select -first 1) -replace \".{3}$\""') do (SET file=%%g)

IF NOT EXIST "%file%" (echo Link Source does not exist! && timeout /t 1 >nul && echo Exiting . . . && timeout /t 1 > nul && exit )

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
echo.
echo Creating symbolic link . . .
echo.
mklink "%curdir%\%f%" "%file%"
reg delete "HKCU\RCWM\fl" /f >NUL
reg add "HKCU\RCWM\fl" /f >NUL
echo Finished!
timeout /t 1 1>NUL
exit
