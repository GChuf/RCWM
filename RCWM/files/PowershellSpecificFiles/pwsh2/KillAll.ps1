$host.UI.RawUI.WindowTitle = "RCWM: Kill All"
#get our own process' ID to filter it out
$id = [System.Diagnostics.Process]::GetCurrentProcess() | Select-Object -ExpandProperty ID

#filter out explorer ID as well
$explorerPID = (Get-Process | Where-Object { $_.ProcessName -eq "explorer" }).ID

#killall
#get all processes with visible main window

$ids = @(Get-Process | Where-Object { $_.MainWindowHandle -ne [IntPtr]::Zero } | Select-Object -ExpandProperty Id | Where-Object {($_ -ne $id -and $explorerPID -notcontains $_)})
if ($ids) { Stop-Process -Id $ids -Force }
