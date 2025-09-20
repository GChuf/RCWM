$item = '"' + $args[0] + '"'

$user = Read-Host "Enter username"
$h0st = Read-Host "Enter destination IP or hostname"
$dest = Read-Host "Enter destination directory"

$command = $user + "@" + $h0st + ":" + $dest
scp $item $command
start-sleep 1