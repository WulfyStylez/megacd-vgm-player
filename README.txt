Mega CD VGM Player v0.99

MegaCD/SegaCD player for Mega Drive VGM files.
Based on Mega Drive VGM Player v3.30 by Dead Fish Software
http://mjsstuf.x10host.com/pages/vgmPlay/vgmPlay.htm
Ported to Mega CD and further modified by WulfyStylez.

Features:
* Moved original homebrew release to live in Word RAM (256KB) instead of cartridge memory.
* Menu system: pressing B will return to the loader, allowing other players to be loaded.
* Working on real hardware, boots using a fork of Sega Loader (https://www.retrodev.com/slo.html)
* Supports US, Japanese, and European regions
* 256KB rom limit (playback will freeze once threshold is hit)


Usage:
1) Build a player binary (vgmPlay.bin), or several, using vgmPlay.exe. 
2) Drop binaries in cd-dir (these can be renamed to anything you want)
3) Run build-iso.bat to create disk images (vgmPlayCD-x.iso) for all regions, ready to burn and run.

Other notes:
At the moment, there is a 256KB limit on total ROM size. This can be worked around by building several binaries with different song sets, but the long-term plan is to implement vgc loading + streaming directly from the disk.

Compilation:
This build system is windows-centric, utilizing asm68k and mkisofs. build-code.bat will build the player and loader binaries, and also copy vgmPlay.dat into the root. 
build-test.bat builds code, creates a working binary with appended music at cd-dir\vgmTest.bin, and creates an ISO. This is intended to be a single-step build script. 
clean.bat will clean all buildfiles, including the SLO images required by build-iso.bat.

Changelog:
v0.99 9.16.2017
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