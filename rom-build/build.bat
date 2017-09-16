@echo off
echo Building vgmPlayCD...
..\tools\asm68k /p /o op+ /o os+ /o ow+ /o ws+ /o oz+ /o oaq+ /o osq+ /o omq+ /o ae- vgmPlayCD.ASM, vgmPlay.dat && echo.
if %errorlevel% neq 0 echo Failed to build vgmPlayCD! && exit /b %errorlevel%
echo Done! && echo.