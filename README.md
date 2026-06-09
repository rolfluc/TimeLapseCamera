# TimeLapseCamera
Repo Housing the Mechanical, Electrical, Tests, and Software / layer config for taking an RPI Zero 2W into a time lapse / mobile camera for a rechargable battery.
The following steps are to setup yocto for building an RPI image for the RPI Zero W2
```
git clone -b scarthgap https://git.yoctoproject.org/poky
```
```
git clone -b scarthgap https://git.yoctoproject.org/meta-raspberrypi
```
```
source poky/oe-init-build-env build-rpi
```
```
bitbake-layers add-layer ../meta-raspberrypi
```
-> Confirm layer was added to conf/bblayers.conf

```
set local.conf -> 'MACHINE ??=' -> 'MACHINE = "raspberrypi0-2w-64"' 
```
^-- this matches ~/yocto-rpi/meta-raspberrypi/conf/machine/
```
set local.conf -> IMAGE_FSTYPES = "wic.bz2"
set local.conf -> LICENSE_FLAGS_ACCEPTED = "synaptics-killswitch"
```
```
cd ~/yocto-rpi/build-rpi
```
```
bitbake core-image-base
```

Once Complete, check in : ~/yocto-rpi/build-rpi/tmp/deploy/images/raspberrypi0-2w-64/
for a file:
core-image-base-raspberrypi0-2w-64.rootfs.wic.bz2

In this case, WSL is being used to build, so RPI Imager is used to flash to an SD card.
