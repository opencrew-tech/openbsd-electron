COMMENT =		fancy self-hosted monitoring tool

VERSION =		2.1.1

DIST_TUPLE =		github louislam uptime-kuma ${VERSION} .

CATEGORIES =		www

HOMEPAGE =		https://uptime.kuma.pet/

MAINTAINER =		Aisha Tammy <aisha@openbsd.org>

# MIT
PERMIT_PACKAGE =	Yes

WANTLIB += ${COMPILER_LIBCXX} m sqlite3

COMPILER =		base-clang ports-gcc

SITES.dist=https://github.com/louislam/uptime-kuma/releases/download/${VERSION}/
DISTFILES.dist =	uptime-kuma-${VERSION}-{}dist.tar.gz

MODULES =		devel/npm

MODNPM_MODS+=esbuild
MODNPM_MODS+=graceful-fs
MODNPM_MODS+=rollup

MODNPM_NO_DEV =		Yes
MODNPM_NO_OPTIONAL =	Yes
MODNPM_INSTALL =	uptime-kuma
MODNPM_INSTALL_DIR =	libexec

LIB_DEPENDS =		databases/sqlite3

NO_TEST =		Yes

# build @louislam/sqlite3 with system lib
MAKE_FLAGS+=		--sqlite=${LOCALBASE}

post-install:
	cp -a ${WRKDIR}/dist \
		${PREFIX}/${MODNPM_INSTALL_DIR}/uptime-kuma/dist

.include "modules.npm.inc"

.include <bsd.port.mk>
