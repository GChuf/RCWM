@echo off
reg add "HKEY_CURRENT_USER\SOFTWARE\RCWM" /f >nul 2>&1
reg add "HKEY_CURRENT_USER\SOFTWARE\RCWM\dlink" /f >nul 2>&1
reg add "HKEY_CURRENT_USER\SOFTWARE\RCWM\flink" /f >nul 2>&1
reg add "HKEY_CURRENT_USER\SOFTWARE\RCWM\miror" /f >nul 2>&1
reg add "HKEY_CURRENT_USER\SOFTWARE\RCWM\rcmov" /f >nul 2>&1
reg add "HKEY_CURRENT_USER\SOFTWARE\RCWM\rcopy" /f >nul 2>&1
reg add "HKEY_CURRENT_USER\SOFTWARE\RCWM\rstrc" /f >nul 2>&1
