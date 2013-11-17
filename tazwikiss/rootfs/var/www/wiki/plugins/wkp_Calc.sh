plugin="Calc"
description_fr="Tableur format CSV"
description="CSV format spreadsheet"
help_fr="AideCalc"
help="HelpCalc"

case "$1" in
showhead) cat <<EOT
<!-- Based on http://jsfiddle.net/ondras/hYfN3/ by Ondřej Žára -->
<script type="text/javascript">
<!--
function csv(id,rows,cols) {
    var data = "";
    for (var i=1; i<=rows; i++) {
	for (var j=1; j<=cols; j++) {
            var letter = String.fromCharCode("A".charCodeAt(0)+j-1);
	    data += document.getElementById(id+letter+i).title+';';
	}
	data += "\\\\n";
    }
    alert(data);
}

var DATA={};
function buildCalc(id, rows, cols) {
    DATA[id] = {};
    for (var i=0; i<=rows; i++) {
        var row = document.getElementById(id).insertRow(-1);
        for (var j=0; j<=cols && j<=26; j++) {
            var letter = String.fromCharCode("A".charCodeAt(0)+j-1);
	    var cell = row.insertCell(-1);
	    if (i&&j) {
		cell.className = "cellcalc";
		cell.innerHTML = "<input id='"+ id+letter+i +"' class='inputcalc'/>";
	    }
	    else {
		cell.className = "bordercalc";
		cell.title = "Show CSV";
		cell.onclick = function(){csv(id,rows,cols);};
		cell.innerHTML = (i||j) ? i||letter : "&radic;";
	    }
        }
    }
}

function getWidth(s)
{
	var e = document.getElementById("widthcalc");
	e.innerHTML = s+" :";
	return (e.offsetWidth < 80 || s.charAt(0) == "=") ? 80 : e.offsetWidth;
}

function setCell(e, v)
{
    e.style.width = getWidth(v)+"px";
    e.style.textAlign = 
	(isNaN(parseFloat(v)) && v.charAt(0) != "=") ? "left" : "right";
    e.title = v;
}
//-->
</script>
<span id="widthcalc" class="cellcalc" style="visibility:hidden;"></span>
EOT
	exit 0 ;;
showtail) cat <<EOT
<script type="text/javascript">
<!--
var INPUTS=[].slice.call(document.getElementsByClassName("inputcalc"));
INPUTS.forEach(function(elm) {
    elm.onfocus = function(e) {
        e.target.value = e.target.title || "";
    };
    elm.onblur = function(e) {
	setCell(e.target, e.target.value);
        computeAll();
    };
    var calcid = elm.id.substring(0,4), cellid = elm.id.substring(4);
    var getter = function() {
        var value = elm.title || "";
        if (value.charAt(0) == "=")
		with (DATA[calcid]) return eval(value.substring(1));
        else return isNaN(parseFloat(value)) ? value : parseFloat(value);
    };
    Object.defineProperty(DATA[calcid], cellid, {get:getter});
    Object.defineProperty(DATA[calcid], cellid.toLowerCase(), {get:getter});
});
(window.computeAll = function() {
    INPUTS.forEach(function(elm) {
	var calcid = elm.id.substring(0,4), cellid = elm.id.substring(4);
	try { elm.value = DATA[calcid][cellid]; } catch(e) {} });
})();
//-->
</script>
EOT
	exit 0 ;;
esac

formatEnd()
{
CONTENT=$(awk -v prg=$plugins_dir/wkp_$plugin.sh '
function showcalc()
{
	if (lines > 1 && rows > 1) {
		id="C" (100+cnt++)
		print "<noscript><u>Enable javascript to see the spreadsheet " id "</u></noscript>"
		print "<table id=\"" id "\" class=\"tablecalc\"></table>"
		print "<script type=\"text/javascript\">"
		print "<!--"
		print "buildCalc(\"" id "\"," lines "," rows ");"
		for (i = 1; i <= lines; i++) {
			gsub("&lt;","<",line[i])
			for (j = 1; j < split(line[i],tmp,";"); j++) {
				if (tmp[j] == "") continue
				gsub("\"","\\\\\"",tmp[j])
				s = "setCell(document.getElementById(\"" id
				c = substr("ABCDEFGHIJKLMNOPQRSTUVWXYZ",j,1)
				print s c i "\"), \"" tmp[j] "\")";
			}
		}
		print "//-->"
		print "</script>"
	}
	else for (i = 1; i <= lines; i++) print line[i]
	rows = lines = gotcalc = 0
}
{
	if (/;<br \/>$/) {
		gotcalc = 1
		if (!headdone) {
			headdone = 1
			showtail = 1
			system("/bin/sh " prg " showhead")
			#print "system(" prg " showhead)"
		}
		line[++lines] = $0
		gsub("&lt;","<",$0)
		i = split($0,tmp,";")-1
		if (lines == 1) rows = i
		if (i != rows) rows = -1
	}
	else {
		if (gotcalc) showcalc()
		print
	}
}
END {
	if (gotcalc) showcalc()
	if (showtail) system("/bin/sh " prg " showtail")
}
' <<EOT
$CONTENT
EOT
)
}

template()
{
	html=$(sed 's|</head>|\t<style type="text/css"> @import "plugins/wkp_Calc.css"; </style>\n&|' <<EOT
$html
EOT
)
}
