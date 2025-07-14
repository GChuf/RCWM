@echo off
title RCWM: Boot Into Safe Mode with Network
echo RCWM v3.0.0
bcdedit /set {current} safeboot network
shutdown /r /t 0 /f