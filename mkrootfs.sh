#!/bin/bash

# https://www.josehu.com/memo/2021/01/02/linux-kernel-build-debug.html
# https://www.starlab.io/blog/using-gdb-to-debug-the-linux-kernel

[ ! -f buildroot/output/images/rootfs.ext4 ] && {
    #git clone -b 2023.02.x git://git.buildroot.net/buildroot
    git clone -b 2024.05.x git://git.buildroot.net/buildroot
    pushd buildroot
    cp ../buildroot.config .config
    make oldconfig
    make -j$(nproc)
    popd
}

# After successful compilation, you will find the root filesystem image at output/images/rootfs.ext4.

qemu-system-x86_64 \
    -kernel linux/arch/x86_64/boot/bzImage \
    -nographic \
    -drive format=raw,file=buildroot/output/images/rootfs.ext4,if=virtio \
    -append "root=/dev/vda console=ttyS0 nokaslr" \
    -m 4G \
    -enable-kvm \
    -cpu host \
    -smp 2 \
    -net nic,model=virtio \
    -net user,hostfwd=tcp::10022-:22 \
    -s


# To start network inside the qemu instance (guest):
# $ ifconfig -a
# $ echo "iface eth0 inet dhcp" >> /etc/network/interfaces
# - add eth0 into auto as 'auto lo eth0' in the file '/etc/network/interfaces'
# $ ifup eth0
#
# Allow ssh to guest
# - edit '/etc/ssh/sshd_config', and then change 'PermitRootLogin' and 'PermitEmptyPasswords' to 'yes'.
# $ /etc/init.d/S50sshd restart
#
# from host, do 'ssh -p 10022 root@localhost'
