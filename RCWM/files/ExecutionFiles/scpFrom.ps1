[console]::InputEncoding = [text.utf8encoding]::UTF8
[system.console]::OutputEncoding = [System.Text.Encoding]::UTF8

$host.UI.RawUI.WindowTitle = "RCWM: SCP from ..."

$path = $args[0]

# add trailing backslash for copying directly into drives
# (pass paths unquoted - powershell adds quotes when needed, manual quotes become literal in pwsh 7.3+)
if ($path.Length -eq 3 -and $path[2] -eq '"') {
	$path = $path.substring(0,2) + '\\'
}

$user = Read-Host "Enter username"
$h0st = Read-Host "Enter source IP or hostname"
$src = Read-Host "Enter source file/folder"

$command = $user + "@" + $h0st + ":" + $src
Write-Host "Executing scp -r $command `"$path`""
scp -r $command $path
start-sleep 1