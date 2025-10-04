COMMENT=		break time reminder app

DIST_TUPLE=		github hovancik stretchly v1.18.0 .

CATEGORIES=		productivity

HOMEPAGE=		https://hovancik.net/stretchly/

MAINTAINER=		Fabien Romano <fabien@openbsd.org>

# BSD 2-Clause
PERMIT_PACKAGE=		Yes

MODULES=		devel/npm \
			www/electron

MODELECTRON_TARGET=	stretchly
MODELECTRON_APP_NAME=	Stretchly
MODELECTRON_BUILDER=	Yes
MODELECTRON_WRAPPER=	Yes

MODNPM_BUILD=		No
MODNPM_INSTALL=		No
MODNPM_OMITOPTIONAL=	Yes

BUILD_DEPENDS+=		devel/app-builder

RUN_DEPENDS+=		devel/desktop-file-utils \
			x11/gtk+4,-guic

ICONS_TARGET=		${PREFIX}/share/icons/hicolor

pre-build:
	# generate icon files
	cd ${WRKSRC} && ${SETENV} ${MAKE_ENV} app-builder icon \
		--input=icon.icns --out=icons --format=set --root=build
.for size in 16 48
	mv ${WRKSRC}/icons/icon_${size}x${size}.png \
		${WRKSRC}/icons/icon_${size}.png
.endfor

post-install:
	# menu
	${INSTALL_DATA_DIR} ${PREFIX}/share/applications
	${INSTALL_DATA} ${WRKSRC}/net.hovancik.Stretchly.desktop \
		${PREFIX}/share/applications/${MODELECTRON_TARGET}.desktop
	${INSTALL_DATA_DIR} ${PREFIX}/share/metainfo/
	${INSTALL_DATA} ${WRKSRC}/net.hovancik.Stretchly.metainfo.xml \
		${PREFIX}/share/metainfo/${MODELECTRON_TARGET}.metainfo.xml
.for size in 16 32 48 64 128 256 512 1024
	${INSTALL_DATA_DIR} ${ICONS_TARGET}/${size}x${size}/apps
	${INSTALL_DATA} ${WRKSRC}/icons/icon_${size}.png \
		${ICONS_TARGET}/${size}x${size}/apps/${MODELECTRON_TARGET}.png
.endfor

.include "modules.inc"

.include <bsd.port.mk>
