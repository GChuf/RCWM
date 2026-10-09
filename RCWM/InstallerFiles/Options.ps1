#"current" or "all" - passed by PrepareUsers.ps1, decides where enabled options are recorded
$installMode = $args[0]
$arch = cmd.exe /c echo "%PROCESSOR_ARCHITECTURE%"
$ps = $psversiontable.psversion.major

$winVerMajor = [System.Environment]::OSVersion.Version.Major
$winVerMinor = [System.Environment]::OSVersion.Version.Minor

if ($winVerMajor -eq 10) {
	#powershell.exe is manifested for windows 10+, so this reports the real build (no WMI query needed)
	$build = [System.Environment]::OSVersion.Version.Build
} else {
	$build = 9999999
}


cd ..\files\Temp

if ( ($winVerMajor -ge 11) -or ( ($winVerMajor -eq 10) -and ($build -ge 22000) ) )  {
	#it's windows 11

	while ($true) {
		$mode1 = Read-Host "Enable old context menu (show more options) in Windows 11 (Y/N)"
		if ($mode1 -eq "Y") {break}
		elseif ($mode1 -eq "N") {break}
		else {echo "Invalid input!"}
	}

	if ($mode1 -eq "Y") {

		$initialLocation = Get-Location

		#load all reg hives, apply registry, and unload

		$allUsers = Get-ChildItem -Path Registry::"HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList\S-1-5-21-*"| Select-Object Name
		$loadedHives = @()

		$regFiles = Get-ChildItem -Path . -Filter "Win11AddOldContextMenu.reg" -Recurse -ErrorAction SilentlyContinue
		cmd.exe /c start /w regedit /s Win11AddOldContextMenu.reg #HKLM

		foreach ($user in $allUsers)
		{
			$userName = $user.Name
			#todo pwsh v2
			$UUID = $userName.Split("\")[-1]
			$profilePathKey = [Microsoft.Win32.Registry]::LocalMachine.OpenSubKey("SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList\$UUID")
			$profilePath = $profilePathKey.GetValue("ProfileImagePath")
			$profilePathKey.Close()

			try {
				reg load HKU\$UUID "$profilePath\NTUSER.DAT" 2>&1>$null
				if ($LASTEXITCODE -ne 0) {throw "reg load failed with exit code $LASTEXITCODE"}
				$loadedHives += $UUID
				cd $initialLocation
			} catch {
				#user might have been deleted, C:\users\$user does not exist
				continue
			}

		}

		foreach ($file in $regFiles) {
			cmd.exe /c start /w regedit /s "`"$($file.FullName)`"" #HKU
		}

		# Force release any handles
		[gc]::Collect()
		[gc]::WaitForPendingFinalizers()

		#only unload hives loaded above - logged in users' hives are loaded by windows
		foreach ($UUID in $loadedHives) { reg unload HKU\$UUID 2>&1>$null }

		cd $initialLocation

	}

}

$AddOptions = @(
	New-Object PSObject -Property @{Name = 'x'; RegFile = 'x'; Desc = 'Do you want to add Copy files (using robocopy)'; exception = "rcopy"}
	New-Object PSObject -Property @{Name = 'x'; RegFile = 'x'; Desc = 'Do you want to add Move files (using robocopy)'; exception = "rcmov"}
	New-Object PSObject -Property @{Name = 'PasteFromClipboard'; RegFile = 'PasteFromClipboard.reg'; Desc = 'Do you want to add Paste from Clipboard (using robocopy)'}
	New-Object PSObject -Property @{Name = 'RmItem'; RegFile = 'RmItem.reg'; Desc = 'Do you want to add Remove files'}
	New-Object PSObject -Property @{Name = 'ScpFrom'; RegFile = 'ScpFrom.reg'; Desc = 'Do you want to add SCP from ...'}
	New-Object PSObject -Property @{Name = 'ScpTo'; RegFile = 'ScpTo.reg'; Desc = 'Do you want to add SCP to ...'}
	New-Object PSObject -Property @{Name = 'CMD'; RegFile = 'CMD.reg'; Desc = 'Do you want to add open CMD to background/folders/drives'}
	New-Object PSObject -Property @{Name = 'CMDshift'; RegFile = 'CMDshift.reg'; Desc = 'Do you want to add open CMD to (shift! + right click)'}
	New-Object PSObject -Property @{Name = 'x'; RegFile = 'x'; Desc = 'Do you want to add open PowerShell to background/folders/drives'; exception = "powershellCheck"}
	New-Object PSObject -Property @{Name = 'ControlPanel'; RegFile = 'ControlPanel.reg'; Desc = 'Do you want to add Control Panel to Desktop'}
	New-Object PSObject -Property @{Name = 'CopyToFolder'; RegFile = 'CopyToFolder.reg'; Desc = 'Do you want to add Copy To Folder'}
	New-Object PSObject -Property @{Name = 'Links'; RegFile = 'Links.reg'; Desc = 'Do you want to add symbolic/hard links'}
	New-Object PSObject -Property @{Name = 'Logoff'; RegFile = 'Logoff.reg'; Desc = 'Do you want to add Sign Out to desktop background'}
	New-Object PSObject -Property @{Name = 'Killall'; RegFile = 'Killall.reg'; Desc = 'Do you want to add Kill All to backgrounds'}
	New-Object PSObject -Property @{Name = 'Mirror'; RegFile = 'Mirror.reg'; Desc = 'Do you want to add Mirror option (using robocopy /MIR)'}
	New-Object PSObject -Property @{Name = 'MoveToFolder'; RegFile = 'MoveToFolder.reg'; Desc = 'Do you want to add Move To Folder'}
	New-Object PSObject -Property @{Name = 'RCopyStructure'; RegFile = 'RCopyStructure.reg'; Desc = 'Do you want to add the option to copy Folder Structure only (exclude files)'}
	New-Object PSObject -Property @{Name = 'Shutdown'; RegFile = 'Shutdown.reg'; Desc = 'Do you want to add option to Shutdown in x seconds'}
	New-Object PSObject -Property @{Name = 'Reboot'; RegFile = 'Reboot.reg'; Desc = 'Do you want to add option to Reboot in x seconds'}
	New-Object PSObject -Property @{Name = 'RunWithPriority'; RegFile = 'RunWithPriority.reg'; Desc = 'Do you want to add Run with Priority'}
	New-Object PSObject -Property @{Name = 'SafeMode'; RegFile = 'SafeMode.reg'; Desc = 'Do you want to add Safe Mode to "This PC"'}
	New-Object PSObject -Property @{Name = 'SafeModeDesktop'; RegFile = 'SafeModeDesktop.reg'; Desc = 'Do you want to add Safe Mode to Desktop'}
	New-Object PSObject -Property @{Name = 'TakeOwn'; RegFile = 'TakeOwn.reg'; Desc = 'Do you want to add Take Ownership to files and directories'}
	New-Object PSObject -Property @{Name = 'TakeOwnDrive'; RegFile = 'TakeOwnDrive.reg'; Desc = 'Do you want to add Take Ownership to drives (All but C:\ drive)'}
)

#Add running powershell scripts as admin if on windows 10+
if ($winVerMajor -ge 10) {
     $AddOptions += New-Object PSObject -Property @{Name = 'RunPwshAsAdmin'; RegFile = 'RunPwshAsAdmin.reg'; Desc = 'Do you want to add Run (PowerShell) script as Administrator'}
}


#Add GodMode if OS is not windows 11
if (($winVerMajor -lt 10) -or ($build -lt 22000)) {
     $AddOptions += New-Object PSObject -Property @{Name = 'GodMode'; RegFile = 'GodMode.reg'; Desc = 'Do you want to add God Mode'; exception = "GodMode"}
}

#Add RebootToRecovery if OS is newer than windows 7
if ( ($winVerMajor -gt 6) -or ( ($winVerMajor -eq 6) -and ($winVerMinor -gt 1))) {
    $AddOptions += New-Object PSObject -Property @{Name = 'RebootToRecovery'; RegFile = 'RebootToRecovery.reg'; Desc = 'Do you want to add Reboot to Recovery to "This PC"'}
	$AddOptions += New-Object PSObject -Property @{Name = 'RebootToRecoveryDesktop'; RegFile = 'RebootToRecoveryDesktop.reg'; Desc = 'Do you want to add Reboot to Recovery to Desktop'}
}


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
	New-Object PSObject -Property @{Name = 'ShowFileExtensions'; RegFile = 'ShowFileExtensions.reg'; Desc = 'Do you want to show file extensions in explorer'; exception = "ShowFileExtensions"}
	New-Object PSObject -Property @{Name = 'ShowHiddenFiles'; RegFile = 'ShowHiddenFiles.reg'; Desc = 'Do you want to show hidden files in explorer'; exception = "ShowHiddenFiles"}
	New-Object PSObject -Property @{Name = 'DisableUAC'; RegFile = 'DisableUAC.reg'; Desc = 'Do you want to always disable User Account Control (UAC)'}
	New-Object PSObject -Property @{Name = 'CMDadmin'; RegFile = 'CMDadmin.reg'; Desc = 'Do you want to always open cmd.exe as admin'}
	New-Object PSObject -Property @{Name = 'ThisPC'; RegFile = 'ThisPC.reg'; Desc = 'Do you want to add "This PC" shortcut to Desktop'}
	New-Object PSObject -Property @{Name = 'x'; RegFile = 'x'; Desc = 'Do you want to increase right-click menu item limit (default is 15)'; exception = "MultipleInvoke"}
	New-Object PSObject -Property @{Name = 'EnableLongPaths'; RegFile = 'EnableLongPaths.reg'; Desc = 'Do you want to enable long paths (over 260 characters)'}
)

$MiscOptions += New-Object PSObject -Property @{Name = 'PowershellConsole'; RegFile = 'x'; Desc = 'Do you want faster PowerShell windows (1000-line scrollback instead of 3000+, TrueType font for unicode characters)'; exception = "PowershellConsole"}

#telemetry only exists in powershell 7 (pwsh)
if (Get-Command pwsh -ErrorAction SilentlyContinue) {
	$MiscOptions += New-Object PSObject -Property @{Name = 'DisablePwshTelemetry'; RegFile = 'x'; Desc = 'Do you want to disable PowerShell 7 telemetry for all users (also slightly faster startup)'; exception = "DisablePwshTelemetry"}
}

#exceptions:
function setConsoleKey($userKey, [string]$consoleKey) {
	$k = $userKey.CreateSubKey("Console\$consoleKey")

	#smaller buffer = much faster output (3000 lines: ~0.7s with 300, ~1s with 1000, ~1.6s with 3000+), but less scrollback
	#keep the width - the buffer can't be narrower than the window
	$size = $k.GetValue("ScreenBufferSize")
	$width = if ($size) { $size -band 0xFFFF } else { 120 }
	$k.SetValue("ScreenBufferSize", [int]((1000 -shl 16) -bor $width), [Microsoft.Win32.RegistryValueKind]::DWord)

	#raster fonts (or no font = raster on windows 7) can't display unicode characters - use a TrueType font
	#keep a TrueType font the user already chose (FontFamily bit 0x4 = TrueType)
	$face = $k.GetValue("FaceName")
	$family = $k.GetValue("FontFamily")
	if (-not $face -or $face -eq "Terminal" -or ($family -ne $null -and -not ($family -band 4))) {
		$k.SetValue("FaceName", "Consolas")
		$k.SetValue("FontFamily", 0x36, [Microsoft.Win32.RegistryValueKind]::DWord)
		$k.SetValue("FontWeight", 400, [Microsoft.Win32.RegistryValueKind]::DWord)
		$k.SetValue("FontSize", 0x00100000, [Microsoft.Win32.RegistryValueKind]::DWord) #16px height (raster sizes are width x height)
	}
	$k.Close()
}

function PowershellConsole(){
	#console settings are per user and per executable - key name is the exe path with \ replaced by _
	$consoleKeys = @("%SystemRoot%_System32_WindowsPowerShell_v1.0_powershell.exe")
	$pwsh = Get-Command pwsh -ErrorAction SilentlyContinue
	if ($pwsh) { $consoleKeys += ($pwsh.Source -replace '\\', '_') }

	if ($installMode -eq "all") {
		$loadedHives = @()
		foreach ($user in Get-ChildItem -Path Registry::"HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList\S-1-5-21-*") {
			$UUID = $user.PSChildName
			$userKey = [Microsoft.Win32.Registry]::Users.OpenSubKey($UUID, $true)
			if (-not $userKey) {
				#user not logged in - load the hive
				reg load HKU\$UUID "$($user.GetValue('ProfileImagePath'))\NTUSER.DAT" 2>&1>$null
				if ($LASTEXITCODE -ne 0) { continue } #user might have been deleted
				$loadedHives += $UUID
				$userKey = [Microsoft.Win32.Registry]::Users.OpenSubKey($UUID, $true)
			}
			foreach ($c in $consoleKeys) { setConsoleKey $userKey $c }
			$userKey.Close()
		}
		# Force release any handles
		[gc]::Collect()
		[gc]::WaitForPendingFinalizers()
		foreach ($UUID in $loadedHives) { reg unload HKU\$UUID 2>&1>$null }

		New-ItemProperty -Path "REGISTRY::HKEY_LOCAL_MACHINE\SOFTWARE\RCWM\InstallInfo" -Name "PowershellConsole" 2>&1>$null
	} else {
		foreach ($c in $consoleKeys) { setConsoleKey ([Microsoft.Win32.Registry]::CurrentUser) $c }
		New-ItemProperty -Path "REGISTRY::HKEY_CURRENT_USER\SOFTWARE\RCWM\InstallInfo" -Name "PowershellConsole" 2>&1>$null
	}
}

function DisablePwshTelemetry(){
	#machine-wide environment variable - SetEnvironmentVariable also notifies running programs (explorer),
	#so windows opened from the context menu pick it up without logging off
	[System.Environment]::SetEnvironmentVariable("POWERSHELL_TELEMETRY_OPTOUT", "1", "Machine")

	if ($installMode -eq "all") {
		New-ItemProperty -Path "REGISTRY::HKEY_LOCAL_MACHINE\SOFTWARE\RCWM\InstallInfo" -Name "DisablePwshTelemetry" 2>&1>$null
	} else {
		New-ItemProperty -Path "REGISTRY::HKEY_CURRENT_USER\SOFTWARE\RCWM\InstallInfo" -Name "DisablePwshTelemetry" 2>&1>$null
	}
}


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
	#cmd.exe /c md C:\Program Files\RCWM\GodMode.{ED7BA470-8E54-465E-825C-99712043E01C} 2>NUL
	cmd.exe /c ..\..\InstallerFiles\GodMode.bat | out-null
}

function ShowFileExtensions() {

		$initialLocation = Get-Location

		#load all reg hives, apply registry, and unload

		$allUsers = Get-ChildItem -Path Registry::"HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList\S-1-5-21-*"| Select-Object Name
		$loadedHives = @()

		$regFiles = Get-ChildItem -Path . -Filter "ShowFileExtensions.reg" -Recurse -ErrorAction SilentlyContinue
		cmd.exe /c start /w regedit /s ShowFileExtensions.reg #HKLM

		foreach ($user in $allUsers)
		{
			$userName = $user.Name
			#todo pwsh v2
			$UUID = $userName.Split("\")[-1]
			$profilePathKey = [Microsoft.Win32.Registry]::LocalMachine.OpenSubKey("SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList\$UUID")
			$profilePath = $profilePathKey.GetValue("ProfileImagePath")
			$profilePathKey.Close()

			try {
				reg load HKU\$UUID "$profilePath\NTUSER.DAT" 2>&1>$null
				if ($LASTEXITCODE -ne 0) {throw "reg load failed with exit code $LASTEXITCODE"}
				$loadedHives += $UUID
				cd $initialLocation
			} catch {
				#user might have been deleted, C:\users\$user does not exist
				continue
			}

		}

		foreach ($file in $regFiles) {
			cmd.exe /c start /w regedit /s "`"$($file.FullName)`"" #HKU
		}

		# Force release any handles
		[gc]::Collect()
		[gc]::WaitForPendingFinalizers()
		#only unload hives loaded above - logged in users' hives are loaded by windows
		foreach ($UUID in $loadedHives) { reg unload HKU\$UUID 2>&1>$null }

		cd $initialLocation

}

function ShowHiddenFiles(){


		$initialLocation = Get-Location

		#load all reg hives, apply registry, and unload

		$allUsers = Get-ChildItem -Path Registry::"HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList\S-1-5-21-*"| Select-Object Name
		$loadedHives = @()

		$regFiles = Get-ChildItem -Path . -Filter "ShowHiddenFiles.reg" -Recurse -ErrorAction SilentlyContinue
		cmd.exe /c start /w regedit /s ShowHiddenFiles.reg #HKLM

		foreach ($user in $allUsers)
		{
			$userName = $user.Name
			#todo pwsh v2
			$UUID = $userName.Split("\")[-1]
			$profilePathKey = [Microsoft.Win32.Registry]::LocalMachine.OpenSubKey("SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList\$UUID")
			$profilePath = $profilePathKey.GetValue("ProfileImagePath")
			$profilePathKey.Close()

			try {
				reg load HKU\$UUID "$profilePath\NTUSER.DAT" 2>&1>$null
				if ($LASTEXITCODE -ne 0) {throw "reg load failed with exit code $LASTEXITCODE"}
				$loadedHives += $UUID
				cd $initialLocation
			} catch {
				#user might have been deleted, C:\users\$user does not exist
				continue
			}

		}
		foreach ($file in $regFiles) {
			cmd.exe /c start /w regedit /s "`"$($file.FullName)`"" #HKU
		}

		[gc]::Collect()
		[gc]::WaitForPendingFinalizers()

		#only unload hives loaded above - logged in users' hives are loaded by windows
		foreach ($UUID in $loadedHives) { reg unload HKU\$UUID 2>&1>$null }

		cd $initialLocation

}


function rcmov(){
	while ($true) {
		$mode1 = Read-Host "* Do you want to add 'Move items' for [S]ingle files/directories, or for [M]ultiple?"
		if ($mode1 -eq "S") {enableReg -regFile "MvDirSingle.reg" -name "MvDirSingle"; break}
		elseif ($mode1 -eq "M") {enableReg -regFile "MvDirMultiple.reg" -name "MvDirMultiple"; break}
		else {echo "Invalid input!"}
	}
}

function rcopy() {
	while ($true) {
		$mode1 = Read-Host "* Do you want to add 'Copy items' for [S]ingle files/directories, or for [M]ultiple?"
		if ($mode1 -eq "S") {enableReg -regFile "RCopySingle.reg" -name "RCopySingle"; break}
		elseif ($mode1 -eq "M") {enableReg -regFile "RCopyMultiple.reg" -name "RCopyMultiple"; break}
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
	if ($winVerMajor -eq 6){
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
	param([string]$desc, [string]$regFile, [string]$name, [string[]]$exception)
	while ($true) {
		$r = Read-Host $desc "(Y/N)"
		if ($r -eq "Y") {
			#echo $regFile
			#invoke function with the same name as the $exception
			if ($exception -ne $null) { &"$exception" }
			else {enableReg -regFile $regFile -name $name}
			#Write-Host "$name enabled"
			break
		}
		elseif ($r -eq "N") {break}
		else {echo "Invalid input!"}
	}
}

function enableReg() {
	param([string]$regFile, [string]$name, [string]$mode = $installMode)
	#pwsh v2
	$reg = get-childitem -path . -recurse -include $regFile -ErrorAction SilentlyContinue

	if (-not $reg) {
		throw "Registry file '$regFile' not found"
	} else {
		regedit /s $reg
	}


	if ($mode -eq "all") {
		New-ItemProperty -Path "REGISTRY::HKEY_LOCAL_MACHINE\SOFTWARE\RCWM\InstallInfo" -Name $name 2>&1>$null
	} else {
		New-ItemProperty -Path "REGISTRY::HKEY_CURRENT_USER\SOFTWARE\RCWM\InstallInfo" -Name $name 2>&1>$null
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