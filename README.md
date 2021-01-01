# Right Click Windows Magic


Right Click Windows Magic is a set of right-click menu tools for admins, power users and other magic beings. If you consider yerself a wizard and would like to save yourself some time and headaches, this is the right set of tools for you.

This little magic pack includes:
- robocopy for copying and moving directories (much faster than regular copy)
- opening CMD or powershell windows into folders or drives
- taking ownership of files, or directories with recursion (takeown && icacls)
- options to boot into Safe Mode from desktop
- option to reboot to recovery (right-click This PC icon)
- opening Control Panel from desktop
- running programs with custom priority
- options to uninstall the changes you've made

You can also remove some right-click menu options, so that your menu doesn't become too cluttered:
- Pin to Quick access
- Pin to Start Screen
- Include in Library
- Send To
- Share
- Add to Windows Media Player


TODO (magic takes time):
- copying files
- creating directory junctions (mklink /D), hard links (mklink /H) and symbolic links [aka soft links] (mklink /J)
- cmd/pwsh opened with admin priv
- rmdir needs to work with admin priv
- mvdir/rcopy also need to work with admin priv
- adding other admin tools to right click in background
- locking folders with passwords?
- your suggestions

![Magic examples](img/RCWM.gif)


# Installation


To install the tools: download the latest zip file under releases ([here](https://github.com/GChuf/RCWM/releases/latest)), unzip it and run the install.cmd script - after that, you'll only need the two most abused keys: __*Y*__ and __*N*__.
If you don't have the administrator privileges on your Windows OS, some magic might not work properly.


# How does it work?

Magic, basically. Right now, the magic happens inside the Windows registry with some help of batch scripting. Some day, this batch magic might evolve into powershell wizardry, but up until now, there was no need for that to happen.

The goal was to simply automate command line tools like robocopy, so that 1) everybody could use it, and 2) it would save some time to those who already know how to use it. While automating the tasks, I've accidentally discovered that I could automate much more than what I thought - and so now, you can select multiple folders to copy/move and paste them all into one folder, just like you can with the regular, slow, lazy windows GUI copy (there are still some problems with overwriting folders, though, and a bug).


# RoboCopy and Move Directory options

RoboCopy/RoboPaste & Move Directory both use robocopy to do the work. 
You have two options: you can copy multiple or single directories at a time.

__Multiple__:
The list of the folder paths to be copied is saved inside multiple files in the *C:\Windows\System32\RCWM\{rc || mv}* folder. Then the script goes through a powershell for loop to copy all of them.

I don't recommend RoboCopying/Moving more than 30 folders at a time (the default windows limit for right-click options is 15, you can increase it to 31 in the install script - see the *MultipleInvokeMinimum.reg* file for more info). Calling multiple (powershell) instances for saving the list of files to be copied can use a lot of resources . . .

You can paste as many folders as you like, though. Recursive copying/moving is also never a problem.

Use this option if you intend to use RoboCopy a lot. I'd recommend reading the rcp/rcm powershell files to understand how the scripts work.

__Single__:
The folder to be copied is written into a file and __overwrites__ any previous folder paths stored there. If you specify a new folder to be copied, the old one (if existing) will be overwritten. It is simpler and faster, and it only uses batch scripting.


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
- <del>powershell scripts (robocopy, mvdir, open powershell) don't work with directories with \[square brackets\] in their names.</del>
Fixed by using -literalPath option
- rmdir and robocopy sometimes need admin privileges (robocopy throws error 5)
- RCWM is not thoroughly tested on Windows 7
  
# Tests
RoboCopy is much faster for copying a large amount of small files.
RmDir is also faster than "standard" delete.


Test results on my machine on an SSD disk:
Folder info: 1.73GB / 12 089 files
- rcopy/normal copy: 43s/91s
- rmdir/normal delete: ~ 3s/4.5s

Results may vary based on your computer and disk - but wherever there are small files, you should benefit.


# Credits

The files for Booting into Safe mode and Running with Priority were heavily influenced by Shawn Brink at [tenforums.com](https://www.tenforums.com/tutorials/1977-windows-10-tutorial-index.html)

The TakeOwn.reg files for Taking Ownership were heavily influenced by Vishal Gupta at [AskVG.com](https://www.askvg.com/) & Shawn Brink.

The Reboot to Recovery option was found somewhere on the internet a while ago. Unfortunately, I cannot remember who the original author is.

I changed and adapted all those files, but their ideas and the initial implementations deserve the credit.

Everything else is my own work, with the help of the Internet.
