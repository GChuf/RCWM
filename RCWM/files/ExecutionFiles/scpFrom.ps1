[console]::InputEncoding = [text.utf8encoding]::UTF8
[system.console]::OutputEncoding = [System.Text.Encoding]::UTF8

$host.UI.RawUI.WindowTitle = "RCWM: SCP from ..."

$path = $args[0]

# add trailing backslash for copying directly into drives
if ($path.Length -eq 3 -and $path[2] -eq '"') {
	$path = $path.substring(0,2)
	$dest = '"' + $path + '\"'
    $path += '\\'
} else {
	$path = '"' + $path + '"'
	$dest = $path
}



$user = Read-Host "Enter username"
$h0st = Read-Host "Enter source IP or hostname"
$src = Read-Host "Enter source file/folder"

$command = $user + "@" + $h0st + ":" + $src
Write-Host "Executing scp -r $command $dest"
scp -r $command $path
start-sleep 1