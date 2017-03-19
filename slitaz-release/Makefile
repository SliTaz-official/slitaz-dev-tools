# Makefile for Tazcraft
#

PACKAGE=slitaz-release
PREFIX?=/usr
DESTDIR?=

all:

install:
	install -m 0755 -d $(DESTDIR)$(PREFIX)/sbin
	install -m 0755 $(PACKAGE) $(DESTDIR)$(PREFIX)/sbin

uninstall:
	rm -f $(DESTDIR)$(PREFIX)/sbin/$(PACKAGE)

