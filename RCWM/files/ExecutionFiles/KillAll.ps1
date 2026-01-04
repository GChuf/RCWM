$host.UI.RawUI.WindowTitle = "RCWM: Kill All"
Write-host "RCWM v3.0.0"
#get our own process' ID to filter it out
$id = [System.Diagnostics.Process]::GetCurrentProcess() | Select-Object -ExpandProperty ID
#killall
#get all processes with visible main window
(gps | ? {$_.mainwindowtitle}).Id | Where-Object {($_ -ne $id)}  | foreach-object -process {taskkill /f /pid $_}
