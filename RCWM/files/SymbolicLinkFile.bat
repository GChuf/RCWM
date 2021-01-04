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
echo 1
wmic process where name="cmd.exe" CALL setpriority 256 >nul
wmic process where name="conhost.exe" CALL setpriority 256 >nul
set curdir=%cd%
set /P file=<C:\Windows\System32\RCWM\fl.log
IF NOT EXIST "%file%" (echo Link Source does not exist! && timeout /t 1 >nul && echo Exiting . . . && timeout /t 1 > nul && exit)

for %%F in ("%file%") do set f=%%~nxF

IF EXIST "%f%" (
goto :f1
) ELSE (
goto :f2
)
:f1
IF EXIST "%f%\" (
echo Folder with the same name already exists!
echo Cannot continue!
timeout /t 3
exit
) ELSE (
echo File with the same name already exists!
echo Cannot continue!
timeout /t 3
exit

)

:f2
echo.
echo Creating symbolic link . . .
echo.
mklink "%curdir%\%f%" "%file%"
del /f /q C:\Windows\System32\RCWM\fl.log
echo Finished!
timeout /t 1 1>NUL
exit
