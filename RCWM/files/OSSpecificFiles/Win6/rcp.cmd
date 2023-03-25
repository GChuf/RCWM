@echo off
reg add HKCU\RCWM /v dir /t REG_MULTI_SZ /f /d %1 1>NUL
powershell.exe C:\Windows\RCWM\rcp.lnk %2 %3