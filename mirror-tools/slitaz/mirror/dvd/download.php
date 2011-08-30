<?php

$options = array(
		"boot"		=>	"--boot",
		"webboot"	=>	"--webboot",
		"website"	=>	"--website",
		"wok"		=>	"--wok", // TOFIX --wok-stable
		"filter"	=>	"--filter",
		"sources"	=>	"--sources",
		"loram_detect"	=>	"--loram-detect",
		"auto_install"	=>	"--auto-install",
		
		"packages"	=>	"--packages",
		"rsync"		=>	"--rsync",
		"doc"		=>	"--doc",
		"tiny"		=>	"--tiny",
		"pxe"		=>	"--pxe",
		"tools"		=>	"--tools",
		"hg"		=>	"--hg",
		"nonfree"	=>	"--nonfree",
		"huge"		=>	"--huge"
	);
$size = $_POST['size'];
$cmdline = "set -- ".$_POST['version'];
foreach ($options as $var => $arg)
	if (isset($_POST[$var]) && $_POST[$var] == 'on')
		$cmdline .= " ".$arg;
$name = "genDVDimage.sh";
$script =<<<EOT
#!/bin/sh

if [ "\$(basename \$0)" == "$name" -a "\$1" == "" ]; then

	# Default arguments by the web tool http://mirror.slitaz.org/dvd/
	# Expected size: $size KB
	$cmdline
fi


EOT;
$script .= file_get_contents("/usr/bin/mkpkgiso");

header("Content-Type: application/octet-stream");
header("Content-Length: ".strlen($script));
header("Content-Disposition: attachment; filename=".$name);
echo $script;

?>
