#!/bin/sh

mount_dir="/mnt/gentoo" 
mount /dev/sdb2 "$mount_dir"
cd "$mount_dir" || exit
mount --types proc /proc /mnt/gentoo/proc
mount --rbind /sys /mnt/gentoo/sys
mount --make-rslave /mnt/gentoo/sys
mount --rbind /dev /mnt/gentoo/dev
chroot "$mount_dir" /bin/bash
