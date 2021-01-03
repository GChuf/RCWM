#flags used when robocopying (overwrites files):

#/E :: copy subdirectories, including Empty ones
#/NP :: No Progress - don't display percentage copied
#/NJH :: No Job Header
#/NJS :: No Job Summary
#/NC :: No Class - don't log file classes
#/NS :: No Size - don't log file sizes
#/MT[:n] :: Do multi-threaded copies with n threads (default 8)


#when merging, these are added to not overwrite any files:

#/XC :: eXclude Changed files.
#/XN :: eXclude Newer files.
#/XO :: eXclude Older files.


#check if list of folders to be copied exist

If (  (Test-Path "C:\Windows\System32\RCWM\rc\*" -PathType Leaf) -eq $false ) {
	echo "List of folders to be copied does not exist!"
	Start-Sleep 1
	echo "Create one by right-clicking on folders and selecting 'RoboCopy'."
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

#get array of contents of files inside C:\windows\system32\rcwm\rc (that would be the pathnames to copy)
$files = get-childitem "C:\windows\system32\rcwm\rc"
[string[]]$array = Get-Content $files.fullName



If ( $array.length -eq 1 ) {
	Write-host "You're about to copy the following folder into" $BaseDirDisp":"
} else {
	Write-host "You're about to copy the following" $array.length "folders into" $BaseDirDisp":"
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
						Remove-Item C:\Windows\System32\RCWM\rc\*
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

	write-host "Begin copying ..."
	write-host ""


	for ($i=0; $i -lt $array.length; $i++) {

		#get folder path
		$path = $array[$i]


		#get folder name
		$folder = $path.split("\")[-1]

		#does source folder exist?
		if (-not ( Test-Path -literalpath "$path" )) {
			echo "Source folder" $path "does not exist. Continuing."
			continue
		}

		#if exist folder (or file)
		
		If (Test-Path -literalPath ".\$folder") {
			#store folders for merge prompt
			#overwrite - or just copy
			[string[]]$merge += $path
		} else {

			#make new directory with the same name as the folder being copied

			New-Item -Path ".\$folder" -ItemType Directory  > $null

			C:\Windows\System32\robocopy.exe "$path" "$folder" /E /NP /NJH /NJS /NC /NS /MT:32
			
			echo "Finished copying $folder"
		}

	}

		#if merge array exists
		if ($merge) {

		Write-host "Successfully copied" $($array.length - $merge.length) "out of" $array.length "folders."

		Write-host "The following" $merge.length "folders already exist inside" $BaseDirDisp":"
		$merge

			Do {
				$Valid = $True
				[string]$prompt = Read-Host -Prompt "Would you like to overwrite files, merge, or abort? (O/M/A)"
				Switch ($prompt) {
					{"o", "overwrite" -contains $_} {
						echo "Overwriting ..."

						for ($i=0; $i -lt $merge.length; $i++) {
							$path = $merge[$i]
							$folder = $path.split("\")[-1]

							C:\Windows\System32\robocopy.exe "$path" "$folder" /E /NP /NJH /NJS /NC /NS /MT:32

							echo "Finished overwriting $folder"
						}

					}
					{"m", "merge" -contains $_} {
						Write-Host "Merging ..."

						for ($i=0; $i -lt $merge.length; $i++) {
							$path = $merge[$i]
							$folder = $path.split("\")[-1]

							C:\Windows\System32\robocopy.exe "$path" "$folder" /E /NP /NJH /NJS /NC /NS /XC /XN /XO /MT:32
									
							echo "Finished merging $folder"
						}					


					}
					{"A", "abort" -contains $_} {
						Write-Host "Aborted copying the remaining folders."

						Do {
							[string]$prompt = Read-Host -Prompt "Delete list of remaining folders? (Y/N)"
							Switch ($prompt) {
							
								default {
									Write-Host "Not a valid entry."
									$Valid = $False
								}	

								{"y", "yes" -contains $_} {
									Remove-Item C:\Windows\System32\RCWM\rc\*
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
					default {
						Write-Host "Not a valid entry."
						$Valid = $False
					}
				}
			} Until ($Valid)

		}

	echo ""
	echo "Finished!"
	Remove-Item C:\Windows\System32\RCWM\rc\*
	Start-Sleep 1

}
