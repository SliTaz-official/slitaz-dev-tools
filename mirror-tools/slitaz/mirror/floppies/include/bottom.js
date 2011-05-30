document.write("<!-- End of content with round corner -->\n")
document.write("</div>\n")
document.write("<div id=\"content_bottom\">\n")
document.write("<div class=\"bottom_left\"></div>\n")
document.write("<div class=\"bottom_right\"></div>\n")
document.write("</div>\n")
document.write("\n")
document.write("<!-- Start of footer and copy notice -->\n")
document.write("<div id=\"copy\">\n")
document.write("<p>\n")
document.write("Copyright &copy; ");
var time=new Date();
var year=time.getYear();
if (year < 2000) year += 1900;
document.write(year);
document.write(" <a href=\"http://www.slitaz.org/\">SliTaz</a> -\n")
document.write("<a href=\"http://www.gnu.org/licenses/gpl.html\">GNU General Public License</a>\n")
document.write("</p>\n")
document.write("<!-- End of copy -->\n")
document.write("</div>\n")
document.write("\n")
document.write("<!-- Bottom and logo's -->\n")
document.write("<div id=\"bottom\">\n")
document.write("<p>\n")
document.write("<a href=\"http://validator.w3.org/check?uri=referer\"><img src=\"../css/pics/website/xhtml10.png\" alt=\"Valid XHTML 1.0\" title=\"Code validé XHTML 1.0\" style=\"width: 80px; height: 15px;\" /></a>\n")
document.write("</p>\n")
document.write("</div>\n")
