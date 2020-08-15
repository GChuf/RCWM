@echo off
title RCWM: RoboCopy
color 02
SETLOCAL EnableDelayedExpansion

IF EXIST C:\Windows\System32\RCWM\rc.log (
goto start
) ELSE (
mode con:cols=65 lines=9
echo Source folder not specified!
echo Right-Click on a folder and select 'RoboCopy Directory'.
timeout /t 3 >nul
exit
)

:start

wmic process where name="cmd.exe" CALL setpriority 256 >nul
wmic process where name="conhost.exe" CALL setpriority 256 >nul

rem get path into which I will copy folders/files
set basedir=%cd%

rem loop
for /f "delims=" %%a in (C:\Windows\System32\RCWM\rc.log) do (


rem set path which is to be copied and cd into it to get folder name
set path=%%a
cd /D "!path!"

rem get folder name
for %%I in (.) do set folder=%%~nxI


echo Merging . . .
echo(


IF EXIST "%basedir%"\"!folder!" ( echo Folder with name !folder! already exists, cannot move! ) else ( cd /d "%basedir%" && md "!folder!" && robocopy "!path!" .\"!folder!" /E /NFL /NJH /NJS /NC /NS /MT:16)
rem /E for all subdirectories (also Empty ones)

)

del /f /q C:\Windows\System32\RCWM\move.log
exit