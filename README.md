# Right Click Windows Magic


Right Click Windows Magic is a set of right-click menu tools for admins, power users and other magic beings. If you consider yerself a wizard and would like to save yourself some time and headaches, this is the right set of tools for you.

This little magic pack includes:
- robocopy for copying and moving directories (much faster than regular copy)
- opening CMD or powershell windows into folders or drives
- taking ownership of files, or directories with recursion (takeown && icacls)
- options to boot into Safe Mode from desktop
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
- reboot to recovery
- cmd/pwsh opened with admin priv
- rmdir needs to work with admin priv
- move away from mutexes for robocopy
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
The list of the folder paths to be copied is appended to the log file inside the *C:\Windows\System32\RCWM* folder. Then the script goes through a for loop to copy all of them.

I don't recommend RoboCopying (appending to the log file) more than 30 folders at a time. Poweshell uses mutexes to append the folders to the log file and calling multiple instances causes a stack overflow.

You can paste as many folders as you like, though.

__Single__:
The folder to be copied is written into a file and overwrites any previous folder paths stored there. If you specify a new folder to be copied, the old one (if existing) will be overwritten.


# Known bugs

- TakeOwn won't work properly when right-clicking on very large amounts of folders (some folders' permissions won't be changed - so you need to do it twice)
Changing ownership of large amounts of recursive folders works fine though.
- <del>When selecting multiple folders to be copied/moved, not all of them are saved into the list for copying/moving (~10% loss?)</del>
Fixed with powershell using mutex
- <del>RoboCopy and MoveDir stopped working when using powershell mutex scripts - work in progress to move existing batch script into powershell to solve the problem. Apparently CMD doesn't like powershell outputs ... </del>?
Fixed by using utf-8 encoding in powershell

# Tests
RoboCopy is much faster for copying a large amount of small files.
RmDir is also faster than "standard" delete.


Results from gif:
Folder info: 1.73GB / 12 089 files
- rcopy/normal copy: 43s/91s
- rmdir/normal delete: ~ 3s/4.5s

![Magic tests](img/RCWMtest.gif)


# Credits

The files for Booting into Safe mode and Running with Priority were heavily influenced by Shawn Brink at [tenforums.com](https://www.tenforums.com/tutorials/1977-windows-10-tutorial-index.html)

The TakeOwn.reg for Taking Ownership was heavily influenced by Vishal Gupta at [AskVG.com](https://www.askvg.com/)

I changed and adapted all those files, but their ideas and the initial implementations deserve the credit.

Everything else is my own work, with the help of the Internet.
