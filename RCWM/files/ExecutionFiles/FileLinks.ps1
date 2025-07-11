Remove-ItemProperty -Path "HKCU:\RCWM\flink" -Name *
New-ItemProperty -Path "HKCU:\RCWM\flink" -Name "$args"