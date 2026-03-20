@echo off
title RCWM: Boot Into Normal Mode
bcdedit /deletevalue {current} safeboot
shutdown.exe /r /t 0 /f