#!/bin/bash

TARGET_SIZE=512
PART1_SIZE=256
IMAGE_NAME=rootfs_ext4.img
TEMP_DIR=temp_dir

#=====================================================================
# check and create temp_dir
#=====================================================================
create_temp_dir()
{
	if [ -d $1 ]
	then
		echo Directory $1 is exist.
		return 0
	fi

	mkdir $1
	if [ $? -ne 0 ]
	then
		echo Failed to create $1
		return 1
	fi

	return 0
}

#=====================================================================
# Check user
#=====================================================================
if [ $(id -u) -ne 0 ]
then
	echo "Please run this shell with root user"
	exit 0
fi

#=====================================================================
# Check parameters
#=====================================================================
if [ $# -ne 1 ]
then
	echo Usage: $0 "<root path>"
	exit 0
fi

if [ ! -f $1 ]
then
	echo File $1 is not exist!
	exit 0
fi

#=====================================================================
# Create dummy file
#=====================================================================
echo Getting dummy data from /dev/zero ...
dd if=/dev/zero of=$IMAGE_NAME bs=1024k count=$TARGET_SIZE

if [ $? -ne 0 ]
then
	echo Failed to get dummy data.
	exit 1
fi
#=====================================================================
# create partition tables on the image
#=====================================================================
sfdisk --force -uM $IMAGE_NAME << EOF
,$PART1_SIZE
;
EOF

if [ $? -ne 0 ]
then
	echo Failed to create partition table!
	rm $IMAGE_NAME
	exit 1
fi

#=====================================================================
# Mapper partition
#=====================================================================
kpartx -av $IMAGE_NAME
if [ $? -ne 0 ]
then
	echo Failed to map image file $IMAGE_NAME.
	rm $IMAGE_NAME
	exit 1
fi

#=====================================================================
# Format file
#=====================================================================
echo Formatting dummy data to ext4 ...
ret1=`mkfs.ext4 /dev/mapper/loop0p1`
ret2=`mkfs.ext4 /dev/mapper/loop0p2`

if [ $ret1 -ne 0  ||  $ret2 -ne 0 ]
then
	echo Failed to format image to ext4.
	rm $IMAGE_NAME
	kpartx -d $IMAGE_NAME
	exit 2
fi

#=====================================================================
# mount image
#=====================================================================
ret1=`create_temp_dir ${TEMP_DIR}1`
ret2=`create_temp_dir ${TEMP_DIR}2`
if [ $ret1 -ne 0 || $ret2 -ne 0 ]
then
	echo Failed to create temp directories for mount.
	rm $IMAGE_NAME
	kpartx -d $IMAGE_NAME
	exit 2
fi

echo mounting dummy image $IMAGE_NAME to $TEMP_DIR ...
ret1=`mount /dev/mapper/loop0p1 ${TEMP_DIR}1`
ret2=`mount /dev/mapper/loop0p2 ${TEMP_DIR}2`
if [ $ret1 -ne 0 || $ret2 -ne 0 ]
then
	echo Failed to mount $IMAGE_NAME to $TEMP_DIR.
	umount ${TEMP_DIR}1
	umount ${TEMP_DIR}2
	rmdir ${TEMP_DIR}1
	rmdir ${TEMP_DIR}2
	kpartx -d $IMAGE_NAME
	rm $IMAGE_NAME
	exit 3
fi

#=====================================================================
# Copy files to image
#=====================================================================
tar xvf $1 -C ${TEMP_DIR}1
if [ $? -ne 0 ]
then
	echo Failed to extract from $1 to ${TEMP_DIR}1.
	umount ${TEMP_DIR}1
	umount ${TEMP_DIR}2
	rmdir ${TEMP_DIR}1
	rmdir ${TEMP_DIR}2
	kpartx -d $IMAGE_NAME
	rm $IMAGE_NAME
	exit 4
fi

echo "Test partition 2 text " > ${TEMP_DIR}2/test.txt

sync

umount ${TEMP_DIR}1
umount ${TEMP_DIR}2
kpartx -d $IMAGE_NAME
rmdir ${TEMP_DIR}*

echo File $IMAGE_NAME is ready!
