

function deleteRegKeys(){
	param([string[]]$mode, [string[]]$user)
	
	#cd REGISTRY::$user
	if ($mode -eq "current") {
		cd REGISTRY::HKEY_CURRENT_USER
	} else {
		cd REGISTRY::HKEY_USERS\$user
	}

	Remove-Item -Path RCWM -Recurse | Out-Null


	Write-Host "RCWM Removed."

}

function LoopThroughUsers() {
	
	param([string[]]$mode, [string[]]$users)
	
	$allUsers = Get-ChildItem -Path Registry::"HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList\S-1-5-21-*"| Select-Object Name

	if ($mode -eq "decide") {
	
		foreach ($user in $users)
		{

			#get reg path for every user
			$userRegPath = $user

			#ProfileImagePath
			#C:\Users\root
			$userPath = (get-itemproperty -path Registry::$userRegPath).ProfileImagePath
			
			$UUID = $userRegPath.Split("\")[-1]
			
			$currentUserName = $userPath.split('\')[-1]
			Write-Host ""
			Write-Host "About to remove RCWM for user " -NoNewLine; Write-Host $currentUserName -ForegroundColor red
			
			while ($true) {
				$mode = Read-Host "Continue (Y/N)?"
				if ($mode -ne "Y" -AND $mode -ne "N") {echo "Invalid input!"}
				else {break}
			}
			
			if ($mode -eq "N") {continue} #go to next user
			else { 
				deleteRegKeys -user $UUID
				RegReplacements -mode "decide" -UUIDs $UUID 
			} #do reg files work
		}	
			
	} elseif ($mode -eq "allcurrent") { #no decide, all users
		
		#generate UUIDs array from users array
		[array]$UUIDs = @()
		foreach ($user in $users) {
			$UUID = $user.Split("\")[-1]
			$UUIDs += $UUID
			#echo "added uuid"
			#echo $user.split('\')[-1]
			deleteRegKeys -user $UUID
		}
		RegReplacements -mode "allCurrent" -UUIDs $UUIDs
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

		deleteRegKeys -mode "current" -user $UUID

		RegReplacements -mode "current" -UUIDs $null

	} else { #allFuture
		#RegReplacements -mode "allFuture"
	}
	
	del .\Temp\*.reg
	
}


function RegReplacements() {

	param($mode, [string[]]$UUIDs)

	Write-Host "Generating all necessary registry files ..."
	cd $initialLocation
	cd ../files

	#make dir "temp" and copy all files there

	#Make sure Temp is clean.
	cmd.exe /c del .\Temp\* /s /q 2>&1>$null
	cmd.exe /c rd /s /q .\Temp /s /q 2>&1>$null
	New-Item Temp -ItemType "directory" 2>&1>$null

	#Copy reg files into temp,
	Copy-Item -Path "RegistryFiles\*.reg" -Destination ".\Temp" | Out-Null

	#HKCR:
	$files = Get-ChildItem ".\Temp\*.reg"
	
	#HKLM:
	$exceptions = Get-ChildItem ".\Temp\Multiple*.reg"
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
		
		#execute all reg uninstaller files
		$uninstallers = get-childitem .\Temp\CurrentUser\*.reg
		foreach ($reg in $uninstallers) { regedit /s $reg }
		Write-Host "Uninstall for current user successful."
		
	} elseif ($mode -eq "allCurrent" -OR $mode -eq "decide" ) { #decide / allCurrent


		foreach ($uuid in $UUIDs) {

			#echo "foreach2"
			#echo $uuid
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
			
			#execute all reg uninstaller files
			$uninstallers = get-childitem .\Temp\$uuid\*.reg
			foreach ($reg in $uninstallers) { regedit /s $reg }
			Write-Host "Uninstall for $uuid successful."

		}
	}

}

$initialLocation = (get-location).path

$allUsers = Get-ChildItem -Path Registry::"HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList\S-1-5-21-*"| Select-Object Name
[array]$users = @()


foreach ($user in $allUsers) {

	cd REGISTRY::HKEY_USERS
	
	try {
		#errorAction is absolutely necessary here for try-catch to work properly
		cd $user.Name.split('\')[-1] -ErrorAction Stop
		$users += $user.Name
	} catch [System.Management.Automation.ItemNotFoundException] {
		#Write-Host "Found inactive user"
	} catch {
		#Write-Host "maybe access denied"
		#$users.Add($user.Name) | Out-Null
	}
}

while ($true) {

	$mode1 = Read-Host "Do you want to uninstall RCWM for [C]urrent user only, [D]ecide for each, or for [A]ll current users?"
	if ($mode1 -eq "C") {break}
	elseif ($mode1 -eq "D") {break}
	elseif ($mode1 -eq "A") {break}
	else {echo "Invalid input!"}
}

if ($mode1 -eq "A") {
	LoopThroughUsers -mode "allcurrent" -users $users
} elseif ($mode1 -eq "D" ) { 
	LoopThroughUsers -mode "decide" -users $users
} elseif ($mode1 -eq "C" ) {
	LoopThroughUsers -mode "current" -users $null
}
