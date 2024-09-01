
# Build Kernel

- Run `make_kernel.sh` will do the followng
- Make sure the kernel is compiled with `CONFIG_DEBUG_INFO` and `CONFIG_GDB_SCRIPTS` enabled,
  and `CONFIG_DEBUG_INFO_REDUCED` disabled.
  If virtio devices are supported, the option `VIRTIO_NET=y` and `VIRTIO_BLK=y` must be set.

- Compile the with `CONFIG_RANDOMIZE_BASE` disabled; or pass in the boot option 'nokaslr'

- There are two ways to make root filesystem: using buildroot, using initramfs, or with an qemu direct kernel boot

## Virsh direct kernel boot (the easiest way)
    - Make an initramfs image that will be used to remount the actual root device later.
    $ mkinitramfs -o initrd.img

    - Edit the domain file with the following new contents:
    <os>
        <kernel>/home/jxiong/qemu-kernel-debug/linux/arch/x86/boot/bzImage</kernel>
        <initrd>/home/jxiong/qemu-kernel-debug/initrd.img</initrd>
        <cmdline>console=tty0 nokaslr root=UUID=27e376c6-45c6-4516-af1b-8df035ccadc8</cmdline>
    </os>
    <qemu:commandline xmlns:qemu='http://libvirt.org/schemas/domain/qemu/1.0'>
        <qemu:arg value='-s'/>
    </qemu:commandline>

## Using buildroot - see mkrootfs.sh

## Using initramfs - see mkinitramfs.sh

# Run GDB on anthoer console

```bash
$ cd ~/srcs/linux
$ gdb vmlinux -ex 'target remote localhost:1234'
```

# References
- https://www.josehu.com/memo/2021/01/02/linux-kernel-build-debug.html
- https://www.starlab.io/blog/using-gdb-to-debug-the-linux-kernel
