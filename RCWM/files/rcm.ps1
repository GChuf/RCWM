#flags used when robocopying (overwrites files):

#/E :: copy subdirectories, including Empty ones
#/NP :: No Progress - don't display percentage copied
#/NJH :: No Job Header
#/NJS :: No Job Summary
#/NC :: No Class - don't log file classes
#/NS :: No Size - don't log file sizes
#/MT[:n] :: Do multi-threaded copies with n threads (default 8)
#/MOVE :: MOVE files AND dirs (delete from source after copying).

#when merging, these are added to not overwrite any files:

#/XC :: eXclude Changed files.
#/XN :: eXclude Newer files.
#/XO :: eXclude Older files.


#check if list of folders to be copied exist

If (  (Test-Path "C:\Windows\System32\RCWM\mv\*" -PathType Leaf) -eq $false ) {
	echo "List of folders to be copied does not exist!"
	Start-Sleep 1
	echo "Create one by right-clicking on folders and selecting 'Move this Directory'."
	Start-Sleep 3
	#exit
}


#set high process priority
$process = Get-Process -Id $pid
$process.PriorityClass = 'High' 


#get cd
$BaseDir = (pwd).path
$BaseDirDisp = '"'
$BaseDirDisp += $BaseDir
$BaseDirDisp += '"'

#get array of contents of files inside C:\windows\system32\RCWM\mv (that would be the pathnames to move)
$files = get-childitem "C:\windows\system32\RCWM\mv"
[string[]]$array = Get-Content $files.fullName



If ( $array.length -eq 1 ) {
	Write-host "You're about to move the following folder into" $BaseDirDisp":"
} else {
	Write-host "You're about to move the following" $array.length "folders into" $BaseDirDisp":"
}
	$array

#Prompt
Do {
	$Valid = $True
	[string]$prompt = Read-Host -Prompt "Is this okay? (Y/N)"
	Switch ($prompt) {

		default {
			Write-Host "Not a valid entry."
			$Valid = $False
		}	

		{"y", "yes" -contains $_} {
			$copy = $True
		}

		{"n", "no" -contains $_} {
	
			Do {
				[string]$prompt = Read-Host -Prompt "Delete list of folders? (Y/N)"
				Switch ($prompt) {

					default {
						Write-Host "Not a valid entry."
						$Valid = $False
					}	
					
					{"y", "yes" -contains $_} {
						Remove-Item C:\Windows\System32\RCWM\mv\*
						Write-Host "List deleted."
						Start-Sleep 2
						exit
					}
					
					{"n", "no" -contains $_} {
						Write-Host "Aborting."
						Start-Sleep 3
						exit
					}

				}
			} Until ($Valid)		

		}
	}
} Until ($Valid)



If ( $copy -eq $True ) {

	write-host "Begin moving ..."
	write-host ""


	for ($i=0; $i -lt $array.length; $i++) {

		#get folder path
		$path = $array[$i]


		#get folder name
		$folder = $path.split("\")[-1]

		#does source folder exist?
		if (-not ($path | Test-Path)) {
			echo "Source folder" $path "does not exist. Continuing."
			continue
		}

		#if exist folder (or file)
		
		If (Test-Path $basedir\$folder) {
			#store folders for merge prompt
			[string[]]$merge += $path
			
		} else {

			#make new directory with the same name as the folder being copied

			New-Item -Path ".\$folder" -ItemType Directory > $null

			C:\Windows\System32\robocopy.exe "$path" "$folder" /MOVE /E /NP /NJH /NJS /NC /NS /MT:32
			
			echo "Finished copying $folder"
		}

	}

		#if merge array exists
		if ($merge) {
		
			Write-host "Successfully moved" $($array.length - $merge.length) "out of" $array.length "folders."
			Write-host "The following" $merge.length "folders already exist inside" $BaseDirDisp":"
			$merge
			Write-host "Cannot move these files! Deleting the list of files ..."
			Remove-Item C:\Windows\System32\RCWM\mv\*		
			Start-Sleep 3
		}


	echo ""
	echo "Finished!"
	Remove-Item C:\Windows\System32\RCWM\mv\*
	Start-Sleep 1

}
