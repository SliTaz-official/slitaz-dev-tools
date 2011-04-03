plugin="<a href=\"?action=admin\">Administration</a>"
description_fr="Administration du Wiki"
description="Wiki administration"
      
admin_enable()
{
	[ -n "$(POST $1)" ] || return
	chmod 0 $3$2*
	for i in $(POST); do
		case "$i" in $2*) chmod 755 $3$i;; esac
	done
}

action()
{
	[ "$1" == "admin" ] || return 1
	curpassword="$(POST curpassword)"
	secret="admin.secret"
	if [ -n "$(POST setpassword)" ]; then
		if [ -z "$curpassword" ]; then	# unauthorized
			if [ ! -s $secret -o "$(cat $secret)" == \
				  "$(echo $(POST password) | md5sum)" ]; then
				curpassword="$(POST password)"
			fi
		fi
		[ -n "$curpassword" ] && echo $curpassword | md5sum > $secret
	fi
	if [ -n "$(POST save)" ]; then
		cat <<EOT
Content-Type: application/octet-stream
Content-Length: $(stat -c %s $(POST file))
Content-Disposition: attachment; filename=$(POST file)

EOT
		cat $(POST file)
		exit 0
	fi
	[ -n "$(POST restore)" ] && mv -f $(FILE file tmpname) $(POST file)
	admin_enable locales config- ./
	admin_enable plugins wkp_ plugins/
	CONTENT="
<table width=\"100%\">
<form method=\"post\" action=\"?action=admin\">
<tr><td><h2>$MDP</h2></td>
<td><input type=\"text\" name=\"password\" />
<input type=\"hidden\" name=\"curpassword\" value=\"$curpassword\" />
<input type=\"submit\" value=\"$DONE_BUTTON\" name=\"setpassword\" /></td></tr>
</form>"
	[ -z "$curpassword" ] && return 0
	CONTENT="$CONTENT
<form method=\"post\" enctype=\"multipart/form-data\" action=\"?action=admin\">
<input type=\"hidden\" name=\"curpassword\" value=\"$curpassword\" />
<tr><td><h2>Plugins</h2></td>
<td><input type=\"submit\" value=\"$DONE_BUTTON\" name=\"plugins\" /></td></tr>
"
	PAGE_TITLE_link=false
	editable=false
	lang="${HTTP_ACCEPT_LANGUAGE%%,*}"
	PAGE_TITLE="Administration"
	for i in $plugins_dir/*.sh ; do
		plugin=
		eval $(grep ^plugin= $i)
		[ -n "$plugin" ] || continue
		eval $(grep ^description= $i)
		alt="$(grep ^description_$lang= $i)"
		[ -n "$alt" ] && eval $(echo "$alt" | sed 's/_..=/=/')
		CONTENT="$CONTENT
<tr><td><b>
<input type=checkbox $([ -x $i ] && echo 'checked=checked ') name=\"$(basename $i)\" />
$plugin</b></td><td><i>$description</i></td></tr>"
	done
	CONTENT="$CONTENT
</form>
<form method=\"post\" enctype=\"multipart/form-data\" action=\"?action=admin\">
<input type=\"hidden\" name=\"curpassword\" value=\"$curpassword\" />
<tr><td><h2>Locales</h2></td>
<td><input type=\"submit\" value=\"$DONE_BUTTON\" name=\"locales\" /></td></tr>
"
	for i in config-*.sh ; do
		j=${i#config-}
		j=${j%.sh}
		[ -n "$j" ] || continue
	CONTENT="$CONTENT
<tr><td><b>
<input type=checkbox $([ -x $i ] && echo 'checked=checked ') name=\"$i\" />
$j</b></td><td><i>$(. ./$i ; echo $WIKI_TITLE)</i></td></tr>
"
	done
	CONTENT="$CONTENT
</form>
<form method=\"post\" action=\"?action=admin\">
<input type=\"hidden\" name=\"curpassword\" value=\"$curpassword\" />
<tr><td><h2>Configuration</h2></td><td>
<select name="file">
$(for i in template.html style.css config*.sh; do
  [ -x $i ] && echo "<option>$i</option>"; done)
</select>
<input type=\"submit\" value=\"$DONE_BUTTON\" name=\"save\" />
<input type=\"submit\" value=\"$RESTORE\" name=\"restore\" /></td></tr>
</form>
</table>
"
}
