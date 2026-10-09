$host.UI.RawUI.WindowTitle = "RCWM: Kill All"
#get our own process' ID to filter it out
$id = [System.Diagnostics.Process]::GetCurrentProcess() | Select-Object -ExpandProperty ID
#killall
#get all processes with visible main window, except explorer
$ids = @((gps | ? {$_.mainwindowtitle -and $_.ProcessName -ne "explorer"}).Id | Where-Object {($_ -ne $id)})
if ($ids) { Stop-Process -Id $ids -Force }
