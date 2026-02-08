$host.UI.RawUI.WindowTitle = "RCWM: Kill All"
#get our own process' ID to filter it out
$id = [System.Diagnostics.Process]::GetCurrentProcess() | Select-Object -ExpandProperty ID

#filter out explorer ID as well
$explorerPID = (Get-Process | Where-Object { $_.ProcessName -eq "explorer" }).ID

#killall
#get all processes with visible main window

Get-Process | Where-Object { $_.MainWindowHandle -ne [IntPtr]::Zero } | Select-Object -ExpandProperty Id | Where-Object {($_ -ne $id -and $_ -ne $explorerPID )} | foreach-object -process {taskkill /f /pid $_}
