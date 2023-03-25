#https://www.lifewire.com/how-to-find-a-users-security-identifier-sid-in-windows-2625149


##TODO
#scrap allFuture? u ant make registry keys for every user in advance
#unless they all use hkcr/hklm at the same time - not a good idea.
#solution is to actually implement an exe that saves this all into memory

function prepareRegKeys(){
	param([string[]]$mode, [string[]]$user)
	
	#cd REGISTRY::$user
	if ($mode -eq "current") {
		cd REGISTRY::HKEY_CURRENT_USER
	} else {
		cd REGISTRY::HKEY_USERS\$user
	}

	Remove-Item -Path RCWM -Recurse 2>&1>$null
	New-Item -Path RCWM  | Out-Null
	
	cd RCWM
	New-ItemProperty -Path . -Name "Version" -Value "2.0.0" -PropertyType String -Force | Out-Null
	New-Item -Path dl | Out-Null
	New-Item -Path fl | Out-Null
	New-Item -Path mir | Out-Null
	New-Item -Path mv | Out-Null
	New-Item -Path rc | Out-Null
	New-Item -Path rcs | Out-Null
	New-Item -Path InstallInfo | Out-Null
	
	#Write-Host "Prepared registry for user " -NoNewLine; Write-Host $user -ForegroundColor red;
}

function LoopThroughUsers() {
	
	param([string[]]$mode, [string[]]$users)
	
	$allUsers = Get-ChildItem -Path Registry::"HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList\S-1-5-21-*"| Select-Object Name
	
	if ($users.count -ge 2) {
		Write-Host "Found " -NoNewLine; Write-Host $allUsers.Name.Count -NoNewLine; " total users in registry." 
		Write-Host "Can prepare RCWM for " -NoNewLine; Write-Host $users.count -NoNewLine; " active users."
	} else {
		if ($mode -ne "current") {
			Write-Host "Found l user in registry."
		}
	}

	#write-host "Warning: Future users will see RCWM menu options, but will be unable to use them without reinstalling."
	#rather install for every user on its own.

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
			Write-Host "About to prepare RCWM for user " -NoNewLine; Write-Host $currentUserName -ForegroundColor red
			
			while ($true) {
				$mode = Read-Host "Continue (Y/N)?"
				if ($mode -ne "Y" -AND $mode -ne "N") {echo "Invalid input!"}
				else {break}
			}
			
			if ($mode -eq "N") {continue} #go to next user
			else { 
				prepareRegKeys -user $UUID
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
			prepareRegKeys -user $UUID
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
	
		#make reg directories
		
		#get guid
		
		#cd $userGUID
		#$Error[0].Exception.GetType().FullName
		
		#try {
		#	cd $UUID
			#$Error[0].Exception.GetType().FullName
		#} catch [System.Security.SecurityException] { #catch user not having the rights to do this
		#	Write-Host "You don't have the rights to install RCWM for this user!"
		#	continue
		#}

		#todo: exception: cd : Requested registry access is not allowed.


		prepareRegKeys -mode "current" -user $UUID

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

		}
	}

#	else { #allFuture - reg files stay the same.
		#only move files to new directory in temp
#		New-Item .\Temp\ALL -ItemType "directory" 2>&1>$null
#		Move-Item -Path .\Temp\*.reg -Destination .\Temp\ALL
#		del .\Temp\*.reg
#	}

}

$initialLocation = (get-location).path


#hkey_users might not be available for the user
#however hklm... returns unavailable users as well. got to check which ones are inactive
$allUsers = Get-ChildItem -Path Registry::"HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList\S-1-5-21-*"| Select-Object Name
#active ones have subkeys? - need to 100% confirm that
#the other option is this: if I can't enter HKCU\$user, it's either inactive or I don't have permissions.
#inactive: 
#System.Management.Automation.ItemNotFoundException

#$users = New-Object -TypeName 'System.Collections.ArrayList';
[array]$users = @()


foreach ($user in $allUsers) {

	cd REGISTRY::HKEY_USERS
	#echo $user.Name.split('\')[-1]
	#if no exception, add to users array
	
	
	
	
	try {
		#echo $user.Name.split('\')[-1]
		#errorAction is absolutely necessary here for try-catch to work properly
		cd $user.Name.split('\')[-1] -ErrorAction Stop
		#echo "adding user"
		#echo $user.Name
		#$users.Add($user.Name) | Out-Null
		$users += $user.Name
		#echo "added user"
		#$users2 += $user.Name
		#$Error[0].Exception.GetType().FullName
	} catch [System.Management.Automation.ItemNotFoundException] {
		#Write-Host "Found inactive user"
	} catch {
		#Write-Host "maybe access denied"
		#$users.Add($user.Name) | Out-Null
	}
}

while ($true) {

	$mode1 = Read-Host "Do you want to install RCWM for [C]urrent user only, [D]ecide for each, or for [A]ll current users?"
	if ($mode1 -eq "C") {break}
	elseif ($mode1 -eq "D") {break}
	elseif ($mode1 -eq "A") {break}
	else {echo "Invalid input!"}
}


#if ($mode1 -eq "A") {
	
#	while ($true) {
#		$mode1 = Read-Host "Do you want to install RCWM for All [C]urrent users only, or for all [F]uture users as well?"
#		if ($mode1 -eq "C") {break}
#		elseif ($mode1 -eq "F") {break}
#		else {echo "Invalid input!"}
#	}
	
#	if ($mode1 -eq "F") { 
#		#echo "all future, default regedit files"
#		#create new allfuture dir? move all files there?
#		LoopThroughUsers -mode "allFuture"		
#	}

	#elseif ($mode1 -eq "C") {
		#echo "all current"
		#LoopThroughUsers -mode "allcurrent" -users $users
	#}
#}



if ($mode1 -eq "A") {
	LoopThroughUsers -mode "allcurrent" -users $users
} elseif ($mode1 -eq "D" ) { 
	LoopThroughUsers -mode "decide" -users $users
} elseif ($mode1 -eq "C" ) {
	LoopThroughUsers -mode "current" -users $null
}


Write-Host "Preparation finished."


Write-Host ""
Write-Host " Choose the options that you want to apply to your right-click menu."
Write-Host " There are 3 sections: Add options, Remove options, and Miscellaneous."
Write-Host ""

if ($mode1 -eq "C") { 
	powershell Set-ExecutionPolicy Bypass -Scope Process; ..\InstallerFiles\Options.ps1 $null
} else {
	powershell Set-ExecutionPolicy Bypass -Scope Process; ..\InstallerFiles\Options.ps1 $users
}
