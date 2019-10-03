PROG =	updatecerts.sh

DESTDIR?=	/usr/local
BINDIR?=	/bin
ETCDIR?=	/etc

INSTALL =	install

install:
	${INSTALL} -C ${PROG} ${DESTDIR}${BINDIR}/${PROG}
	${INSTALL} -C certmgr.sudoers ${DESTDIR}${ETCDIR}/sudoers.d/certmgr
.PHONY: install
