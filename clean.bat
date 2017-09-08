@echo off
cd rom-build
cmd /c clean.bat
cd ../sega-loader
cmd /c clean.bat
cd ..
echo Cleaning up finalized disk images...
del vgmPlayCD-eur.iso vgmPlayCD-jap.iso vgmPlayCD-usa.iso
pause