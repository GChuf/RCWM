reg add "HKEY_CURRENT_USER\SOFTWARE\RCWM" /f
reg add "HKEY_CURRENT_USER\SOFTWARE\RCWM\dlink" /f
reg add "HKEY_CURRENT_USER\SOFTWARE\RCWM\flink" /f
reg add "HKEY_CURRENT_USER\SOFTWARE\RCWM\miror" /f
reg add "HKEY_CURRENT_USER\SOFTWARE\RCWM\rcmov" /f
reg add "HKEY_CURRENT_USER\SOFTWARE\RCWM\rcopy" /f
reg add "HKEY_CURRENT_USER\SOFTWARE\RCWM\rstrc" /f

rem delete the script itself
del "%~f0"
