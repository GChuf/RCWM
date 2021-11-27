@echo off

rem utf-8: https://docs.microsoft.com/en-us/windows/win32/intl/code-page-identifiers
chcp 65001 >NUL

IF EXIST C:\Windows\System32\RCWM\mv.log (
goto start
) ELSE (
echo Source folder not specified!
echo Right-Click and select 'Move Directory'.
timeout /t 3 > nul
exit
)

:start
wmic process where name="cmd.exe" CALL setpriority 256 >nul
wmic process where name="conhost.exe" CALL setpriority 256 >nul
set curdir=%cd%
set /P folder=<C:\Windows\System32\RCWM\mv.log

IF NOT EXIST %folder% (echo Source folder does not exist! && timeout /t 1 >nul && echo Exiting . . . && timeout /t 1 > nul && exit)

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
timeout /t 2 1>NUL
exit
)

:f2
echo.
echo Moving . . .
echo.
md "%fname%"
robocopy %folder% "%fname%" /MOV /E /NP /NJH /NJS /NC /NS /MT:16
rd /s /q %folder%
del /f /q C:\Windows\System32\RCWM\mv.log
echo Finished!
timeout /t 1 1>NUL
exit
