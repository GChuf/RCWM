# Right Click Windows Magic


Right Click Windows Magic is a set of right-click (context) menu tools for admins, power users and other magic beings. If you consider yerself a wizard and would like to save yourself some time and headaches, this is the *right* set of context menu tools for you.

This little magic pack includes:
- option to add the old context menu back in Windows 11
- robocopy for copying and moving directories (much faster than regular copy)
- opening CMD or powershell windows into folders or drives
- taking ownership of files, or directories with recursion (takeown && icacls)
- options to boot into Safe Mode
- option to Reboot to Recovery
- opening Control Panel
- running programs with custom priority
- option to always open cmd as admin
- making symbolic/hard links
- opening "God Mode"
- options to uninstall the changes you've made
- options to MoveTo / SendTo folder (from Windows 7)
- signing out from desktop background

You can also remove some right-click menu options, so that your menu doesn't become too cluttered:
- Pin to Quick access
- Pin to Start Screen
- Include in Library
- Send To
- Share
- Add to Windows Media Player
- Scan with Windows Defender

Other removals:
- "Version" tab inside explorer


TODO (magic takes time):
- takeown for files (.exe and other)
- robocopy mirror option
- copying files
- directory juntions for multiple files/folders
- pwsh opened with admin priv
- adding other admin tools to right click in background
- remove "cast to device", check "add to win media player list"
- locking folders with passwords?
- your suggestions

![Magic examples](img/RCWM.gif)


# Installation


To install the tools: download the latest zip file under releases ([here](https://github.com/GChuf/RCWM/releases/latest)), unzip it and run the install.cmd script __as administrator__ - after that, you'll only need the two most abused keys: __*Y*__ and __*N*__ (and maybe a few others).
If you don't have the administrator privileges on your Windows OS, some magic might not work properly.


# How does it work?

Magic, basically. Right now, the magic happens inside the Windows registry with some help of batch and powershell scripting. Some day, this batch magic might evolve into powershell wizardry (it's already happening), but up until now, there was no need for that to happen everywhere.

The goal was to automate command line tools like robocopy, so that 1) everybody could use it, and 2) it would save some time to those who already know how to use it. While automating the tasks, I've accidentally discovered that I could automate much more than what I thought - and so now, you can select multiple folders to copy/move and paste them all into one folder, just like you can with the regular, slow, lazy windows GUI copy.


# RoboCopy and Move Directory options

RoboCopy/RoboPaste & Move Directory both use robocopy to do the work. 
You have two options: you can copy multiple or single directories at a time.

__Single__:
The folder (directory path) to be copied (when you right-click "RoboCopy") is written into registry and __overwrites__ any previous folder paths stored there. If you specify a new folder to be copied, the old one (if existing) will be overwritten. It is simpler and faster.

__Multiple__:
The list of the folder paths to be copied is __appended__ to registry under *C:\Windows\System32\RCWM\{rc || mv}* keys. Then the script goes through a powershell loop to copy all of them.

By default, you can only select up to 15 folders to be copied (the default windows limit for right-click options is 15, you can increase it to 31 or more in the install script - see the *MultipleInvokeMinimum.reg* file for more info). Recursive copying/moving is also never a problem (you can have as many subfolders as you like).

Use this option if you intend to use RoboCopy a lot. I'd recommend reading the rcp.ps1 powershell file to understand how the script works.


RoboCopy (multiple) versus Move Directory (single):

![Single vs Multiple](img/sm.gif)

# Known bugs

- TakeOwn won't work properly when right-clicking on very large amounts of folders (some folders' permissions won't be changed - so you need to do it twice)?
Changing ownership of large amounts of recursive folders works fine though.
- Run with Priority won't show the menu to choose with which priority to run a program - please report if this happens to you
- <del>When selecting multiple folders to be copied/moved, not all of them are saved into the list for copying/moving (~10% loss?)
Fixed with powershell using mutex</del>
Fixed by saving folder paths into files generated with random names
- <del>RoboCopy and MoveDir stopped working when using powershell mutex scripts - work in progress to move existing batch script into powershell to solve the problem. Apparently CMD doesn't like powershell outputs ... </del>?
Fixed by using utf-8 encoding in powershell
Also fixed some other issues by applying UTF-8 in batch (UTF-7 for Windows7)
- <del>powershell scripts (robocopy, mvdir, open powershell) don't work with directories with \[square brackets\] in their names.</del>
Fixed by using -literalPath option
- rmdir and robocopy sometimes need admin privileges (robocopy throws error 5) - if you experience this, takeown or always running cmd as admin will help
  
# Tests
RoboCopy is much faster for copying a large amount of small files.
RmDir is also faster than "standard" delete.


Test results on my machine on an SSD disk:
Folder info: 1.73GB / 12 089 files
- rcopy/normal copy: 43s/91s
- rmdir/normal delete: ~ 3s/4.5s

Results may vary based on your computer and disk - but wherever there are lots of small files, you should benefit.


# Credits

The files for Booting into Safe mode and Running with Priority were heavily influenced by Shawn Brink at [tenforums.com](https://www.tenforums.com/tutorials/1977-windows-10-tutorial-index.html)

The TakeOwn.reg files for Taking Ownership were heavily influenced by Vishal Gupta at [AskVG.com](https://www.askvg.com/) & Shawn Brink.

The Reboot to Recovery option was found somewhere on the internet a while ago. Unfortunately, I cannot remember who the original author is.

I changed and adapted all those files, but their ideas and the initial implementations deserve the credit.

Everything else is my own work, with the help of the Internet.
