echo off
title Boot Into Normal Mode
bcdedit /deletevalue {current} safeboot
shutdown /r /t 0 /f