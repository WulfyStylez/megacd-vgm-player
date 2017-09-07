del build-USA.iso build-JAP.iso build-EUR.iso
tools\mkisofs -pad -G tools\base-slo-usa.bin -o build-USA.iso cd-dir
tools\mkisofs -pad -G tools\base-slo-jap.bin -o build-JAP.iso cd-dir
tools\mkisofs -pad -G tools\base-slo-eur.bin -o build-EUR.iso cd-dir
pause