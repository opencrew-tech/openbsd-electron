COMMENT =	all your web-services in one place

DIST_TUPLE =	github ferdium ferdium-app v7.1.1 .

CATEGORIES =	net

HOMEPAGE =	https://ferdium.org/

MAINTAINER=	Fabien Romano <fabien@openbsd.org>

# Apache-2.0
PERMIT_PACKAGE =Yes

WANTLIB += ${COMPILER_LIBCXX} m

# bundle node_sqlite3.node
# XXX base-gcc ? (to check)
COMPILER =		base-clang ports-gcc base-gcc

RECIPES_ID =	3379a5b911789b02a0267902762356c8995a0c3c
DIST_TUPLE+=	github ferdium ferdium-recipes ${RECIPES_ID} recipes

BUILD_TIMESTAMP =	$(now)
BUILD_SHORTHASH =	c503018

MODULES =		devel/pnpm \
			www/electron

MODELECTRON_TARGET =	ferdium
MODELECTRON_BUILDER =	Yes
MODELECTRON_BUILDER_DIR=${MODELECTRON_SRC}/out/linux-unpacked/resources
MODELECTRON_WRAPPER =	Yes

MODPNPM_TARGETS =	${WRKSRC} ${WRKSRC}/recipes
MODPNPM_BUILD =		No
MODPNPM_INSTALL =	No

MODPNPM_MODS+=		esbuild
MODPNPM_GEN_UPDATE+=	electron-builder@26.0.12

RUN_DEPENDS+=		devel/desktop-file-utils \
			x11/gtk+4,-guic

SUBST_VARS+=		BUILD_TIMESTAMP BUILD_SHORTHASH

ICONS_TARGET=		${PREFIX}/share/icons/hicolor

post-patch:
	${SUBST_CMD} ${WRKSRC}/esbuild.mjs

pre-build:
	# Building recipes
	cd ${WRKSRC}/recipes && \
		${MODPNPM_CMD} rebuild && \
		${MODPNPM_CMD} package
	# Building apps
	cd ${WRKSRC} && \
		${MODPNPM_CMD} rebuild && \
		${MODPNPM_CMD} build
	ln -fs ${WRKSRC}/node_modules ${WRKSRC}/build/
	ln -fs ${WRKSRC}/pnpm-lock.yaml ${WRKSRC}/build/

post-install:
	# remove build detritus
	cd ${PREFIX}/${MODELECTRON_DIST_T}.asar.unpacked/node_modules && \
		rm -rf sqlite3/build-tmp-napi-v6 sqlite3/deps sqlite3/src
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
