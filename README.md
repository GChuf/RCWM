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
- removing directories
- copying files
- creating junctions (soft links)
- your suggestions



# Installation


To install the tools: download the zip file, unzip it and run the install.cmd script - after that, you'll only need the two most famous keys: Y and N.
If you don't have the administrator privileges on your Windows OS, I'm afraid you won't see much magic.


# How does it work?

Magic, basically. Right now, the magic happens inside the Windows registry with some help of batch scripting. Some day, this batch magic might evolve into powershell wizardry, but up until now, there was no need for that to happen.

The goal was to simply automate command line tools like robocopy, so that 1) everybody could use it, and 2) it would save some time to those who already know how to use it. While automating the tasks, I've accidentally discovered that I could automate much more than what I thought - and so now, you can select multiple folders to copy/move and paste them all into one folder, just like you can with the regular, slow, lazy windows GUI copy (there are still some problems with overwriting folders, though, and a bug).

RoboCopy/RoboPaste & Move Directory both use robocopy to do the work. The list of the folders to be copied is first saved into a log file inside C:\Windows\System32\RCWM folder. The folders get appended to this list if you choose to copy/move multiple files. The logs for copy/move are separate of course. This allows to copy more than one folder at a time, but introduces a bug, and can be easily broken if you don't let the operation finish (the log file will not get deleted). This is to be fixed/improved.


# Known bugs

- When selecting multiple folders to be copied/moved, not all of them are saved into the list for copying/moving (~10% loss?)


# Credits

The files for Booting into Safe mode and Running with Priority were heavily influenced by Shawn Brink at tenforums.com

The files for Taking Ownership was heavily influenced by Vishal Gupta at AskVG.com

I changed and adapted all those files, but their ideas and the initial implementations deserve the credit.

Everything else is my own work, with the help of Internet.




