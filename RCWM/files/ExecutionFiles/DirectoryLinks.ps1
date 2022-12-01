Remove-ItemProperty -Path "HKCU:\RCWM\dl" -Name *
New-ItemProperty -Path "HKCU:\RCWM\dl" -Name "$args"