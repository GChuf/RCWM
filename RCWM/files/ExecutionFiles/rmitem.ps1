[console]::InputEncoding = [text.utf8encoding]::UTF8
[system.console]::OutputEncoding = [System.Text.Encoding]::UTF8

$host.UI.RawUI.WindowTitle = "RCWM: Remove"
Write-host "RCWM v3.0.0"

Remove-Item $args[0] -Recurse
if (-not $?) {
    Start-Sleep -Seconds 3
} else {
    Write-Output "Finished!"
    Start-Sleep -Seconds 1
}