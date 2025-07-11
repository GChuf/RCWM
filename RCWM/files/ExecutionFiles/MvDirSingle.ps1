Remove-ItemProperty -Path "HKCU:\RCWM\rmove" -Name *
New-ItemProperty -Path "HKCU:\RCWM\rmove" -Name "$args"