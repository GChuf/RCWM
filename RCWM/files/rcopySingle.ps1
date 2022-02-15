Remove-ItemProperty -Path "HKCU:\RCWM\rc" -Name * | Out-Null
New-ItemProperty -Path "HKCU:\RCWM\rc" -Name "$args" | out-null