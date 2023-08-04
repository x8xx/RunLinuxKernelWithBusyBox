#!/bin/bash

SCRIPT_DIR=$(cd $(dirname $0); pwd)
cd $SCRIPT_DIR

set -ex

git clone https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux.git

tar xvf busybox-1.32.1.tar.bz2
cd busybox-1.32.1
cp ../busybox.config ./.config

make -j$(nproc)
make install

cd ./_install
mkdir dev
sudo mknod dev/null c 1 3
mkdir proc
mkdir sys
mkdir -p etc/init.d

cat << EOF > ./etc/init.d/rcS
#!/bin/sh
mount -t proc none /proc
mount -t sysfs none /sys
/sbin/mdev -s
EOF

cat << EOF > ./etc/inittab
::sysinit:/etc/init.d/rcS
::respawn:-/bin/sh
::respawn:/sbin/getty -L ttyS5 115200 vt100
::ctrlaltdel:/bin/umount -a -r
EOF

cat << EOF > ./init.c
/* init.c */
#include <stdio.h>

void main() {
    printf("Hello World!");
    while(1);
}
EOF
gcc -static -o init ./init.c

chmod 755 ./init ./etc/init.d/rcS

find . | cpio -o --format=newc | gzip > ../../initrd.img
