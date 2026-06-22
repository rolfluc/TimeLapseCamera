TARGET_DIR="$HOME/rpi"
cp menuchanges.config "$TARGET_DIR/linux/"
cd "$TARGET_DIR"
# Now for the instructions from : https://www.raspberrypi.com/documentation/computers/linux_kernel.html#configure-the-kernel 
cd linux
# Check below for config
# make menuconfig
KERNEL=kernel8
make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- bcm2711_defconfig
make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- -j$(nproc) Image modules dtbs
