#install true = installing
#install false = uninstalling
param(
    [bool]$install
)


function prepareRegKeys(){
	param([string[]]$mode, [string[]]$user, [bool]$install)


	#cd REGISTRY::$user
	if ($mode -eq "current") {
		cd REGISTRY::HKEY_CURRENT_USER
	} else {
		#possible error here
		cd REGISTRY::HKEY_USERS\$user
	}

	try {
		cd SOFTWARE -ErrorAction Stop
	} catch {
		Write-Host "Error loading registry for UUID $user"
	}


	Remove-Item -Path RCWM -Recurse 2>&1>$null
	
	if ($install) {

		New-Item -Path RCWM  | Out-Null
		cd RCWM
		New-ItemProperty -Path . -Name "Version" -Value "3.0.0" -PropertyType String -Force | Out-Null
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

function LoopThroughUsers() {
	
	param([string[]]$mode, [string[]]$users, [bool]$install)

	$sysdrive = $env:SystemDrive

	#get all users from hklm
	$allUsers = Get-ChildItem -Path Registry::"HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList\S-1-5-21-*"| Select-Object Name

	if ($allUsers.count -ge 2) {
		Write-Host "Found " -NoNewLine; Write-Host $allUsers.Name.Count -NoNewLine; " total users in registry." 
	} elseif ($mode -ne "current") {
		Write-Host "Found l user in registry."
	}

	if ($mode -eq "decide") {

		[array]$UUIDsloadedManually = @()

		foreach ($user in $allUsers)
		{
			cd REGISTRY::HKEY_USERS
			$user = $user.Name
			#ProfileImagePath
			#C:\Users\root
			$userPath = (get-itemproperty -path Registry::$user).ProfileImagePath

			$UUID = $user.Split("\")[-1]
			
			$currentUserName = $userPath.split('\')[-1]

			Write-Host ""
			if ($install) {
				Write-Host "About to prepare RCWM for user " -NoNewLine; Write-Host $currentUserName -ForegroundColor red
			} else {
				Write-Host "About to remove RCWM for user " -NoNewLine; Write-Host $currentUserName -ForegroundColor red
			}
			while ($true) {
				$mode = Read-Host "Continue (Y/N)?"
				if ($mode -ne "Y" -AND $mode -ne "N") {echo "Invalid input!"}
				else {break}
			}

			if ($mode -eq "N") {continue} #go to next user

			#$hiveLoaded = $false
			
			#if user is already logged in, no reg hive load is needed.
			#else, load it manually.
			try {
				#errorAction is absolutely necessary here for try-catch to work properly
				#todo powershell v2
				cd $UUID -ErrorAction Stop
			} catch {
				#user not logged in
				#load hive manually
				try {
					reg load HKU\$UUID "$sysdrive\Users\$currentUserName\NTUSER.DAT" | out-null
					$UUIDsloadedManually += $UUID
					cd $UUID -ErrorAction Stop

					#$hiveLoaded = $true
				} catch {
					Write-Host "Error loading $currentUserName!"
					continue
				}
			} 

			prepareRegKeys -user $UUID -install $install


			RegReplacements -mode "decide" -UUIDs $UUID -install $install


		}

		foreach ($UUID in $loadedManually) {
			reg unload HKU\$UUID
		}

	} elseif ($mode -eq "all") {

		#prepare reg keys - works for logged in users only
		foreach ($user in $allUsers)
		{
			$user = $user.Name
			#todo pwsh v2
			$UUID = $user.Split("\")[-1]
			if (-not $install) {
				write-host Uninstalling for $uuid

				#load reg hives in case of uninstalling
				try {
					cd REGISTRY::HKEY_USERS
					cd $UUID -ErrorAction Stop
				} catch {
					try {
						reg load HKU\$UUID "$sysdrive\Users\$currentUserName\NTUSER.DAT" | out-null
						$UUIDsloadedManually += $UUID
						cd $UUID -ErrorAction Stop
					} catch {
						Write-Host "Error loading $currentUserName!"
						continue
					}
				}

			}
			
			prepareRegKeys -user $UUID -install $install
			
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
		if ($mode -eq "N") {write-host "Exiting ..."; start-sleep 2; break}

		prepareRegKeys -mode "current" -user $UUID -install $install

		RegReplacements -mode "decide" -UUIDs $UUID -install $install


	}

}

function writeVersion(){
	param([string[]]$mode)
	cd REGISTRY::HKEY_LOCAL_MACHINE
	cd SOFTWARE
	New-Item -Path RCWM  | Out-Null
	cd RCWM
	New-ItemProperty -Path . -Name "Version" -Value "3.0.0" -PropertyType String -Force | Out-Null
	New-ItemProperty -Path . -Name "Mode" -Value "$mode" -PropertyType String -Force | Out-Null
}

function regReplacements() {

	param($mode, [string[]]$UUIDs, [bool]$install)

	Write-Host "Generating all necessary registry files ..."
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

	} elseif ($mode -eq "decide" ) {

		foreach ($uuid in $UUIDs) {

			New-Item .\Temp\$uuid -ItemType "directory" 2>&1>$null

			foreach ($file in $files){
				$fileName = $file.Name
				(Get-Content $file) -Replace "HKEY_CLASSES_ROOT\\", "HKEY_USERS\$uuid\Software\Classes\" | Set-Content .\Temp\$uuid\$fileName
			}

			foreach ($file in $exceptions){  #in powershell2, there can be empty "files" (there is no Win11.reg)
				$fileName = $file.Name
				if ($file.Name -ne $null) {
					(Get-Content $file) -Replace "HKEY_LOCAL_MACHINE\\", "HKEY_USERS\$uuid\Software\Classes\" | Set-Content .\Temp\$uuid\$fileName
				}
			}

		}
	}

	#in case sysroot is not C:\, replace
	if ($sysdrive -ne "C:") {
		Write-Host "System drive not on C:, you silly goose ..."
		Write-Host "Replacing strings from C: to $sysdrive"

		#reg files
		$regFiles = Get-ChildItem ".\Temp\*.reg" -Recurse
		foreach ($file in $regFiles){
			(Get-Content $file) -Replace "C:\\", "$sysdrive\\" | Set-Content $file
		}

		#execution files under program files\rcwm, .bat and .ps1 only
		$exeFiles = Get-ChildItem "$sysdrive\\Program Files\RCWM" -Recurse -File -Include *.bat, *.ps1
		foreach ($file in $exeFiles){
			(Get-Content $file) -Replace "C:\\", "$sysdrive\\" | Set-Content $file
		}

	}

}

$initialLocation = (get-location).path

while ($true) {

	if ($install) {
		$mode1 = Read-Host "Do you want to install RCWM for [C]urrent user only, [D]ecide for each, or for [A]ll users?"
		if ($mode1 -eq "C") {break}
		elseif ($mode1 -eq "D") {break}
		elseif ($mode1 -eq "A") {break}
		else {echo "Invalid input!"}
	} else {
		$mode1 = Read-Host "Do you want to uninstall RCWM for [C]urrent user only, [D]ecide for each, or for [A]ll users?"
		if ($mode1 -eq "C") {break}
		elseif ($mode1 -eq "D") {break}
		elseif ($mode1 -eq "A") {break}
		else {echo "Invalid input!"}
	}

}

if ($mode1 -eq "A") {

	$sysdrive = $env:SystemDrive
	$rcwmroot = Join-Path $sysdrive 'Program Files\RCWM'

	#add rcwm_createregkeys to HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Run
	#runs at startup for all users
	$registryPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run"
	$registryVersionPath = "HKLM:\SOFTWARE\RCWM"
	$valueName = "RCWM"
	$initregkeysPath = $sysdrive + '\Program Files\RCWM\InitRegKeys.exe'
	
	
	if ($install) {
		New-ItemProperty -Path $registryPath -Name $valueName -Value $initregkeysPath -PropertyType String -Force | out-null
	} else {
		Remove-ItemProperty -Path $registryPath -Name $valueName -ErrorAction SilentlyContinue | out-null
		Remove-Item -Path $registryVersionPath -Recurse -Force -ErrorAction SilentlyContinue | out-null
		Remove-Item -Path $initregkeysPath -ErrorAction SilentlyContinue| out-null
		Remove-Item -Path $rcwmroot -Recurse -Force -ErrorAction SilentlyContinue | out-null
	}

	LoopThroughUsers -mode "all" -install $install
} elseif ($mode1 -eq "D" ) { 
	LoopThroughUsers -mode "decide" -install $install
} elseif ($mode1 -eq "C" ) {
	LoopThroughUsers -mode "current" -install $install
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
		powershell Set-ExecutionPolicy Bypass -Scope Process; ..\InstallerFiles\Options.ps1 $null
		writeVersion("current")
	} elseif ($mode1 -eq "A" ) { 
		powershell Set-ExecutionPolicy Bypass -Scope Process; ..\InstallerFiles\Options.ps1 $null
		writeVersion("all")
	} elseif ($mode1 -eq "D" ) {
		powershell Set-ExecutionPolicy Bypass -Scope Process; ..\InstallerFiles\Options.ps1 $users
		writeVersion("decide")
	}


} else {
	Write-Host "Uninstall finished."
}
