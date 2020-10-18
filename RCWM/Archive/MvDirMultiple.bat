@echo off
title RCWM: RoboCopy
color 02
SETLOCAL EnableDelayedExpansion

IF NOT EXIST C:\Windows\System32\RCWM\mv.log (
mode con:cols=65 lines=9
echo Source folder not specified!
echo Right-Click on a folder and select 'Move Directory'.
timeout /t 3 >nul
exit
)

:start

wmic process where name="cmd.exe" CALL setpriority 256 >nul
wmic process where name="conhost.exe" CALL setpriority 256 >nul

rem get path into which I will copy folders/files
set basedir=%cd%

rem loop
for /f "delims=" %%a in (C:\Windows\System32\RCWM\mv.log) do (


rem set path which is to be copied and cd into it to get folder name
set path=%%a
cd /D "!path!"

rem get folder name
for %%I in (.) do set folder=%%~nxI

echo(
echo Moving !path! into %basedir%\!folder! ...

IF EXIST "%basedir%"\"!folder!" ( echo Folder with name !folder! already exists, cannot move! && C:\Windows\System32\timeout /t 3 >nul
) else (
rem /NFL for no file names
rem /NP for no progress
rem /NJS no job summary
rem /NJH no job header
rem NC no class NS no size
cd /d "%basedir%" && md "!folder!" && C:\Windows\System32\robocopy.exe /move !path! "!folder!" /E /NP /NJH /NJS /NC /NS /NP /MT:16 )
rem /E for all subdirectories (also Empty ones)
)

del /f /q C:\Windows\System32\RCWM\mv.log
exit