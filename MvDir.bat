@echo off
title RCWM: Move Directory
color 03
SETLOCAL EnableDelayedExpansion

IF EXIST C:\Windows\System32\RCWM\move.log (
goto start
) ELSE (
mode con:cols=65 lines=9
echo Source folder not specified!
echo Right-Click on a folder and select 'Move Directory'.
timeout /t 3 >nul
exit
)

:start

wmic process where name="cmd.exe" CALL setpriority 256 >nul
wmic process where name="conhost.exe" CALL setpriority 256 >nul

rem get folder name into which I will copy folders/files
set basedir=%cd%

rem loop
for /f "delims=" %%a in (C:\Windows\System32\RCWM\move.log) do (


rem set path which is to be copied and cd into it to get folder name
set path=%%a
cd /D "!path!"

rem get folder name
for %%I in (.) do set folder=%%~nxI


echo Merging . . .
echo(


IF EXIST "%basedir%"\"!folder!" ( echo Folder with name !folder! already exists, cannot move! ) else ( cd /d %basedir% && md "!folder!" && robocopy /move !path! .\"!folder!" /E /NFL /NJH /NJS /NC /NS /MT:16)
rem /E for all subdirectories (also Empty ones)

)

del /f /q C:\Windows\System32\RCWM\move.log
exit



rem - if directory to be copied doesnt exist, is it known what happend?
rem I mean - dir is in the log file, but actual directory isnt there any more.
rem need another  check.