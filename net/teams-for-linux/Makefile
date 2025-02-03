COMMENT=		unofficial Microsoft Teams client

DIST_TUPLE=		github IsmaelMartinez teams-for-linux v1.12.7 .

CATEGORIES=		net

MAINTAINER=		Fabien Romano <fabien@openbsd.org>

# GPLv3
PERMIT_PACKAGE=		Yes

# Any modules we may be using
MODULES=		devel/npm \
			www/electron

MODELECTRON_TARGET=	teams-for-linux
MODELECTRON_BUILDER=	Yes
MODELECTRON_WRAPPER=	Yes

MODNPM_BUILD=		No
MODNPM_INSTALL=		No

RUN_DEPENDS+=		devel/desktop-file-utils

post-install:
	# menu
	${INSTALL_DATA_DIR} ${PREFIX}/share/applications
	${INSTALL_DATA} ${FILESDIR}/${MODELECTRON_TARGET}.desktop \
		${PREFIX}/share/applications/${MODELECTRON_TARGET}.desktop
	${INSTALL_DATA_DIR} ${PREFIX}/share/pixmaps
	${INSTALL_DATA} ${WRKSRC}/build/icons/1024x1024.png \
		${PREFIX}/share/pixmaps/${MODELECTRON_TARGET}.png

.include "modules.inc"

.include <bsd.port.mk>
