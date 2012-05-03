# Makefile for Qemu-box.
#

PREFIX?=/usr
DESTDIR?=

all:

install:
	mkdir -p $(DESTDIR)$(PREFIX)/bin $(DESTDIR)/usr/share/applications
	install -m 0755 qemu-box $(DESTDIR)$(PREFIX)/bin
	install -m 0644 qemu-box.desktop $(DESTDIR)/usr/share/applications

uninstall:
	rm -rf \
		$(DESTDIR)$(PREFIX)/bin/qemu-box \
		$(DESTDIR)/usr/share/applications/qemu-box.desktop
