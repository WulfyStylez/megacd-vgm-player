This is a fork of Mike Pavone's Sega Loader 1.0, see here https://www.retrodev.com/slo.html
This was forked to integrate it into a build system, and to tweak a few features for consistency.

This outputs a .bin for all 3 regions ready to be used as the first 16 sectors of a Sega/Mega CD image, featuring SLO. You can integrate this with an iso9660 filesystem using mkisofs -G [SLO-xxx.img].

The final image is assembled from:
1) Header and region-specific security code, padded to 784h bytes for all regions
2) SLO binary, padded to (1000h - 784h) bytes
3) descriptor for sub-cpu payload, describing a 1000h byte payload with entrypoint at offset 0. 24h bytes.
4) cdread binary, padded to (1000h - 24h) bytes
5) padding up to 8000h (16 sectors)