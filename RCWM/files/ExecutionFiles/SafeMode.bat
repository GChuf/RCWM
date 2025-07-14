@echo off
title RCWM: Boot Into Safe Mode
echo RCWM v3.0.0
bcdedit /set {current} safeboot minimal
shutdown /r /t 0 /f