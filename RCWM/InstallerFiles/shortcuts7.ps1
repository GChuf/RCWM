$bytes = [System.IO.File]::ReadAllBytes(".\OSSpecificFiles\Win6\Win7.lnk")
[System.IO.File]::WriteAllBytes(".\Temp\Win7.lnk", $bytes)
$bytes = [System.IO.File]::ReadAllBytes(".\OSSpecificFiles\Win6\Win7NoBypass.lnk")
[System.IO.File]::WriteAllBytes(".\Temp\Win7NoBypass.lnk", $bytes)
Write-Host "Generated shortcuts."