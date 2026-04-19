COMMENT =	fast, reliable, and secure dependency management for node.js

V =		4.12.0
DISTNAME =	berry--yarnpkg-cli-${V}
PKGNAME =	berry-${V}
DIST_TUPLE =	github yarnpkg berry @yarnpkg/cli/${V} .

CATEGORIES =	devel

HOMEPAGE =	https://yarnpkg.com/

MAINTAINER =	Fabien Romano <fabien@openbsd.org>

# BSD-2-Clause
PERMIT_PACKAGE =	Yes

RUN_DEPENDS =		lang/node

do-build:
	cd ${WRKSRC} && node ./scripts/run-yarn.js build:cli

do-install:
	${INSTALL_DATA_DIR} ${PREFIX}/lib/node/berry
	cd ${WRKSRC} && cp -r * ${PREFIX}/lib/node/berry/
	chmod +x ${PREFIX}/lib/node/berry/packages/yarnpkg-cli/bundles/yarn.js
	chown -R ${SHAREOWN}:${SHAREGRP} ${PREFIX}/lib/node
	ln -s ../lib/node/berry/packages/yarnpkg-cli/bundles/yarn.js \
		${PREFIX}/bin/berry

.include <bsd.port.mk>
