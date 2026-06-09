#!/bin/bash

# --- Configuration ---
# Change this variable to build a different image (e.g., core-image-minimal)
IMAGE_NAME="core-image-base"

# Machine-specific paths
BUILD_DIR="$HOME/yocto-rpi/build-rpi"
MACHINE_DIR="raspberrypi0-2w-64"

# ---------------------

# 1. Capture the current working directory
CWD=$(pwd)
echo "Starting build process..."
echo "Current working directory captured: $CWD"

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
source ../poky/oe-init-build-env build-rpi
echo "Running bitbake $IMAGE_NAME..."
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
TARGET_IMAGE="$BUILD_DIR/tmp/deploy/images/$MACHINE_DIR/$IMAGE_NAME-$MACHINE_DIR.rootfs.wic.bz2"
LOCAL_FILENAME="$IMAGE_NAME-$MACHINE_DIR.rootfs.wic.bz2"
DECOMPRESSED_WIC="$IMAGE_NAME-$MACHINE_DIR.rootfs.wic"

# 4.5 Clean up existing .wic file if it exists
if [ -f "$DECOMPRESSED_WIC" ]; then
	    echo "Found existing image: $DECOMPRESSED_WIC. Deleting it..."
	        rm "$DECOMPRESSED_WIC"
fi

# 5. Pull the file into the current working directory
echo "Copying the build image to the current directory..."
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
