[console]::InputEncoding = [text.utf8encoding]::UTF8
[system.console]::OutputEncoding = [System.Text.Encoding]::UTF8

$host.UI.RawUI.WindowTitle = "RCWM: SCP"
Write-host "RCWM v3.0.0"

$dest = '"' + $args[0] + '"'

$user = Read-Host "Enter username"
$h0st = Read-Host "Enter source IP or hostname"
$src = Read-Host "Enter source file"

$command = $user + "@" + $h0st + ":" + $src
scp $command $dest
start-sleep 1