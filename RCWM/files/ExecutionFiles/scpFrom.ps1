$dest = '"' + $args[0] + '"'

$user = Read-Host "Enter username"
$h0st = Read-Host "Enter source IP or hostname"
$src = Read-Host "Enter source file"

$command = $user + "@" + $h0st + ":" + $src
scp $command $dest
start-sleep 1