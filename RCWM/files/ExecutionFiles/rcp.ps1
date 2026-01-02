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

$host.UI.RawUI.WindowTitle = "RCWM: robocopy"
Write-host "RCWM v3.0.0"

#set high process priority
$process = Get-Process -Id $pid
$process.PriorityClass = 'High'
$sysRoot = (cmd.exe /c echo %SystemRoot%).Trim()
$robocopy = Join-Path $sysRoot "System32\robocopy.exe"

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
	} elseif ($mode -eq "p") {
		echo "Items to be $string1 do not exist!"
		Start-Sleep 1
		echo "Try selecting and pressing Ctrl+C again."
		Start-Sleep 3
		exit
	}
}
$command = $args[0] #copy / move / mirror
$mode = $args[1] #single, multiple, paste (from clipboard)

if ($command -eq "rcmov") {
	$flag = "/MOV"
	$string1 = "moved"
	$string2 = "'Move file/directory'"
	$string3 = "moving"
    $string4 = "move"
} elseif  ($command -eq "rcopy") {
	$flag=""
	$string1 = "copied"
	$string2 = "'Copy file/directory'"
	$string3 = "copying"
    $string4 = "copy"
} elseif  ($command -eq "miror") {
	$flag="/MIR"
	$string1 = "mirrored"
	$string2 = "'Mirror Source'"
	$string3 = "mirroring"
    $string4 = "mirror"
}


#get directory into which we paste
if ($args[2] -eq $null) #pwsh 4 and less, uses rcp.cmd: reg add HKCU\SOFTWARE\RCWM /v dir /t REG_MULTI_SZ /f /d %1 1>NUL
{
	$regInsert = (Get-itemproperty -Path 'HKCU:\SOFTWARE\RCWM').dir #must not be string, but string array

	#fix inserts like "\0" into registry, which translates into new line ... (every folder that starts with "0" has this problem)

	if ($regInsert.count -ge 2) { #if more than 1 line

		foreach ($part in $regInsert) {
			[string]$tempString += [string]$part + "\0"
		}

		#subtract last 2 symbols
		[string]$destDir = [string]$tempString.substring(0,$tempString.length-2)

	}
	if ($regInsert[0][2] -eq '"') { #copying directly into a drive
		$destDir = $reginsert[0].substring(0,2)
	} else {
		$destDir = [string](Get-itemproperty -Path 'HKCU:\SOFTWARE\RCWM').dir
	}

} else {

	#fix issues with trailing backslash when copying directly into drives
	If (($args[2][-1] -eq "'" ) -and ($args[2][-2] -eq "\" )){ #pwsh v5
		$destDir = $args[2].substring(1,2)
	} elseif (($args[2][-1] -eq '"' ) -and ($args[2][-2] -eq ':' )){ #pwsh v7
		$destDir = $args[2].substring(0,2)
	} else {
		$destDir = $args[2]
	}

}

$destDirectoryDisplay = "'" + $destDir + "'"


if ($mode -eq "p") {

	#get list form clipboard
	#check if folders and files exist
	Add-Type -AssemblyName System.Windows.Forms

	$array = [System.Windows.Forms.Clipboard]::GetFileDropList()
	$arrayLength = ($array|measure).count
	if ($arrayLength -eq 0) {
		NoListAvailable
	}

} else {

	#get array of contents of paths inside HKCU\SOFTWARE\RCWM\command
	$array = (Get-Item -Path Registry::HKCU\SOFTWARE\RCWM\$command).property 2> $null

	$arrayLength = ($array|measure).count

	#delete '(default)' in first place
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
	
}



#skip prompt on single mode
if ($mode -ne "s") {

	if ( $arrayLength -eq 1 ) {
		Write-host "You're about to $string4 the following file/folder into" $destDirectoryDisplay":"
	} else {
		Write-host "You're about to $string4 the following" $arrayLength "files/folders into" $destDirectoryDisplay":"
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
							Remove-ItemProperty -Path "HKCU:\SOFTWARE\RCWM\$command" -Name * | Out-Null
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

	Write-Host "Begin $string3 ..."
	Write-Host ""

	foreach ($fullPath in $array) {

		if (Test-Path -LiteralPath "$fullPath" -PathType Container) { #if source is a folder
			$isDirectory = $true
			if ($psversiontable.PSVersion.Major -eq 2) {
				$sourceDir = ($fullPath -split "\\")[-1]
			} else {
				$sourceDir = $fullPath.split("\")[-1]
			}

			$filename = ""

			$sourceDirFullPath = $fullPath
			#dest: target dir + folder
			[string]$destination = [string]$destDir + "\" + [string]$sourceDir

			#destination check for merge
			[string]$destinationToCheck = [string]$destination
			#echo "checking destination: folder:"
			#echo $destinationToCheck

		} elseif (Test-Path -LiteralPath "$fullPath" -PathType Leaf) { #if source is a file
			$isDirectory = $false
			write-host "source is a file"
			if ($psversiontable.PSVersion.Major -eq 2) {
				$sourceDir = ($fullPath -split "\\")[-2]
				$filename = ($fullPath -split "\\")[-1]
			} else {
				$sourceDir = $fullPath.split("\")[-2]
				$filename = $fullPath.split("\")[-1]
				Write-Host "directory: $sourceDir, filename: $filename"
				#start-sleep 5
			}

			#trim filename from the path - filename is passed as another argument into robocopy
			#and is empty in case source is a folder
			$sourceDirFullPath = ($fullPath -replace "\\$filename$", "")

			#dest: target dir
			[string]$destination = [string]$destDir

			#destination check for merge
			[string]$destinationToCheck = [string]$destDir + "\" + [string]$filename
		} else {
			Write-Host "Source file or folder" $fullPath "does not exist!"
			Start-Sleep 1
			continue
		}

		#if folder (or file) exists in the destination
		if (Test-Path -literalPath "$destinationToCheck") {
			#store folders for merge prompt
			#overwrite - or just copy
			[string[]]$merge += $destinationToCheck
		} else {
			#if the source! is a folder, make new directory with the same name as the folder being copied
			if ($isDirectory) {
				New-Item -Path "$destination" -ItemType Directory > $null
			}
			Write-Host "Executing $robocopy $sourceDirFullPath $destination $filename $flag /E /NP /NJH /NJS /NC /NS /MT:32"
			& $robocopy "$sourceDirFullPath" "$destination" "$filename" "$flag" /E /NP /NJH /NJS /NC /NS /MT:32

			if ($command -eq "rcmov" -and $isDirectory) {
				#Write-Host "removing: $sourceDirFullPath"
				cmd.exe /c rd /s /q "$sourceDirFullPath"
			}

			echo "Finished $string3 $sourceDirFullPath\$filename"
		}
	}

	#if merge array exists
	if ($merge) {

		Write-host "Successfully copied" $($arrayLength - $merge.length) "out of" $arrayLength "folders."

		if ($merge.length -eq 1) {
			Write-host "The following folder or file already exists inside" $destDirectoryDisplay":"
		} else {
			Write-host "The following" $merge.length "folders or files already exist inside" $destDirectoryDisplay":"
		}
		$merge

		Do {
			$Valid = $True
			Write-host "Would you like to [O]verwrite files, [M]erge, or [A]bort?"
			Write-host "Overwrite flags: /E"
			Write-host "Merge flags:     /E /XC /XN /XO"
			[string]$prompt = Read-Host -Prompt "(O/M/A)"
			Switch ($prompt) {
				{"o", "overwrite" -contains $_} {
					echo "Overwriting ..."

					for ($i=0; $i -lt $merge.length; $i++) {
						$fullPath = $merge[$i]
						$sourceDir = $fullPath.split("\")[-1]
						$destination = $destDir + "\" + $sourceDir

						#todo duplicated code
						if (Test-Path -LiteralPath "$fullPath" -PathType Container) { #if source is a folder
							$isDirectory = $true
						}

						& $robocopy "$fullPath" "$destination" "$flag" /E /NP /NJH /NJS /NC /NS /MT:32

						if ($command -eq "rcmov" -and $isDirectory) {
							Write-Host "directory."
							start-sleep 5
							#cmd.exe /c cmd.exe /c rd /s /q "$fullPath"
						} else {
							Write-Host "file."
							start-sleep 5
						}

						echo "Finished overwriting $sourceDir"
					}

				}
				{"m", "merge" -contains $_} {
					Write-Host "Merging ..."

					for ($i=0; $i -lt $merge.length; $i++) {
						$fullPath = $merge[$i]
						$sourceDir = $fullPath.split("\")[-1]
						$destination = $destDir + "\" + $sourceDir

						#todo duplicated code
						if (Test-Path -LiteralPath "$fullPath" -PathType Container) { #if source is a folder
							$isDirectory = $true
						}

						& $robocopy "$fullPath" "$destination" "$flag" /E /NP /NJH /NJS /NC /NS /XC /XN /XO /MT:32
								
						if ($command -eq "rcmov" -and $isDirectory) {
							Write-Host "directory."
							start-sleep 5
							#cmd.exe /c cmd.exe /c rd /s /q "$fullPath"
						} else {
							Write-Host "file."
							start-sleep 5
						}
						echo "Finished merging $sourceDir"
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

								if ($mode -eq "p") {
									[System.Windows.Forms.Clipboard]::Clear()
								} else {
									Remove-ItemProperty -Path "HKCU:\SOFTWARE\RCWM\$command" -Name * | Out-Null
								}
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

	if ($mode -eq "p") {
		[System.Windows.Forms.Clipboard]::Clear()
	} else {
		Remove-ItemProperty -Path "HKCU:\SOFTWARE\RCWM\$command" -Name * | Out-Null
	}
	echo ""
	Write-Host "Finished!" -ForegroundColor blue
	Start-Sleep 1000
}
