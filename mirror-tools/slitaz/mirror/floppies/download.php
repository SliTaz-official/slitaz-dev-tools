<?php

$fdsz=80*18*1024;
$cpiopad=512;
function download($name, $size, $cmd)
{
	header("Content-Type: application/octet-stream");
	header("Content-Length: ".$size);
	header("Content-Disposition: attachment; filename=".$name);
	echo `$cmd 2> /dev/null`;
	exit;
}

function my_filesize($path)	// 2G+ file support
{
	return rtrim(shell_exec("stat -c %s '".$path."'"));
}

if (isset($_GET['iso']))
	$_POST['iso'] = $_GET['iso'];

if (isset($_GET['file']))
{
	$max = floor((my_filesize("../".$_GET["iso"]) + $fdsz - 1 + $cpiopad) / $fdsz);
	$cmd = "cd ../".dirname($_GET['iso'])."; ls ".
		basename($_GET['iso'],".iso").".*".
		" | cpio -o -H newc | cat - /dev/zero ";
	if ($_GET['file'] == "md5sum") {
		$cmd .= "| for i in \$(seq 1 $max); do dd bs=$fdsz ".
			"count=1 2> /dev/null | md5sum | ".
			"sed \"s/-\\\$/\$(printf 'fdiso%02d.img' \$i)/\"; done";
		download("md5sum", 46 * $max, $cmd);
	}
	else {
		$cmd .= "| dd bs=".$fdsz." count=1 skip=".($_GET['file'] - 1)." "; 
		download(sprintf("fdiso%02d.img",$_GET['file']), $fdsz, $cmd);
	}
}
?><!DOCTYPE html>
<html lang="en">
<head>
	<meta charset="UTF-8">
	<title>SliTaz Boot Floppies</title>
	<meta name="description" content="slitaz boot floppies">
	<meta name="robots" content="index, nofollow">
	<meta name="author" content="SliTaz Contributors">
	<link rel="shortcut icon" href="static/favicon.ico">
	<link rel="stylesheet" href="static/slitaz.min.css">
	<style type="text/css">
.block_info { width: 40%; }
nav table { margin: 6px 0 0 0; }
nav table a { color: #215090; }
nav header::before { content: url(pics/floppy.png); vertical-align: middle; padding: 0 6px 0 0; }
pre, tt, code { font-size: 0.9rem; }
	</style>
</head>
<body>

<script>de=document.documentElement;de.className+=(("ontouchstart" in de)?' touch':' no-touch');</script>

<header>
	<h1 id="top"><a href="http://www.slitaz.org/">Boot floppies</a></h1>

	<div class="network">
		<a href="http://www.slitaz.org/" class="home"></a>
		<a href="floppy-grub4dos" title="Boot tools">Generic boot floppy</a>
		<a href="http://tiny.slitaz.org/" title="SliTaz in one floppy !">Tiny SliTaz</a>
		<a href="builder/index.php" title="Build floppies with your own kernel and initramfs">Floppy set web builder</a>
		<a href="builder/bootloader" title="Build your floppy sets without Internet">Shell builder</a>
	</div>
</header>

<!-- Block -->
<div class="block"><div>

	<!-- Information/image -->
	<div class="block_info">
		<header>Available boot floppies</header>
		<ul>
<?php
for ($i = 1; file_exists("index-$i.0.html") ; $i++);
while (--$i > 0) {
	echo "			<li><a href=\"index-$i.0.html\">SliTaz $i.0</a>";
	if (file_exists("index-loram-".$i.".0.html"))
		echo "				&middot; <a href=\"index-loram-$i.0.html\">loram</a>";
	echo "			</li>\n";
}
?>
		</ul>
	</div>


	<!-- Navigation -->
	<nav>
		<header>Download 1.44MB images for <?php $dir = explode('/',$_POST["iso"]); echo $dir[1]; ?></header>
		<table>
<?php
$max = floor((my_filesize("../".$_POST["iso"]) + $fdsz - 1 + $cpiopad) / $fdsz);
for ($i = 1; $i <= $max ; $i++) {
	if ($i % 6 == 1) echo "			<tr>\n";
	echo "				<td><a href=\"download.php?file=$i&amp;iso=".
		urlencode($_POST["iso"])."\">fdiso".sprintf("%02d",$i);
	echo "</a></td>\n";
	if ($i % 6 == 0) echo "			</tr>\n";
}
if ($max % 6 != 0) {
	while ($max % 6 != 5) { echo "				<td> </td>"; $max++; }
}
else echo "			<tr>\n";
echo "				<td><a href=\"download.php?file=md5sum&amp;iso=".
	urlencode($_POST["iso"])."\">md5</a></td>\n			</tr>";
?>
		</table>
	</nav>
</div></div>


<!-- Content -->
<main>

<h2>ISO image floppy set</h2>

<p>You can restore the <a href="../<?php echo $_POST['iso'].
'">'.basename($_POST['iso']); ?></a> ISO image on your hard disk using:</p>

<pre>
# dd if=/dev/fd0 of=fdiso01.img
# dd if=/dev/fd0 of=fdiso02.img
# ...
# cat fdiso*.img | cpio -i
</pre>


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
		Copyright &copy; <span class="year"></span>
		<a href="http://www.slitaz.org/">SliTaz</a>
	</div>
	<div>
		Network:
		<a href="http://scn.slitaz.org/">Community</a> &middot;
		<a href="http://doc.slitaz.org/">Doc</a> &middot;
		<a href="http://forum.slitaz.org/">Forum</a> &middot;
		<a href="http://pkgs.slitaz.org/">Packages</a> &middot;
		<a href="http://bugs.slitaz.org">Bugs</a> &middot;
		<a href="http://hg.slitaz.org/?sort=lastchange">Hg</a>
	</div>
	<div>
		SliTaz @
		<a href="http://twitter.com/slitaz">Twitter</a> &middot;
		<a href="http://www.facebook.com/slitaz">Facebook</a> &middot;
		<a href="http://distrowatch.com/slitaz">Distrowatch</a> &middot;
		<a href="http://en.wikipedia.org/wiki/SliTaz">Wikipedia</a> &middot;
		<a href="http://flattr.com/profile/slitaz">Flattr</a>
	</div>
	<img src="/static/qr.png" alt="#" onmouseover="this.title = location.href"
	onclick="this.src = QRCodePNG(location.href, this)"/>
</footer>

</body>
</html>
