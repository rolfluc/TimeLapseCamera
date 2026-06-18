#!/bin/bash

# --- Configuration ---
# Change this variable to build a different image (e.g., core-image-minimal)
IMAGE_NAME="core-image-full-cmdline"
CONF_NAME="local.conf"
TARGET_NEW_DIR="$HOME/yocto-rpi/meta-timelapse/conf/machine"

# Machine-specific paths
BUILD_DIR="$HOME/yocto-rpi/"
MACHINE_DIR="raspberrypi0-2w-64"

# New configs
NEW_RECIPE_NAME='meta-timelapse'
NEW_CONF_NAME='raspberrypi0-2w-custom.conf'

# ---------------------

# 1. Capture the current working directory
CWD=$(pwd)
echo "Starting build process..."
echo "Current working directory captured: $CWD"

# 1.5 Move local.conf over to the build dir
if [ -f "$CONF_NAME" ]; then
            cp $CONF_NAME $BUILD_DIR/build-rpi/conf/$CONF_NAME
    else 
	    echo "Error: Local Configuration not found: $CONF_NAME"
	    exit 1
fi

#[ ! -d "$TARGET_DIR" ] && dir_missing=true || dir_missing=false

#if [ "$dir_missing" = true ]; then
#	echo "Bitbake layer ready. Only copying config over."
#	cp $NEW_CONF_NAME $BUILD_DIR/$NEW_RECIPE_NAME/conf/machine/
#fi

# 2. Move to the Yocto build directory
if [ -d "$BUILD_DIR" ]; then
	    cd "$BUILD_DIR" || { echo "Error: Failed to change directory to $BUILD_DIR"; exit 1; }
    else
	        echo "Error: Build directory $BUILD_DIR does not exist."
		    exit 1
fi

# NOTE: Yocto/BitBake usually requires environment variables to be set.
# If your setup requires sourcing an environment script (like oe-init-build-env),
# uncomment the line below and update the path if necessary:
# source ../oe-init-build-env .


# 3. Run bitbake
unset MACHINE
source poky/oe-init-build-env build-rpi

# 3.1 Setup the new build env. Should only be run once
#if [ "$dir_missing" = false ]; then
#	cd "$BUILD_DIR" || { echo "Error: Failed to change directory to $BUILD_DIR"; exit 1; }

#	bitbake-layers create-layer ../$NEW_RECIPE_NAME
#	bitbake-layers add-layer ../$NEW_RECIPE_NAME
#	mkdir -p ../$NEW_RECIPE_NAME/conf/machine/
#	echo "Created the desired layer. Exiting now. Please rerun to complete"
#	exit 1;
#fi


echo "Cleaning Local Build & Sstate Cache for $IMAGE_NAME"
#bitbake -c cleansstate rpi-config
bitbake -c cleansstate "$IMAGE_NAME"
echo "Running bitbake $IMAGE_NAME..."

# bitbake -e $IMAGE_NAME | grep -B 2 -A 2 "qemux86-64"

#MACHINE="raspberrypi0-2w-custom" bitbake "$IMAGE_NAME"
bitbake "$IMAGE_NAME"

# Check if the bitbake command succeeded
if [ $? -eq 0 ]; then
	    echo "Bitbake build completed successfully."
    else
	        echo "Error: Bitbake build failed."
		    # Even if it fails, return to the original directory before exiting
		        cd "$CWD"
			    exit 1
fi

# 4. Move back to the captured working directory
cd "$CWD" || { echo "Error: Could not return to $CWD"; exit 1; }

# Define the source path using the configured variables
TARGET_IMAGE="$BUILD_DIR/build-rpi/tmp/deploy/images/$MACHINE_DIR/$IMAGE_NAME-$MACHINE_DIR.rootfs.wic.bz2"
LOCAL_FILENAME="$IMAGE_NAME-$MACHINE_DIR.rootfs.wic.bz2"
DECOMPRESSED_WIC="$IMAGE_NAME-$MACHINE_DIR.rootfs.wic"

# 4.5 Clean up existing .wic file if it exists
if [ -f "$DECOMPRESSED_WIC" ]; then
	    echo "Found existing image: $DECOMPRESSED_WIC. Deleting it..."
	        rm "$DECOMPRESSED_WIC"
fi

# 5. Pull the file into the current working directory
echo "Copying the build image to the current directory ${TARGET_IMAGE}..."
if [ -f "$TARGET_IMAGE" ]; then
	    cp "$TARGET_IMAGE" .
	        echo "Success! Image copied to: $CWD/$(basename "$TARGET_IMAGE")"
	else
		    echo "Error: Expected output file not found at:"
		        echo "$TARGET_IMAGE"
			    exit 1
fi

# 6. Decompress the copied .bz2 file
echo "Decompressing $LOCAL_FILENAME..."
if [ -f "$LOCAL_FILENAME" ]; then
	    # -d: decompress, -k: keep original .bz2 file
	        bzip2 -dk "$LOCAL_FILENAME"
		    echo "Decompression complete. Your new .wic file is ready in $CWD"
	    else
		        echo "Error: Copied file not found for decompression."
			    exit 1
fi
