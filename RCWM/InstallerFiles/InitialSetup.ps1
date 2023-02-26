Write-Host "Initialising setup ..."
$ps = $psversiontable.psversion.major
$arch = (Get-WmiObject win32_processor | Where-Object{$_.deviceID -eq "CPU0"}).AddressWidth
$os = [System.Environment]::OSVersion.Version.Major
#win7 and win8 virtual machines both return "6"
#new win servers(!) return "10"


#Make sure Temp is clean.
cmd.exe /c del .\Temp\* /s /q 2>&1>$null
cmd.exe /c rd /s /q .\Temp /s /q 2>&1>$null
New-Item Temp -ItemType "directory" 2>&1>$null

#Copy reg files into temp,
Copy-Item -Path "RegistryFiles\*.reg" -Destination ".\Temp" | Out-Null

#todo new folder for reg files
#New-Item Temp\TempRegFiles -ItemType "directory" 2>&1>$null
#Copy-Item -Path "RegistryFiles\*.reg" -Destination ".\Temp\TempRegFiles" | Out-Null

#copy execution files and icons
Copy-Item -Path "ExecutionFiles\*" -Destination ".\Temp" | Out-Null
Copy-Item -Path "Icons\*" -Destination ".\Temp" | Out-Null


#Overwrite default files with specific files - if they exist/if applicable
Copy-Item -Path "PowershellSpecificFiles\pwsh$ps\*" -Destination ".\Temp" -erroraction 'silentlycontinue'
Copy-Item -Path "OSSpecificFiles\Win$os\*" -Destination ".\Temp" -erroraction 'silentlycontinue'

#generate os-specific files - but look for powershell version, not OS version
#this is only needed so that OS doesn't prompt the user to run the shortcut
if ($ps -eq 4) { #Generate shortcuts for win8
	Write-Host "Generating shortcuts ..."
	..\InstallerFiles\shortcuts8.ps1 
}
elseif ($ps -eq 2) { #Generate shortcuts for win7
	Write-Host "Generating shortcuts ..."
	..\InstallerFiles\shortcuts7.ps1 
}

#Generate .exe files
#don't touch this very fragile part ...
Write-Host "Generating binary files ..."

Copy-Item -Path "..\InstallerFiles\ps2exe\*" -Destination ".\Temp"

#powershell .\Temp\ps2exe.ps1 -inputfile .\Temp\RCopySingle.ps1 -outputfile .\Temp\rcopyS.exe -noconsole -novisualstyles -x86 -nooutput -iconfile .\Temp\rcopy.ico -verbose 2>&1>$null
powershell .\Temp\ps2exe.ps1 -inputfile .\Temp\RCopySingle.ps1 -outputfile .\Temp\rcopyS.exe -noconsole -novisualstyles -x86 -nooutput -iconfile .\Temp\rcopy.ico 2>&1>$null
powershell .\Temp\ps2exe.ps1 -inputfile .\Temp\RCopyMultiple.ps1 -outputfile .\Temp\rcopyM.exe -noconsole -novisualstyles -x86 -nooutput -iconfile .\Temp\rcopy.ico 2>&1>$null
powershell .\Temp\ps2exe.ps1 -inputfile .\Temp\MvDirSingle.ps1 -outputfile .\Temp\mvdirS.exe -noconsole -novisualstyles -x86 -nooutput -iconfile .\Temp\move.ico 2>&1>$null
powershell .\Temp\ps2exe.ps1 -inputfile .\Temp\MvDirMultiple.ps1 -outputfile .\Temp\mvdirM.exe -noconsole -novisualstyles -x86 -nooutput -iconfile .\Temp\move.ico 2>&1>$null
powershell .\Temp\ps2exe.ps1 -inputfile .\Temp\DirectoryLinks.ps1 -outputfile .\Temp\dlink.exe -noconsole -novisualstyles -x86 -nooutput -iconfile .\Temp\link.ico 2>&1>$null
powershell .\Temp\ps2exe.ps1 -inputfile .\Temp\FileLinks.ps1 -outputfile .\Temp\flink.exe -noconsole -novisualstyles -x86 -nooutput -iconfile .\Temp\link.ico 2>&1>$null


#Files generated.


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
	}
}


#copy only: executionFIles and Icons for now

function recreateFiles() {
	#$sysroot = cmd.exe /c echo %systemroot% 
	cmd.exe /c del /f /q %SystemRoot%\RCWM | Out-Null
	cmd.exe /c rd /s /q %SystemRoot%\RCWM | Out-Null
	cmd.exe /c md %SystemRoot%\RCWM | Out-Null

	#copy binaries, shortcuts, icons, .bat and .ps1 files into RCWM folder
	$sysroot = cmd.exe /c echo %SystemRoot%
	Copy-Item -Path "Temp\*" -Destination "$sysroot\RCWM"

	#take ownership of that folder for administrators & users
	cmd.exe /c takeown /F %SystemRoot%\RCWM /R /D Y | Out-Null
	cmd.exe /c icacls %SystemRoot%\RCWM /grant administrators:F /T /C | Out-Null
	cmd.exe /c icacls %SystemRoot%\RCWM /grant users:F /T /C | Out-Null

	#Files copied.
	
	echo "Recreated RCWM directory"
}

function mergeFiles() {
	robocopy .\Temp\* "%SystemRoot%\RCWM" /XC /XN /XO | Out-Null

	echo "New files copied"
}


function installRCWM() {
	
	cmd.exe /c md %SystemRoot%\RCWM
	#attrib +h +s %SystemRoot%\RCWM

	#copy binaries, shortcuts, icons, .bat and .ps1 files into RCWM folder
	$sysroot = cmd.exe /c echo %SystemRoot%
	Copy-Item -Path "Temp\*" -Destination "$sysroot\RCWM"

	#take ownership of that folder for administrators & users
	cmd.exe /c takeown /F %SystemRoot%\RCWM /R /D Y | Out-Null
	cmd.exe /c icacls %SystemRoot%\RCWM /grant administrators:F /T /C | Out-Null
	cmd.exe /c icacls %SystemRoot%\RCWM /grant users:F /T /C | Out-Null

	#add exclusion - just in case
	powershell -Command Add-MpPreference -ExclusionPath "C:\Windows\RCWM" | Out-Null
	echo "Created directory at C:\Windows\RCWM and copied all files."
}

$sysroot = cmd.exe /c echo %SystemRoot%
$existingFolder = Test-Path -Path "$sysroot\RCWM"
$RCWMv1Folder = Test-Path -Path "$sysroot\System32\RCWM"

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
		write-host "Old files deleted."

		$uninstallers = get-childitem ..\UninstallerFiles\RegistryFiles\*.reg
		foreach ($reg in $uninstallers) { regedit /s $reg }
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
	$sysroot = cmd.exe /c echo %SystemRoot%

	Write-Host "Preparing directory at $sysroot\RCWM"
	installRCWM
}



#check for v7 and overwrite if it exists
# adapted from https://devblogs.microsoft.com/scripting/use-a-powershell-function-to-see-if-a-command-exists/
$oldPreference = $ErrorActionPreference
$ErrorActionPreference = 'stop'
try {if(Get-Command pwsh){$global:ps = (Get-Command pwsh).version.major}}
Catch {}
$ErrorActionPreference=$oldPreference

Write-Host "Using powershell version $ps on $arch bit CPU."

# Unblock ps1 files (not entirely necessary)
# Won't work on older powershell versions, so output error message to NUL
#Unblock-File *.ps1 > $null
