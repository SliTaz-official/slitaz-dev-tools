<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
    "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
<head>
	<title>Mirror RRD stats</title>
	<meta http-equiv="content-type" content="text/html; charset=ISO-8859-1" />
	<meta name="description" content="slitaz mirror rrdtool graphs" />
	<meta name="robots" content="noindex" />
	<meta name="author" content="SliTaz Contributors" />
	<link rel="shortcut icon" href="/css/favicon.ico" />
	<link rel="stylesheet" type="text/css" href="/css/slitaz.css" />
</head>
<body>

<!-- Header -->
<div id="header">
    <a href="http://<?php echo $_SERVER["HTTP_HOST"]; ?>/info/"><img id="logo"
		src="/css/pics/website/logo.png" 
		title="<?php echo $_SERVER["HTTP_HOST"]; ?>/info/" alt="<?php echo $_SERVER["HTTP_HOST"]; ?>/info/" /></a>
    <p id="titre">#!/project/<?php echo preg_replace('/(\w+).*/i','$1',$_SERVER["HTTP_HOST"]); ?></p>
</div>

<!-- Content -->
<div id="content-full">

<!-- Block begin -->
<div class="block">
	<!-- Nav block begin -->
	<div id="block_nav">
		<h4>SliTaz Network</h4>
		<ul>
			<li><a href="http://www.slitaz.org/">Main Website</a></li>
			<li><a href="http://doc.slitaz.org/">Documentation</a></li>
			<li><a href="http://forum.slitaz.org/">Community Forum</a></li>
			<li><a href="http://scn.slitaz.org/">Community Platform</a></li>
			<li><a href="http://labs.slitaz.org/">SliTaz Laboratories</a></li>
			<li><a href="http://pkgs.slitaz.org/">Packages Database</a></li>
			<li><a href="http://boot.slitaz.org/">SliTaz Web Boot</a></li>
			<li><a href="http://tank.slitaz.org/">SliTaz main server</a></li>
			<li><a href="http://bb.slitaz.org/">SliTaz Build Bot</a></li>
			<li><a href="http://hg.slitaz.org/">SliTaz Repositories</a></li>
			<li><a href="http://twitter.com/slitaz">SliTaz on Twitter</a></li>
			<li><a href="http://www.distrowatch.com/slitaz">SliTaz on DistroWatch</a></li>
		</ul>
	<!-- Nav block end -->
	</div>
	<!-- Top block begin -->
	<div id="block_top">
		<h1>Mirror RRD stats</h1>
		<meta http-equiv="content-type" content="text/html; charset=ISO-8859-1" />
		<meta name="description" content="slitaz mirror rrdtool graphs" />
		<meta name="robots" content="noindex" />
		<meta name="author" content="SliTaz Contributors" />
		<link rel="shortcut icon" href="/css/favicon.ico" />
		<link rel="stylesheet" type="text/css" href="/css/slitaz.css" />
		<style type="text/css">
#nav {
	right: 4%;
}

#content {
	padding: 0px 40px 60px 4%;
}

#copy {
	text-align: center;
}

#bottom {
	text-align: center;
}

	</style>

		<p>
			This is the SliTaz GNU/Linux main mirror. The server runs naturally SliTaz 
			(stable) in an lguest virtual machine provided by 
			<a href="http://www.ads-lu.com/">Allied Data Sys. (ADS)</a>.
		</p>
		<p>
			Mirror CPU is a <?php system("sed -e '/^model name/!d;s/.*Intel(R) //;" .         
			"s/@//;s/(.*)//;s/CPU //;s/.*AMD //;s/.*: //;s/Processor //' </proc/cpuinfo |" .
			" awk '{ s=$0; n++ } END { if (n == 2) printf \"dual \";" .
			"if (n == 4) printf \"quad \"; print s }' ")?> -
			<?php system("free | awk '/Mem:/ { x=2*$2-1; while (x >= 1024) { x /= 1024; ".
			"n++ }; y=1; while (x > 2) { x /= 2; y *= 2}; ".
			"printf \"%d%cB RAM\",y,substr(\"MG\",n,1) }' ")?> - Located in France next to 
			Roubaix. This page has real time statistics provided by PHP 
			<code>system()</code> Mirror is also monitored by RRDtool which provides 
			<a href="graphs.php">graphical stats</a>.
		</p>
	<!-- Top block end -->
	</div>
<!-- Block end -->
</div>



<?php

$myurl="http://".$_SERVER['SERVER_NAME'].$_SERVER['SCRIPT_NAME'];

function one_graphic($img,$name)
{
	echo '<img src="pics/rrd/'.$img.'" title="'.
		$name.'" alt="'.$name.'" />'."\n";
}

function graphic($res, $img='')
{
	global $myurl;
	if (!$img) $img=$res;
	echo "<a name=\"".$res."\"></a>";
	echo "<a href=\"".$myurl."?stats=".$res."#".$res."\">\n";
	one_graphic($img."-day.png",$res." daily");
	echo "</a>";
	if ($_GET['stats'] == $res) {
		one_graphic($img."-week.png",$res." weekly");
		one_graphic($img."-month.png",$res." monthly");
		one_graphic($img."-year.png",$res." yearly");
	}
}

echo "<h2>CPU</h2>\n";
graphic("cpu");
echo "<h2>Memory</h2>\n";
graphic("memory");
echo "<h2>Disk</h2>\n";
graphic("disk");
echo "<h2>Network</h2>\n";
$eth = array();
exec("/sbin/route -n | awk '{ if (/^0.0.0.0/) print $8 }'", $eth);
graphic("net",$eth[0]);

?>

<!-- End of content -->
</div>

<!-- Start of footer and copy notice -->
<div id="copy">
<p>                                                                          
Last update : <?php echo date('r'); ?>
</p> 
<p>
Copyright &copy; <?php echo date('Y'); ?> <a href="http://www.slitaz.org/">SliTaz</a> -
<a href="http://www.gnu.org/licenses/gpl.html">GNU General Public License</a>
</p>
<!-- End of copy -->
</div>

<!-- Bottom and logo's -->
<div id="bottom">
<p>
<a href="http://validator.w3.org/check?uri=referer"><img
   src="/css/pics/website/xhtml10.png" alt="Valid XHTML 1.0"
   title="Code validé XHTML 1.0"
   style="width: 80px; height: 15px;" /></a>
</p>
</div>

</body>
</html>
