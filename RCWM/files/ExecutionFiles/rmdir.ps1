Remove-Item $args[0] -Recurse
if (-not $?) {
    Start-Sleep -Seconds 3
} else {
    Write-Output "Finished!"
    Start-Sleep -Seconds 1
}