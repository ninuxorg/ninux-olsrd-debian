#!/bin/bash

set -x

qemu-img create -f qcow2 disk.img 4G

# wheezy
wget http://http.us.debian.org/debian/dists/wheezy/main/installer-mips/current/images/malta/netboot/initrd.gz
wget http://http.us.debian.org/debian/dists/wheezy/main/installer-mips/current/images/malta/netboot/vmlinux-3.2.0-4-4kc-malta

qemu-system-mips64 \
    -M malta \
    -hda /tmp/disk.img \
    -kernel wheezy/vmlinux-3.2.0-4-4kc-malta \
    -initrd wheezy/initrd.gz \
    -append "console=ttyS0" \
    -nographic 

