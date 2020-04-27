#!/bin/sh
# shellcheck source=/dev/null
echo "Starting within 5 seconds..."
sleep 5


source="/etc/profile"
. "$source" 
export PS1="(chroot) ${PS1}"
emerge-webrsync ; emerge --sync
eselect profile set "default/linux/amd64/17.1/desktop/gnome"
emerge --verbose --update --deep --newuse @world

echo "Asia/Dhaka" > /etc/timezone
emerge --config sys-libs/timezone-data
echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
locale-gen
eselect locale set "en_US"
env-update ; . "$source" ; export PS1="(chroot) ${PS1}"

# Kernel Part
emerge --ask sys-kernel/gentoo-sources
emerge --ask sys-apps/pciutils
cd /usr/src/linux || exit
make menuconfig
make && make modules_install
make install

emerge --ask sys-kernel/genkernel
genkernel --install initramfs
genkernel --lvm --mdadm --install initramfs

mkdir -p /etc/modules-load.d
touch /etc/modules-load.d/network.conf
echo "3c59x" >> /etc/modules-load.d/network.conf

emerge --ask sys-kernel/linux-firmware

rm /etc/conf.d/hostname
touch /etc/conf.d/hostname
echo 'hostname="tux"' >> /etc/conf.d/hostname

emerge --ask --noreplace net-misc/netifrc
rm /etc/conf.d/net
touch /etc/conf.d/net
echo 'config_eth0="dhcp"' >> /etc/conf.d/net

cd /etc/init.d || exit
ln -s net.lo net.eth0
rc-update add net.eth0 default


rm /etc/hosts
echo "127.0.0.1 research localhost" >> /etc/hosts
echo "::1 research localhost" >> /etc/hosts

passwd

emerge --ask app-admin/sysklogd
rc-update add sysklogd default

emerge --ask sys-apps/mlocate

emerge --ask net-misc/dhcpcd

user="uniminin"
useradd -m -G users,wheel,audio -s /bin/bash "$user"
passwd "$user"
rm /stage3-*.tar.*

emerge git neofetch fish x11-drivers/xf86-video-intel

emerge --deep --with-bdeps=y --changed-use --update --verbose @world

emerge --verbose --keep-going gnome-base/gnome
emerge --ask --verbose --oneshot x11-base/xorg-drivers

rm /etc/conf.d/xdm
touch /etc/conf.d/xdm
echo "CHECKVT=7" >> /etc/conf.d/xdm
echo 'DISPLAYMANAGER="gdm"' >> /etc/conf.d/xdm

rc-update add dbus default
rc-update add xdm default
rc-update add openrc-settingsd default
rc-update add elogind boot

gpasswd -a "$user"
getent group plugdev && gpasswd -a "$user" plugdev
getent group games && gpasswd -a "$user" games
getent group video && gpasswd -a "$user" video
emerge -uDN @world

echo "Done!!!"
