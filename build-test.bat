@echo off
cmd /c clean.bat
cmd /c build-code.bat
if %errorlevel% neq 0 exit
copy /b vgmPlay.dat + tools\buildtest.vgc cd-dir\vgmTest.bin
cmd /c build-iso.bat