#!/bin/bash

#set -x 

IMG_URL="http://downloads.raspberrypi.org/raspios_lite_armhf/images/raspios_lite_armhf-2022-01-28/2022-01-28-raspios-bullseye-armhf-lite.zip"
IMG_PATH="$HOME/dockerpi3_image"
FILENAME=$(basename $IMG_URL)
NAME=$(basename $IMG_URL .zip)
FILEPATH="${IMG_PATH}/${NAME}.img"
IMG_RESIZE="4G"
BOOTSTART=`fdisk -l "$FILEPATH" | sed -nr "s/^\S+1\s+([0-9]+).*  c W95 FAT32 \(LBA\)$/\1/p"`

! [ –d "${IMG_PATH}" ] && mkdir -p ${IMG_PATH} 

if  [ ! -f "${IMG_PATH}/${FILENAME}" ] 
  then 
  wget -O "${IMG_PATH}/${FILENAME}" "${IMG_URL}"
fi 

if [ ! -f "${IMG_PATH}/${NAME}.img" ]
  then
    unzip -q "${IMG_PATH}/${FILENAME}" -d "${IMG_PATH}" 
    qemu-img resize -f raw "${FILEPATH}" "${IMG_RESIZE}" 

   # Find the first, DOS partition and mount it
   if [[ -z "$BOOTSTART" ]]; then
     echo "Can't find FAT32 first partition in image \"$FILEPATH\""
     exit
   fi

  sudo losetup /dev/loop10 "$FILEPATH" -o $((BOOTSTART*512))
  sudo mkdir rpi-boot
  sudo mount /dev/loop10 rpi-boot

# Make the change
   if [[ -e "rpi-boot/ssh" ]]; then
     echo "\"`basename "$FILEPATH"`\" ALREADY had boot/ssh set."
   else
     sudo touch rpi-boot/ssh
     echo "\"`basename "$FILEPATH"`\" now has boot/ssh set."
  fi
fi 

# Start dockerpi3 
docker run -p 5022:22 --rm -v "${IMG_PATH}/${NAME}.img":/sd.img  \
  --name rpi -it clutroth/dockerpi:vmlatest \
  -m 1024 -smp 4 -M raspi3 \
  -kernel kernel8.img -dtb bcm2710-rpi-3-b-plus.dtb -sd /sd.img \
  -append "console=ttyAMA0 root=/dev/mmcblk0p2 rw rootwait rootfstype=ext4" \
  -nographic \
  -device usb-net,netdev=net0 -netdev user,id=net0,hostfwd=tcp::22-:22
