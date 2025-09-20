[console]::InputEncoding = [text.utf8encoding]::UTF8
[system.console]::OutputEncoding = [System.Text.Encoding]::UTF8

$host.UI.RawUI.WindowTitle = "RCWM: SCP"
Write-host "RCWM v3.0.0"

$item = '"' + $args[0] + '"'

$user = Read-Host "Enter username"
$h0st = Read-Host "Enter destination IP or hostname"
$dest = Read-Host "Enter destination directory"

$command = $user + "@" + $h0st + ":" + $dest
scp $item $command
start-sleep 1