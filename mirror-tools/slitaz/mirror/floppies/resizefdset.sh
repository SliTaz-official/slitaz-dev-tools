#!/bin/sh

[ -z "$1" ] &&
echo "Usage: $0 [360|720|1200|2880]   resize a floppy disk set" && exit 2
i=0
while [ $(cat fd$i*.img 2> /dev/null | wc -c) -ne 0 ]; do
	cat fd$i*.img | split -b ${1}k - fdx$$ 
	n=0; [ $i -eq 0 ] && n=1
	for f in fdx$$* ; do
		[ -z "$(hexdump -C $f | sed 4!dq)" ] && rm $f && continue
		x=fd$i$(printf "%02d" $n).$1
		mv $f $x
		dd of=$x bs=1k seek=$1 count=0 2> /dev/null
		ls -l $x
		n=$(($n+1))
	done
	i=$(($i+1))
done
trk=80
[ $1 -lt 720 ] && trk=40
false && for i in $(seq 0 9) ; do
	[ $(($1%($trk+$i))) -eq 0 ] || continue
	for j in 362 369 ; do
		[ $(od -j $j -N 2 -t u2 -An fd001.$1) -eq 20733 ] &&
		printf '\\\\x%02X' $(($trk+$i)) | xargs echo -en | \
		dd bs=1 seek=$(($j+1)) of=fd001.$1 conv=notrunc
	done 2> /dev/null
	break
done
false && if [ $1 -lt 200 ]; then
	while read j d ; do
		[ $(od -j $j -N 2 -t u2 -An fd001.$1) -eq $d ] && echo -en \
		\\xF6 | dd bs=1 seek=$(($j+1)) of=fd001.$1 conv=notrunc
	done 2> /dev/null <<EOT
355	12494
359	4566
EOT
fi
