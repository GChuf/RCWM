$host.UI.RawUI.WindowTitle = "RCWM: Remove"

Remove-Item $args[0] -Recurse -Force
if (-not $?) {
    Start-Sleep -Seconds 3
} else {
    Write-Output "Finished!"
    Start-Sleep -Seconds 1
}