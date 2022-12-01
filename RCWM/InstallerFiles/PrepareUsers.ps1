$initialLocation = (get-location).path

$mode = $args

$ps = $psversiontable.psversion.major
$os = [System.Environment]::OSVersion.Version.Major

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

		Write-Host "Prepared registry for user at " -NoNewLine; Write-Host $userPath -ForegroundColor red -NoNewLine; Write-Host " with user ID " -NoNewLine; Write-Host $userGUID -ForegroundColor red
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


	Write-Host "Prepared registry for user at " -NoNewLine; Write-Host $userPath -ForegroundColor red -NoNewLine; Write-Host " with user ID " -NoNewLine; Write-Host $userGUID -ForegroundColor red

}


	cd $InitialLocation
	Write-Host "Preparing files ..."
	#Copy all files to Temp, copy specific files to Temp and overwrite old ones

	New-Item Temp -ItemType "directory" 2>&1>$null
	Copy-Item -Path ".\ExecutionFiles\*" -Destination ".\Temp"
	Copy-Item -Path ".\RegistryFiles\*" -Destination ".\Temp"
	
	#Overwrite default files with specific files - if they exist/if applicable
	Copy-Item -Path ".\PowershellSpecificFiles\pwsh$ps\*" -Destination ".\Temp" 2>&1>$null
	Copy-Item -Path ".\OSSpecificFiles\Win$os\*" -Destination ".\Temp" 2>&1>$null
	
	Copy-Item -Path "..\InstallerFiles\ps2exe\*" -Destination ".\Temp"


if ($mode -eq "current" ) {
	#change registry files to only apply to current user.
	
	$files = Get-ChildItem ".\Temp\*.reg"
	
	foreach ($file in $files){
		(Get-Content $file) -Replace 'HKEY_CLASSES_ROOT', 'HKEY_CURRENT_USER' | Set-Content $file
		#KEY_USERS\S-1-5-21-117113989-4160453655-1229134872-1001
	}
	
	#exceptions
	#MultipleInvokeMinimum
	(Get-Content ".\Temp\MultipleInvokeMinimum.reg") -Replace 'HKEY_LOCAL_MACHINE', 'HKEY_CURRENT_USER' | Set-Content ".\Temp\MultipleInvokeMinimum.reg"
	(Get-Content ".\Temp\MultipleInvokeMinimum64.reg") -Replace 'HKEY_LOCAL_MACHINE', 'HKEY_CURRENT_USER' | Set-Content ".\Temp\MultipleInvokeMinimum64.reg"
	(Get-Content ".\Temp\MultipleInvokeMinimum128.reg") -Replace 'HKEY_LOCAL_MACHINE', 'HKEY_CURRENT_USER' | Set-Content ".\Temp\MultipleInvokeMinimum128.reg"
	(Get-Content ".\Temp\Win11AddOldContextMenu.reg") -Replace 'HKEY_LOCAL_MACHINE', 'HKEY_CURRENT_USER' | Set-Content ".\Temp\Win11AddOldContextMenu.reg"
	(Get-Content ".\Temp\ThisPC.reg") -Replace 'HKEY_LOCAL_MACHINE', 'HKEY_CURRENT_USER' | Set-Content ".\Temp\ThisPC.reg"
	(Get-Content ".\Temp\CMDAdmin.reg") -Replace 'HKEY_LOCAL_MACHINE', 'HKEY_CURRENT_USER' | Set-Content ".\Temp\CMDAdmin.reg"
	
	#include in library is only configured for all users.
	
}

	#Generate .exe files
	#don't touch this very fragile part ...
	New-Item Temp\bin -ItemType "directory" 2>&1>$null
	powershell .\Temp\ps2exe.ps1 -inputfile Temp\RCopySingle.ps1 -outputfile Temp\bin\rcopyS.exe -noconsole -novisualstyles -x86 -nooutput -iconfile Temp\rcopy.ico -verbose
	powershell .\Temp\ps2exe.ps1 -inputfile Temp\RCopyMultiple.ps1 -outputfile Temp\bin\rcopyM.exe -noconsole -novisualstyles -x86 -nooutput -iconfile Temp\rcopy.ico -verbose
	powershell .\Temp\ps2exe.ps1 -inputfile Temp\MvDirSingle.ps1 -outputfile Temp\bin\mvdirS.exe -noconsole -novisualstyles -x86 -nooutput -iconfile Temp\move.ico -verbose
	powershell .\Temp\ps2exe.ps1 -inputfile Temp\MvDirMultiple.ps1 -outputfile Temp\bin\mvdirM.exe -noconsole -novisualstyles -x86 -nooutput -iconfile Temp\move.ico -verbose
	powershell .\Temp\ps2exe.ps1 -inputfile Temp\DirectoryLinks.ps1 -outputfile Temp\bin\dlink.exe -noconsole -novisualstyles -x86 -nooutput -iconfile Temp\link.ico -verbose
	powershell .\Temp\ps2exe.ps1 -inputfile Temp\FileLinks.ps1 -outputfile Temp\bin\flink.exe -noconsole -novisualstyles -x86 -nooutput -iconfile Temp\link.ico -verbose


	if ($os -lt 10) { #Generate shortcuts for win7 and win8
		.\InstallerFiles\shortcuts.ps1
	}


Write-Host "Preparation finished."