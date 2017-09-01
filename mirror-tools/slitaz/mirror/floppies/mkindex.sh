#!/bin/sh

list_version() {
	ls rolling ?.0 -dr | \
	while read dir; do
		echo $dir
		[ -d loram-$dir ] && echo loram-$dir
		[ -d  web-$dir ] && echo  web-$dir
		[ -d  mini-$dir ] && echo  mini-$dir
	done
}

build_page() {
	DIR=$1
	case "$DIR" in
	*.*)	stable=stable;;
	*)	stable=development;;
	esac
	VERSION=${DIR#*-}
	case "$DIR" in
		web*)	TYPE="&nbsp;web" ;;
		mini*)	TYPE="&nbsp;mini" ;;
		loram*)	TYPE="&nbsp;loram" ;;
		*)	TYPE=""
	esac
	TITLE="Floppy image set"
	[ -s $DIR/title ] && TITLE="$(cat $DIR/title)"
	cat <<EOT
<!DOCTYPE html>
<html lang="en">
<head>
	<title>SliTaz Boot Floppies</title>
	<meta charset="UTF-8">
	<meta name="description" content="slitaz$TYPE boot floppies $VERSION">
	<meta name="robots" content="index, nofollow">
	<meta name="author" content="SliTaz Contributors">
	<meta name="viewport" content="width=device-width, initial-scale=1.0">
	<link rel="shortcut icon" href="static/favicon.ico">
	<link rel="stylesheet" href="static/slitaz.min.css">
	<link rel="stylesheet" href="menu.css">
	<style type="text/css">
.block_info { width: inherit; }
nav table { margin: 6px 0 0 0; }
nav table a { color: #215090; }
nav header::before { content: url(pics/floppy.png); vertical-align: middle; padding: 0 6px 0 0; }
pre, tt, code { font-size: 0.9rem; }
	</style>
</head>
<body>

<script>de=document.documentElement;de.className+=(("ontouchstart" in de)?' touch':' no-touch');</script>

<header>
	<h1 id="top"><a href="http://www.slitaz.org/">Boot floppies $DIR</a></h1>

	<div class="network">
		<a href="http://www.slitaz.org/" class="home"></a>
		<ul id="menu">
			<li>
				<a href="floppy-grub4dos"
				title="Boot tools"
				>Generic boot floppy</a>
			</li>
			<li>
				<a href="http://tiny.slitaz.org/"
				title="SliTaz in one floppy and 4Mb RAM"
				>Tiny SliTaz</a>
				<ul>
$(
list_version | \
while read dir; do
	case "$dir" in
	*-*)
		echo -n "					<li>"
		text="${dir/-/ }";;
	*)
		echo -n "					$ul<li>"
		text="SliTaz ${dir/-/ }";;
	esac

	echo "						<a href=\"index-$dir.html\""
	echo "						title=\"$(cat $dir/title)\""
	echo "						>$text</a>"

	case "$dir" in
	*-*)
		echo "					</li>";;
	*)
		echo "						<ul>"
		ul="						</ul>
					</li>";;
	esac
done )
						</ul>
					</li>
				</ul>
			</li>
			<li>
				<a href="builder/index.php"
				title="Build floppies with your own kernel and initramfs"
				>Floppy set builder</a>
				<ul>
					<li>
						<a href="builder/bootloader"
						title="Build your floppy sets without Internet"
						>Standalone shell</a>
					</li>
				</ul>
			</li>
		</ul>
	</div>
</header>

<!-- Block -->
<div class="block"><div>

	<!-- Information/image -->
	<div class="block_info">
		<header>Available boot floppies</header>
		<ul>
$(
tail=""
list_version | \
while read dir; do
	case "$dir" in
	web*)	echo -en "\n				· <a href=\"index-$dir.html\">web</a>" ;;
	mini*)	echo -en "\n				· <a href=\"index-$dir.html\">mini</a>" ;;
	loram*)	echo -en "\n				· <a href=\"index-$dir.html\">loram</a>" ;;
	*)   	echo -en "$tail			<li><a href=\"index-$dir.html\">SliTaz $dir</a>" ;;
	esac
	tail="</li>\n"
done
)</li>
		</ul>
	</div>

	<!-- Navigation -->
	<nav>
		<header>1.44MB SliTaz$TYPE $VERSION floppy images</header>
		<div class="large"><table>
$(
n=0
for f in $DIR/fd*img ; do
	[ $n -eq 0 ] && echo "			<tr>"
	echo "				<td><a href=\"$f\">$(basename $f .img)</a></td>"
	n=$(( ($n+1)%6 ))
	[ $n -eq 0 ] && echo "			</tr>"
done
[ $n -eq 0 ] && echo "			<tr>"
while [ $n -ne 5 ]; do
	echo "				<td> </td>"
	n=$(($n+1))
done
)
				<td><a href="$DIR/md5sum">md5</a></td>
			</tr>
		</table></div>
	</nav>
</div></div>


<!-- Content -->
<main>

<h2>$TITLE</h2>

<p>This floppy set will boot a SliTaz $stable$TYPE version. You can write floppies
with SliTaz <code>bootfloppybox</code>, <a
href="http://en.wikipedia.org/wiki/RaWrite" target="_blank">Windows rawrite</a>
or simply <code>dd</code>:</p>

<pre># dd if=fd001.img of=/dev/fd0</pre>

<p>If you have a CD-ROM, an USB port and an USB key or a network card, but you
can't boot these devices directly, then try <a
href="http://mirror.slitaz.org/boot/floppy-grub4dos" target="_blank"
>floppy-grub4dos</a> first. This 1.44Mb floppy provides tiny programs to boot
these devices without BIOS support and some other tools.</p>

$(cat $DIR/description.html)

<p>Each floppy set detects disk swaps and can be used without a keyboard.</p>

<p>Good luck.</p>


<h2 id="fdiso">ISO image floppy set</h2>

<form method="get" action="http://mirror1.slitaz.org/floppies/download.php">

	<p>The floppy image set above includes an embedded installer and can install
	SliTaz on your hard disk.</p>

	<p>Anyhow you may want these ISO images to <a
	href="http://doc.slitaz.org/en:guides:uncommoninst#floppy-install">install
	SliTaz</a>

	<select name="iso">
$(
for file in $(ls ../iso/*/flavors/slitaz-*.iso ../iso/*/slitaz-*.iso | sort); do
	set -- $(echo $(basename $file .iso) | sed 's/-/ /g')
	echo "		<option value=\"${file#../}\">${3:-core} $4 $2</option>"
done
)
	</select>

	<input name="build" value="Build floppy set" type="submit"/>
	</p>
</form>

<p>You can restore the ISO image on your hard disk using:</p>

<pre>
# dd if=/dev/fd0 of=fdiso01.img
# dd if=/dev/fd0 of=fdiso02.img
# ...
# cat fdiso*.img | cpio -i
</pre>


<h2>Images generation</h2>

<ul>
	<li>All these floppy images are built from a <i>core</i> or a <i>Nin1</i>
		ISO.</li>
	<li>The <i>loram</i> is preprocessed by <code>tazlitobox</code> (Low RAM
		tab) or <code>tazlito build-loram</code>.</li>
	<li>The versions 1.0 and 2.0 are built with <code>bootfloppybox</code>
		available since 3.0.</li>
	<li>The newer versions are built with <code>taziso floppyset</code>
		available since 5.0.</li>
	<li>You can extract the <u>kernel</u>, <u>cmdline</u> and <u>rootfs*</u>
		files with <a href="floppies">this tool</a>.</li>
	<li>You can change the floppy format (to 2.88M, 1.2M ...)
		with <a href="resizefdset.sh">this tool</a>.</li>
</ul>

<!-- End of content -->
</main>


<script>
	function QRCodePNG(str, obj) {
		try {
			obj.height = obj.width += 300;
			return QRCode.generatePNG(str, {ecclevel: 'H'});
		}
		catch (any) {
			var element = document.createElement("script");
			element.src = "/static/qrcode.min.js";
			element.type = "text/javascript";
			element.onload = function() {
				obj.src = QRCode.generatePNG(str, {ecclevel: 'H'});
			};
			document.body.appendChild(element);
		}
	}
</script>

<footer>
	<div>
		Copyright © <span class="year"></span>
		<a href="http://www.slitaz.org/">SliTaz</a>
	</div>
	<div>
		Network:
		<a href="http://scn.slitaz.org/">Community</a> ·
		<a href="http://doc.slitaz.org/">Doc</a> ·
		<a href="http://forum.slitaz.org/">Forum</a> ·
		<a href="http://pkgs.slitaz.org/">Packages</a> ·
		<a href="http://bugs.slitaz.org">Bugs</a> ·
		<a href="http://hg.slitaz.org/?sort=lastchange">Hg</a>
	</div>
	<div>
		SliTaz @
		<a href="http://twitter.com/slitaz">Twitter</a> ·
		<a href="http://www.facebook.com/slitaz">Facebook</a> ·
		<a href="http://distrowatch.com/slitaz">Distrowatch</a> ·
		<a href="http://en.wikipedia.org/wiki/SliTaz">Wikipedia</a> ·
		<a href="http://flattr.com/profile/slitaz">Flattr</a>
	</div>
	<img src="/static/qr.png" alt="#" onmouseover="this.title = location.href"
	onclick="this.src = QRCodePNG(location.href, this)"/>
</footer>

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
