Remove-ItemProperty -Path "HKCU:\RCWM\rcopy" -Name *
New-ItemProperty -Path "HKCU:\RCWM\rcopy" -Name "$args"