PROG =	updatecerts.sh

DESTDIR?=	/usr/local
BINDIR?=	/bin

INSTALL =	install

install:
	${INSTALL} -C ${PROG} ${DESTDIR}${BINDIR}/${PROG}
.PHONY: install
