#!/bin/sh

# Current root of web server
rootwww=/var/www/slitaz/mirror
packages=$rootwww/packages/cooking

# Location of slitaz rolling release
rolling=$rootwww/iso/rolling

flavor=core

# We use the last build as build environment
system=$rolling/slitaz-*.iso
[ -s $system ] || system=$rootwww/iso/cooking/slitaz-cooking.iso

# Build the rolling release if something is new on mirror
if [ $packages/$flavor.flavor -nt $system -o \
     $packages/packages.list -nt $system ]; then
	[ -d $rolling ] || mkdir -p $rolling
	TMP=/tmp/rolling$$
	mkdir -p $TMP/iso $TMP/fs/home/slitaz/cooking/packages
	ln $packages/* $TMP/fs/home/slitaz/cooking/packages
	mount -o loop,ro $system $TMP/iso
	for i in $TMP/iso/boot/rootfs*.gz ; do
		unlzma -c $i | ( cd $TMP/fs ; cpio -id )
	done
	umount -d $TMP/iso
	cat > $TMP/fs/root/build.sh <<EOT
#!/bin/sh

tazlito get-flavor $flavor
echo -e "\n" | tazlito gen-distro
EOT
	cat > $TMP/fs/BUILD <<EOT
#!/bin/sh

DIR=\$(dirname \$0)
MOUNTS="/proc /sys /dev/pts /dev/shm"
[ -s /etc/resolv.conf ] && cp /etc/resolv.conf \$DIR/etc
if [ ! -d \$DIR/proc/1 ]; then
	for i in \$MOUNTS; do
		[ -d \$i ] && mount --bind \$i \$DIR/\$i 
	done
	mount --bind /tmp \$DIR/tmp || mount -t tmpfs tmpfs \$DIR/tmp
fi
script -c "SHELL=/bin/sh chroot \$DIR /bin/sh -x /root/build.sh" $TMP/slitaz-$flavor.log
umount \$DIR/tmp
for i in \$MOUNTS; do
	umount \$DIR/\$i 
done
EOT
	sh $TMP/fs/BUILD
	mv -f $TMP/fs/home/slitaz/cooking/distro/slitaz-$flavor.* $rolling/
	mv -f $TMP/slitaz-$flavor.log $rolling/
	rm -rf $TMP
fi
