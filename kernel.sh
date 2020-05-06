#!/bin/sh

ls -l /usr/src/linux
cd /usr/src/linux
make menuconfig
make -j30 && make modules_install
make install
