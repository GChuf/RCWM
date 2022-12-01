$users = Get-ChildItem -Path Registry::"HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList\S-1-5-21-*"| Select-Object Name

#if only one user, $user.Length returns nothing (????????)
if ($users.Length -ge 2) {echo "install for current/all users/decide for each?"} else {echo "Only one user found."}


#current, all, decide




if ($mode -eq "all" or "decide") { 

	foreach ($user in $users)
	{
		$install = True
		#get reg path for every user
		$userRegPath = $user.Name

		#ProfileImagePath
		#C:\Users\root

		#$userPath = (get-itemproperty -path Registry::"HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList\S-1-5-21-117113989-4160453655-1229134872-1001").ProfileImagePath

		$userPath = (get-itemproperty -path Registry::$userRegPath).ProfileImagePath
		
		
		$userGUID = $userRegPath.Split("\")[-1]
		
		)
		
		
		if ($mode -eq "decide") {
			echo ("Install for user at " + $userPath + " with user ID " + $userGUID + "?"
			$install = "god knows what" #set to false here if not installing. else, no need to do anything
			
		}


		
		if ($install -eq True) {
			#make reg directories
			
			#get guid
			cd REGISTRY::HKEY_USERS
			cd $userGUID
			New-Item -Path RCWM
			cd RCWM
			New-Item -Path dl
			New-Item -Path fl
			New-Item -Path mir
			New-Item -Path mv
			New-Item -Path rc
			New-Item -Path rcs
			
			#copy all .reg files to temp directory for each user and change 'HKEY_CURRENT_USER' string into 'HKEY_USERS\GUID'
			mkdir $userGUID > $null
			
			
			Write-Host "Prepared RCWM for user at " -NoNewLine; Write-Host $userPath -ForegroundColor red -NoNewLine; Write-Host " with user ID " -NoNewLine; Write-Host $userGUID -ForegroundColor red
			
		} else {
			Write-Host "Not installing RCWM for user at " -ForegroundColor red -NoNewLine; Write-Host $userPath

		}

	}
} else {
	#current user only
	$userRegPath = $users[0].Name
	$userPath = (get-itemproperty -path Registry::$userRegPath).ProfileImagePath
	$userGUID = $userRegPath.Split("\")[-1]

	cd REGISTRY::HKEY_USERS
	cd $userGUID
	New-Item -Path RCWM
	cd RCWM
	New-Item -Path dl
	New-Item -Path fl
	New-Item -Path mir
	New-Item -Path mv
	New-Item -Path rc
	New-Item -Path rcs
	
	Write-Host "Prepared RCWM for user at " -NoNewLine; Write-Host $userPath -ForegroundColor red -NoNewLine; Write-Host " with user ID " -NoNewLine; Write-Host $userGUID -ForegroundColor red
	
	
}
