cd $args[0]

$bytes = [System.IO.File]::ReadAllBytes(".\pwsh2\Win7.lnk")
[System.IO.File]::WriteAllBytes(".\Win7.lnk", $bytes)

$bytes = [System.IO.File]::ReadAllBytes(".\pwsh2\Win7NoBypass.lnk")
[System.IO.File]::WriteAllBytes(".\Win7NoBypass.lnk", $bytes)

$bytes = [System.IO.File]::ReadAllBytes(".\pwsh4\Win8.lnk")
[System.IO.File]::WriteAllBytes(".\in8.lnk", $bytes)

$bytes = [System.IO.File]::ReadAllBytes(".\pwsh4\Win8NoBypass.lnk")
[System.IO.File]::WriteAllBytes(".\pWin8NoBypass.lnk", $bytes)
