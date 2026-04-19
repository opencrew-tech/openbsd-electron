COMMENT =	best way to play your itch.io games

DIST_TUPLE =	github itchio itch v26.9.0 .

# toggle if tag doesn't match pkg spec (kitch is -canary)
#V =		26.9.0
#PKGNAME =	itch-${V}

CATEGORIES =	games

HOMEPAGE =	https://itch.io/app

MAINTAINER=	Fabien Romano <fabien@openbsd.org>

# MIT
PERMIT_PACKAGE =Yes

MODULES =		devel/npm \
			www/electron

# XXX app detec itself as kitch (-canary), missing version maybe
# build as kitch or fix version then force to (k)itch (patch)
MODELECTRON_TARGET=	kitch
MODELECTRON_UNVEIL=	Yes

MODNPM_BUILD=		No
MODNPM_INSTALL=		No

MODNPM_MODS+=esbuild
MODNPM_MODS+=graceful-fs

RUN_DEPENDS+=		x11/gtk+4,-guic \
			devel/desktop-file-utils

ICONS_TARGET=		${PREFIX}/share/icons/hicolor

do-build:
# release/package-all.js > packaging/build.js
#https://github.com/itchio/itch/blob/master/release/packaging/build.js
	mkdir -p ${WRKSRC}/prefix/src
	cd ${WRKSRC} && ${MODNPM_CMD} run compile
	cp -rf ${WRKSRC}/dist ${WRKSRC}/prefix/
	cp -rf ${WRKSRC}/src/static ${WRKSRC}/prefix/src
# XXX custom package.json ?
	cp ${WRKSRC}/package.json ${WRKSRC}/prefix/

do-install:
	# resources
	${INSTALL_DATA_DIR} ${PREFIX}/${MODELECTRON_DIST_T}
	cp -Rp ${WRKSRC}/prefix/* ${PREFIX}/${MODELECTRON_DIST_T}/
	chown -R ${SHAREOWN}:${SHAREGRP} ${PREFIX}/${MODELECTRON_DIST_T}
	# unveil
	${MODELECTRON_UNVEIL_INSTALL}
	# wraper
	${SUBST_PROGRAM} ${FILESDIR}/${MODELECTRON_TARGET} \
		${PREFIX}/bin/${MODELECTRON_TARGET}
	# menu
	${INSTALL_DATA_DIR} ${PREFIX}/share/applications
	${INSTALL_DATA} ${FILESDIR}/${MODELECTRON_TARGET}.desktop \
		${PREFIX}/share/applications/${MODELECTRON_TARGET}.desktop
	# icon
.for size in 16 32 36 48 64 72 114 128 144 150 256 512 1024
	${INSTALL_DATA_DIR} ${ICONS_TARGET}/${size}x${size}/apps
	${INSTALL_DATA} \
		${WRKSRC}/release/images/itch-icons/icon${size}.png \
		${ICONS_TARGET}/${size}x${size}/apps/${MODELECTRON_TARGET}.png
.endfor

.include "modules.npm.inc"

.include <bsd.port.mk>
