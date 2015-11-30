#!/bin/bash

set -x

# note that the kernel and initrd differ from the installation ones
# to get this kernel and initrd, transfer them out of the qemu VM after the installation has been completed

qemu-system-mips64 \
    -M malta \
    -hda disk.img \
    -kernel vmlinux-3.2.0-4-5kc-malta \
    -initrd initrd.img-3.2.0-4-5kc-malta \
    -append "root=/dev/sda1 console=ttyS0" \
    -m 1024 \
    -nographic 

