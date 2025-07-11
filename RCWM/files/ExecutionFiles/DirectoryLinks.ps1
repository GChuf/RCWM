Remove-ItemProperty -Path "HKCU:\RCWM\dlink" -Name *
New-ItemProperty -Path "HKCU:\RCWM\dlink" -Name "$args"