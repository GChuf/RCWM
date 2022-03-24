Remove-ItemProperty -Path "HKCU:\RCWM\mv" -Name *
New-ItemProperty -Path "HKCU:\RCWM\mv" -Name "$args"