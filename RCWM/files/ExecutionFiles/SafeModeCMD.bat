@echo off
title RCWM: Boot Into Safe Mode with Command Prompt
echo RCWM v3.0.0
bcdedit /set {current} safeboot minimal
bcdedit /set {current} safebootalternateshell yes
shutdown.exe /r /t 0 /f