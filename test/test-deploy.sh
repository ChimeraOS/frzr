#! /bin/bash

set -e
set -x

# Prepare the image
pacman -Sy --noconfirm
pacman -S --noconfirm archlinux-keyring
pacman-key --init
pacman-key --populate archlinux
pacman -Syu --noconfirm

pacman -S --noconfirm parted btrfs-progs file libnewt dosfstools jq util-linux zstd xz curl wget arch-install-scripts

# Create the frzr group
groupadd -g 379 frzr
usermod -a -G frzr $(whoami)


# Define variables
export IMG_FILE="archlinux.img"
export IMG_SIZE="4G"
export MOUNT_POINT="/mnt/arch"
export ARCH_MIRRORLIST="Server = http://mirror.rackspace.com/archlinux/\$repo/os/\$arch"
export TARGET_FILENAME="/workdir/output/archlinux.img.xz"

# Create an empty img file
truncate -s $IMG_SIZE $IMG_FILE

# Format the img file as btrfs
mkfs.btrfs $IMG_FILE

# Create the mount directory
mkdir -p $MOUNT_POINT

# Mount the img file
mount -o loop $IMG_FILE $MOUNT_POINT

btrfs subvol create $MOUNT_POINT/archlinux

# Bootstrap Arch Linux into the img file
yes | pacstrap $MOUNT_POINT/archlinux base base-devel linux linux-firmware mkinitcpio

# Generate fstab
#genfstab -U $MOUNT_POINT >> $MOUNT_POINT/archlinux/etc/fstab

echo "archlinux-frzr" > $MOUNT_POINT/archlinux/build_info

# Make the subvolume read-only (btrfs send cannot work on rw/ subvolumes)
btrfs property set -fts $MOUNT_POINT/archlinux ro true

# Create the deployment file
if btrfs send $MOUNT_POINT/archlinux | xz -e -9 --memory=95% -T0 > $TARGET_FILENAME; then

	# Unmount the img file
	umount $MOUNT_POINT

	rm -rf $IMG_FILE

	# Perform the deployment

	export FILENAME=install_deploy.img
	export BUILD_DIR="/workdir/output"
	export BUILD_IMG="$BUILD_DIR/$FILENAME"

	mkdir -p "$BUILD_DIR"
	dd if=/dev/zero of=$BUILD_IMG bs=1M count=8192

	# Associate the image file with a loop device
	losetup -fP "$BUILD_IMG"

	# Find the loop device associated with the image file
	MOUNTED_DEVICE=$(losetup -a | grep "$FILENAME" | cut -d ' ' -f 1 | sed 's/://')

	export DISK="$MOUNTED_DEVICE"
	export SWAP_GIB=0
	bash /workdir/frzr bootstrap

	export SHOW_UI="0"
	export SKIP_UEFI_CHECK="yes"
	export MOUNT_PATH="/tmp/frzr_root"
	export EFI_MOUNT_PATH="/tmp/frzr_root/efi"
	export SYSTEMD_RELAX_ESP_CHECKS=1

	# deploy archlinux
	bash /workdir/frzr deploy $TARGET_FILENAME

	# old releases used an older frzr
	INSTALLED_RELEASE=$(cat "$MOUNT_PATH/deployments/archlinux/build_info" | head -n 1)

	# Umount the loopback device
	losetup -d "$MOUNTED_DEVICE"

	# Remove the file
	rm -f $BUILD_IMG
	rm -f $TARGET_FILENAME

	if [ "$INSTALLED_RELEASE" = "archlinux-frzr" ]; then
		echo "VERIFIED"
	else
		exit 1
	fi
else
	exit 1
fi