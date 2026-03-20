@echo off
title RCWM: Boot Into Safe Mode
bcdedit /set {current} safeboot minimal
shutdown.exe /r /t 0 /f