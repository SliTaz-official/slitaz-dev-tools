plugin="FullScreen"
description="Full screen support"
 
FULLSCREEN="Fullscreen"

case "$1" in
showjs) cat <<EOT
<script type="text/javascript">
<!--
function isInFullScreen() {
	return (document.fullScreenElement &&
	        document.fullScreenElement !== null) ||
	       (document.mozFullScreen || document.webkitIsFullScreen);
}

var changeHandler = function() {
	var t = document.getElementById("mainTable");
	t.rows[0].style.display = t.rows[1].style.display = 
	t.rows[3].style.display = (isInFullScreen()) ? "none" : "";
t.rows[2].style.transform = (isInFullScreen()) ? "scale(2)" : "";
t.style.height = (isInFullScreen()) ? "100%" : "";
t.style.width = (isInFullScreen()) ? "85%" : "";
t.style.padding = (isInFullScreen()) ? "0 0 0 30%": "";
//t.style.height = t.style.width = (isInFullScreen()) ? "50%" : "100%";
//t.rows[2].style.transform = "matrix(2,0,0,2,'50%',0)";
}

function doFullScreen() {
	var e = document.body;
	var r = e.requestFullScreen || e.webkitRequestFullScreen ||
		  e.mozRequestFullScreen || e.msRequestFullScreen;
	if (r) r.call(e);
	document.addEventListener("fullscreenchange", changeHandler, false);
	document.addEventListener("webkitfullscreenchange", changeHandler, false);
	document.addEventListener("mozfullscreenchange", changeHandler, false);
}
//-->
</script>
EOT
esac

template()
{
	[ -n "$(GET page)" -a -z "$(GET action)" ] || return 1
	FULLSCREEN="<a href='#' onClick='doFullScreen()'>$FULLSCREEN</a>"
	html="$(sed "s|EDIT|& / $FULLSCREEN|" <<EOT | \
		awk -v prg=$plugins_dir/wkp_$plugin.sh '
{
	if (/<\/head>/) {
		system("/bin/sh " prg " showjs")
	}
	print
}'
$html
EOT
)"
	return 0
}
