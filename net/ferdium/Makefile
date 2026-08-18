COMMENT =	all your web-services in one place

DIST_TUPLE =	github ferdium ferdium-app v7.1.2 .
REVIVION =	0

CATEGORIES =	net

HOMEPAGE =	https://ferdium.org/

MAINTAINER=	Fabien Romano <fabien@openbsd.org>

# Apache-2.0
PERMIT_PACKAGE =Yes

WANTLIB += ${COMPILER_LIBCXX} m

# bundle node_sqlite3.node
COMPILER =		base-clang ports-gcc

RECIPES_ID =	785591facd25563dc2354e6f97088511e9cdfac8
DIST_TUPLE+=	github ferdium ferdium-recipes ${RECIPES_ID} recipes

BUILD_TIMESTAMP =	$$(date +%s)
BUILD_SHORTHASH =	c503018

MODULES =		devel/pnpm \
			www/electron

MODELECTRON_TARGET =	ferdium
MODELECTRON_BUILDER =	Yes
MODELECTRON_BUILDER_DIR=${MODELECTRON_SRC}/out/linux-unpacked/resources
MODELECTRON_WRAPPER =	Yes
MODELECTRON_APP_NAME =	Ferdium

MODPNPM_TARGETS =	${WRKSRC} ${WRKSRC}/recipes
MODPNPM_BUILD =		No
MODPNPM_INSTALL =	No

MODPNPM_MODS+=7zip-bin
MODPNPM_MODS+=app-builder-bin
MODPNPM_MODS+=electron-builder
MODPNPM_MODS+=esbuild
MODPNPM_MODS+=graceful-fs

# fix build, to revisit on next update
MODPNPM_GEN_UPDATE=sqlite3@5.1.7

RUN_DEPENDS+=		devel/desktop-file-utils \
			x11/gtk+4,-guic

SUBST_VARS+=		BUILD_TIMESTAMP BUILD_SHORTHASH

ICONS_TARGET=		${PREFIX}/share/icons/hicolor

post-patch:
	${SUBST_CMD} ${WRKSRC}/esbuild.mjs

pre-build:
	${MODPNPM_PREBUILD_TARGET}
	# Cleaning sqlite3 build
	cd ${WRKSRC}/node_modules/sqlite3 && \
		mkdir -p Release && \
		cp -p build/Release/node_sqlite3.node Release/ && \
		rm -rf build
	# Building recipes
	cd ${WRKSRC}/recipes && \
		${MODPNPM_CMD_BUILD} package
	# Building apps
	cd ${WRKSRC} && \
		${MODPNPM_CMD_BUILD} build

post-install:
	# remove build detritus
	cd ${PREFIX}/${MODELECTRON_DIST_T}.asar.unpacked/node_modules && \
		rm -rf sqlite3/deps sqlite3/src
	# menu
	${INSTALL_DATA_DIR} ${PREFIX}/share/applications
	${INSTALL_DATA} ${FILESDIR}/${MODELECTRON_TARGET}.desktop \
		${PREFIX}/share/applications/${MODELECTRON_TARGET}.desktop
.for size in 16 24 32 48 64 96 128 256 512 1024
	${INSTALL_DATA_DIR} ${ICONS_TARGET}/${size}x${size}/apps
	${INSTALL_DATA} \
		${WRKSRC}/build-helpers/images/icons/${size}x${size}.png \
		${ICONS_TARGET}/${size}x${size}/apps/${MODELECTRON_TARGET}.png
.endfor

.include "modules.pnpm.inc"

.include <bsd.port.mk>
