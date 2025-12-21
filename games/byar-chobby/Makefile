COMMENT=	launcher for Beyond All Reason

V=		1.2988.0
DISTNAME=	BYAR-Chobby-${V}
PKGNAME=	${DISTNAME:L}
REVISION=	2

# EACCES: '/launcher/node_modules/pngjs/lib/*'
FIX_EXTRACT_PERMISSIONS=Yes

DIST_TUPLE=	github beyond-all-reason BYAR-Chobby v${V} .

COMMIT=		2c0a6e17b50ab04ea592c53963c571e5ccb071ba
DIST_TUPLE+=	github beyond-all-reason spring-launcher ${COMMIT} .

CATEGORIES=	games

HOMEPAGE=	https://www.beyondallreason.info/
MAINTAINER=	Fabien Romano <fabien@openbsd.org>

# XXX licence ??? (spring-launcher = MIT)
PERMIT_PACKAGE=	Yes

BUILD_DEPENDS+=	devel/app-builder

RUN_DEPENDS+=	archivers/p7zip \
		devel/desktop-file-utils \
		www/electron

MODULES=	devel/npm \
		www/electron

MODNPM_TARGETS=		${WRKSRC}/launcher
MODNPM_OMITOPTIONAL=	Yes
MODNPM_BUILD=		No
MODNPM_INSTALL=		No

MODELECTRON_TARGET=	byar_chobby_launcher
MODELECTRON_APP_NAME=	Beyond-All-Reason
MODELECTRON_UNVEIL=	Yes
MODELECTRON_BUILDER=	Yes
MODELECTRON_SRC=	${WRKSRC}/launcher

# DIST_TUPLE run after MODNPM_post-extract
post-extract:
	mv ${WRKDIR}/spring-launcher-${COMMIT} ${WRKSRC}/launcher

pre-build:
	# subst engine_launcher.js TRUEPREFIX for --isolation-dir
	${SUBST_CMD} ${WRKSRC}/launcher/src/engine_launcher.js
	# dist_cfg->launcher/ : build, src/config.json, src/renderer
# XXX from github workflow, cook something less smart ?
	cp -r ${WRKSRC}/dist_cfg/* ${WRKSRC}/launcher/src/
	for dir in bin files build; do \
		mkdir -p ${WRKSRC}/launcher/$$dir ; \
		if [ -d ${WRKSRC}/launcher/src/$$dir/ ]; then \
			mv ${WRKSRC}/launcher/src/$$dir/* \
				${WRKSRC}/launcher/$$dir/ ; \
			rm -rf ${WRKSRC}/launcher/src/$$dir ; \
		fi ; \
	done
	# package.json
# XXX replace with a patch ?
	cd ${WRKSRC} && ${SETENV} ${MAKE_ENV} \
		node build/make_package_json.js \
			launcher/package.json \
			dist_cfg/config.json \
			beyond-all-reason/BYAR-Chobby ${V}

post-install:
	# wraper
	${SUBST_PROGRAM} ${FILESDIR}/${MODELECTRON_TARGET} \
		${PREFIX}/bin/${MODELECTRON_TARGET}
	# menu
	${INSTALL_DATA_DIR} ${PREFIX}/share/applications
	${INSTALL_DATA} ${FILESDIR}/${MODELECTRON_TARGET}.desktop \
		${PREFIX}/share/applications/${MODELECTRON_TARGET}.desktop
	${INSTALL_DATA_DIR} ${PREFIX}/share/pixmaps
	${INSTALL_DATA} ${WRKSRC}/dist_cfg/build/icon.png \
		${PREFIX}/share/pixmaps/${MODELECTRON_TARGET}.png
	# remove uneded files
	cd ${PREFIX}/${MODELECTRON_DIST_T}.asar.unpacked/ && \
		rm -rf node_modules/7zip-bin/linux && \
		rm -rf node_modules/7zip-bin/mac

.include "modules.inc"

.include <bsd.port.mk>