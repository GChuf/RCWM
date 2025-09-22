#https://www.lifewire.com/how-to-find-a-users-security-identifier-sid-in-windows-2625149

function prepareRegKeys(){
	param([string[]]$mode, [string[]]$user)

	#cd REGISTRY::$user
	if ($mode -eq "current") {
		cd REGISTRY::HKEY_CURRENT_USER
	} else {
		cd REGISTRY::HKEY_USERS\$user
	}

	cd SOFTWARE

	Remove-Item -Path RCWM -Recurse 2>&1>$null
	New-Item -Path RCWM  | Out-Null

	cd RCWM
	New-ItemProperty -Path . -Name "Version" -Value "3.0.0" -PropertyType String -Force | Out-Null
	New-Item -Path dlink | Out-Null
	New-Item -Path flink | Out-Null
	New-Item -Path miror | Out-Null
	New-Item -Path rcmov | Out-Null
	New-Item -Path rcopy | Out-Null
	New-Item -Path rstrc | Out-Null
	
	#Write-Host "Prepared registry for user " -NoNewLine; Write-Host $user -ForegroundColor red;
}

function LoopThroughUsers() {
	
	param([string[]]$mode, [string[]]$users)
	

	$sysdrive = $env:SystemDrive


	#get all users from hklm
	$allUsers = Get-ChildItem -Path Registry::"HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList\S-1-5-21-*"| Select-Object Name
	#only able to change registry for logged in users - those who have reg loaded into HKEY_USERS
	#inactive? user: 
	#System.Management.Automation.ItemNotFoundException


	foreach ($user in $allUsers) {

		cd REGISTRY::HKEY_USERS

		#if no exception, add to users array
		try {
			#echo $user.Name.split('\')[-1]
			#errorAction is absolutely necessary here for try-catch to work properly
			cd $user.Name.split('\')[-1] -ErrorAction Stop
			#$users.Add($user.Name) | Out-Null
			$users += $user.Name
			#$users2 += $user.Name
			#$Error[0].Exception.GetType().FullName
		} catch [System.Management.Automation.ItemNotFoundException] {
			#Write-Host "Found inactive user"
		} catch {
			#Write-Host "maybe access denied"
			#$users.Add($user.Name) | Out-Null
		}
	}

	if ($allUsers.count -ge 2) {
		Write-Host "Found " -NoNewLine; Write-Host $allUsers.Name.Count -NoNewLine; " total users in registry." 
	} elseif ($mode -ne "current") {
		Write-Host "Found l user in registry."
	}

	if ($mode -eq "decide") {

		[array]$UUIDsloadedManually = @()

		foreach ($user in $allUsers)
		{
			$user = $user.Name
			#ProfileImagePath
			#C:\Users\root
			$userPath = (get-itemproperty -path Registry::$user).ProfileImagePath
			
			$UUID = $user.Split("\")[-1]
			
			$currentUserName = $userPath.split('\')[-1]


			Write-Host ""
			Write-Host "About to prepare RCWM for user " -NoNewLine; Write-Host $currentUserName -ForegroundColor red
			
			while ($true) {
				$mode = Read-Host "Continue (Y/N)?"
				if ($mode -ne "Y" -AND $mode -ne "N") {echo "Invalid input!"}
				else {break}
			}
			
			if ($mode -eq "N") {continue} #go to next user

			#$hiveLoaded = $false
			cd REGISTRY::HKEY_USERS


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
					cd $UUID -ErrorAction Stop
					$UUIDsloadedManually += $UUID
					#$hiveLoaded = $true
				} catch {
					Write-Host "Error loading $currentUserName!"
					continue
				}
			} 

			prepareRegKeys -user $UUID
			RegReplacements -mode "decide" -UUIDs $UUID

			#if ($hiveLoaded) {reg unload HKU\$UUID | out-null}


			#load with runas example:
			#$success = $false
			#do {
			#	cmd.exe /C runas /user:$currentUserName /profile cmd
			#	$exitcode = $LASTEXITCODE
			#	if ($exitcode -ne 0) {
			#		while ($true) {
			#			$mode = Read-Host "Retry (Y/N)?"
			#			if ($mode -ne "Y" -AND $mode -ne "N") {echo "Invalid input!"}
			#			else {break}
			#		}
			#		if ($mode -eq "N") {$success = $true} else {continue}
			#	} else {$success = $true}
			#} until ($success)


		}

		foreach ($UUID in $loadedManually) {
			reg unload HKU\$UUID
		}


	} elseif ($mode -eq "all") {

		#prepare reg keys for logged in users only
		foreach ($user in $allUsers)
		{
			$user = $user.Name
			#todo pwsh v2
			$UUID = $user.Split("\")[-1]
			prepareRegKeys -user $UUID
		}

		#only move all files to "ALL" folder, no replacements needed
		regReplacements -mode "all" -UUIDs $null

	} elseif ($mode -eq "current") {
	
		#get current user-name
		$currUserName = cmd.exe /c whoami
		
		Write-Host "About to prepare RCWM for user " -NoNewLine; Write-Host $currUserName.split('\')[-1] -ForegroundColor red
		while ($true) {
			$mode = Read-Host "Continue (Y/N)?"
			if ($mode -ne "Y" -AND $mode -ne "N") {echo "Invalid input!"}
			else {break}
		}
		#todo exit script here
		if ($mode -eq "N") {write-host "Exiting ..."; start-sleep 2; break}
	
		prepareRegKeys -mode "current" -user $UUID
		regReplacements -mode "current" -UUIDs $null

	}
	
}

function writeVersion(){
	param([string[]]$mode)
	cd REGISTRY::HKEY_LOCAL_MACHINE
	cd SOFTWARE
	cd RCWM
	New-ItemProperty -Path . -Name "Version" -Value "3.0.0" -PropertyType String -Force | Out-Null
	New-ItemProperty -Path . -Name "Mode" -Value "$mode" -PropertyType String -Force | Out-Null
}

function regReplacements() {

	param($mode, [string[]]$UUIDs)

	Write-Host "Generating all necessary registry files ..."
	cd $initialLocation
	cd ../files
	
	
	#echo "uuids received:"
	#echo $UUIDs

	#HKCR:
	$files = Get-ChildItem ".\Temp\*.reg"
	
	#HKLM:
	$exceptions = @()
	$exceptions += Get-ChildItem ".\Temp\Multiple*.reg"
	$exceptions += Get-ChildItem ".\Temp\Win11*.reg"
	$exceptions += Get-ChildItem ".\Temp\ThisPC.reg"
	$exceptions += Get-ChildItem ".\Temp\CMDAdmin.reg"


	if ($mode -eq "current") {
		
		New-Item .\Temp\CurrentUser -ItemType "directory" 2>&1>$null
		
		foreach ($file in $files){
			$fileName = $file.Name
			(Get-Content $file) -Replace "HKEY_CLASSES_ROOT\\", "HKEY_CURRENT_USER\Software\Classes\" | Set-Content .\Temp\CurrentUser\$fileName
			#KEY_USERS\S-1-5-21-117113989-4160453655-1229134872-1001
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
				#KEY_USERS\S-1-5-21-117113989-4160453655-1229134872-1001
			}
			
			foreach ($file in $exceptions){  #in powershell2, there can be empty "files" (there is no Win11.reg)
				$fileName = $file.Name
				if ($file.Name -ne $null) {
					(Get-Content $file) -Replace "HKEY_LOCAL_MACHINE\\", "HKEY_USERS\$uuid\Software\Classes\" | Set-Content .\Temp\$uuid\$fileName
				}
			}

		}
	}

	elseif ($mode -eq "all" ) { #reg files stay the same.
		#only move files to new directory in temp
		New-Item .\Temp\ALL -ItemType "directory" 2>&1>$null
		Move-Item -Path .\Temp\*.reg -Destination .\Temp\ALL
	}

	#in case sysroot is not C:\, replace

	if ($sysdrive -ne "C:") {
		Write-Host "System drive not on C:, you silly goose ..."
		Write-Host "Replacing."

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

	$mode1 = Read-Host "Do you want to install RCWM for [C]urrent user only, [D]ecide for each, or for [A]ll users?"
	if ($mode1 -eq "C") {break}
	elseif ($mode1 -eq "D") {break}
	elseif ($mode1 -eq "A") {break}
	else {echo "Invalid input!"}
}

if ($mode1 -eq "A") {
	#Copy RCWM_CreateRegistryKeys.bat file to ProgramData\Microsoft\Windows\Start Menu\Programs\StartUp so it executes on login for all users.
	#cd $initialLocation
	#Copy-Item -Path "..\InstallerFiles\RCWM_CreateRegistryKeys.bat" -Destination "$env:SystemDrive\ProgramData\Microsoft\Windows\Start Menu\Programs\StartUp" | Out-Null

	#add rcwm_createregkeys to HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Run
	#runs at startup for all users
	$registryPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run"
	$valueName = "RCWM"
	$valueData = '"C:\Program Files\RCWM\InitRegKeys.exe"'
	New-ItemProperty -Path $registryPath -Name $valueName -Value $valueData -PropertyType String -Force | out-null

	LoopThroughUsers -mode "all"
} elseif ($mode1 -eq "D" ) { 
	LoopThroughUsers -mode "decide"
} elseif ($mode1 -eq "C" ) {
	LoopThroughUsers -mode "current"
}

cd $initialLocation

#remove all .regs not in folders
Remove-Item -Path .\Temp\*.reg | out-null

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


