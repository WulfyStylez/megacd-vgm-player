Mega CD VGM Player v0.96

MegaCD/SegaCD player for Mega Drive VGM files.
Based on Mega Drive VGM Player v3.30 by Dead Fish Software
http://mjsstuf.x10host.com/pages/vgmPlay/vgmPlay.htm

Features:
-Moved original homebrew release to live in Word RAM (256KB) instead of cartridge memory, and use MegaCD-safe 68k ram regions.
-Re-entrant: pressing B will return to the loader allowing other players to be loaded
-Supports US, Japanese, and European regions
-Working on real hardware, boots using a fork of Sega Loader (https://www.retrodev.com/slo.html)
-256KB rom limit (playback will freeze once threshold is hit)


Usage:
1) Build a player binary, or several, using vgmPlay.exe. 
2) Drop binaries in cd-dir (these can be freely renamed).
3) Run build-iso.bat to create disk images (vgmPlayCD-x.iso) for all regions, ready to burn and run.

Compilation:
This build system is windows-centric, utilizing asm68k and mkisofs. build-loaders-and-code.bat will build the loader chain and also rebuild and update vgmPlay.dat, which vgmPlay.exe bases its output ROMs on.

Changelog:
v0.96
    -ISO generation now creates USA, EUR, and JP region images.
v0.95
    -initial release, based on vgmPlay v3.30 with lots of tweaks