[console]::InputEncoding = [text.utf8encoding]::UTF8
[console]::OutputEncoding = [System.Text.Encoding]::UTF8
Remove-ItemProperty -Path "HKCU:\RCWM\mv" -Name *
New-ItemProperty -Path "HKCU:\RCWM\mv" -Name "$args"