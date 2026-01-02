#install true = installing
#install false = uninstalling
param(
    [bool]$install
)

function prepareUserRegKeys(){
	param([string]$mode, [string[]]$user, [bool]$install)

	if ($mode -eq "current") {
		cd REGISTRY::HKEY_CURRENT_USER
	} else {
		#errors if user is not logged in or hive loaded - caught at "cd software" below
		cd REGISTRY::HKEY_USERS\$user -erroraction SilentlyContinue
	}

	try {
		cd SOFTWARE -ErrorAction Stop
	} catch {
		#Write-Host "Error loading registry for UUID $user"
		return
	}

	Remove-Item -Path RCWM -Recurse 2>&1>$null

	if ($install) {

		New-Item -Path RCWM  | Out-Null
		cd RCWM
		New-Item -Path dlink | Out-Null
		New-Item -Path flink | Out-Null
		New-Item -Path miror | Out-Null
		New-Item -Path rcmov | Out-Null
		New-Item -Path rcopy | Out-Null
		New-Item -Path rstrc | Out-Null

	} else {
		#Make sure Temp is clean.
		cmd.exe /c del .\Temp\* /s /q 2>&1>$null
		cmd.exe /c rd /s /q .\Temp /s /q 2>&1>$null
		New-Item Temp -ItemType "directory" 2>&1>$null
	}
}

function prepareHKLMRegKeys(){

	#cd REGISTRY::$user
	cd REGISTRY::HKEY_LOCAL_MACHINE

	cd SOFTWARE -ErrorAction Stop

	Remove-Item -Path RCWM -Recurse 2>&1>$null
	New-Item -Path RCWM  | Out-Null
	cd RCWM
	New-Item -Path dlink | Out-Null
	New-Item -Path flink | Out-Null
	New-Item -Path miror | Out-Null
	New-Item -Path rcmov | Out-Null
	New-Item -Path rcopy | Out-Null
	New-Item -Path rstrc | Out-Null
}

function loopThroughUsers() {
	
	param([string]$mode, [string[]]$users, [bool]$install)

	$sysDrive = $env:SystemDrive

	#get all users from hklm
	$allUsers = Get-ChildItem -Path Registry::"HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList\S-1-5-21-*"| Select-Object Name

	if ($allUsers.count -ge 2) {
		Write-Host "Found " -NoNewLine; Write-Host $allUsers.Name.Count -NoNewLine; " users in registry."
	} elseif ($mode -ne "current") {
		Write-Host "Found l user in registry."
	}

	if ($mode -eq "all") {

		if (-not $install) {
			$regs = get-childitem -path ..\UninstallerFiles
			Write-Host $regs
			foreach ($reg in $regs) {
				regedit /s ..\UninstallerFiles\$reg
			}
		} else {
			regReplacements -mode "all" -install $install
			prepareHKLMRegKeys
		}

		#prepare reg keys - works for logged in users only
		foreach ($user in $allUsers)
		{
			$user = $user.Name
			#todo pwsh v2
			$UUID = $user.Split("\")[-1]
			$profilePath = Get-ItemPropertyValue -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList\$UUID" -Name ProfileImagePath
			if (-not $install) {
				Write-Host "Removing reg keys for $uuid"

				#load reg hives in case of uninstalling
				try {
					cd REGISTRY::HKEY_USERS
					cd $UUID -ErrorAction Stop
				} catch {
					try {
						reg load HKU\$UUID "$profilePath\NTUSER.DAT" | out-null
						$UUIDsloadedManually += $UUID
						cd $UUID -ErrorAction Stop
						prepareUserRegKeys -user $UUID -install $install
						reg unload "$sysDrive\Users\$profilePath\NTUSER.DAT" | out-null
					} catch {
						#user might have been deleted, C:\users\$user does not exist
						continue
					}
				}

				#reg unload HKU\$UUID "$sysDrive\Users\$currentUserName\NTUSER.DAT" | out-null

			} else {
				prepareUserRegKeys -mode "all" -user $UUID -install $install
			}
		}

		
		#only move all files to "ALL" folder, no reg replacements needed
		cd $initialLocation
		cd ../files

		if ($install) {
			New-Item .\Temp\ALL -ItemType "directory" 2>&1>$null
			Move-Item -Path .\Temp\*.reg -Destination .\Temp\ALL
		} else {
			#Make sure Temp is clean.
			cmd.exe /c del .\Temp\* /s /q 2>&1>$null
			cmd.exe /c rd /s /q .\Temp /s /q 2>&1>$null
			New-Item Temp -ItemType "directory" 2>&1>$null

			New-Item .\Temp\ALL -ItemType "directory" 2>&1>$null
			Copy-Item -Path ..\UninstallerFiles\*.reg -Destination .\Temp\ALL
		}

	} elseif ($mode -eq "current") {

		#get current user-name
		$currUserName = cmd.exe /c whoami

		if ($install) {

			Write-Host "About to prepare RCWM for user " -NoNewLine; Write-Host $currUserName.split('\')[-1] -ForegroundColor red
		} else {
			Write-Host "About to uninstall RCWM for user " -NoNewLine; Write-Host $currUserName.split('\')[-1] -ForegroundColor red
		}
		while ($true) {
			$mode = Read-Host "Continue (Y/N)?"
			if ($mode -ne "Y" -AND $mode -ne "N") {echo "Invalid input!"}
			else {break}
		}

		#todo exit script here
		if ($mode -eq "N") {
			Write-Host "Exiting ..."; start-sleep 2; break
		}

		prepareUserRegKeys -mode "current" -user $UUID -install $install

		regReplacements -mode "current" -install $install


	}

}

function writeVersion(){
	param([string]$mode)
	$currentDir = Get-Location
	write-host $currentDir

	#write under hkcu for current user, or hklm for all users
	cd REGISTRY::HKEY_LOCAL_MACHINE
	cd SOFTWARE\RCWM

	#remove if exists - in case of reinstalls
	Remove-ItemProperty -Path . -Name "Version" -ErrorAction SilentlyContinue | out-null
	Remove-ItemProperty -Path . -Name "Mode" -ErrorAction SilentlyContinue | out-null

	New-ItemProperty -Path . -Name "Version" -Value "3.0.0" -PropertyType String -Force | out-null
	New-ItemProperty -Path . -Name "Mode" -Value $mode -PropertyType String -Force | out-null
	cd $currentDir
}

function regReplacements() {

	param([string]$mode, [bool]$install)

	#Write-Host "Generating all necessary registry files ..."
	cd $initialLocation
	cd ../files


	if ($install) {
		#HKCR:
		$files = Get-ChildItem ".\Temp\*.reg"
		#HKLM:
		$exceptions = @()
		$exceptions += Get-ChildItem ".\Temp\Multiple*.reg"
		$exceptions += Get-ChildItem ".\Temp\Win11*.reg"
		$exceptions += Get-ChildItem ".\Temp\ThisPC.reg"
		$exceptions += Get-ChildItem ".\Temp\CMDAdmin.reg"
	} else {
		#HKCR:
		$files = Get-ChildItem "..\UninstallerFiles\*.reg"
		#HKLM:
		$exceptions = @()
		$exceptions += Get-ChildItem "..\UninstallerFiles\Multiple*.reg"
		$exceptions += Get-ChildItem "..\UninstallerFiles\Win11*.reg"
		$exceptions += Get-ChildItem "..\UninstallerFiles\ThisPC.reg"
		$exceptions += Get-ChildItem "..\UninstallerFiles\CMDAdmin.reg"
	}

	if ($mode -eq "current") {

		New-Item .\Temp\CurrentUser -ItemType "directory" 2>&1>$null

		foreach ($file in $files){
			$fileName = $file.Name
			(Get-Content $file) -Replace "HKEY_CLASSES_ROOT\\", "HKEY_CURRENT_USER\Software\Classes\" | Set-Content .\Temp\CurrentUser\$fileName
		}

		foreach ($file in $exceptions){
			$fileName = $file.Name
			if ($file.Name -ne $null) {
				(Get-Content $file) -Replace "HKEY_LOCAL_MACHINE\\", "HKEY_CURRENT_USER\Software\Classes\" | Set-Content .\Temp\CurrentUser\$fileName
			}
		}

		if (-not $install) {
			$regs = get-childitem -path .\Temp\CurrentUser
			Write-Host $regs
			foreach ($reg in $regs) {
				regedit /s .\Temp\CurrentUser\$reg
			}
		}

	}

	#in case sysRoot is not C:\, replace
	if ($sysDrive -ne "C:") {
		Write-Host "System drive not on C:, you silly goose ..."
		Write-Host "Replacing strings from C: to $sysDrive"

		#reg files
		$regFiles = Get-ChildItem ".\Temp\*.reg" -Recurse
		foreach ($file in $regFiles){
			(Get-Content $file) -Replace "C:\\", "$sysDrive\\" | Set-Content $file
		}

		#execution files under program files\rcwm, .bat and .ps1 only
		$exeFiles = Get-ChildItem "$sysDrive\\Program Files\RCWM" -Recurse -File -Include *.bat, *.ps1
		foreach ($file in $exeFiles){
			(Get-Content $file) -Replace "C:\\", "$sysDrive\\" | Set-Content $file
		}

	}

}

$initialLocation = (get-location).path

while ($true) {

	if ($install) {
		$mode1 = Read-Host "Do you want to install RCWM for [C]urrent user only, or for [A]ll users?"
		if ($mode1 -eq "C") {break}
		elseif ($mode1 -eq "A") {break}
		else {echo "Invalid input!"}
	} else {

		#TODO duplicated code
		$currentUserWithoutDomain = [Environment]::UserName
		$currentUSer = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name
		Write-Host "Running script as " -NoNewLine; Write-Host $currentUser -ForegroundColor red

		$mode1 = Read-Host "Do you want to uninstall RCWM for [C]urrent user only, or for [A]ll users?"
		if ($mode1 -eq "C") {break}
		elseif ($mode1 -eq "A") {break}
		else {echo "Invalid input!"}
	}

}

if ($mode1 -eq "A") {

	$sysDrive = $env:SystemDrive
	$rcwmRoot = Join-Path $sysDrive 'Program Files\RCWM'

	#add rcwm_createregkeys to HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Run
	#runs at startup for all users
	$startupRegistryPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run"
	$rcwmRegistryPath = "HKLM:\SOFTWARE\RCWM"
	$valueName = "RCWM"
	$initregkeysPath = '"' + $sysDrive + '\Program Files\RCWM\RCWMInit.exe' + '"'

	
	if ($install) {
		New-ItemProperty -Path $startupRegistryPath -Name $valueName -Value $initregkeysPath -PropertyType String -Force | out-null
	} else {
		Remove-Item -Path $rcwmRoot -Recurse -Force -ErrorAction SilentlyContinue | out-null
		Remove-Item -Path $initregkeysPath -ErrorAction SilentlyContinue| out-null

		Remove-Item -Path $rcwmRegistryPath -Recurse -Force -ErrorAction SilentlyContinue | out-null

		Remove-ItemProperty -Path $startupRegistryPath -Name $valueName -ErrorAction SilentlyContinue | out-null
	}

	loopThroughUsers -mode "all" -install $install

	} elseif ($mode1 -eq "C" ) {
		loopThroughUsers -mode "current" -install $install
	}

cd $initialLocation

#remove all .regs not in folders
Remove-Item -Path .\Temp\*.reg | out-null


if ($install) {
	Write-Host "Preparation finished."
	
	Write-Host ""
	Write-Host " Choose the options that you want to apply to your right-click menu."
	Write-Host " There are 3 sections: Add options, Remove options, and Miscellaneous."
	Write-Host ""

	if ($mode1 -eq "C") {
		writeVersion("current")
		powershell Set-ExecutionPolicy Bypass -Scope Process; ..\InstallerFiles\Options.ps1 $null
	} elseif ($mode1 -eq "A" ) { 
		writeVersion("all")
		powershell Set-ExecutionPolicy Bypass -Scope Process; ..\InstallerFiles\Options.ps1 $null
	}


} else {
	cmd.exe /c del .\Temp\* /s /q 2>&1>$null
	cmd.exe /c rd /s /q .\Temp /s /q 2>&1>$null
	Write-Host "Uninstall finished."
}
