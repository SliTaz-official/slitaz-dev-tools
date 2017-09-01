function updateHtmlCode() {
if (location.hash != "#test") return false;
	var f = document.forms["io"]
	document.getElementById("note1").innerHTML = 
		"Note 1: client side tool. No size limits."
	f.elements["build"].onclick = buildFloppies
	f.enctype = "application/x-www-form-urlencoded"
	f.action = ""
}

function buildFloppies() {
	var f = document.forms["io"]
	if (f.elements["kernel"].value == "") {
		alert("The kernel file is required.")
		return false
	}
alert("buildFloppies() ")
	var total = f.elements["kernel"].file.size
alert("buildFloppies() total="+total)
	var i
	for (i = 0; i < elements["initrd"].files.length; i++)
		total += elements["initrd"].files[i].size
	for (i = 0; i < elements["initrd2"].files.length; i++)
		total += elements["initrd2"].files[i].size
alert("buildFloppies() total="+total)
var s = ""
for (i = 0; i < f.elements.length; i++) {
	s += i+ ": " + f.elements[i].name+"="+f.elements[i].value+", "
}
alert(s);
	f.style.visibility = "hidden";
	dlfiles = document.createElement("div")
	f.appendChild = dlfiles
alert("end buildFloppies()")
	return false
}

// document.getElementById(id)
// document.getElementsByTagName(name)   "p"
// document.getElementsByClassName(name)
// element.innerHTML =  new html 
// element.setAttribute(attribute, value)
// document.createElement(element)
// document.removeChild(element)
// document.appendChild(element)
// document.replaceChild(element)
// parentNode
// childNodes[nodenumber]
// firstChild
// lastChild
// nextSibling
// previousSibling

