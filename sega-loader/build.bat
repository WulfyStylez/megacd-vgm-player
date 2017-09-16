@echo off
echo Deleting old binaries...
del /f slo.bin cdread.bin SLO-eur.img SLO-usa.img SLO-jap.img

echo Building SLO...
..\tools\asm68k /p /o ws+ slo.ASM, slo.bin && echo.
if %errorlevel% neq 0 echo Failed to build SLO! && exit /b %errorlevel%

echo Building cdread...
..\tools\asm68k /p /o ws+ cdread.ASM, cdread.bin && echo.
if %errorlevel% neq 0 echo Failed to build CDRead! && exit /b %errorlevel%

echo Building final images...
copy /b assets\security-usa.bin + slo.bin + cdread.bin + assets\pad-6000h.bin SLO-usa.img
copy /b assets\security-jap.bin + slo.bin + cdread.bin + assets\pad-6000h.bin SLO-jap.img
copy /b assets\security-eur.bin + slo.bin + cdread.bin + assets\pad-6000h.bin SLO-eur.img
echo Done! && echo.