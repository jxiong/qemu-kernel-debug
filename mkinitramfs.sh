#!/bin/bash

[ ! -f initramfs.cpio.gz ] && {
    TMPDIR=$(mktemp -d -p .)
    pushd ${TMPDIR}

    # compile busybox - make sure the busybox is compile with 'CONFIG_STATIC'
    git clone -b 1_36_stable git://git.busybox.net/busybox
    pushd busybox
    cp ../../busybox.config .config
    make oldconfig
    make -j $(nproc)
    make install
    popd

    # make initramfs
    mkdir initramfs
    pushd initramfs
    cp -rf ../busybox/_install/* ./
    mkdir dev proc sys
    sudo cp -a /dev/{null,console,tty,tty1,tty2,tty3,tty4} dev/
    rm -f linuxrc

    cat > init << EOF
#!/bin/busybox sh
mount -t proc none /proc
mount -t sysfs none /sys
exec /sbin/init
EOF
    chmod +x init

    find . -print0 | cpio --null -ov --format=newc | gzip -9 > ../../initramfs.cpio.gz
    popd

    popd # out of TMPDIR
}

# Make sure the kernel is compiled with 'CONFIG_DEBUG_INFO' and 'CONFIG_GDB_SCRIPTS' enabled, and 'CONFIG_DEBUG_INFO_REDUCED' disabled. If virtio devices are supported, the option 'VIRTIO_NET=y' and 'VIRTIO_BLK=y' must be set.
#
# Run kernel with this initramfs. '-s' is a acronym of '-gdb tcp::1234' that will start a gdb server at port 1234
# Add '-S' to stop kernel running on startup
qemu-system-x86_64 -s -kernel ./linux/arch/x86/boot/bzImage -initrd ./initramfs.cpio.gz -nographic -append "console=ttyS0 nokaslr"

# on another console, to start gdb with the following commands
# $ cd ~/srcs/linux
# $ gdb vmlinux -ex 'target remote localhost:1234'
# (gdb) break start_kernel
# (gdb) c
