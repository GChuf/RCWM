Remove-ItemProperty -Path "HKCU:\RCWM\fl" -Name *
New-ItemProperty -Path "HKCU:\RCWM\fl" -Name "$args"