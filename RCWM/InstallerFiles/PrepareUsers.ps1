#install true = installing
#install false = uninstalling
param(
    [bool]$install
)

$sysDrive = ($env:SystemRoot).Substring(0, 3)
$rcwmRoot = Join-Path $sysDrive 'Program Files\RCWM'

function prepareUserRegKeys(){
	param([string]$mode, [string]$user, [bool]$install)

	if ($mode -eq "current") {
		cd REGISTRY::HKEY_CURRENT_USER
	} else {
		#errors if user is not logged in or hive loaded - caught at "cd software" below
		cd REGISTRY::HKEY_USERS\$user -erroraction SilentlyContinue
	}

	try {
		cd SOFTWARE -ErrorAction Stop
	} catch {
		Write-Host "Error loading registry for UUID $UUID"
		return
	}

	if ($install) {
		New-Item -Path RCWM  2>&1>$null
		cd RCWM
		New-Item -Path dlink 2>&1>$null
		New-Item -Path flink 2>&1>$null
		New-Item -Path miror 2>&1>$null
		New-Item -Path rcmov 2>&1>$null
		New-Item -Path rcopy 2>&1>$null
		New-Item -Path rstrc 2>&1>$null

	} else {
		Remove-Item -Path RCWM -Recurse
	}
}

function prepareHKLMRegKeys(){

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
		Write-Host "Found " -NoNewLine; Write-Host $allUsers.Count -NoNewLine; " users in registry."
	} elseif ($mode -ne "current") {
		Write-Host "Found l user in registry."
	}

	if ($mode -eq "all") {

		if (-not $install) {
			$regs = get-childitem -path ..\UninstallerFiles
			foreach ($reg in $regs) {
				regedit /s ..\UninstallerFiles\$reg
			}

			#Make sure Temp is clean.
			cmd.exe /c del .\Temp\* /s /q 2>&1>$null
			cmd.exe /c rd /s /q .\Temp /s /q 2>&1>$null

			#Remove scheduled task for rcwminit
			schtasks /Delete /TN "RCWM Init" /F
			
			#Remove registry keys under HKLM
			$rcwmRegistryPath = "HKLM:\SOFTWARE\RCWM"
			Remove-Item -Path $rcwmRoot -Recurse -Force -ErrorAction SilentlyContinue | out-null
			Remove-Item -Path $rcwmRegistryPath -Recurse -Force -ErrorAction SilentlyContinue | out-null

		} else {
			regReplacements -mode "all" -install $install
			#prepareHKLMRegKeys
		}

		#prepare reg keys - works for logged in users without loading reg hives
		#with loading reg hives works for all users, except some exceptions
		foreach ($user in $allUsers)
		{
			$userName = $user.Name
			#todo pwsh v2
			$UUID = $userName.Split("\")[-1]
			#$profilePath = Get-ItemPropertyValue -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList\$UUID" -Name ProfileImagePath
			$profilePath = [Microsoft.Win32.Registry]::LocalMachine.OpenSubKey("SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList\$UUID").GetValue("ProfileImagePath")
			if (-not $install) {
				Write-Host "Removing reg keys for $UUID"
			} 
			#else {
				#Write-Host "Preparing reg keys for $UUID"
			#}

			#load reg hives in case of uninstalling
			try {
				cd REGISTRY::HKEY_USERS
				cd $UUID -ErrorAction Stop
				prepareUserRegKeys -user $UUID -install $install
			} catch {
				try {
					cd REGISTRY::HKEY_USERS
					reg load HKU\$UUID "$profilePath\NTUSER.DAT"
					$UUIDsloadedManually += $UUID
					cd $UUID -ErrorAction Stop
					prepareUserRegKeys -user $UUID -install $install
					try {
						reg unload HKU\$UUID
					} catch {
						#Write-Host "User logged in"
						continue
					}
				} catch {
					#user might have been deleted, C:\users\$user does not exist
					continue
				}
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

	#write under hkcu for current user, or hklm for all users

	if ($mode -eq "current") {
		cd REGISTRY::HKEY_CURRENT_USER
		cd SOFTWARE

		Remove-Item -Path RCWM -Recurse 2>&1>$null
		New-Item -Path RCWM  | Out-Null

		cd RCWM

		#remove if exists - in case of reinstalls
		Remove-ItemProperty -Path . -Name "Version" -ErrorAction SilentlyContinue | out-null
		Remove-ItemProperty -Path . -Name "Mode" -ErrorAction SilentlyContinue | out-null

		New-ItemProperty -Path . -Name "Version" -Value "3.0.0" -PropertyType String -Force | out-null
		New-ItemProperty -Path . -Name "Mode" -Value $mode -PropertyType String -Force | out-null
	}

	elseif ($mode -eq "all") {
		cd REGISTRY::HKEY_LOCAL_MACHINE
		cd SOFTWARE

		Remove-Item -Path RCWM -Recurse 2>&1>$null
		New-Item -Path RCWM  | Out-Null

		cd RCWM

		#remove if exists - in case of reinstalls
		Remove-ItemProperty -Path . -Name "Version" -ErrorAction SilentlyContinue | out-null
		Remove-ItemProperty -Path . -Name "Mode" -ErrorAction SilentlyContinue | out-null

		New-ItemProperty -Path . -Name "Version" -Value "3.0.0" -PropertyType String -Force | out-null
		New-ItemProperty -Path . -Name "Mode" -Value $mode -PropertyType String -Force | out-null
	}

	cd $currentDir
}

function regReplacements() {

	param([string]$mode, [bool]$install)

	#Write-Host "Generating all necessary registry files ..."
	cd $initialLocation
	cd ../files


	if ($install) {
		$files = Get-ChildItem ".\Temp\*.reg"
	} else {
		$files = Get-ChildItem "..\UninstallerFiles\*.reg"
	}

	if ($mode -eq "current") {

		New-Item .\Temp\CurrentUser -ItemType "directory" 2>&1>$null

		foreach ($file in $files){
			$fileName = $file.Name
			(Get-Content $file) -Replace "HKEY_CLASSES_ROOT", "HKEY_CURRENT_USER\Software\Classes" | Set-Content .\Temp\CurrentUser\$fileName
		}

		if (-not $install) {
			$regs = get-childitem -path .\Temp\CurrentUser
			foreach ($reg in $regs) {
				regedit /s .\Temp\CurrentUser\$reg
			}
		}
	}

	if ($mode -eq "all") {
		if ($install) {

			#create folders for all users
			#for specific options that need HKCU inserts as well as HKLM
			#example win11 old context menu

			#reg hives are already loaded
			foreach ($user in $allUsers)
			{
				$userName = $user.Name
				#todo pwsh v2
				$UUID = $userName.Split("\")[-1]

				New-Item .\Temp\$UUID -ItemType "directory" 2>&1>$null
				(Get-Content .\Temp\Win11AddOldContextMenu.reg) -Replace "HKEY_LOCAL_MACHINE", "HKEY_USERS\$UUID" | Set-Content .\Temp\$UUID\Win11AddOldContextMenu.reg

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
		$exeFiles = Get-ChildItem "$sysDrive\\Program Files\RCWM" -Recurse -File -Include *.cmd, *.bat, *.ps1
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
}
