#!/bin/sh

list_version()
{
	ls ?.0 -dr | while read dir ; do
		echo $dir
		[ -d loram-$dir ] && echo loram-$dir
	done
}

build_page()
{
	DIR=$1
	VERSION=${DIR#*-}
	case "$DIR" in
	loram*)	LORAM="&nbsp;loram" ;;
	*)	LORAM="";
	esac
	cat <<EOT
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
	"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xml:lang="en" xmlns="http://www.w3.org/1999/xhtml" lang="en">
<head>
	<title>SliTaz Boot Floppies</title>
	<meta http-equiv="content-type" content="text/html; charset=ISO-8859-1" />
	<meta name="description" content="slitaz$LORAM boot floppies $VERSION" />
	<meta name="robots" content="index, nofollow" />
	<meta name="author" content="SliTaz Contributors" />
	<link rel="shortcut icon" href="static/favicon.ico" />
	<link rel="stylesheet" type="text/css" href="static/slitaz.css" />
	<link rel="stylesheet" type="text/css" href="menu.css" />
	<style type="text/css">
table {
	background-color: inherit;
	margin: 10px 0px 0px 0px;
}
#copy {
	text-align: center;
}

#bottom {
	text-align: center;
}

	</style>
</head>
<body bgcolor="#ffffff">
<!-- Header -->
<div id="header">
    <a name="top"></a>
	<div id="logo"></div>
	<div id="network">
	    <ul id="menu">
	      <li>
		<a href="http://www.slitaz.org/">
		<img src="static/home.png" alt="[ home ]" /></a>
	      </li>
	      <li>
		<a href="floppy-grub4dos" title="Boot tools">Generic boot floppy</a>
	      </li>
	      <li>
		<a href="http://tiny.slitaz.org/" title="SliTaz in one floppy and 8Mb RAM">Tiny SliTaz</a>
	        <ul>
$( list_version | while read dir; do
	echo "		  <li>"
	echo "		    <a href=\"index-$dir.html\" title=\"$(cat $dir/title)\">SliTaz ${dir/-/ }</a>"
	echo "		  </li>"
done )
		</ul>
	      </li>
	      <li>
		<a href="builder/index.php" title="Build floppies with your own kernel and initramfs">Floppy set builder</a>
	        <ul>
        	  <li>
		  <a href="builder/bootloader" title="Build your floppy sets without Internet">Standalone shell</a>
        	  </li>
	        </ul>
	      </li>
	    </ul>
	</div>
	<h1><a href="http://www.slitaz.org/">Boot&nbsp;floppies$LORAM&nbsp;$VERSION</a></h1>
</div>   

<!-- Block -->
<div id="block">
	<!-- Navigation -->
	<div id="block_nav" style="height: 146px;">
		<h4><img src="pics/floppy.png" alt="@" />1.44Mb SliTaz$LORAM $VERSION floppy images</h4>
<table width="100%">
$(
n=0
for f in $DIR/fd*img ; do
	[ $n -eq 0 ] && echo "<tr>"
	echo "	<td> <a href=\"$f\">$(basename $f)</a> </td>"
	n=$(( ($n+1)&3 ))
	[ $n -eq 0 ] && echo "</tr>"
done
[ $n -eq 0 ] && echo "<tr>"
while [ $n -ne 3 ]; do
	echo "	<td> </td>"
	n=$(($n+1))
done
)
	<td> <a href="$DIR/md5sum">md5sum</a> </td>
</tr>
</table>
	</div>
	<!-- Information/image -->
	<div id="block_info">
		<h4>Available boot floppies</h4>
		<ul>
$(
tail=""
list_version | while read dir; do
	case "$dir" in
	loram*)	echo -en "\n	<a href=\"index-$dir.html\">loram</a>" ;;
	*) 	echo -en "$tail	<li><a href=\"index-$dir.html\">SliTaz $dir</a>" ;;
	esac
	tail="</li>\n"
done
)</li>
		</ul>
	</div>
</div>
		
<!-- Content top. -->
<div id="content_top">
<div class="top_left"></div>
<div class="top_right"></div>
</div>

<!-- Content -->
<div id="content">

<h2>Floppy image set</h2>

<p>
This floppy set will boot a Slitaz stable$LORAM version. You can write floppies
with SliTaz <i>bootfloppybox</i>, 
<a href="http://en.wikipedia.org/wiki/RaWrite">Windows rawrite</a> or simply dd:
</p><pre># dd if=fd001.img of=/dev/fd0
</pre>

<p>
If you have a CD-ROM, an USB port and an USB key or a network card, but you
can't boot these devices directly, then try
<a href="http://mirror.slitaz.org/boot/floppy-grub4dos">floppy-grub4dos</a> 
first. This 1.44Mb floppy provides tiny programs to boot these devices without BIOS
support and some other tools.
</p>
$(cat $DIR/description.html)
<p>
Each floppy set detects disk swaps and can be used without a keyboard.
</p>
<p>
If you have an ext3 partition on your hard disk, the bootstrap can create the
installation script <u>slitaz/install.sh</u>. You will be able to install SliTaz
on your hard disk without extra media.
</p>
<p>
Good luck.
</p>

<a name="fdiso"></a>
<h2>ISO image floppy set</h2>

<form method="post" action="http://mirror.slitaz.org/floppies/download.php">
<p>
The floppy image set above includes an embedded installer and can install
SliTaz on your hard disk.
</p>
<p>
Anyway you may want these ISO images to
<a href="http://doc.slitaz.org/en:guides:uncommoninst#floppy-install">
install SliTaz</a>
<select name="iso">
$(
for file in $(ls ../iso/*/flavors/slitaz-*.iso ../iso/*/slitaz-*.iso | sort); do
	set -- $(echo $(basename $file .iso) | sed 's/-/ /g')
	echo "	<option value=\"${file#../}\">${3:-core} $4 $2</option>"
done
)
</select>
<input name="build" value="Build floppy set" type="submit" />
</p>
</form>
<p>
You can restore the ISO image on your hard disk using :
</p>
<pre>
# dd if=/dev/fd0 of=fdiso01.img
# dd if=/dev/fd0 of=fdiso02.img
# ...
# cat fdiso*.img | cpio -i
</pre>

<h2>Images generation</h2>
<p>
All these floppy images are built with <b>bootfloppybox</b> from
a <i>core</i> or a <i>4in1</i> iso. The <i>loram</i> is preprocessed by
<b>tazlitobox</b> (Low RAM tab). These tools are available since 3.0.
You can extract the <u>kernel</u>, <u>cmdline</u> and <u>rootfs</u> files with 
<a href="floppies">this tool</a>
</p>

<!-- End of content with round corner -->
</div>
<div id="content_bottom">
<div class="bottom_left"></div>
<div class="bottom_right"></div>
</div>

<!-- Start of footer and copy notice -->
<div id="copy">
<p>
Copyright &copy; <span class="year"></span> <a href="http://www.slitaz.org/">SliTaz</a> -
<a href="http://www.gnu.org/licenses/gpl.html">GNU General Public License</a>
</p>
<!-- End of copy -->
</div>

<!-- Bottom and logo's -->
<div id="bottom">
<p>
<a href="http://validator.w3.org/check?uri=referer"><img src="static/xhtml10.png" alt="Valid XHTML 1.0" title="Code validé XHTML 1.0" style="width: 80px; height: 15px;" /></a>
</p>
</div>

</body>
</html>
EOT
}

if [ -n "$1" ]; then
	build_page $1
else
	list_version | while read dir ; do
		[ -s $dir/description.html ] || continue
		[ -s $dir/md5sum ] || continue
		build_page $dir > index-$dir.html
	done
fi
