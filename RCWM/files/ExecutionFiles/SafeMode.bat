echo off
title Boot Into Safe Mode
bcdedit /set {current} safeboot minimal
shutdown /r /t 0 /f