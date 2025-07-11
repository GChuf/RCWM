@echo off
reg add HKCU\SOFTWARE\RCWM /v dir /t REG_MULTI_SZ /f /d %1 1>NUL
powershell.exe C:\Program Files (x86)\RCWM\rcopy.lnk %2 %3