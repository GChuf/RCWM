# Right Click Windows Magic


Right Click Windows Magic is a set of right-click menu tools for admins, power users and other magic beings. If you consider yerself a wizard and would like to save yourself some time and headaches, this is the right set of tools for you.

This little magic pack includes:
- robocopy for copying and moving directories (much faster than regular copy)
- opening CMD or powershell windows into folders or drives
- taking ownership of files, or directories with recursion
- options to boot into Safe Mode from desktop
- opening Control Panel from desktop
- running programs with custom priority

You can also remove some right-click menu options, so that your menu doesn't become too cluttered:
- Pin to Quick menu
- Pin to Start Screen
- Include in Library
- Send To
- Share 


TODO (magic takes time):
- copying files
- creating junctions (soft links)
- your suggestions

![Magic examples](img/RCWM.gif)


# Installation


To install the tools: download the zip file, unzip it and run the install.cmd script inside the "files" folder - after that, you'll only need the two most famous keys: Y and N.
If you don't have the administrator privileges on your Windows OS, I'm afraid you won't see much magic.


# How does it work?

Magic, basically. Right now, the magic happens inside the Windows registry with some help of batch scripting. Some day, this batch magic might evolve into powershell wizardry, but up until now, there was no need for that to happen.

The goal was to simply automate command line tools like robocopy, so that 1) everybody could use it, and 2) it would save some time to those who already know how to use it. While automating the tasks, I've accidentally discovered that I could automate much more than what I thought - and so now, you can select multiple folders to copy/move and paste them all into one folder, just like you can with the regular, slow, lazy windows GUI copy (there are still some problems with overwriting folders, though, and a bug).


# RoboCopy and Move Directory options

RoboCopy/RoboPaste & Move Directory both use robocopy to do the work. The list of the folders to be copied is first saved into a log file inside the C:\Windows\System32\RCWM folder.
The default version only works for copying/moving one folder at a time. If you specify a new folder to be copied, the old one (if existing) will be overwritten.

Beta version (multiple folders at a time): the folders get appended to this list inside the log file. This allows to copy more than one folder at a time, but introduces a bug, and can be easily broken if you don't let the operation finish (the log file will not get deleted, which means the folder will get copied again the next time you try to RoboPaste). This is to be fixed/improved.

Up until then, please use the safe version (one folder at a time), or use copying/moving multiple folders cautiously!

# Known bugs

- When selecting multiple folders to be copied/moved, not all of them are saved into the list for copying/moving (~10% loss?)


# Tests
RoboCopy is much faster for copying a large amount of small files.
RmDir is also faster than "standard" delete.


Results from gif:
Folder info: 1.73GB / 12 089 files
- rcopy/normal copy: 43s/91s
- rmdir/normal delete: ~ 3s/4.5s

![Magic tests](img/RCWMtest.gif)


# Credits

The files for Booting into Safe mode and Running with Priority were heavily influenced by Shawn Brink at tenforums.com

The files for Taking Ownership was heavily influenced by Vishal Gupta at AskVG.com

I changed and adapted all those files, but their ideas and the initial implementations deserve the credit.

Everything else is my own work, with the help of the Internet.
