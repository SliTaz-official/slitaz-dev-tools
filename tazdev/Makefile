# Makefile for Tazdev.
#

PREFIX?=/usr
DESTDIR?=

all:

install:
	install -m 0777 tazdev $(DESTDIR)$(PREFIX)/bin
	install -m 0644 tazdev.conf $(DESTDIR)/etc/slitaz

uninstall:
	rm -rf \
		$(DESTDIR)$(PREFIX)/bin/tazdev \
		$(DESTDIR)/etc/slitaz/tazdev.conf
