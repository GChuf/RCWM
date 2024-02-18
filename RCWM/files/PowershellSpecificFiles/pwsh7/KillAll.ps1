#get our own process' ID to filter it out
$id = [System.Diagnostics.Process]::GetCurrentProcess() | Select-Object -ExpandProperty ID
#killall
(gps | ? {$_.mainwindowtitle}).Id | Where-Object {($_ -ne $id)}  | foreach-object -parallel {taskkill /f /pid $_}
