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

#Set UTF-8 encoding
[console]::InputEncoding = [text.utf8encoding]::UTF8
[system.console]::OutputEncoding = [System.Text.Encoding]::UTF8

#set high process priority
$process = Get-Process -Id $pid
$process.PriorityClass = 'High' 


#get cd
#$BaseDir = (pwd).path
$BaseDirDisp = '"' + $args[1] + '"'


#copy / move
$command = $args[0]

#single/multiple
$mode = $args[2]

if ($command -eq "mv") {
	$flag = "/MOV"
	$string1 = "moved"
	$string2 = "'Move Directory'"
	$string3 = "moving"
    $string4 = "move"
} elseif  ($command -eq "rc") { #rc
	$flag=""
	$string1 = "copied"
	$string2 = "'RoboCopy'"
	$string3 = "copying"
    $string4 = "copy"
}


#add mirror command



if ($mode -eq "s") {
	$string10 = "List of folders to be $string1 does not exist!"
	$string11 = "Create the list by right-clicking on folders and selecting $string2."
} elseif ($mode -eq "m") { #m
	$string10 = "Folder to be $string1 does not exist!"
	$string11 = "Create one by right-clicking on a folder and selecting $string2."
}


#get array of contents of paths inside HKCU\RCWM\command
$array = (Get-Item -Path Registry::HKCU\RCWM\$command).property 2> $null

#delete '(default)' in first place
$arrayLength = ($array|measure).count

try {
	if ( $array[0] -eq "(default)" ) {
		if ($arrayLength -eq 1) {
			$array = $null
		} else {
			$array = $array[1..($array.Length-1)]
		}
	} elseif ( $array -eq "(default)" ) { #empty registry and powershell v2
		echo $string10
		Start-Sleep 1
		echo $string11
		Start-Sleep 3
		exit
	}
} catch {
	echo $string10
	Start-Sleep 1
	echo $string11
	Start-Sleep 3
	exit
}

#check if list of folders to be copied exist
if ( $arrayLength -eq 0 ) {
	echo "List of folders to be $string1 does not exist!"
	Start-Sleep 1
	echo "Create one by right-clicking on folders and selecting $string2."
	Start-Sleep 3
	exit
}

#skip prompt on single mode
if ($mode -eq "m") {

	if ( $arrayLength -eq 1 ) {
		Write-host "You're about to $string4 the following folder into" $BaseDirDisp":"
	} else {
		Write-host "You're about to $string4 the following" $array.length "folders into" $BaseDirDisp":"
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
							Remove-ItemProperty -Path "HKCU:\RCWM\$command" -Name * | Out-Null
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
	
} else { #on single mode just set $copy to $True
	$copy = $True
}

If ( $copy -eq $True ) {

	write-host "Begin $string3 ..."
	write-host ""


	foreach ($path in $array) {

		#get folder name

		if ($psversiontable.PSVersion.Major -eq 2) {
		$folder = ($path -split "\\")[-1]
		} else {
		$folder = $path.split("\")[-1]
		}

		#concatenation has to be done like this
		$destination = $args[1] + "\" + $folder

		#does source folder exist?
		if (-not ( Test-Path -literalpath "$path" )) {
			echo "Source folder" $path "does not exist."
			continue
		}

		#if exist folder (or file)


		If (Test-Path -literalPath "$destination") {
			#store folders for merge prompt
			#overwrite - or just copy
			[string[]]$merge += $path
		} else {
			#make new directory with the same name as the folder being copied

			New-Item -Path "$destination" -ItemType Directory  > $null

			C:\Windows\System32\robocopy.exe "$path" "$destination" "$flag" /E /NP /NJH /NJS /NC /NS /MT:32
			
			if ($command -eq "mv") { 
				cmd.exe /c rd /s /q "$path"
			}

			echo "Finished $string3 $folder"
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
							$destination = $args[1] + "\" + $folder

							C:\Windows\System32\robocopy.exe "$path" "$destination" "$flag" /E /NP /NJH /NJS /NC /NS /MT:32

							if ($command -eq "mv") { 
								cmd.exe /c cmd.exe /c rd /s /q "$path"
							}

							echo "Finished overwriting $folder"
						}

					}
					{"m", "merge" -contains $_} {
						Write-Host "Merging ..."

						for ($i=0; $i -lt $merge.length; $i++) {
							$path = $merge[$i]
							$folder = $path.split("\")[-1]
							$destination = $args[1] + "\" + $folder

							C:\Windows\System32\robocopy.exe "$path" "$destination" "$flag" /E /NP /NJH /NJS /NC /NS /XC /XN /XO /MT:32
									
							if ($command -eq "mv") { 
								cmd.exe /c rd /s /q "$path"
							}
							echo "Finished merging $folder"
						}					


					}
					{"A", "abort" -contains $_} {
						Write-Host "Aborted $string3 the remaining folders."

						Do {
							[string]$prompt = Read-Host -Prompt "Delete list of remaining folders? (Y/N)"
							Switch ($prompt) {
							
								default {
									Write-Host "Not a valid entry."
									$Valid = $False
								}	

								{"y", "yes" -contains $_} {
									Remove-ItemProperty -Path "HKCU:\RCWM\$command" -Name * | Out-Null
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
	Remove-ItemProperty -Path "HKCU:\RCWM\$command" -Name * | Out-Null
	Start-Sleep 1
}
