del build-USA.iso build-JAP.iso build-EUR.iso
tools\mkisofs -pad -G sega-loader\SLO-usa.img -o vgmPlayCD-USA.iso cd-dir
tools\mkisofs -pad -G sega-loader\SLO-jap.img -o vgmPlayCD-JAP.iso cd-dir
tools\mkisofs -pad -G sega-loader\SLO-eur.img -o vgmPlayCD-EUR.iso cd-dir
pause