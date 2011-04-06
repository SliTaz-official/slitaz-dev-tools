# Makefile for Tank tools.
# Check the README for more information.
#
PREFIX?=/usr
SYSCONFDIR?=/etc
LOCALSTATDIR?=/usr/share
DOCDIR?=$(LOCALSTATDIR)/doc
DESTDIR?=
	
all:

install:
	mkdir -p $(DESTDIR)$(PREFIX)/bin \
		$(DESTDIR)$(SYSCONFDIR)/slitaz \
		$(DESTDIR)$(LOCALSTATDIR)/taztpd \
		$(DESTDIR)$(DOCDIR)/taztpd
	cp -f taztpd $(DESTDIR)$(PREFIX)/bin
	cp -f taztpd.conf $(DESTDIR)$(SYSCONFDIR)/slitaz
	cp -f *.css *.html *.cgi $(DESTDIR)$(LOCALSTATDIR)/taztpd
	cp -f README $(DESTDIR)$(DOCDIR)/taztpd

uninstall:
	rm -rf $(DESTDIR)$(PREFIX)/bin/taztpd \
		$(DESTDIR)$(SYSCONFDIR)/slitaz/taztpd.conf \
		$(DESTDIR)$(LOCALSTATDIR)/taztpd \
		$(DESTDIR)$(DOCDIR)/taztpd

clean:
	rm -rf $(DESTDIR) _pkg install
