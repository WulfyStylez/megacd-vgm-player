@echo off
cd rom-build
cmd /c build.bat
copy vgmPlay.dat ..\vgmPlay.dat
cd ../sega-loader
cmd /c build.bat
pause