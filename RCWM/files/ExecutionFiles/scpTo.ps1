[console]::InputEncoding = [text.utf8encoding]::UTF8
[system.console]::OutputEncoding = [System.Text.Encoding]::UTF8

$host.UI.RawUI.WindowTitle = "RCWM: SCP to ..."
Write-host "RCWM v3.0.0"

$item = '"' + $args[0] + '"'

#read previous from reg

$user = Read-Host "Enter username"
$h0st = Read-Host "Enter destination IP or hostname"
$dest = Read-Host "Enter destination directory (default is /tmp)"

if ($dest -eq "") {$dest = "/tmp"}

$command = $user + "@" + $h0st + ":" + $dest
Write-Host "Executing scp -r $item $command"
scp -r $item $command
start-sleep 1