#!/bin/sh

# Location of slitaz rolling release
rolling=/home/bellard/rolling

flavors="core-4in1 core preinit"
lorams="core-4in1"
packages=/home/slitaz/cooking/chroot/home/slitaz/packages

# We use the last build as build environment
system=$rolling/slitaz-core.iso

create_loram()
{
case " $lorams " in
*\ $1\ *)	true;;
*)		false;;
esac
}

htmlize()
{
echo -e "<html>\n<body>\n<pre>"
sed 's/.*%.\[/[/g' | dos2unix | sed 's/?Getting/? y\nGetting/' | sed \
    -e 's|\(Filesystem size:\).*G\([0-9\.]*M\) *$|\1 \2|' \
    -e 's|.\[1m|<b>|' -e 's|.\[0m|</b>|' -e 's|.\[[0-9Gm;]*||g' \
    -e 's|#.*|<i><span style="color: blue">&</span></i>|' \
    -e ':a;s/^\(.\{1,68\}\)\(\[ [A-Za-z]* \]\)/\1 \2/;ta' \
    -e 's#\[ OK \]#[ <span style="color: green">OK</span> ]#' \
    -e 's#\[ Failed \]#[ <span style="color: red">Failed</span> ]#'
echo -e "</pre>\n</body>\n</html>"
}

# Build the rolling release if something is new on mirror
for flavor in $flavors ; do
    if [ ! -s $rolling/slitaz-$flavor.iso -o \
	 $packages/$flavor.flavor -nt $rolling/slitaz-$flavor.iso -o \
         $packages/packages.list -nt $rolling/slitaz-$flavor.iso ]; then
	[ -d $rolling ] || mkdir -p $rolling
	TMP=$rolling/tmp$$
	mkdir -p $TMP/iso $TMP/fs/var/lib/tazpkg $TMP/fs/home/slitaz/cooking \
		 $TMP/fs/var/cache/tazpkg/cooking/packages
	chown -R root.root $TMP
	chmod -R 755 $TMP
	mount -o loop,ro $system $TMP/iso
	for i in $(ls -r $TMP/iso/boot/rootfs*.gz) ; do
		unlzma -c $i | ( cd $TMP/fs ; cpio -idmu )
	done
	mount --bind $packages $TMP/fs/var/cache/tazpkg/cooking/packages
	ln -s /var/cache/tazpkg/cooking/packages $TMP/fs/home/slitaz/cooking
	# 3.0 compatibility...
	ln -s cooking/packages $TMP/fs/home/slitaz/packages
	cp -a $packages/packages.* $TMP/fs/var/lib/tazpkg
	cp $packages/$flavor.flavor $TMP/fs
	[ -d $rolling/fixes ] && cp -a $rolling/fixes/. $TMP/fs/.
	echo "cooking" > $TMP/fs/etc/slitaz-release
	umount -d $TMP/iso
	cat > $TMP/fs/root/build.sh <<EOT
#!/bin/sh

echo "# date"
date
echo "# tazlito get-flavor $flavor"
tazlito get-flavor $flavor
echo "# yes '' | tazlito gen-distro"
yes '' | tazlito gen-distro
EOT
	create_loram $flavor && cat >> $TMP/fs/root/build.sh <<EOT
if [ -s /home/slitaz/cooking/distro/slitaz-$flavor.iso ]; then
echo "# yes y | tazlito build-loram  /home/slitaz/cooking/distro/slitaz-$flavor.iso /root/slitaz-$flavor.loram.iso"
yes y | tazlito build-loram  /home/slitaz/cooking/distro/slitaz-$flavor.iso /root/slitaz-$flavor.loram.iso
fi
EOT
	cat >> $TMP/fs/root/build.sh <<EOT
echo "# date"
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
script -c "SHELL=/bin/sh chroot \$DIR /bin/sh /root/build.sh" $TMP/slitaz-$flavor.log
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
	htmlize < $rolling/slitaz-$flavor.log > $rolling/slitaz-$flavor.log.html
	if [ -s $TMP/fs/root/slitaz-$flavor.loram.iso ]; then
		mv -f $TMP/fs/root/slitaz-$flavor.loram.iso $rolling/
		cd $rolling
		md5sum slitaz-$flavor.loram.iso > slitaz-$flavor.loram.md5
		cd - > /dev/null
		echo
	fi
	rm -rf $TMP
    fi
    export DROPBEAR_PASSWORD=none
    SSH="dbclient -i /home/bellard/.ssh/id_rsa.dropbear"
    #BWLIMIT="--bwlimit=40"
    BWLIMIT=""
    rsync $BWLIMIT -vtP -e "$SSH" $rolling/slitaz-$flavor.* \
	bellard@mirror.slitaz.org:/var/www/slitaz/mirror/iso/rolling
done
