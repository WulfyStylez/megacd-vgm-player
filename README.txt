Mega CD VGM Player v0.97

MegaCD/SegaCD player for Mega Drive VGM files.
Based on Mega Drive VGM Player v3.30 by Dead Fish Software
http://mjsstuf.x10host.com/pages/vgmPlay/vgmPlay.htm

Features:
-Moved original homebrew release to live in Word RAM (256KB) instead of cartridge memory.
-Menu system: pressing B will return to the loader allowing other players to be loaded
-Working on real hardware, boots using a fork of Sega Loader (https://www.retrodev.com/slo.html)
-Supports US, Japanese, and European regions
-256KB rom limit (playback will freeze once threshold is hit)


Usage:
1) Build a player binary (vgmPlay.bin), or several, using vgmPlay.exe. 
2) Drop one or more binaries in cd-dir (these can be renamed to anything you want)
3) Run build-iso.bat to create disk images (vgmPlayCD-x.iso) for all regions, ready to burn and run.

Compilation:
This build system is windows-centric, utilizing asm68k and mkisofs. build-loaders-and-code.bat will build the loader chain and also rebuild and update vgmPlay.dat, which vgmPlay.exe bases its output ROMs on.

Changelog:
v0.99 9.13.2017
    -New binary is less than half the size of the old one, at about 3.2kb
    -CD BIOS font is now used
    -Lots of behind-the-scenes changes (binary is now compiled from a full disassembly instead of doing asm patches on top of the original binary)
v0.97
    -Backing out to the loader no longer needs to re-launch the SEGA logo, speeding things up dramatically
    -Further improvements to overall system stability and other minor adjustments have been made to enhance the user experience(tm)
v0.96
    -ISO generation now creates USA, EUR, and JP region images.
v0.95
    -initial release, based on vgmPlay v3.30 with lots of tweaks