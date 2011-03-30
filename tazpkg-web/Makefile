# Makefile for Tazpkg.
#
PREFIX?=/usr
LIBDIR?=/var/lib/tazpkg-web
SYSCONFDIR?=/etc/slitaz
DESTDIR?=

all:

# Installation.

install:
	mkdir -p $(DESTDIR)$(PREFIX)/bin \
		$(DESTDIR)$(SYSCONFDIR) \
		$(LIBDIR)
	cp -a tazpkg-web $(DESTDIR)$(PREFIX)/bin
	cp -a tazpkg-web.conf $(DESTDIR)$(SYSCONFDIR)
	cp -a html style xml search.cgi $(LIBDIR)
	
	
# Uninstallation and clean-up commands.

uninstall:
	rm -f $(DESTDIR)$(PREFIX)/bin/tazpkg-web
	rm -f $(DESTDIR)$(SYSCONFDIR)/tazpkg-web.conf
	rm -rf $(LIBDIR)
