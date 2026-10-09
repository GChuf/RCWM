@echo off
title RCWM: Boot Into Normal Mode
bcdedit /deletevalue {current} safeboot
rem set by SafeModeCMD.bat - would otherwise turn the next plain Safe Mode boot into Safe Mode with Command Prompt
bcdedit /deletevalue {current} safebootalternateshell >nul 2>&1
shutdown.exe /r /t 0 /f