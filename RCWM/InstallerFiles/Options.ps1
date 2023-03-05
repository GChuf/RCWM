$arch = cmd.exe /c echo "%PROCESSOR_ARCHITECTURE%"
#$arch = (Get-WmiObject win32_processor | Where-Object{$_.deviceID -eq "CPU0"}).AddressWidth
$ps = $psversiontable.psversion.major
$os = [System.Environment]::OSVersion.Version.Major

cd ..\files\Temp

$users = $args[0]

[array]$UUIDs = @()
foreach ($user in $users) {
	$UUID = $user.Split("\")[-1]
	$UUIDs += $UUID
}

$AddOptions = @(
	New-Object PSObject -Property @{Name = 'x'; RegFile = 'x'; Desc = 'Do you want to add RoboCopy Directory'; exception = "RCopy"}
	New-Object PSObject -Property @{Name = 'x'; RegFile = 'x'; Desc = 'Do you want to add Move Directory (using robocopy)'; exception = "MvDir"}
	New-Object PSObject -Property @{Name = 'x'; RegFile = 'x'; Desc = 'Do you want to add Remove Directory'; exception = "RmDirectory"}
	New-Object PSObject -Property @{Name = 'CMD'; RegFile = 'CMD.reg'; Desc = 'Do you want to add open CMD to background/folders/drives'}
	New-Object PSObject -Property @{Name = 'CMDshift'; RegFile = 'CMDshift.reg'; Desc = 'Do you want to add open CMD to (shift! + right click)'}
	New-Object PSObject -Property @{Name = 'x'; RegFile = 'x'; Desc = 'Do you want to add open PowerShell to background/folders/drives'; exception = "powershellCheck"}
	New-Object PSObject -Property @{Name = 'ControlPanel'; RegFile = 'ControlPanel.reg'; Desc = 'Do you want to add Control Panel to Desktop'}
	New-Object PSObject -Property @{Name = 'CopyToFolder'; RegFile = 'CopyToFolder.reg'; Desc = 'Do you want to add Copy To Folder'}
	New-Object PSObject -Property @{Name = 'GodMode'; RegFile = 'GodMode.reg'; Desc = 'Do you want to add God Mode'; exception = "GodMode"}
	New-Object PSObject -Property @{Name = 'Links'; RegFile = 'Links.reg'; Desc = 'Do you want to add symbolic/hard links'}
	New-Object PSObject -Property @{Name = 'Logoff'; RegFile = 'Logoff.reg'; Desc = 'Do you want to add Sign Off to desktop background'}
	New-Object PSObject -Property @{Name = 'Mirror'; RegFile = 'Mirror.reg'; Desc = 'Do you want add RoboCopy Mirror option'}
	New-Object PSObject -Property @{Name = 'MoveToFolder'; RegFile = 'MoveToFolder.reg'; Desc = 'Do you want to add Move To Folder'}
	New-Object PSObject -Property @{Name = 'RCopyStructure'; RegFile = 'RCopyStructure.reg'; Desc = 'Do you want to add RoboCopy to copy Folder Structure only (exclude files)'}
	New-Object PSObject -Property @{Name = 'RebootToRecovery'; RegFile = 'RebootToRecovery.reg'; Desc = 'Do you want to add Reboot to Recovery to "This PC"'}
	New-Object PSObject -Property @{Name = 'RebootToRecoveryDesktop'; RegFile = 'RebootToRecoveryDesktop.reg'; Desc = 'Do you want to add Reboot to Recovery to Desktop'}
	New-Object PSObject -Property @{Name = 'RunWithPriority'; RegFile = 'RunWithPriority.reg'; Desc = 'Do you want to add Run with Priority'}
	New-Object PSObject -Property @{Name = 'SafeMode'; RegFile = 'SafeMode.reg'; Desc = 'Do you want to add Safe Mode to "This PC"'}
	New-Object PSObject -Property @{Name = 'SafeModeDesktop'; RegFile = 'SafeModeDesktop.reg'; Desc = 'Do you want to add Safe Mode to Desktop'}
	New-Object PSObject -Property @{Name = 'TakeOwn'; RegFile = 'TakeOwn.reg'; Desc = 'Do you want to add Take Ownership to files and directories'}
	New-Object PSObject -Property @{Name = 'TakeOwnDrive'; RegFile = 'TakeOwnDrive.reg'; Desc = 'Do you want to add Take Ownership to drives (All but C:\ drive)'}
)

$RemoveOptions = @(
	New-Object PSObject -Property @{Name = 'DeleteLibrary'; RegFile = 'DeleteLibrary.reg'; Desc = 'Do you want to remove Include in Library (only possible to remove for ALL users)'}
	New-Object PSObject -Property @{Name = 'DeletePinQuick'; RegFile = 'DeletePinQuick.reg'; Desc = 'Do you want to remove Pin to quick access'}
	New-Object PSObject -Property @{Name = 'DeletePinStartScreen'; RegFile = 'DeletePinStartScreen.reg'; Desc = 'Do you want to remove Pin to Start'}
	New-Object PSObject -Property @{Name = 'DeletePrevVersons'; RegFile = 'DeletePrevVersons.reg'; Desc = 'Do you want to remove Previous Versions tab in explorer'}
	New-Object PSObject -Property @{Name = 'DeleteScanDefender'; RegFile = 'DeleteScanDefender.reg'; Desc = 'Do you want to remove Scan with Windows Defender'}
	New-Object PSObject -Property @{Name = 'DeleteSendTo'; RegFile = 'DeleteSendTo.reg'; Desc = 'Do you want to remove Send To'}
	New-Object PSObject -Property @{Name = 'DeleteShare'; RegFile = 'DeleteShare.reg'; Desc = 'Do you want to remove Share'}
	New-Object PSObject -Property @{Name = 'DeleteWinPlayer'; RegFile = 'DeleteWinPlayer.reg'; Desc = 'Do you want to remove Add to Windows Media Player'}
)

$MiscOptions = @(
	New-Object PSObject -Property @{Name = 'CMDadmin'; RegFile = 'CMDadmin.reg'; Desc = 'Do you want to always open cmd.exe as admin '}
	New-Object PSObject -Property @{Name = 'ThisPC'; RegFile = 'ThisPC.reg'; Desc = 'Do you want to add "This PC" shortcut to Desktop'}
	New-Object PSObject -Property @{Name = 'x'; RegFile = 'x'; Desc = 'Do you want to increase right-click menu item limit (default is 15)'; exception = "MultipleInvoke"}
)

#exceptions:
function MultipleInvoke(){
	while ($true) {
		$mode1 = Read-Host "* Increase to 32[1], 64[2] or 128[3]"
		if ($mode1 -eq "1") {enableReg -regFile "MultipleInvokeMinimum.reg" -name "MultipleInvokeMinimum"; break}
		elseif ($mode1 -eq "2") {enableReg -regFile "MultipleInvokeMinimum64.reg" -name "MultipleInvokeMinimum64"; break}
		elseif ($mode1 -eq "3") {enableReg -regFile "MultipleInvokeMinimum128.reg"  -name "MultipleInvokeMinimum128"; break}
		else {echo "Invalid input!"}
	}
}

function GodMode(){
	enableReg -regFile "GodMode.reg" -name GodMode
	#cmd.exe /c md C:\windows\RCWM\GodMode.{ED7BA470-8E54-465E-825C-99712043E01C} 2>NUL
	cmd.exe /c ..\..\InstallerFiles\GodMode.bat | out-null
}

function MvDir(){
	while ($true) {
		$mode1 = Read-Host "* Do you want to add 'Move Directory' for [S]ingle directories, or for [M]ultiple?"
		if ($mode1 -eq "S") {enableReg -regFile "MvDirSingle.reg" -name "MvDirSingle"; break}
		elseif ($mode1 -eq "M") {enableReg -regFile "MvDirMultiple.reg" -name "MvDirMultiple"; break}
		else {echo "Invalid input!"}
	}
}

function RCopy() {
	while ($true) {
		$mode1 = Read-Host "* Do you want to add 'RoboCopy Directory' for [S]ingle directories, or for [M]ultiple?"
		if ($mode1 -eq "S") {enableReg -regFile "RCopySingle.reg" -name "RCopySingle"; break}
		elseif ($mode1 -eq "M") {enableReg -regFile "RCopyMultiple.reg" -name "RCopyMultiple"; break}
		else {echo "Invalid input!"}
	}
}

function RmDirectory(){
	while ($true) {
		Write-Host "* The faster Remove Directory option also removes symlink contents, not symlinks themselves."
		$mode1 = Read-Host "* Do you want to add the [F]ast Remove Directory option, or the [S]afer/slower one "
		if ($mode1 -eq "S") {enableReg -regFile "RmDirS.reg" -name "RmDirS"; break}
		elseif ($mode1 -eq "F") {enableReg -regFile "RmDir.reg" -name "RmDir"; break}
		else {echo "Invalid input!"}
	}
}

function powershellCheck(){
	#IF !pwsh! LSS 4 ( 
	#    IF "%PROCESSOR_ARCHITECTURE%" EQU "amd64" ( start /w regedit /s pwrshell32.reg ) else ( start /w regedit /s pwrshell64.reg )
	#) ELSE ( start /w regedit /s pwrshell.reg )
	#)

	#todo: check 32bit!
	#https://superuser.com/questions/305901/possible-values-of-processor-architecture
	if ($ps -lt 4){
		if ($arch -eq "amd64"){
			enableReg -regFile "pwrshell64.reg" -name "Pwrshell64"
		} else {
			enableReg -regFile "pwrshell32.reg" -name "Pwrshell32"
		}
	} else {
		enableReg -regFile "pwrshell.reg" -name "Pwrshell"
	}

}

function prompt() {
	param([string[]]$desc, [string[]]$regFile, [string[]]$name, [string[]]$exception)
	while ($true) {
		$r = Read-Host $desc "(Y/N)"
		if ($r -eq "Y") {
			#echo $regFile
			#invoke function with the same name as the $exception
			if ($exception -ne $null) { &"$exception" }
			else {enableReg -regFile $regFile -name $name}
			#write-host "$name enabled"
			break
		}
		elseif ($r -eq "N") {break}
		else {echo "Invalid input!"}
	}
}


function getUsers(){
	#get all subdirectories, see which users are you installing for
	#this should be a parameter passed on from PrepareUsers
	
}

function enableReg() {
	param([string[]]$regFile, [string]$name)
	#pwsh v2
	$regs = get-childitem -path . -recurse -include $regFile
	#$regs = get-childitem $regFile -depth 1
	#write-host $regs
	foreach ($reg in $regs) {
		regedit /s $reg
	}
	
	#add info in registry about which options are installed
	#insert to all UUIDs passed from PrepareUsers ($args[0])
	if ($UUIDs -ne $null) {
		foreach ($uuid in $UUIDs) {
			New-ItemProperty -Path "REGISTRY::HKEY_USERS\$uuid\RCWM\InstallInfo" -Name $name 2>&1>$null
		}
	} else { #current only
		New-ItemProperty -Path "REGISTRY::HKEY_CURRENT_USER\RCWM\InstallInfo" -Name $name 2>&1>$null
	}

}

while ($true) {
	Write-Host ""
	$r = Read-Host "Do you want to Add options to context menu (Y/N)"
	if ($r -eq "Y") {
		foreach ($option in $AddOptions) {
			prompt -desc $option.Desc -regFile $option.RegFile -name $option.Name -exception $option.exception
			
		}
		break
	}
	elseif ($r -eq "N") {break}
	else {echo "Invalid input!"}
}

while ($true) {
	Write-Host ""
	$r = Read-Host "Do you want to Remove options from context menu (Y/N)"
	if ($r -eq "Y") {
		foreach ($option in $RemoveOptions) {
			prompt -desc $option.Desc -regFile $option.RegFile -name $option.Name -exception $option.exception
		}
		break
	}
	elseif ($r -eq "N") {break}
	else {echo "Invalid input!"}
}

while ($true) {
	Write-Host ""
	$r = Read-Host "Do you want to see other, Miscellaneous options (Y/N)"
	if ($r -eq "Y") {
		foreach ($option in $MiscOptions) {
			prompt -desc $option.Desc -regFile $option.RegFile -name $option.Name -exception $option.exception
		}
		break
	}
	elseif ($r -eq "N") {break}
	else {echo "Invalid input!"}
}