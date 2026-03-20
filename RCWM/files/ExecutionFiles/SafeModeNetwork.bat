@echo off
title RCWM: Boot Into Safe Mode with Network
bcdedit /set {current} safeboot network
shutdown.exe /r /t 0 /f