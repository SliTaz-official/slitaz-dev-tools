plugin="<a href=\"?action=list\">ListPlugins</a>"
description_fr="Affiche la liste des plugins chargés"
description="List plugins"
      
action()
{
	case "$1" in
	list|config);;
	backup)	if [ -n "$(POST save)" ]; then
			file=$(mktemp -p /tmp)
			find */ | cpio -o -H newc | gzip -9 > $file
			cat <<EOT
Content-Type: application/octet-stream
Content-Length: $(stat -c %s $file)
Content-Disposition: attachment; filename=wiki-$(date '+%Y%m%d%H%M').cpio.gz

EOT
			cat $file
		else
			file=$(FILE file tmpname)
			zcat $file | cpio -idmu $(echo */ | sed 's|/||g')
			return 1
		fi
		rm -f $file
		exit 0
		;;
	*) return 1
	esac
	CONTENT='
<table width="100%">
<tr><td span=2><h2>Plugins</h2></td></tr>
'
	PAGE_TITLE_link=false
	editable=false
	lang="${HTTP_ACCEPT_LANGUAGE%%,*}"
	PAGE_TITLE="Configuration"
	for i in $plugins_dir/*.sh ; do
		plugin=
		eval $(grep ^plugin= $i)
		[ -n "$plugin" ] || continue
		eval $(grep ^description= $i)
		alt="$(grep ^description_$lang= $i)"
		[ -n "$alt" ] && eval $(echo "$alt" | sed 's/_..=/=/')
		CONTENT="$CONTENT
<tr><td><b>
<input type=checkbox disabled=disabled $([ -x $i ] && echo 'checked=checked ')/>
$plugin</b></td><td><i>$description</i></td></tr>"
	done
	CONTENT="$CONTENT
<tr><td span=2><br /><h2>Locales</h2></td></tr>
"
	for i in config-*.sh ; do
		i=${i#config-}
		i=${i%.sh}
		[ -n "$i" ] || continue
	CONTENT="$CONTENT
<tr><td><b>
<input type=checkbox disabled=disabled $([ "$i" == "$lang" ] && echo 'checked=checked ')/>
$i</b></td></tr>
"
	done
	CONTENT="$CONTENT
<tr><td><br /><h2>Data</h2></td>
<td><form method=\"post\" enctype=\"multipart/form-data\" action=\"?action=backup\">
<input type=\"submit\" name=\"save\" value=\"$DONE_BUTTON\" />"
	[ "$ALLOW_UPLOAD" == "yes" ] && CONTENT="$CONTENT
<input type=\"file\" name=\"file\" value=\"file\" />
<input type=\"submit\" name=\"restore\" value=\"$RESTORE\" />"
	CONTENT="$CONTENT
</form></td></tr>
$(du -hs */ | awk '{ printf "<tr><td><b>%s</b></td><td><i>%s</i></td></tr>\n",$1,$2 }')
</table>
"
}
