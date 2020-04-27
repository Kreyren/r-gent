#!/bin/sh

mount_dir="/mnt/gentoo" 
stage3_link = https://bouncer.gentoo.org/fetch/root/all/releases/amd64/autobuilds/20200422T214502Z/stage3-amd64-20200422T214502Z.tar.xz

mkdir "$mount_dir"
mount /dev/sdb2 "$mount_dir"
cd "$mount_dir"
wget "$stage3_link"
tar xpvf stage3-*.tar.xz --xattrs-include='*.*' --numeric-owner

cd "$mount_dir"/etc/portage/
rm make.conf
wget -O make.conf https://raw.githubusercontent.com/Uniminin/portage-config/master/make.conf2
cd ; mkdir --parents "$mount_dir"/etc/portage/repos.conf
cp "$mount_dir"/usr/share/portage/config/repos.conf "$mount_dir"/etc/portage/repos.conf/gentoo.conf
cp --dereference /etc/resolv.conf "$mount_dir"/etc/

mount --types proc /proc /mnt/gentoo/proc
mount --rbind /sys /mnt/gentoo/sys
mount --make-rslave /mnt/gentoo/sys
mount --rbind /dev /mnt/gentoo/dev
chroot "$mount_dir" /bin/bash