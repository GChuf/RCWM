cd $args[0]

$bytes = [System.IO.File]::ReadAllBytes(".\pwsh2\pwsh7.lnk")
[System.IO.File]::WriteAllBytes(".\pwsh8.lnk", $bytes)

$bytes = [System.IO.File]::ReadAllBytes(".\pwsh2\pwsh7NoBypass.lnk")
[System.IO.File]::WriteAllBytes(".\pwsh8.lnk", $bytes)

$bytes = [System.IO.File]::ReadAllBytes(".\pwsh2\pwsh8.lnk")
[System.IO.File]::WriteAllBytes(".\pwsh8.lnk", $bytes)

$bytes = [System.IO.File]::ReadAllBytes(".\pwsh2\pwsh8NoBypass.lnk")
[System.IO.File]::WriteAllBytes(".\pwsh8.lnk", $bytes)
