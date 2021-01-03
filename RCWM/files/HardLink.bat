@echo off

IF EXIST C:\Windows\System32\RCWM\fl.log (
goto start
) ELSE (
echo Source file not specified!
echo Right-Click on a directory and select a Link Source.
timeout /t 3 > nul
exit
)

:start
wmic process where name="cmd.exe" CALL setpriority 256 >nul
wmic process where name="conhost.exe" CALL setpriority 256 >nul
set curdir=%cd%
set /P folder=<C:\Windows\System32\RCWM\fl.log

IF NOT EXIST "%folder%" (echo Link Source does not exist! && timeout /t 1 >nul && echo Exiting . . . && timeout /t 1 > nul && exit)

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
pause
exit
)

:f2
echo.
echo Creating hard link . . .
echo.

mklink /H "%curdir%\%fname%" "%folder%"

del /f /q C:\Windows\System32\RCWM\fl.log
echo Finished!
timeout /t 1 1>NUL
exit
