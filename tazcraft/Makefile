# Makefile for Tazcraft
#

PACKAGE=tazcraft
PREFIX?=/usr
DESTDIR?=

all:

# Installation

install:
	install -m 0755 -d $(DESTDIR)$(PREFIX)/bin
	install -m 0755 -d $(DESTDIR)$(PREFIX)/share/applications
	install -m 0755 -d $(DESTDIR)$(PREFIX)/share/pixmaps
	install -m 0755 $(PACKAGE) $(DESTDIR)$(PREFIX)/bin
	install data/minecraft.desktop $(DESTDIR)$(PREFIX)/share/applications
	install images/minecraft.png $(DESTDIR)$(PREFIX)/share/pixmaps

# Uninstallation

uninstall:
	rm -f $(DESTDIR)$(PREFIX)/bin/$(PACKAGE)

