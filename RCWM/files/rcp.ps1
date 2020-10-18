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
 

#check if rc.log exists
If ( (Test-Path C:\Windows\System32\RCWM\rc.log) -eq $false ) {
	echo "List of folders to be copied does not exist!"
	Start-Sleep 1
	echo "Create one by right-clicking on folders and selecting 'RoboCopy'."
	Start-Sleep 3
	exit
}	


#set high process priority
$process = Get-Process -Id $pid
$process.PriorityClass = 'High' 


#get cd
$BaseDir = (pwd).path
$BaseDirDisp = '"'
$BaseDirDisp += $BaseDir
$BaseDirDisp += '"'


[string[]]$array = Get-Content -Path C:\Windows\System32\RCWM\rc.log


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
					Remove-Item C:\Windows\System32\RCWM\rc.log
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


		#if exist folder
		
		If (Test-Path $basedir\$folder) {
			#store folders for merge prompt
			#overwrite - or just copy
			[string[]]$merge += $path
		} else {
			#todo -to so 3 linije zdej
			#echo "Copying" $path "..."
			
			#make new directory with the same name as the folder being copied

			New-Item -Path ".\$folder" -ItemType Directory | Out-Null

			C:\Windows\System32\robocopy.exe "$path" "$folder" /E /NP /NJH /NJS /NC /NS /MT:16
			
			#delete first line here?
			(Get-Content C:\Windows\System32\RCWM\rc.log | Select-Object -Skip 1) | Set-Content C:\Windows\System32\RCWM\rc.log		
			#Start-Sleep 20		
			echo "Finished copying $folder"				
		}

	}	

		#if merge array exists
		if ($merge) {
		
		Write-host "Successfully copied" '$array.length - $merge.length' "out of" $array.length "folders."
		#todo merge acts like before array
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
		
							New-Item -Path ".\$folder" -ItemType Directory | Out-Null

							C:\Windows\System32\robocopy.exe "$path" "$folder" /E /NP /NJH /NJS /NC /NS /MT:16
							
							(Get-Content C:\Windows\System32\RCWM\rc.log | Select-Object -Skip 1) | Set-Content C:\Windows\System32\RCWM\rc.log		
							echo "Finished overwriting $folder"		
						}

					}
					{"m", "merge" -contains $_} {
						Write-Host "Merging ..."
						
						
						for ($i=0; $i -lt $merge.length; $i++) {
							$path = $merge[$i]
							$folder = $path.split("\")[-1]
		
							New-Item -Path ".\$folder" -ItemType Directory | Out-Null

							C:\Windows\System32\robocopy.exe "$path" "$folder" /E /NP /NJH /NJS /NC /NS /XC /XN /XO /MT:16
							
							(Get-Content C:\Windows\System32\RCWM\rc.log | Select-Object -Skip 1) | Set-Content C:\Windows\System32\RCWM\rc.log		
							echo "Finished merging $folder"		
						}					
						

						
					}
					{"A", "abort" -contains $_} {
						Write-Host "Aborted copying the remaining folders."
					
					
						#todo duplication, kinda. prompt is not the same text
						Do {
							[string]$prompt = Read-Host -Prompt "Delete list of remaining folders? (Y/N)"
							Switch ($prompt) {
							
								default {
								Write-Host "Not a valid entry."
								$Valid = $False
								}	
								
								{"y", "yes" -contains $_} {
								Remove-Item C:\Windows\System32\RCWM\rc.log
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
	Remove-Item C:\Windows\System32\RCWM\rc.log
	Start-Sleep 2

}





