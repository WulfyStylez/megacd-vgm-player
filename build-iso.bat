@echo off
del vgmPlayCD-USA.iso vgmPlayCD-JAP.iso vgmPlayCD-EUR.iso
tools\mkisofs -pad -G sega-loader\SLO-usa.img -o vgmPlayCD-USA.iso cd-dir && echo.
if %errorlevel% neq 0 goto end
tools\mkisofs -pad -G sega-loader\SLO-jap.img -o vgmPlayCD-JAP.iso cd-dir && echo.
if %errorlevel% neq 0 goto end
tools\mkisofs -pad -G sega-loader\SLO-eur.img -o vgmPlayCD-EUR.iso cd-dir && echo.
if %errorlevel% neq 0 goto end
echo Success!

:end
if %errorlevel% neq 0 echo Failed!
pause
exit /b %errorlevel%