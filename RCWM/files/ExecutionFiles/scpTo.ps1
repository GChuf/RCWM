[console]::InputEncoding = [text.utf8encoding]::UTF8
[system.console]::OutputEncoding = [System.Text.Encoding]::UTF8

$host.UI.RawUI.WindowTitle = "RCWM: SCP to ..."

$item = '"' + $args[0] + '"'

#read previous from reg

$user = Read-Host "Enter username"
$h0st = Read-Host "Enter destination IP or hostname"
$dest = Read-Host "Enter destination directory (default is /tmp)"

if ($dest -eq "") {$dest = "/tmp"}

$command = $user + "@" + $h0st + ":" + $dest
Write-Host "Executing scp -r $item $command"
# scp writes its own error message to the console; keep the window open so it can be read
try {
	scp -r $item $command
	$scpFailed = $LASTEXITCODE -ne 0
	$scpError = "scp failed (exit code $LASTEXITCODE), see the error above."
} catch {
	$scpFailed = $true
	$scpError = $_.Exception.Message
}

if ($scpFailed) {
	Write-Host $scpError -ForegroundColor red
	Read-Host "Press Enter to exit" | Out-Null
} else {
	start-sleep 1
}