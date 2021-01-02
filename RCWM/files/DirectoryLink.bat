@echo off

IF EXIST C:\Windows\System32\RCWM\dl.log (
goto start
) ELSE (
echo Source folder not specified!
echo Right-Click on a directory and select a Link Source.
timeout /t 3 > nul
exit
)

:start
wmic process where name="cmd.exe" CALL setpriority 256 >nul
wmic process where name="conhost.exe" CALL setpriority 256 >nul
set curdir=%cd%
set /P folder=<C:\Windows\System32\RCWM\dl.log

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
IF EXIST "%fname%\NUL" (
echo Folder with the same name already exists!
echo Cannot continue!
) ELSE (
echo File with the same name already exists!
echo Cannot continue!
pause
exit
)

:f2
echo.
echo Creating link . . .
echo.

mklink /D "%curdir%\%fname%" "%folder%"

rem del /f /q C:\Windows\System32\RCWM\dl.log
echo Finished!
timeout /t 5 1>NUL
exit
