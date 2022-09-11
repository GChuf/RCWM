echo off
title Boot Into Safe Mode with Command Prompt
bcdedit /set {current} safeboot minimal
bcdedit /set {current} safebootalternateshell yes
shutdown /r /t 0 /f