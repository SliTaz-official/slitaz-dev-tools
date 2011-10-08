#!/bin/sh
# Tiny CGI search engine for SliTaz packages on http://pkgs.slitaz.org/
# Christophe Lincoln <pankso@slitaz.org>
#

[ -f "/etc/slitaz/tazpkg-web.conf" ] && . /etc/slitaz/tazpkg-web.conf
[ -f "tazpkg-web.conf" ] && . ./tazpkg-web.conf

read QUERY_STRING
for i in $(echo $QUERY_STRING | sed 's/&/ /g'); do
	eval $i
done
LANG=$lang
SEARCH=$query
SLITAZ_VERSION=$version
OBJECT=$object
DATE=`date +%Y-%m-%d\ \%H:%M:%S`
VERSION=cooking
if [ "$REQUEST_METHOD" = "GET" ]; then
	SEARCH=""
	VERBOSE=0
	for i in $(echo $REQUEST_URI | sed 's/[?&]/ /g'); do
		SLITAZ_VERSION=cooking
		case "$(echo $i | tr [A-Z] [a-z])" in
		search=*)
			SEARCH=${i#*=};;
		object=*)
			OBJECT=${i#*=};;
		verbose=*)
			VERBOSE=${i#*=};;
		lang=*)
			LANG=${i#*=};;
		file=*)
			SEARCH=${i#*=}
			OBJECT=File;;
		desc=*)
			SEARCH=${i#*=}
			OBJECT=Desc;;
		tags=*)
			SEARCH=${i#*=}
			OBJECT=Tags;;
		receipt=*)
			SEARCH=${i#*=}
			OBJECT=Receipt;;
		filelist=*)
			SEARCH=${i#*=}
			OBJECT=File_list;;
		package=*)
			SEARCH=${i#*=}
			OBJECT=Package;;
		depends=*)
			SEARCH=${i#*=}
			OBJECT=Depends;;
		builddepends=*)
			SEARCH=${i#*=}
			OBJECT=BuildDepends;;
		fileoverlap=*)
			SEARCH=${i#*=}
			OBJECT=FileOverlap;;
		version=s*|version=3*)
			SLITAZ_VERSION=stable;;
		version=[1-9]*)
			i=${version%%.*}
			SLITAZ_VERSION=${i#*=}.0;;
		esac
	done
	[ -n "$SEARCH" ] && REQUEST_METHOD="POST"
fi

case "$OBJECT" in
File)	 	selected_file="selected";;
Desc)	 	selected_desc="selected";;
Tags)	 	selected_tags="selected";;
Receipt) 	selected_receipt="selected";;
File_list) 	selected_file_list="selected";;
Depends)	selected_depends="selected";;
BuildDepends)	selected_build_depends="selected";;
FileOverlap)	selected_overlap="selected";;
esac

case "$SLITAZ_VERSION" in
1.0)	 	selected_1="selected";;
2.0)	 	selected_2="selected";;
stable)		selected_stable="selected";;
esac

# unescape query
SEARCH="$(echo $SEARCH | sed 's/%2B/+/g' | sed 's/%3A/:/g' | sed 's|%2F|/|g')"

if [ -z "$LANG" ]; then
	for i in $(echo $HTTP_ACCEPT_LANGUAGE | sed 's/[,;]/ /g'); do
		case "$i" in
		fr|de|pt|cn)
			LANG=$i
			break;;
		esac
	done
fi

package="Package"
file="File"
desc="Description"
tags="Tags"
receipt="Receipt"
file_list="File list"
depends="Depends"
bdepends="Build depends"
search="Search"
cooking="cooking"
stable="stable"
result="Result for : $SEARCH"
noresult="No package $SEARCH"
deptree="Dependency tree for : $SEARCH"
rdeptree="Reverse dependency tree for : $SEARCH"
bdeplist="$SEARCH needs these packages to be built"
rbdeplist="Packages who need $SEARCH to be built"
overloading="Theses packages may overload files of "
overlap="common files"
charset="ISO-8859-1"

case "$LANG" in

fr)	package="Paquet"
	receipt="Recette"
	depends="D�pendances"
	bdepends="Fabrication"
	search="Recherche"
	result="Recherche de : $SEARCH"
	noresult="Paquet $SEARCH introuvable"
	deptree="Arbre des d�pendances de $SEARCH"
	rdeptree="Arbre invers� des d�pendances de $SEARCH"
	bdeplist="$SEARCH a besion de ces paquets pour �tre fabriqu�"
	rbdeplist="Paquets ayant besion de $SEARCH pour �tre fabriqu�s"
	overloading="Paquets pouvant �craser des fichiers de "
	overlap="Fichiers communs"
	file_list="Liste des fichiers"
	file="Fichier";;

de)	package="Paket"
	depends="Abh�ngigkeiten"
	desc="Beschreibung"
	search="Suche"
	cooking="Cooking"
	stable="Stable"
	result="Resultate f�r : $SEARCH"
	noresult="Kein Paket f�r $SEARCH"
	deptree="Abh�ngigkeiten von: $SEARCH"
	rdeptree="Abh�ngigkeit f�r: $SEARCH"
	file_list="Datei liste"
	file="Datei";;

pt)	package="Pacote"
	search="Buscar"
	cooking="cooking"
	stable="stable"
	result="Resultado para : $SEARCH"
	noresult="Sem resultado: $SEARCH"
	deptree="�rvore de depend�ncias para: $SEARCH"
	rdeptree="�rvore de depend�ncias reversa para: $SEARCH"
	depends="Depend�ncias"
	desc="Descri��o"
	file_list="Arquivo lista"
	file="Arquivo";;

cn)	package="软件包："
	cooking="开发版"
	stable="稳定版"
	desc="描述"
	tags="标签"
	depends="依赖"
	file="文件"
	file_list="文件列表"
	search="Search"
	result="Result for : $SEARCH"
	noresult="No package $SEARCH"
	deptree="Dependency tree for : $SEARCH"
	rdeptree="Reverse dependency tree for : $SEARCH"
	charset="UTF-8";;

*)	LANG="en";;

esac

WOK=$SLITAZ/$SLITAZ_VERSION/wok-hg
PACKAGES_REPOSITORY=$SLITAZ/$SLITAZ_VERSION/packages

echo Content-type: text/html
echo

# Search form
search_form()
{
	cat << _EOT_

<div style="text-align: center; margin-bottom: 30px;">
	<form method="post" action="search.cgi">
		<div class="searchbox">
			<p>
				<input type="hidden" name="lang" value="$LANG" />
				<input type="text" name="query" 
					size="20" value="$SEARCH" style="width: 80%;" />
				<input type="submit" name="search" value="$search" />
			</p>
		</div>
		Search for:
		<select name="object">
			<option value="Package">$package</option>
			<option $selected_desc value="Desc">$desc</option>
			<option $selected_tags value="Tags">$tags</option>
			<option $selected_receipt value="Receipt">$receipt</option>
			<option $selected_depends value="Depends">$depends</option>
			<option $selected_build_depends value="BuildDepends">$bdepends</option>
			<option $selected_file value="File">$file</option>
			<option $selected_file_list value="File_list">$file_list</option>
			<option $selected_overlap value="FileOverlap">$overlap</option>
		</select>
		in
		<select name="version">
			<option value="cooking">$cooking</option>
			<option $selected_stable value="stable">$stable</option>
			<option $selected_1 value="1.0">1.0</option>
			<option $selected_2 value="2.0">2.0</option>
		</select>
	</form>
</div>
_EOT_
}

# xHTML Header.
xhtml_header()
{
	cat << _EOF_
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
	"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="$LANG" lang="$LANG">
<head>
	<title>SliTaz Packages - Search $SEARCH</title>
	<meta http-equiv="content-type" content="text/html; charset=$charset" />
	<meta name="description" content="SliTaz packages" />
	<meta name="keywords" lang="en" content="tazpkg" />
	<meta name="robots" content="index, follow, all" />
	<meta name="modified" content="$DATE" />
	<link rel="shortcut icon" href="favicon.ico" />
	<link rel="stylesheet"  type="text/css" href="slitaz.css" />
</head>
<body>

<!-- Header -->
<div id="header">
	<div id="logo"></div>
	<div id="network">
		<a href="http://www.slitaz.org/">
			<img src="images/network.png" alt="network.png" /></a>
		<a href="http://scn.slitaz.org/">Community</a>
		<a href="http://doc.slitaz.org/">Doc</a>
		<a href="http://forum.slitaz.org/">Forum</a>
		<a href="http://bugs.slitaz.org/">Bugs</a>
		<a href="http://hg.slitaz.org/">Hg</a>
	</div>
	<h1><a href="http://pkgs.slitaz.org/">SliTaz Packages</a></h1>
</div>

<!-- Block -->
<div id="block">
	<!-- Navigation -->
	<div id="block_nav" style="padding: 10px;">
		<h4><img src="images/tazpkg.png" alt="tazpkg.png" />Tools &amp; Doc</h4>
		<div class="right_box">
			<ul>
				<li><a href="http://doc.slitaz.org/en:cookbook:wok">Wok &amp; Tools</a></li>
				<li><a href="http://doc.slitaz.org/en:cookbook:receipt">Receipts</a></li>
			</ul>
		</div>
		<ul>
			<li><a href="http://hg.slitaz.org/wok">Hg Repos</a></li>
			<li><a href="http://cook.slitaz.org/">Build Bot</a></li>
			<li><a href="http://bugs.slitaz.org/">Bug Tracker</a></li>
			<li><a href="http://forum.slitaz.org/">Get Support</a></li>
		</ul>
	</div>
	<!-- Information/image -->
	<div id="block_info">
		<h4>$package</h4>
		<p>
			Search for SliTaz packages! 
		</p>
		<p>
			Any results ? Make a package request on the official
			<a href="http://forum.slitaz.org/">forum</a>
		</p>
	</div>
</div>

_EOF_
}

# xHTML Footer.
xhtml_footer()
{
	cat << _EOT_
<center>
<i>$(ls $WOK/ | wc -l) packages and $(unlzma -c $PACKAGES_REPOSITORY/files.list.lzma | wc -l) files in $SLITAZ_VERSION database</i>
</center>

<!-- End of content -->
</div>

<!-- Footer -->
<div id="footer">
	Copyright &copy; <span class="year"></span>
	<a href="http://www.slitaz.org/">SliTaz</a> - Network:
	<a href="http://scn.slitaz.org/">Community</a>
	<a href="http://doc.slitaz.org/">Doc</a>
	<a href="http://forum.slitaz.org/">Forum</a>
	<a href="http://pkgs.slitaz.org/">Packages</a>
	<a href="http://bugs.slitaz.org/">Bugs</a>
	<a href="http://hg.slitaz.org/">Hg</a>
	<p>
		SliTaz @
		<a href="http://twitter.com/slitaz">Twitter</a>
		<a href="http://www.facebook.com/slitaz">Facebook</a>
		<a href="http://distrowatch.com/slitaz">Distrowatch</a>
		<a href="http://en.wikipedia.org/wiki/SliTaz">Wikipedia</a>
		<a href="http://flattr.com/profile/slitaz">Flattr</a>
	</p>
</div>

</body>
</html>
_EOT_
}

installed_size()
{
[ $VERBOSE -gt 0 ] &&
grep -A 3 "^$1\$" $SLITAZ/$SLITAZ_VERSION/packages/packages.txt | \
       grep installed | sed 's/.*(\(.*\) installed.*/(\1) /'
}

package_entry()
{
if [ -s "$(dirname $0)/$SLITAZ_VERSION/$CATEGORY.html" ]; then
	cat << _EOT_
<a href="$SLITAZ_VERSION/$CATEGORY.html#$PACKAGE">$PACKAGE</a> $(installed_size $PACKAGE): $SHORT_DESC
_EOT_
else
	cat << _EOT_
<a href="http://mirror.slitaz.org/packages/$SLITAZ_VERSION/$PACKAGE-$VERSION$EXTRA_VERSION.tazpkg">$PACKAGE</a> $(installed_size $PACKAGE): $SHORT_DESC
_EOT_
fi
}

# recursive dependencies scan
dep_scan()
{
for i in $1; do
	case " $ALL_DEPS " in
	*\ $i\ *) continue;;
	esac
	ALL_DEPS="$ALL_DEPS $i"
	if [ -n "$2" ]; then
		echo -n "$2"
		(
		. $WOK/$i/receipt
		package_entry
		)
	fi
	[ -f $WOK/$i/receipt ] || continue
	DEPENDS=""
	. $WOK/$i/receipt
	[ -n "$DEPENDS" ] && dep_scan "$DEPENDS" "$2    "
done
}

# recursive reverse dependencies scan
rdep_scan()
{
SEARCH=$1
case "$SEARCH" in
glibc-base|gcc-lib-base) cat <<EOT
	glibc-base and gcc-lib-base are implicit dependencies,
	<b>every</b> package is supposed to depend on them.
EOT
	return;;
esac
for i in $WOK/* ; do
	DEPENDS=""
	. $i/receipt
	echo "$(basename $i) $(echo $DEPENDS)"
done | awk -v search=$SEARCH '
function show_deps(deps, all_deps, pkg, space)
{
	if (all_deps[pkg] == 1) return
	all_deps[pkg] = 1
	if (space != "") printf "%s%s\n",space,pkg
	for (i = 1; i <= split(deps[pkg], mydeps, " "); i++) {
		show_deps(deps, all_deps, mydeps[i],"////" space)
	}
}

{
	all_deps[$1] = 0
	for (i = 2; i <= NF; i++)
		deps[$i] = deps[$i] " " $1
}

END {
	show_deps(deps, all_deps, search, "")
}
' | while read pkg; do
		. $WOK/${pkg##*/}/receipt
		cat << _EOT_
$(echo ${pkg%/*} | sed 's|/| |g') $(package_entry) 
_EOT_
done
}

# Check package exists
package_exist()
{
	[ -f $WOK/$1/receipt ] && return 0
	cat << _EOT_

<h3>$noresult</h3>
<pre>
_EOT_
	return 1
}

# Display < > &
htmlize()
{
	sed -e 's/&/\&amp;/g' -e 's/</\&lt;/g' -e 's/>/\&gt;/g'
}

display_packages_and_files()
{
last=""
while read pkg file; do
	pkg=${pkg%:}
	if [ "$pkg" != "$last" ]; then
		. $WOK/$pkg/receipt
		
		package_entry
		last=$pkg
	fi
	echo "    $file"
done
}

# Display search form and result if requested.
if [ "$REQUEST_METHOD" != "POST" ]; then
	xhtml_header
	cat << _EOT_

<!-- Content -->
<div id="content">

_EOT_
	search_form
	xhtml_footer
else
	xhtml_header
	cat << _EOT_

<!-- Content -->
<div id="content">

_EOT_
	search_form
	if [ "$OBJECT" = "Depends" ]; then
		if package_exist $SEARCH ; then
			cat << _EOT_

<h3>$deptree</h3>
<pre>
_EOT_
			ALL_DEPS=""
			dep_scan $SEARCH ""
			SUGGESTED=""
			. $WOK/$SEARCH/receipt
			if [ -n "$SUGGESTED" ]; then
				cat << _EOT_
</pre>

<h3>$deptree (SUGGESTED)</h3>
<pre>
_EOT_
				ALL_DEPS=""
				dep_scan "$SUGGESTED" "    "
			fi
			cat << _EOT_
</pre>

<h3>$rdeptree</h3>
<pre>
_EOT_
			ALL_DEPS=""
			rdep_scan $SEARCH
			cat << _EOT_
</pre>
_EOT_
		fi
	elif [ "$OBJECT" = "BuildDepends" ]; then
		if package_exist $SEARCH ; then
			cat << _EOT_

<h3>$bdeplist</h3>
<pre>
_EOT_
			BUILD_DEPENDS=""
			. $WOK/$SEARCH/receipt
			[ -n "$BUILD_DEPENDS" ] && for dep in $BUILD_DEPENDS ; do
				if [ ! -s $WOK/$dep/receipt ]; then
					cat << _EOT_
$dep: not found !
_EOT_
					continue
				fi
				. $WOK/$dep/receipt
				package_entry
			done
			cat << _EOT_
</pre>

<h3>$rbdeplist</h3>
<pre>
_EOT_
			for dep in $(grep -l $SEARCH $WOK/*/receipt); do
				BUILD_DEPENDS=""
				. $dep
				echo " $BUILD_DEPENDS " | grep -q " $SEARCH " &&
				package_entry
			done
			cat << _EOT_
</pre>
_EOT_
		fi
	elif [ "$OBJECT" = "FileOverlap" ]; then
		if package_exist $SEARCH ; then
			cat << _EOT_

<h3>$overloading $SEARCH</h3>
<pre>
_EOT_
			( unlzma -c $PACKAGES_REPOSITORY/files.list.lzma | grep ^$SEARCH: ;
			  unlzma -c $PACKAGES_REPOSITORY/files.list.lzma | grep -v ^$SEARCH: ) | awk '
BEGIN { pkg=""; last="x" }
{
	if ($2 == "") next
	if (index($2,last) == 1 && substr($2,1+length(last),1) == "/")
		delete file[last]
	last=$2
	if (pkg == "") pkg=$1
	if ($1 == pkg) file[$2]=$1
	else if (file[$2] == pkg) print
}
' | display_packages_and_files
			cat << _EOT_
</pre>
_EOT_
		fi
	elif [ "$OBJECT" = "File" ]; then
		cat << _EOT_

<h3>$result</h3>
<pre>
_EOT_
		last=""
		unlzma -c $PACKAGES_REPOSITORY/files.list.lzma \
		| grep $SEARCH | while read pkg file; do
			echo "$file" | grep -q $SEARCH || continue
			if [ "$last" != "${pkg%:}" ]; then
				last=${pkg%:}
				(
				. $WOK/$last/receipt
				cat << _EOT_

<i>$(package_entry)</i>
_EOT_
				)
			fi
			echo "    $file"
		done
	elif [ "$OBJECT" = "File_list" ]; then
		package_exist $SEARCH && cat << _EOT_

<h3>$result</h3>
<pre>
_EOT_
		last=""
		unlzma -c $PACKAGES_REPOSITORY/files.list.lzma \
		| grep ^$SEARCH: |  sed 's/.*: /    /' | sort
	elif [ "$OBJECT" = "Desc" ]; then
		if [ -f $WOK/$SEARCH/description.txt ]; then
			cat << _EOT_

<h3>$result</h3>
<pre>
<pre>
$(htmlize < $WOK/$SEARCH/description.txt)
</pre>
_EOT_
		else
			cat << _EOT_

<h3>$result</h3>
<pre>
_EOT_
			last=""
			grep -i $SEARCH $PACKAGES_REPOSITORY/packages.desc | \
			sort | while read pkg extras ; do
				. $WOK/$pkg/receipt
				package_entry
			done
		fi
	elif [ "$OBJECT" = "Tags" ]; then
		cat << _EOT_

<h3>$result</h3>
<pre>
_EOT_
		last=""
		grep ^TAGS= $WOK/*/receipt |  grep -i $SEARCH | \
		sed "s|$WOK/\(.*\)/receipt:.*|\1|" | sort | while read pkg ; do
				. $WOK/$pkg/receipt
				package_entry
			done
	elif [ "$OBJECT" = "Receipt" ]; then
		package_exist $SEARCH && cat << _EOT_

<h3>$result</h3>
<pre>
<pre>
$(if [ -f  $WOK/$SEARCH/taz/*/receipt ]; then
	cat $WOK/$SEARCH/taz/*/receipt
  else
    cat $WOK/$SEARCH/receipt
  fi | htmlize)
</pre>
_EOT_
	else
		cat << _EOT_

<h3>$result</h3>
<pre>
_EOT_
		for pkg in `ls $WOK/ | grep $SEARCH`
		do
			. $WOK/$pkg/receipt
			DESC=" <a href=\"?desc=$pkg\">description</a>"
			[ -f $WOK/$pkg/description.txt ] || DESC=""
			cat << _EOT_
$(package_entry)$DESC
_EOT_
		done
		equiv=$PACKAGES_REPOSITORY/packages.equiv
		vpkgs="$(cat $equiv | cut -d= -f1 | grep $SEARCH)"
		for vpkg in $vpkgs ; do
	cat << _EOT_
</pre>

<h3>$result (package providing $vpkg)</h3>
<pre>
_EOT_
			for pkg in $(grep $vpkg= $equiv | sed "s/$vpkg=//"); do
				. $WOK/${pkg#*:}/receipt
				package_entry
			done
		done
	fi
	cat << _EOT_
</pre>
_EOT_
	xhtml_footer
fi

exit 0
