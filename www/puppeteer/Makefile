# XXX many tests failure
# chome works in most of the tests, but still lot of faillure with BiDi-only
# firefox just fails, looks related to BiDi (missing from firefox ?)

COMMENT =	JavaScript API for Chrome and Firefox

V =		24.39.0
PKGNAME =	puppeteer-${V}

DIST_TUPLE =	github puppeteer puppeteer puppeteer-v${V} .

CATEGORIES =	www

HOMEPAGE =	https://pptr.dev/

MAINTAINER=	Fabien Romano <fabien@openbsd.org>

# Apache 2.0
PERMIT_PACKAGE =	Yes

MODULES =		devel/npm

# skip initial download during pre-build, openbsd fix did not rebuild yet (.ts)
MODNPM_ENV+=		PUPPETEER_SKIP_DOWNLOAD=1

# some tests need a display, 'Xvfb :1 &'
MODNPM_ENV_TEST+=	DISPLAY=:1

# system browsers runs with unveil, use /tmp (which is unveiled)
MODNPM_ENV_TEST+=	TMP=/tmp

# using modnpm workspace install, do not bundle
MODNPM_GEN_BUNDLE=	No

MODNPM_INSTALL =	puppeteer
MODNPM_MODS_SKIP+=	puppeteer

# puppeteer is a rollup test depends but pkg managers only handle dev depends.
# upstream @rollup/rollup-openbsd-x64 may work but looks fragile
MODNPM_MODS_SKIP+=	rollup
MODNPM_GEN_OVERRIDES=	rollup "npm:@rollup/wasm-node"

MODNPM_MODS+=esbuild
MODNPM_MODS+=graceful-fs
MODNPM_MODS+=@swc/core
MODNPM_MODS+=unrs-resolver

do-build:
	cd ${WRKSRC} && ${MODNPM_CMD_BUILD} run build
	${MODNPM_BUILD_TARGET}

.include "modules.npm.inc"

.include <bsd.port.mk>
