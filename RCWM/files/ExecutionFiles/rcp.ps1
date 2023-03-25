#if folder name begins with "0", registry doesn't work ..... (\0) == "newline"

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


function NoListAvailable {
	if ($mode -eq "m") {
		echo "List of folders to be $string1 does not exist!"
		Start-Sleep 1
		echo "Create the list by right-clicking on folders and selecting $string2."
		Start-Sleep 3
		exit
	} elseif ($mode -eq "s") {
		echo "Folder to be $string1 does not exist!"
		Start-Sleep 1
		echo "Create one by right-clicking on a folder and selecting $string2."
		Start-Sleep 3
		exit
	}
}

#copy / move
$command = $args[0]
$mode = $args[1]


if ($args[2] -eq $null) #old windows stores info into registry
{
	$regInsert = [string](Get-itemproperty -Path 'HKCU:\RCWM').dir
	
	#concat spaces
	foreach ($part in $regInsert) {[string]$pasteIntoDirectory = [string]$pasteIntoDirectory + [string]$part + " "}
	
	#get rid of last space
	$pasteIntoDirectory = $pasteIntoDirectory.substring(0,$pasteIntoDirectory.length-1)
	
	
} else {

	#fix issues with trailing backslash when copying directly into drives - like C:\
	If (($args[2][-1] -eq "'" ) -and ($args[2][-2] -eq "\" )){ #pwsh v5
		$pasteIntoDirectory = $args[2].substring(1,2)
	} elseif (($args[2][-1] -eq '"' ) -and ($args[2][-2] -eq ':' )){ #pwsh v7
		$pasteIntoDirectory = $args[2].substring(0,2)
	} else {
		$pasteIntoDirectory = $args[2]
	}

}

$pasteDirectoryDisplay = "'" + $pasteIntoDirectory + "'"

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
		NoListAvailable
	}
} catch {
	NoListAvailable
}

#check if list of folders to be copied exist
if ( $arrayLength -eq 0 ) {
	NoListAvailable
}

#skip prompt on single mode
if ($mode -eq "m") {

	if ( $arrayLength -eq 1 ) {
		Write-host "You're about to $string4 the following folder into" $pasteDirectoryDisplay":"
	} else {
		Write-host "You're about to $string4 the following" $array.length "folders into" $pasteDirectoryDisplay":"
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
		[string]$destination = [string]$pasteIntoDirectory + "\" + [string]$folder

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

			New-Item -Path "$destination" -ItemType Directory > $null

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

		Write-host "The following" $merge.length "folders already exist inside" $pasteDirectoryDisplay":"
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
							$destination = $pasteIntoDirectory + "\" + $folder

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
							$destination = $pasteIntoDirectory + "\" + $folder

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

	Remove-ItemProperty -Path "HKCU:\RCWM\$command" -Name * | Out-Null
	echo ""
	Write-Host "Finished!" -ForegroundColor blue
	Start-Sleep 1
}
