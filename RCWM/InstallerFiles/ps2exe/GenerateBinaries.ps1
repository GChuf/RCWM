echo (get-location).path
start-sleep 1
New-Item bin -ItemType "directory" 2>&1>$null
.\ps2exe.ps1 -inputfile RCopySingle.ps1 -outputfile .\bin\rcopyS.exe -noconsole -novisualstyles -x86 -nooutput -iconfile .\rcopy.ico -verbose
.\ps2exe.ps1 -inputfile RCopyMultiple.ps1 -outputfile .\bin\rcopyM.exe -noconsole -novisualstyles -x86 -nooutput -iconfile .\rcopy.ico -verbose
.\ps2exe.ps1 -inputfile MvDirSingle.ps1 -outputfile .\bin\mvdirS.exe -noconsole -novisualstyles -x86 -nooutput -iconfile .\move.ico -verbose
.\ps2exe.ps1 -inputfile MvDirMultiple.ps1 -outputfile .\bin\mvdirM.exe -noconsole -novisualstyles -x86 -nooutput -iconfile .\move.ico -verbose
.\ps2exe.ps1 -inputfile DirectoryLinks.ps1 -outputfile .\bin\dlink.exe -noconsole -novisualstyles -x86 -nooutput -iconfile .\link.ico -verbose
.\ps2exe.ps1 -inputfile FileLinks.ps1 -outputfile .\bin\flink.exe -noconsole -novisualstyles -x86 -nooutput -iconfile .\link.ico -verbose