New-ItemProperty -Path "HKCU:\rc" -Name $args[0] -Value ""

#batch: reg add "HKCU\rc" /v %1 /t REG_SZ
#cmd.exe reg add "HKCU\rc" /v "%V" /t REG_SZ
