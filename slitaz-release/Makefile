# Makefile for slitaz-release
#

PACKAGE=slitaz-release
PREFIX?=/usr
DESTDIR?=

all:

install:
	install -m 0755 $(PACKAGE) $(DESTDIR)$(PREFIX)/sbin

uninstall:
	rm -f $(DESTDIR)$(PREFIX)/sbin/$(PACKAGE)

