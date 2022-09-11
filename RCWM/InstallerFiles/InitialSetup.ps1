$ps = $psversiontable.psversion.major
$arch = (Get-WmiObject win32_processor | Where-Object{$_.deviceID -eq "CPU0"}).AddressWidth

#check for v7 and overwrite if it exists
# adapted from https://devblogs.microsoft.com/scripting/use-a-powershell-function-to-see-if-a-command-exists/
$oldPreference = $ErrorActionPreference
$ErrorActionPreference = ‘stop’
try {if(Get-Command pwsh){$global:ps = (Get-Command pwsh).version.major}}
Catch {}
$ErrorActionPreference=$oldPreference


Write-Host "Using powershell version $ps on $arch bit CPU."

# Unblock ps1 files (not entirely necessary)
# Won't work on older powershell versions, so output error message to NUL
Unblock-File *.ps1 > NUL



#install/overwrite/update files