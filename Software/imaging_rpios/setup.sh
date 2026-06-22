TARGET_DIR="$HOME/rpi"
if [ ! -d "$TARGET_DIR" ]; then
	  echo "Directory $TARGET_DIR does not exist. Creating it now..."
	    mkdir -p "$TARGET_DIR"
fi
cd "$TARGET_DIR"
git clone --depth=1 https://github.com/raspberrypi/linux
sudo apt install bc bison flex libssl-dev make
sudo apt install libncurses5-dev
