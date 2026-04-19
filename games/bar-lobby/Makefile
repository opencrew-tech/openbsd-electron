COMMENT =	BAR Lobby Client

H =		bc1131016e4124ce4439eb4a33b5d31e9cf1dd6a
PKGNAME =	bar-lobby-0.15.2pl20260222
DIST_TUPLE =	github beyond-all-reason bar-lobby ${H} .

CATEGORIES =	games

HOMEPAGE =	https://beyond-all-reason.github.io/bar-lobby/

MAINTAINER =	Fabien Romano <fabien@openbsd.org>

# Summary of Used Licenses
# The majority of the code is licensed under the MIT License, but some files
# are licensed under other permissive licenses.
# Assets are licensed under a wide range of licenses, spanning from CC0 to the
# **not open** Creative Commons BY-NC-SA 4.0 and **full proprietary** licenses.
PERMIT_PACKAGE =	not open CC BY-NC-SA 4.0 and full proprietary licenses
PERMIT_DISTFILES =	not open CC BY-NC-SA 4.0 and full proprietary licenses

WANTLIB += ${COMPILER_LIBCXX} m

COMPILER=base-clang ports-gcc

MODULES =		devel/npm \
			www/electron

MODELECTRON_TARGET =	bar-lobby
MODELECTRON_APP_NAME=	BeyondAllReason
MODELECTRON_UNVEIL=	Yes
MODELECTRON_BUILDER =	Yes
MODELECTRON_WRAPPER =	Yes

MODNPM_MODS+=7zip-bin
MODNPM_MODS+=app-builder-bin
MODNPM_MODS+=electron-builder
MODNPM_MODS+=esbuild
MODNPM_MODS+=graceful-fs
MODNPM_MODS+=@parcel/watcher
MODNPM_MODS+=rollup

MODNPM_BUILD =		No
MODNPM_INSTALL =	No

# XXX 7za is only used for the initial pool cache
RUN_DEPENDS+=	archivers/p7zip \
		devel/desktop-file-utils

post-patch:
	${SUBST_CMD} ${WRKSRC}/src/main/game/game.ts

do-build:
# XXX @electron/packager unsupported OS, may brake tests (todo)
# XXX arch ? only for ?
	# electron-forge, ignore packaging issues
	cd ${WRKSRC} && ${MODNPM_CMD_BUILD} \
		run package -- --platform=linux --arch=x64 || true \
	# electron-builder
	${MODELECTRON_BUILDER_BUILD}

post-install:
	# wraper
	${SUBST_PROGRAM} ${FILESDIR}/${MODELECTRON_TARGET} \
		${PREFIX}/bin/${MODELECTRON_TARGET}
	# menu
	${INSTALL_DATA_DIR} ${PREFIX}/share/applications
	${INSTALL_DATA} ${FILESDIR}/${MODELECTRON_TARGET}.desktop \
		${PREFIX}/share/applications/${MODELECTRON_TARGET}.desktop
	${INSTALL_DATA_DIR} ${PREFIX}/share/pixmaps
	${INSTALL_DATA} ${WRKSRC}/buildResources/icon.png \
		${PREFIX}/share/pixmaps/${MODELECTRON_TARGET}.png
	# remove uneded files
	cd ${PREFIX}/${MODELECTRON_DIST_T}.asar.unpacked/ && \
		rm -rf node_modules/7zip-bin/linux && \
		rm -rf node_modules/7zip-bin/mac

.include "modules.npm.inc"

.include <bsd.port.mk>
