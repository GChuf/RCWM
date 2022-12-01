echo off
title Boot Into Safe Mode with Network
bcdedit /set {current} safeboot network
shutdown /r /t 0 /f