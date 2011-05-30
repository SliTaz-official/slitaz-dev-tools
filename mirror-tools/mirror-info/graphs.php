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
	<style type="text/css">
#copy {
	text-align: center;
}

#bottom {
	text-align: center;
}
	</style>
</head>
<body>

<!-- Header -->
<div id="header">
	<div id="logo"></div>
	<div id="network">
		<a href="http://www.slitaz.org/">
		<img src="/css/pics/network.png" alt="network.png" /></a>
		<a href="http://scn.slitaz.org/">Community</a>
		<a href="http://doc.slitaz.org/" title="SliTaz Community Documentation">Doc</a>
		<a href="http://forum.slitaz.org/" title="Slitaz Forum">Forum</a>
		<a href="http://bugs.slitaz.org/" title="Bug Tracking System">Bugs</a>
		<a href="http://hg.slitaz.org/" title="SliTaz repositories">Hg</a>
	</div>
	<h1><a href="http://<?php echo $_SERVER["HTTP_HOST"]; ?>/">SliTaz 
	<?php $host=preg_replace('/(\w+).*/i','$1',$_SERVER["HTTP_HOST"]); echo $host; ?></a></h1>
</div>

<!-- Block -->
<div id="block">
	<!-- Navigation -->
	<div id="block_nav">
		<h4><img src="/css/pics/development.png" alt="development.png" />Developers Corner</h4>
		<ul>
			<li><a href="http://www.slitaz.org/en/devel/">Website devel</a></li>
			<li><a href="http://scn.slitaz.org/">Community</a></li>
			<li><a href="http://labs.slitaz.org/">Laboratories</a></li>
			<li><a href="http://hg.slitaz.org/">Mercurial Repos</a></li>
			<li><a href="http://cook.slitaz.org/">Build Bot</a></li>
			<li><a href="http://tank.slitaz.org/">Tank Server</a></li>
			<li><a href="http://mirror.slitaz.org/info/">Mirror Server</a></li>
		</ul>
	</div>
	<!-- Information/image -->
	<div id="block_info">
	<h4>Codename: <?php echo $host; ?></h4>
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
	</div>
</div>

<!-- Content -->
<div id="content">

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
