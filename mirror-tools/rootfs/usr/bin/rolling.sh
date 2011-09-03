#!/bin/sh

# Location of slitaz rolling release
rolling=/home/bellard/rolling

flavors="core-4in1 core"
packages=/home/slitaz/cooking/chroot/home/slitaz/packages

# We use the last build as build environment
system=$rolling/slitaz-core.iso

# Build the rolling release if something is new on mirror
for flavor in $flavors ; do
    if [ $packages/$flavor.flavor -nt $rolling/slitaz-$flavor.iso -o \
         $packages/packages.list -nt $rolling/slitaz-$flavor.iso ]; then
	[ -d $rolling ] || mkdir -p $rolling
	TMP=$rolling/tmp$$
	mkdir -p $TMP/iso $TMP/fs/var/lib/tazpkg $TMP/fs/home/slitaz/cooking \
		 $TMP/fs/var/cache/tazpkg/cooking/packages
	mount --bind $packages $TMP/fs/var/cache/tazpkg/cooking/packages
	ln -s /var/cache/tazpkg/cooking/packages $TMP/fs/home/slitaz/cooking
	# 3.0 compatibility...
	ln -s cooking/packages $TMP/fs/home/slitaz/packages
	cp -a $packages/packages.* $TMP/fs/var/lib/tazpkg
	cp $packages/$flavor.flavor $TMP/fs
	mount -o loop,ro $system $TMP/iso
	for i in $TMP/iso/boot/rootfs*.gz ; do
		unlzma -c $i | ( cd $TMP/fs ; cpio -id )
	done
	[ -d $rolling/fixes ] && cp -a $rolling/fixes/. $TMP/fs/.
	echo "cooking" > $TMP/fs/etc/slitaz-release
	umount -d $TMP/iso
	cat > $TMP/fs/root/build.sh <<EOT
#!/bin/sh

date
tazlito get-flavor $flavor
yes '' | tazlito gen-distro
date
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
	# 3.0 compatibility...
	[ -d $TMP/fs/home/slitaz/cooking/distro ] || 
	ln -s ../distro $TMP/fs/home/slitaz/cooking/distro
	umount $TMP/fs/var/cache/tazpkg/cooking/packages
	mv -f $TMP/fs/home/slitaz/cooking/distro/slitaz-$flavor.* $rolling/
	mv -f $TMP/slitaz-$flavor.log $rolling/
	rm -rf $TMP
    fi
    rsync --bwlimit=40 -vtP -e 'ssh -i /home/bellard/.ssh/id_rsa' \
	$rolling/slitaz-$flavor.* \
	bellard@mirror.slitaz.org:/var/www/slitaz/mirror/iso/rolling
done
