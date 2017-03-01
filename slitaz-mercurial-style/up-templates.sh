#!/bin/sh
#
. /lib/libtaz.sh
check_root

rm -rf /usr/lib/python2.7/site-packages/mercurial/templates/slitaz

echo "Copying template files to system wide location..."
cp -rf templates/slitaz \
	/usr/lib/python2.7/site-packages/mercurial/templates

cp -rf templates/static \
	/usr/lib/python2.7/site-packages/mercurial/templates

exit 0
