Remove-ItemProperty -Path "HKCU:\RCWM\rc" -Name *
New-ItemProperty -Path "HKCU:\RCWM\rc" -Name "$args"