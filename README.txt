Mega CD VGM Player v0.96

MegaCD/SegaCD player for Mega Drive VGM files.
Based on Mega Drive VGM Player v3.30 by Dead Fish Software
http://mjsstuf.x10host.com/pages/vgmPlay/vgmPlay.htm

Features:
-Moved original homebrew release to live in Word RAM (256KB) instead of cartridge memory, and use MegaCD-safe 68k ram regions.
-Re-entrant: pressing B will return to the loader allowing other players to be loaded
-Supports US, Japanese, and European regions
-Working on real hardware, boots using (unmodified) Sega Loader (https://www.retrodev.com/slo.html)
-256kb rom limit (playback will glitch out/crash once threshold is hit)


Usage:
1) build a player, or several, using vgmPlay.exe
2) drop binaries in cd-dir
3) run build-iso.bat to create build.iso, ready to burn and run

Compilation:
This build system is windows-centric, utilizing asm68k and mkisofs. Run build-vgmplay.bat to build rom-build/vgmPlayCD.ASM. This will rebuild and update vgmPlay.dat, which vgmPlay.exe bases its output ROMs on.

Changelog:
v0.96
    -ISO generation now creates USA, EUR, and JP region images.
v0.95
    -initial release, based on vgmPlay v3.30 with lots of tweaks