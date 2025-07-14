@echo off
title RCWM: Boot Into Normal Mode
echo RCWM v3.0.0
bcdedit /deletevalue {current} safeboot
shutdown /r /t 0 /f