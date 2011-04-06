#!/bin/sh
#
# CGI/Shell script example for TazTPD Web Server
#
echo "Content-Type: text/html"
echo ""

var=${QUERY_STRING#var=}

# xHTML 5 output
cat << EOT
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
	<title>TazTPD CGI</title>
	<style type="text/css">
		body { padding: 40px 16%; }
		h1 { color: #4d4d4d; border-bottom: 1px dotted #ddd; }
	</style>
<head>
<body>
<h1>TazTPD and CGI</h1>
<p>
	Entered form value: $var
</p>
<form method="get" action="taztpd.cgi">
	<input type="text" name="var" size="32">
</form>
<p>
	`date '+%Y-%m-%d %H:%M'`
</p>
</body>
</html>
EOT
