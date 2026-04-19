COMMENT =		production process manager with a built-in load balancer

GH_ACCOUNT =		Unitech
GH_PROJECT =		pm2
GH_TAGNAME =		v6.0.14

CATEGORIES =		www

HOMEPAGE =		https://pm2.keymetrics.io/

MAINTAINER =		Aisha Tammy <aisha@openbsd.org>

# AGPL-3.0
PERMIT_PACKAGE =	Yes

MODULES =		devel/npm

MODNPM_OMITDEV =	Yes

NO_BUILD =		Yes
NO_TEST =		Yes

do-install:
	cp -a ${WRKSRC} ${PREFIX}/libexec/pm2
	rm -r ${PREFIX}/libexec/pm2/test
	ln -sf ${TRUEPREFIX}/libexec/pm2/bin/pm2 ${PREFIX}/bin/pm2
	${INSTALL_DATA_DIR} ${PREFIX}/share/doc/pm2
	${INSTALL_DATA} ${FILESDIR}/ecosystem.config.js ${PREFIX}/share/doc/pm2/

.include "modules.npm.inc"

.include <bsd.port.mk>
