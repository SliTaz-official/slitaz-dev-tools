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
?><!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
	"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xml:lang="en" xmlns="http://www.w3.org/1999/xhtml" lang="en">
<head>
	<title>SliTaz Boot Floppies</title>
	<meta http-equiv="content-type" content="text/html; charset=ISO-8859-1" />
	<meta name="description" content="slitaz boot floppies" />
	<meta name="robots" content="index, nofollow" />
	<meta name="author" content="SliTaz Contributors" />
	<link rel="shortcut icon" href="../css/favicon.ico" />
	<link rel="stylesheet" type="text/css" href="../css/slitaz.css" />
	<style type="text/css">
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
		<a href="http://www.slitaz.org/">
		<img src="/css/pics/network.png" alt="network.png" /></a>
		<a href="../boot/floppy-grub4dos" title="Boot tools">Generic boot floppy</a> |
		<a href="http://tiny.slitaz.org/" title="SliTaz in one floppy !">Tiny SliTaz</a> |
		<a href="index-loram.html" title="Floppy image sets for low ram systems">Loram floppies</a> |
		<a href="builder/index.php" title="Build floppies with your own kernel and initramfs">Floppy set web builder</a> |
		<a href="builder/bootloader" title="Build your floppy sets without Internet">Shell builder</a>
	</div>
	<h1><a href="http://www.slitaz.org/">Boot floppies</a></h1>
</div>   

<!-- Block -->
<div id="block">
	<!-- Navigation -->
	<div id="block_nav">
		<h4><img src="pics/floppy.png" alt="@" />Download 1.44Mb images for <?php $dir = explode('/',$_POST["iso"]); echo $dir[1]; ?></h4>
<table width="100%">
<?php
$max = floor((my_filesize("../".$_POST["iso"]) + $fdsz - 1 + $cpiopad) / $fdsz);
for ($i = 1; $i <= $max ; $i++) {
	if ($i % 4 == 1) echo "<tr>\n";
	echo "	<td><a href=\"download.php?file=$i&amp;iso=".
		urlencode($_POST["iso"])."\">fdiso".sprintf("%02d",$i);
	if ($max < 100) echo ".img";
	echo "</a></td>\n";
	if ($i % 4 == 0) echo "</tr>\n";
}
if ($max % 4 != 0) {
	while ($max % 4 != 3) { echo "<td></td>"; $max++; }
}
else echo "<tr>\n";
echo "	<td><a href=\"download.php?file=md5sum&amp;iso=".
	urlencode($_POST["iso"])."\">md5sum</a></td>\n</tr>";
?>
</table>
	</div>
	<!-- Information/image -->
	<div id="block_info">
		<h4>Available boot floppies</h4>
		<ul>
	<li><a href="index-3.0.html">SliTaz 3.0</a></li>
	<li><a href="index-loram-3.0.html">SliTaz loram 3.0</a></li>
	<li><a href="index-2.0.html">SliTaz 2.0</a></li>
	<li><a href="index-1.0.html">SliTaz 1.0</a></li>
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

<h2>ISO image floppy set</h2>

<p>
You can restore the <a href="../<?php echo $_POST['iso'].
'">'.basename($_POST['iso']); ?></a> ISO image on your hard disk using :
</p>
<pre>
# dd if=/dev/fd0 of=fdiso01.img
# dd if=/dev/fd0 of=fdiso02.img
# ...
# cat fdiso*.img | cpio -i
</pre>

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

<!-- Bottom and logos -->
<div id="bottom">
<p>
<a href="http://validator.w3.org/check?uri=referer"><img src="../css/pics/website/xhtml10.png" alt="Valid XHTML 1.0" title="Code validé XHTML 1.0" style="width: 80px; height: 15px;" /></a>
</p>
</div>

</body>
</html>
