$a = (get-location).path
echo $a


$mode = $args

$users = Get-ChildItem -Path Registry::"HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList\S-1-5-21-*"| Select-Object Name

if ($mode -eq "all" ) { 

	#if only one user, $user.Length returns nothing (????????)
	if ($users.Length -ge 2) {echo "Preparing RCWM for all users."} else {echo "Only one user found. Preparing RCWM for current user."}

	#write-host "Warning: Future users will see RCWM menu options, but will be unable to use them without reinstalling."
	#rather install for every user on its own.

	foreach ($user in $users)
	{

		#get reg path for every user
		$userRegPath = $user.Name

		#ProfileImagePath
		#C:\Users\root
		$userPath = (get-itemproperty -path Registry::$userRegPath).ProfileImagePath
		
		$userGUID = $userRegPath.Split("\")[-1]

		#make reg directories
		
		#get guid
		cd REGISTRY::HKEY_USERS
		cd $userGUID

		Remove-Item -Path RCWM -Recurse | Out-Null
		New-Item -Path RCWM  | Out-Null
		cd RCWM
		New-Item -Path dl | Out-Null
		New-Item -Path fl | Out-Null
		New-Item -Path mir | Out-Null
		New-Item -Path mv | Out-Null
		New-Item -Path rc | Out-Null
		New-Item -Path rcs | Out-Null
		
		Write-Host "Prepared RCWM for user at " -NoNewLine; Write-Host $userPath -ForegroundColor red -NoNewLine; Write-Host " with user ID " -NoNewLine; Write-Host $userGUID -ForegroundColor red
	}

} else {
	
	echo "Preparing RCWM for current user."
	
	#current user only
	$userRegPath = $users[0].Name
	$userPath = (get-itemproperty -path Registry::$userRegPath).ProfileImagePath
	$userGUID = $userRegPath.Split("\")[-1]

	cd REGISTRY::HKEY_USERS
	cd $userGUID
	Remove-Item -Path RCWM -Recurse | Out-Null
	New-Item -Path RCWM  | Out-Null
	cd RCWM
	New-Item -Path dl | Out-Null
	New-Item -Path fl | Out-Null
	New-Item -Path mir | Out-Null
	New-Item -Path mv | Out-Null
	New-Item -Path rc | Out-Null
	New-Item -Path rcs | Out-Null
	
	
	#replace in .reg files
	$files = Get-ChildItem . -Filter *.reg
	
	foreach ($file in $files){
		
		(Get-Content $file) -Replace 'HKEY_CLASSES_ROOT', 'HKEY_CURRENT_USER' | Set-Content $file
		#KEY_USERS\S-1-5-21-117113989-4160453655-1229134872-1001
	}
	

	
	Write-Host "Prepared RCWM for user at " -NoNewLine; Write-Host $userPath -ForegroundColor red -NoNewLine; Write-Host " with user ID " -NoNewLine; Write-Host $userGUID -ForegroundColor red

}
