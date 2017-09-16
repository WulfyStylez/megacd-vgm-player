@echo off
cd rom-build
cmd /c build.bat
if %errorlevel% neq 0 goto end
copy vgmPlay.dat ..\vgmPlay.dat
if %errorlevel% neq 0 echo Failed to copy vgmPlay.dat into root! && goto end
cd ..

cd sega-loader
cmd /c build.bat
if %errorlevel% neq 0 goto end

:end
pause
exit /b %errorlevel%