
$bytes = [System.IO.File]::ReadAllBytes(".\PowershellSpecificFiles\pwsh2\Win7.lnk")
[System.IO.File]::WriteAllBytes(".\Temp\Win7.lnk", $bytes)

$bytes = [System.IO.File]::ReadAllBytes(".\PowershellSpecificFiles\pwsh2\Win7NoBypass.lnk")
[System.IO.File]::WriteAllBytes(".\Temp\Win7NoBypass.lnk", $bytes)

$bytes = [System.IO.File]::ReadAllBytes(".\PowershellSpecificFiles\pwsh4\Win8.lnk")
[System.IO.File]::WriteAllBytes(".\Temp\Win8.lnk", $bytes)

$bytes = [System.IO.File]::ReadAllBytes(".\PowershellSpecificFiles\pwsh4\Win8NoBypass.lnk")
[System.IO.File]::WriteAllBytes(".\Temp\Win8NoBypass.lnk", $bytes)

Write-Host "Generated shortcuts."