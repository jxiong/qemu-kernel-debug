#!/bin/bash

git clone https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux.git -b linux-6.9.y linux

cp kernel_config linux/.config

pushd linux
make oldconfig
make -j $(nproc) vmlinux bzImage
