if (-not (New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
# Prompt the user to elevate the script
$arguments = "& '" + $myInvocation.MyCommand.Definition + "'"
Start-Process powershell -Verb runAs -ArgumentList $arguments
exit
}

Write-Host "Initialising setup ..."

$sysdrive = ($env:SystemRoot).Substring(0, 3)
$sysroot = (cmd.exe /c echo %SystemRoot%).Trim()
$sys32 = Join-Path $sysroot "System32"
$rcwmroot = Join-Path $sysdrive 'Program Files\RCWM'
$existingFolder = Test-Path -Path $rcwmroot
$RCWMv1Folder = Test-Path -Path "$sysroot\System32\RCWM"
$RCWMv2Folder = Test-Path -Path "$sysroot\RCWM"

$ps = $psversiontable.psversion.major
$arch = cmd.exe /c echo "%PROCESSOR_ARCHITECTURE%"
$os = [System.Environment]::OSVersion.Version.Major
#if major==6, minor==1 => windows 2008
#2008 needs different icons
#minor 3 == 2012 R2

#win7 and win8 virtual machines both return "6"
#new win servers(!) return "10"

$pwsh7Version = (get-command pwsh).Version.Major 2>$null
$pwsh7CommandType = (get-command pwsh).CommandType 2>$null #fix for bugged pwsh7 version outputs in old windows

if ($pwsh7Version -eq 7 -or $pwsh7CommandType -eq "Application") {
	Write-Host "Powershell 7 detected along with Powershell $ps."
	while ($true) {
		$pwsh7 = Read-Host "Would you like to use Powershell 7 where applicable? (Y/N)"
		if ($pwsh7 -eq "Y") {$ps = 7; break}
		elseif ($pwsh7 -eq "N") {break}
		else {echo "Invalid input!"}
	}
}

Write-Host "Using Powershell version $ps on $arch architecture."


#Make sure Temp is clean.
cmd.exe /c del .\Temp\* /s /q 2>&1>$null
cmd.exe /c rd /s /q .\Temp /s /q 2>&1>$null
New-Item Temp -ItemType "directory" 2>&1>$null

#Copy reg files into temp,
Copy-Item -Path "RegistryFiles\*.reg" -Destination ".\Temp" | Out-Null


#copy execution files and icons
Copy-Item -Path "ExecutionFiles\*" -Destination ".\Temp" | Out-Null
Copy-Item -Path "Icons\*" -Destination ".\Temp" | Out-Null

xcopy Icons\rcwmimg.dll $sys32 /y | Out-Null

#Overwrite default files with specific files - if they exist/if applicable

Copy-Item -Path "OSSpecificFiles\Win$os\*" -Destination ".\Temp" -erroraction 'silentlycontinue'
#if powershell 7 on old windows, overwrite old windows files
Copy-Item -Path "PowershellSpecificFiles\pwsh$ps\*" -Destination ".\Temp" 2> $null

#generate os-specific files
#this is only needed so that OS doesn't prompt the user to run the shortcut
if ($os -eq 6) {
	Write-Host "Generating shortcuts ..."
	..\InstallerFiles\shortcuts6.ps1 
}

#rcp script
#"minify" - take out tabs
(Get-Content .\Temp\rcp.ps1) -replace "`t", "" | Set-Content .\Temp\rcp.ps1


#win11 - enable old context menu
$winver = ([Environment]::OSVersion).Version.Major

if ($winver -eq 11) {
	
	while ($true) {
		$mode1 = Read-Host "Enable old context menu in Windows 11 (Y/N)"
		if ($mode1 -eq "Y") {break}
		elseif ($mode1 -eq "N") {break}
		else {echo "Invalid input!"}
	}

	if ($mode1 -eq "Y") { #todo check location
	    cmd.exe /c start /w regedit /s Win11AddOldContextMenu.reg
		Write-Host "Restarting explorer.exe ..."
		Stop-Process -Name explorer -Force
		Start-Process explorer.exe
		Write-Host "Restarted."
	}
} elseif ($winver -eq 10) {
	#edge case - some win11 still return major version 10
	#check build number instead
	$version = (Get-CimInstance Win32_OperatingSystem).Version
	$build = [int]($version.Split('.')[2])
	if ($build -ge 22000) {
		#it's windows 11
		while ($true) {
			$mode1 = Read-Host "Enable old context menu in Windows 11 (Y/N)"
			if ($mode1 -eq "Y") {break}
			elseif ($mode1 -eq "N") {break}
			else {echo "Invalid input!"}
		}

		if ($mode1 -eq "Y") { #todo check location
			cmd.exe /c start /w regedit /s Win11AddOldContextMenu.reg
			Write-Host "Restarting explorer.exe ..."
			Stop-Process -Name explorer -Force
			Start-Process explorer.exe
			Write-Host "Restarted."
		}
	}

}


#copy only: executionFiles and Icons for now

function recreateFiles() {
	$sysdrive = ($env:SystemRoot).Substring(0, 3)
	$rcwmroot = Join-Path $sysdrive 'Program Files\RCWM'
	cmd.exe /c del /f /q $rcwmroot | Out-Null
	cmd.exe /c rd /s /q $rcwmroot | Out-Null
	cmd.exe /c md $rcwmroot | Out-Null

	#copy binaries, shortcuts, icons, .bat and .ps1 files into RCWM folder
	Copy-Item -Path "Temp\*" -Destination $rcwmroot

	#take ownership of that folder for administrators & users
	cmd.exe /c takeown /F $rcwmroot /R /D Y | Out-Null
	cmd.exe /c icacls $rcwmroot /grant administrators:F /T /C | Out-Null
	cmd.exe /c icacls $rcwmroot /grant users:F /T /C | Out-Null

	#Files copied.
	
	echo "Recreated RCWM directory"
}

function mergeFiles() {
	$sysdrive = ($env:SystemRoot).Substring(0, 3)
	$rcwmroot = Join-Path $sysdrive 'Program Files\RCWM'
	robocopy .\Temp\* $rcwmroot /XC /XN /XO | Out-Null

	echo "New files copied"
}


function installRCWM() {
	$sysdrive = ($env:SystemRoot).Substring(0, 3)
	$rcwmroot = Join-Path $sysdrive 'Program Files\RCWM'
	cmd.exe /c md $rcwmroot

	#copy binaries, shortcuts, icons, .bat and .ps1 files into RCWM folder
	Copy-Item -Path "Temp\*" -Destination $rcwmroot

	#take ownership of that folder for administrators & users
	cmd.exe /c takeown /F $rcwmroot /R /D Y | Out-Null
	cmd.exe /c icacls $rcwmroot /grant administrators:F /T /C | Out-Null
	cmd.exe /c icacls $rcwmroot /grant users:F /T /C | Out-Null

	#add exclusion - just in case
	Add-MpPreference -ExclusionPath "$rcwmroot" | Out-Null
	echo "Created directory at $rcwmroot and copied all files."
}



if ($RCWMv1Folder -eq $true) {
	write-host "Old RCWM v1.x folder detected."
	while ($true) {
		$mode1 = Read-Host "Delete old files and uninstall now (recommended) (Y/N)"
		if ($mode1 -eq "y") {break}
		elseif ($mode1 -eq "n") {break}
		else {echo "Invalid input!"}
	}
	
	if ($mode1 -eq "Y") {
		cmd.exe /c del /f /q %SystemRoot%\System32\RCWM | Out-Null
		cmd.exe /c rd /s /q %SystemRoot%\System32\RCWM | Out-Null
		reg delete HKCU\RCWM /F | Out-Null
		write-host "Old files deleted."

		$uninstallers = get-childitem ..\UninstallerFiles\RegistryFiles\*.reg
		foreach ($reg in $uninstallers) { cmd.exe /c regedit /s $reg }
		write-host "Registry cleaned."
	}
	
}

if ($RCWMv2Folder -eq $true) {
	write-host "Old RCWM v2.x folder detected."
	while ($true) {
		$mode1 = Read-Host "Delete old files and uninstall now (recommended) (Y/N)"
		if ($mode1 -eq "y") {break}
		elseif ($mode1 -eq "n") {break}
		else {echo "Invalid input!"}
	}
	
	if ($mode1 -eq "Y") {
		cmd.exe /c del /f /q %SystemRoot%\RCWM | Out-Null
		cmd.exe /c rd /s /q %SystemRoot%\RCWM | Out-Null
		reg delete HKCU\RCWM /F | Out-Null
		write-host "Old files deleted."

		$uninstallers = get-childitem ..\UninstallerFiles\RegistryFiles\*.reg
		foreach ($reg in $uninstallers) { cmd.exe /c regedit /s $reg }
		write-host "Registry cleaned."
	}
	
}

if ($existingFolder -eq $true) {
	write-host "RCWM folder already exists."
	#version from reg
	#Get-ItemProperty -Path "HKCU:\RCWM" -name "version"
	
	while ($true) {
		$mode1 = Read-Host "[R]ecreate existing files (recommended) or [K]eep old files and copy new files only"
		if ($mode1 -eq "R") {break}
		elseif ($mode1 -eq "K") {break}
		else {echo "Invalid input!"}
	}
	
	if ($mode1 -eq "K") {mergeFiles}
	else {recreateFiles}

	
} else {
	#install
	$sysdrive = ($env:SystemRoot).Substring(0, 3)
	$rcwmroot = Join-Path $sysdrive 'Program Files\RCWM'

	Write-Host "Preparing directory at $rcwmroot"
	installRCWM
}

#check for v7 and overwrite if it exists
#does not work on older windows sometimes.
# adapted from https://devblogs.microsoft.com/scripting/use-a-powershell-function-to-see-if-a-command-exists/
#$oldPreference = $ErrorActionPreference
#$ErrorActionPreference = 'stop'
#try {if(Get-Command pwsh){$global:ps = (Get-Command pwsh).version.major}}
#Catch {}
#$ErrorActionPreference=$oldPreference

# Unblock ps1 files (not entirely necessary)
# Won't work on older powershell versions, so output error message to NUL
#Unblock-File *.ps1 > $null
