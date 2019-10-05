PROG =	updatecerts.sh

DESTDIR?=	/usr/local
BINDIR?=	/bin
ETCDIR?=	/etc

INSTALL =	install

install:
	${INSTALL} -C ${PROG} ${DESTDIR}${BINDIR}/${PROG}
	${INSTALL} -C -m 0440 certmgr.sudoers ${DESTDIR}${ETCDIR}/sudoers.d/certmgr
.PHONY: install

install.acme:
	${INSTALL} -C distributecerts.sh ${DESTDIR}${BINDIR}/distributecerts.sh
	${INSTALL} -C acmecron.sh ${DESTDIR}${BINDIR}/acmecron.sh
	${INSTALL} -C -m 0440 acme.sudoers ${DESTDIR}${ETCDIR}/sudoers.d/acme
.PHONY: install.acme
