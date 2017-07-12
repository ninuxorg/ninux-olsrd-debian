This repository contains an HowTo, scripts, and config files to build an olsrd routing daemon package for mips/mips64, which is the architecture used by some routers such as the ubiquiti edgerouter.

The motivation for this is that the olsrd packages provided officially by debian are **very** outdated.

We will set-up a qemu mips64 vritual machine and then use it to build an olsrd .deb package.


Build a debian qemu-mips64 virtual machine
------------------------------------------

Install qemu on your system, then create a disk::

    qemu-img create -f qcow2 disk.img 4G

Download the debian mips kernel and the initrd that contains the debian installer (the debian version used by the edgerouter is wheezy)::

    wget http://http.us.debian.org/debian/dists/wheezy/main/installer-mips/current/images/malta/netboot/vmlinux-3.2.0-4-4kc-malta
    wget http://http.us.debian.org/debian/dists/wheezy/main/installer-mips/current/images/malta/netboot/initrd.gz

Launch the virtual machine::

    qemu-system-mips64 \
        -M malta \
        -hda /tmp/disk.img \
        -kernel vmlinux-3.2.0-4-4kc-malta \
        -initrd initrd.gz \
        -append "console=ttyS0" \
        -nographic 

And install debian using the installer.

After finishing the installation the system will reboot and you will be prompted again with the language selection dialog. Follow the instructions below. 


Launch the debian qemu-mips64 virtual machine
---------------------------------------------

Press ESC and then select "Configure the network".

When prompted with the debian mirror selection dialog, press again ESC and then select "Execute a shell".

We need to copy the installed kernel and initrd from the ``/boot/`` directory of the VM to the host.

Mount the disk to /mnt and chroot::

    mount /dev/sda1 /mnt
    chroot /mnt/ bash

To transfer them out you can use an ``scp`` command through the network to another machine. For example::

    scp /boot/vmlinux-3.2.0-4-5kc-malta myhostname:/tmp/
    scp /boot/initrd.img-3.2.0-4-5kc-malta myhostname:/tmp/

Exit the virtual machine window using ctrl-a,x.

Lauch the debian qemu-mips64 virtual machine (note that the kernel and initrd files are different from the installation ones used above)::

    qemu-system-mips64 \
        -M malta \
        -hda disk.img \
        -kernel vmlinux-3.2.0-4-5kc-malta \
        -initrd initrd.img-3.2.0-4-5kc-malta \
        -append "root=/dev/sda1 console=ttyS0" \
        -m 1024 \
        -nographic 


Later, to exit the qemu VM you can use ctrl-a,x.

Build the debian package from inside the debian qemu-mips64 virtual machine
---------------------------------------------------------------------------

After launching the debian qemu-mips64 virtual machine as described above, install some build dependencies::

   apt-get update
   apt-get install build-essential devscripts debhelper flex bison pkg-config
  
Download the olsrd tarball for which you want to build the debian package::

   wget http://www.olsr.org/releases/0.9/olsrd-0.9.0.3.tar.gz
  
Check the checksum and then rename the olsrd tarball according to the debian's way::

   mv olsrd-0.9.0.3.tar.gz olsrd_0.9.0.3.orig.tar.gz
  
Extract it::

   tar xf olsrd_0.9.0.3.orig.tar.gz
  
Download the ``debian/`` directory with some ninux-targeted customizations (contained in this repository and described below)::

   wget https://github.com/ninuxorg/ninux-olsrd-debian/archive/master.tar.gz -O ninux-olsrd-debian.tar.gz

and extract it::

   tar xf ninux-olsrd-debian.tar.gz
  
Move the ``debian/`` directory to the directory with the olsrd sources and cd to it::

   mv -v ninux-olsrd-debian-master/debian olsrd-0.9.0.3/
   cd olsrd-0.9.0.3/debian
  
Update the debian ``changelog`` with the ``dch`` tool (e.g. the ``-v`` option updates the version in the changelog)::

   export EDITOR=vim
   dch -v 0.9.0.3
  
Edit the ``control`` file, if needed::

   vim control
  
Build the debian packages (from inside the debian directory)::

   debuild -us -uc 

If the build is successful the .deb files will be in the parent directory.
We can transfer them through scp::

   scp ../../olsrd_0.9.0.3_mips.deb myhostname:/tmp/
   scp ../../olsrd-plugins_0.9.0.3_mips.deb myhostname:/tmp/


Ninux targeted customizations
-----------------------------
The customizations are essentially a mix of the official olsrd debian package and the FunkFeuer olsrd debian package (http://build.ffgraz.net/deb/dists/wheezy/main/source/net/ which is currently not available for mips).

For more details please see the ``git log`` of the ``debian/`` directory of this repository.


References
----------

- https://gmplib.org/~tege/qemu.html
- https://wiki.debian.org/IntroDebianPackaging

