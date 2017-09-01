<?php
if (false) { // no php support on this mirror !
?>
<!DOCTYPE html>
<html lang="en">
<head>
	<meta charset="UTF-8">
	<title>SliTaz Boot Floppies redirection</title>
	<meta name="description" content="slitaz boot floppies builder redirection">
	<meta name="robots" content="index, nofollow">
	<meta name="viewport" content="width=device-width, initial-scale=1">
	<meta name="author" content="SliTaz Contributors">
	<meta http-equiv="Refresh" content="0;url=http://mirror1.slitaz.org/floppies/builder/index.php">
</head>
<body>
	<script type="text/javascript">
	window.location.replace('http://mirror1.slitaz.org/floppies/builder/index.php')
	</script>
	<noscript>
	<frameset rows="100%">
		<frame src="http://mirror1.slitaz.org/floppies/builder/index.php">
		<noframes>
		<body>Please follow <a href="http://mirror1.slitaz.org/floppies/builder/index.php
		">this link</a>.</body>
		</noframes>
	</frameset>
	</noscript>
</body>
</html>
<?php
}
ini_set('upload_max_filesize','16M');
ini_set('post_max_size','16M');
if (isset($_GET['id']) && is_file("/tmp/".$_GET['id']."/fd")) {

	// Download a floppy image

	$size = $_GET['s'];
	if ($size == 0)
		$size = filesize("/tmp/".$_GET['id']."/fd");
	header("Content-Type: application/octet-stream");
	header("Content-Length: ".$size);
	header("Content-Disposition: attachment; filename=".
		sprintf("fd%03d.img",$_GET['n']));
	$cmd = "cat /tmp/".$_GET['id']."/fd";
	if ($_GET['s'] != 0) {
		$cmd .= " /dev/zero | dd count=1 bs=".$_GET['s'];
		if ($_GET['n'] > 1)
			$cmd .= " skip=".($_GET['n']-1);
	}
	echo `$cmd 2> /dev/null`;
	exit;
}
?>
<!DOCTYPE html>
<html lang="en">
<head>
	<meta charset="UTF-8">
	<title>SliTaz Boot Floppies</title>
	<meta name="description" content="slitaz boot floppies builder">
	<meta name="robots" content="index, nofollow">
	<meta name="viewport" content="width=device-width, initial-scale=1">
	<meta name="author" content="SliTaz Contributors">
	<link rel="shortcut icon" href="../static/favicon.ico">
	<link rel="stylesheet" href="../static/slitaz.min.css">
	<style>
input[type=text] { width: inherit; }
	</style>
</head>
<body>

<script>de=document.documentElement;de.className+=(("ontouchstart" in de)?' touch':' no-touch');</script>

<header>
	<h1 id="top"><a href="http://www.slitaz.org/">Boot floppies builder</a></h1>
	<div class="network">
		<a href="http://www.slitaz.org/" class="home"></a>
		<a href="bootloader" title="Build your floppy sets without Internet">Shell builder</a>
		<a href="../floppy-grub4dos" title="Boot tools">Generic boot floppy</a>
	</div>
</header>

<!-- Block -->
<div class="block"><div>

	<!-- Navigation menu -->

<?php

	// Cleanup old sessions

	$dir = opendir("/tmp");
	while (($name = readdir($dir)) !== false) {
		if (preg_match('/^fdbuild/',$name) == 0) continue;
		if (filemtime("/tmp/$name") > strtotime("-1 hour")) continue;
		system("rm -rf /tmp/$name");
	}
	closedir($dir);

function get_long($file, $offset)
{
	$value = 0;
	if ($fp = fopen($file,"r")) {
		fseek($fp,$offset,SEEK_SET);
		for ($i = 0; $i < 32; $i += 8) {
			$value += ord(fgetc($fp)) << $i;
		}
		fclose($fp);
	}
	return $value;
}

function error($string, $title="Error")
{
	echo <<<EOT
	<nav>
		<header>$title</header>
		<p>$string</p>
	</nav>
EOT;
}

	$size = 0;
	$initrd_size = 0;
	$info_size = 0;

	// Upload kernel

	foreach($_FILES as $data) {
		$msg="The file ".$data['name']." ";
		switch ($data["error"]) {
		case UPLOAD_ERR_INI_SIZE   : 
			error($msg."exceeds upload_max_filesize.");
			break;
		case UPLOAD_ERR_FORM_SIZE  : 
			error($msg."exceeds max_post_size.");
			break;
		case UPLOAD_ERR_PARTIAL    : 
			error($msg."was only partially uploaded.");
			break;
		case UPLOAD_ERR_NO_TMP_DIR : 
			error("Missing a temporary folder.");
			break;
		case UPLOAD_ERR_CANT_WRITE : 
			error("Failed to write file to disk.");
			break;
		}
	}
	if (isset($_FILES["kernel"]['tmp_name']) &&
		is_uploaded_file($_FILES["kernel"]['tmp_name'])) {
		$tmp_dir = tempnam('','fdbuild');
		if (file_exists($tmp_dir)) unlink($tmp_dir);
		mkdir($tmp_dir);
		$tmp_dir .= '/';
		move_uploaded_file($_FILES["kernel"]['tmp_name'],
				   $tmp_dir."kernel");
		$kernel = $tmp_dir."kernel";
		$boot_version = get_long($kernel,0x206) & 255;
		if (get_long($kernel,0x202) != 0x53726448) // 'HdrS' magic
			$boot_version = 0;
		$size = get_long($kernel,0x1F4);	// syssize paragraphs
		if ($boot_version < 4) $size &= 0xFFFF;	// 16 bits before 2.4
		$size = ($size + 0xFFF) & 0xFFFF000;	// round up to 64K
		$size <<= 4;				// paragraphs -> bytes
		$msg = "The size of the file ".$_FILES["kernel"]['name'];
	}

	if ($size && isset($_FILES["info"]['tmp_name']) &&
		is_uploaded_file($_FILES["info"]['tmp_name'])) {
		move_uploaded_file($_FILES["info"]['tmp_name'],
				   $tmp_dir."info");
		$info_size = $_FILES["info"]['size'];
	}

	// Upload initrd

	if ($size) for ($i = 0; $i < count($_FILES["initrd"]['name']); $i++)
	if (isset($_FILES["initrd"]['tmp_name'][$i]) &&
		is_uploaded_file($_FILES["initrd"]['tmp_name'][$i])) {
		move_uploaded_file($_FILES["initrd"]['tmp_name'][$i],
				   $tmp_dir."initrd.".$i);
		$initrd_cmd .= " --initrd ".$tmp_dir."initrd.".$i;
		$initrd_size = $_FILES["initrd"]['size'][$i];
		$size += $initrd_size;
		if ($i == 0)
		$msg = "The total size of the files ".$_FILES["kernel"]['name'].
		       " and ".$_FILES["initrd"]['name'][$i];
		else $msg .= ", ".$FILE["initrd"]['name'][$i];
	}
	if ($initrd_size) for ($i = 0; $i < count($_FILES["initrd2"]['name']); $i++)
	if (isset($_FILES["initrd2"]['tmp_name'][$i]) &&
		is_uploaded_file($_FILES["initrd2"]['tmp_name'][$i])) {
		move_uploaded_file($_FILES["initrd2"]['tmp_name'][$i],
				   $tmp_dir."initrd2.".$i);
		$initrd2_cmd .= " --initrd ".$tmp_dir."initrd2.".$i;
		$initrd2_size = $_FILES["initrd2"]['size'][$i];
		$size += $initrd2_size;
		$msg .= ", ".$FILE["initrd2"]['name'][$i];
	}
	if ($size == 0) {
		if (isset($tmp_dir))
			system("rm -f $tmp_dir");
	}
	else {
		$cmd = "./bootloader ".$tmp_dir."kernel --prefix "
		     . $tmp_dir."fd --format 0 --flags ".$_POST['flags']
		     . " --video ".$_POST['video']." --mem ".$_POST['ram'];
		if ($_POST['edit'] == "")
			$cmd .= " --dont-edit-cmdline";
		if ($_POST['cmdline'])
			$cmd .= " --cmdline '".$_POST['cmdline']."'";
		if ($info_size)
			$cmd .= " --info ".$tmp_dir."info";
		if (file_exists($_POST['rdev']))
			$cmd .= " --rdev ".$_POST['rdev'];
		if ($initrd_size)
			$cmd .= $initrd_cmd;
		if ($initrd2_size)
			$cmd .= $initrd2_cmd;
		switch ($_POST['size']) {
		case 1763328 : 
		case 2015232 : 
		case 3526656 :
		case 4030464 :
			$cmd .= " --tracks 82"; break;
		case 1784832 : 
			$cmd .= " --tracks 83"; break;
		}
		shell_exec($cmd);
		$count = 1;
		if ($_POST['size'] != 0) {
			$count += (filesize($tmp_dir."fd") -1) / $_POST['size'];
			$padding = $_POST['size'] - 
				(filesize($tmp_dir."fd") % $_POST['size']);
		}
	}
	$sizes = array(
		"368640" => "360 KB",   "737280" => "720 KB",
		"1228800" => "1.20 MB",
		"1474560" => "1.44 MB", "1638400" => "1.60 MB",
		"1720320" => "1.68 MB", "1763328" => "1.72 MB",
		"1784832" => "1.74 MB", "1802240" => "1.76 MB",
		"1884160" => "1.84 MB", "1966080" => "1.92 MB", 
		"2015232" => "1.96 MB", "2949120" => "2.88 MB",
		"3440640" => "3.36 MB", "3526656" => "3.44 MB",
		"3932160" => "3.84 MB", "4030464" => "3.92 MB",
		"0"       => "no limit"
	);

function show_size($size)
{
	global $sizes;
	if ($size != 0) return " ".$sizes[$size];
}
?>

	<!-- End navigation menu -->
</div></div>


<!-- Content -->
<main>

<h2>Floppy image set builder</h2>

<script>
if (window.File && window.FileReader && window.FileList && window.Blob) {
	try {
		updateHtmlCode();
	}
	catch (any) {
		var element = document.createElement("script");
		element.src = "clientbuilder.js";
		element.type = "text/javascript";
		element.onload = function() {
			updateHtmlCode();
		};
		document.body.appendChild(element);
	}
}
</script>
<?php
	if (!isset($count)) {
		$max = rtrim(ini_get('upload_max_filesize'),"M");
		$max_post = rtrim(ini_get('post_max_size'),"M");
		if ($max_post < $max) $max = $max_post;
		$msg = "the web server can't upload more than $max MB";
?>
<form id="io" method="post" enctype="multipart/form-data" action="<?php echo $_SERVER["PHP_SELF"]; ?>">

<div class="large"><table>
	<tr>
		<td>Linux kernel:</td>
		<td><input type="file" name="kernel" size="37" /> <i>required</i></td>
	</tr>
	<tr>
		<td>Initramfs / Initrd:</td>
		<td><input type="file" name="initrd[]" size="37" multiple /> <i>optional</i></td>
	</tr>
	<tr>
		<td>Extra initramfs:</td>
		<td><input type="file" name="initrd2[]" size="37" multiple /> <i>optional</i></td>
	</tr>
	<tr>
		<td>Boot message:</td>
		<td><input type="file" name="info" size="37" /> <i>optional</i></td>
	</tr>
	<tr>
		<td>Default cmdline:</td>
		<td id="cmdline"><input type="text" name="cmdline" size="36" <?php
		if (isset($_GET['cmdline'])) echo 'value="'.$_GET['cmdline'].'"';
	?>/> <input type="checkbox" name="edit" checked="checked" />edit
	<i>optional</i></td>
	</tr>
	<tr>
		<td>Root device:</td>
		<td><input type="text" name="rdev" size="8" value="<?php
		if (isset($_GET['rdev'])) echo $_GET['rdev'];
		else echo "/dev/ram0";
	?>" />
	&nbsp;&nbsp;Flags: <select name="flags">
		<option value="1">R/O</option>
		<option value="0" <?php
			if (isset($_GET['rdev']) && $_GET['rdev'] == "0")
				echo ' selected="selected"'
		?>>R/W</option>
	</select>
	&nbsp;&nbsp;VESA: <select name="video">
		<?php
			$selected=-1;
			if (isset($_GET['video'])) $selected = $_GET['video'];
			$options = array();
			$options[-3] = "Ask";
			$options[-2] = "Extended";
			$options[-1] = "Standard";
			for ($i = 0; $i < 16; $i++) $options[$i] = $i;
			$options[0xF00] = "80x25";
			$options[0xF01] = "80x50";
			$options[0xF02] = "80x43";
			$options[0xF03] = "80x28";
			$options[0xF05] = "80x30";
			$options[0xF06] = "80x34";
			$options[0xF07] = "80x60";
			$options[0x30A] = "132x43";
			$options[0x309] = "132x25";
			$options[0x338] = "320x200x8"; // 382?
			$options[0x30D] = "320x200x15";
			$options[0x30E] = "320x200x16";
			$options[0x30F] = "320x200x24";
			$options[0x320] = "320x200x32";
			$options[0x332] = "320x240x8"; // 392?
			$options[0x393] = "320x240x15";
			$options[0x335] = "320x240x16";// 394?
			$options[0x395] = "320x240x24";
			$options[0x396] = "320x240x32";
			$options[0x333] = "400x300x8";// 3A2?
			$options[0x3A3] = "400x300x15";
			$options[0x336] = "400x300x16";// 3A4?
			$options[0x3A5] = "400x300x24";
			$options[0x3A6] = "400x300x32";
			$options[0x334] = "512x384x8";// 3B2?
			$options[0x3B3] = "512x384x15";
			$options[0x337] = "512x384x16";// 3B4?
			$options[0x3B5] = "512x384x24";
			$options[0x3B6] = "512x384x32";
			$options[0x3C2] = "640x350x8";
			$options[0x3C3] = "640x350x15";
			$options[0x3C4] = "640x350x16";
			$options[0x3C5] = "640x350x24";
			$options[0x3C6] = "640x350x32";
			$options[0x300] = "640x400x8";
			$options[0x383] = "640x400x15";
			$options[0x339] = "640x400x16";// 384?
			$options[0x385] = "640x400x24";
			$options[0x386] = "640x400x32";
			$options[0x301] = "640x480x8";
			$options[0x310] = "640x480x15";
			$options[0x311] = "640x480x16";
			$options[0x312] = "640x480x24";
			$options[0x33A] = "640x480x32";// 321?
			$options[879]   = "800x500x8";
			$options[880]   = "800x500x15";
			$options[881]   = "800x500x16";
			$options[882]   = "800x500x24";
			$options[883]   = "800x500x32";
			//$options[770] = "800x600x4";
			$options[0x303] = "800x600x8";
			$options[0x313] = "800x600x15";
			$options[0x314] = "800x600x16";
			$options[0x315] = "800x600x24";
			$options[0x33B] = "800x600x32";//322?
			$options[815]   = "896x672x8";
			$options[816]   = "896x672x15";
			$options[817]   = "896x672x16";
			$options[818]   = "896x672x24";
			$options[819]   = "896x672x32";
			$options[874]   = "1024x640x8";
			$options[875]   = "1024x640x15";
			$options[876]   = "1024x640x16";
			$options[877]   = "1024x640x24";
			$options[878]   = "1024x640x32";
			//$options[772] = "1024x768x4";
			$options[0x305] = "1024x768x8";
			$options[0x316] = "1024x768x15";
			$options[0x317] = "1024x768x16";
			$options[0x318] = "1024x768x24";
			$options[0x33C] = "1024x768x32";//323?
			$options[869]   = "1152x720x8";
			$options[870]   = "1152x720x15";
			$options[871] =   "1152x720x16";
			$options[872] =   "1152x720x24";
			$options[873] =   "1152x720x32";
			$options[0x307] = "1280x1024x8";
			$options[0x319] = "1280x1024x15";
			$options[0x31A] = "1280x1024x16";
			$options[0x31B] = "1280x1024x24";
			$options[0x33D] = "1280x1024x32";
			$options[835]   = "1400x1050x8";
			$options[837] =   "1400x1050x16";
			$options[838] =   "1400x1040x24";
			$options[864]   = "1440x900x8";
			$options[864]   = "1440x900x15";
			$options[866] =   "1440x900x16";
			$options[867] =   "1440x900x24";
			$options[868] =   "1440x900x32";
			$options[0x330] = "1600x1200x8";
			$options[0x331] = "1600x1200x16";
			$options[893]   = "1920x1200x8";
			foreach ($options as $key => $value) {
				echo '<option value="'.$key.'"';
				if ($key == $selected || $value == $selected)
					echo ' selected="selected"';
				echo '>'.$value."</option>\n";
			}
		?>
		</select>
		</td>
	</tr>
	<tr>
		<td>Floppy size:</td>
		<td><select name="size">
<?php
	foreach ($sizes as $key => $value) {
		switch ($key) {
		case "368640" :
			echo "		<optgroup label=\"5&frac14; SD\">\n";
			break;
		case "737280" :
			echo "		</optgroup>\n";
			echo "		<optgroup label=\"3&frac12; SD\">\n";
			break;
		case "1228800" :
			echo "		</optgroup>\n";
			echo "		<optgroup label=\"5&frac14; HD\">\n";
			break;
		case "1474560" :
			echo "		</optgroup>\n";
			echo "		<optgroup label=\"3&frac12; HD\">\n";
			break;
		case "2949120" :
			echo "		</optgroup>\n";
			echo "		<optgroup label=\"3&frac12; ED\">\n";
			break;
		case "0" :
			echo "		</optgroup>\n";
			break;
		}
		echo "		<option value=\"$key\"";
		if ($key == "1474560") echo " selected='selected'";
		echo ">$value</option>\n";
	}
?>
	</select>&nbsp;
	RAM used&nbsp;<select name="ram">
<?php
	for ($i = 16; $i >= 4; $i--)
		echo "		<option value=\"$i\">$i MB</option>\n";
?>
	</select>&nbsp;
		<input name="build" value="Build floppy set" type="submit" />
	</td>
	</tr>
</table></div>
<?php
		echo <<<EOT
<p id="note1">Note 1: $msg of files (kernel and initramfs) in memory.</p>

<p>Note 2: the extra initramfs may be useful to add your own configuration files.</p>

<p>Note 3: the keyboard is read for ESC or ENTER on every form feed (ASCII 12) in the boot message.</p>
</form>
EOT;
	}
	else {
?>

<h4>Download image<?php if ($count >= 2) echo "s"; ?></h4>

<ul>
<?php
		for ($i = 1; $i <= $count; $i++) {
			echo '	<li><a href="'.$_SERVER["PHP_SELF"].
			     "?id=".basename($tmp_dir)."&amp;n=$i&amp;s=".
			     $_POST["size"].'">'.sprintf("fd%03d.img",$i).
			     show_size($_POST["size"])."</a></li>\n";
		}
		echo "</ul>\n".floor($padding/1024)."KB padding.\n";
?>

<p>You can write floppies with SliTaz <code>bootfloppybox</code>, <a
href="http://en.wikipedia.org/wiki/RaWrite">Windows rawrite</a> or simply
<code>dd</code>:</p>

<pre># dd if=fd001.img of=/dev/fd0</pre>

<p>Start your computer with <tt>fd001.img</tt>. It will show the kernel version
string and the kernel cmdline line. You can edit the cmdline. Most users can
just press Enter.</p>

<?php
		if ($count >= 2) {
?>
<p>The floppy is then loaded into memory (one dot each 64K) and you will be
prompted to insert the next floppy, <tt>fd002.img</tt>. And so on.</p>

<p>The floppy set detects disk swaps and can be used without a keyboard.</p>
<?php
		}
?>
<p>Good luck.</p>

<?php
	}
?>


<h3>How does it work?</h3>

<p>This tool updates the boot sector of your kernel with <a
href="http://hg.slitaz.org/wok/raw-file/13835bce7189/syslinux/stuff/iso2exe/bootloader.S">this
code</a>. You may add a default cmdline and an initramfs. The cmdline can be
edited at boot time but the <acronym title="Check for disk swap every 5 seconds"
>keyboard is not mandatory</acronym>. A <a href="bootloader">standalone
version</a> is available to break the web server upload limit.</p>

<p>Each part (boot, setup, boot message, cmdline, kernel, initramfs) is aligned
to 512 bytes. The result is split to fit the floppy size. The last floppy image
is padded with zeros.</p>

<p>You can extract the <u>kernel</u>, <u>cmdline</u> and <u>rootfs</u> files
with <a href="bootloader" title="./bootloader --extract floppy.*">this tool</a>
from the floppy images.</p>


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
