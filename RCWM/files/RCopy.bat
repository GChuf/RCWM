@echo off

IF EXIST C:\Windows\System32\RCWM\rc.log (
goto start
) ELSE (
echo Source folder not specified!
echo Right-Click and 'RoboCopy' a folder.
timeout /t 3 > nul
exit
)

:start
wmic process where name="cmd.exe" CALL setpriority 256 >nul
wmic process where name="conhost.exe" CALL setpriority 256 >nul
set curdir=%cd%
set /P folder=<C:\Windows\System32\RCWM\rc.log
cd %folder%
for %%I in (.) do set fname=%%~nxI
cd "%curdir%"

IF EXIST %fname% (
goto :f1
) ELSE (
goto :f2
)

:f1
IF EXIST %fname%\NUL (
echo Folder with the same name already exists!
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
cd "%fname%"
robocopy %folder% . /E /NP /NJH /NJS /NC /NS /NP /MT:16
del /f /q C:\Windows\System32\RCWM\rc.log
exit

:choice
choice /C yn /M "Merge folders"
goto option%errorlevel%

:option1
echo.
echo Merging . . .
echo.
cd "%fname%"
robocopy %folder% . /E /NP /NJH /NJS /NC /NS /NP /MT:16
del /f /q C:\Windows\System32\RCWM\rc.log
exit

:option2
echo Exiting . . .
timeout /t 1 1>NUL
exit
