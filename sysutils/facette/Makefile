COMMENT =	time series data visualization and graphing software

V=0.5.1
MODGO_MODNAME =	facette.io/facette
MODGO_VERSION = v0.0.0-20190810091543-9b280bed86bf
REVISION =	5

DISTNAME =	facette-${V}

CATEGORIES =	sysutils

HOMEPAGE =	https://facette.io

MAINTAINER =	Fabien Romano <fabien@openbsd.org>

# BSD
PERMIT_PACKAGE =	Yes

WANTLIB +=	c pthread rrd

MODULES +=	devel/yarn \
		lang/go

MODYARN_TARGETS=${WRKSRC}/ui
MODYARN_BUILD=	No
MODYARN_INSTALL=No

MODYARN_MODS+=graceful-fs

BUILD_DEPENDS =	devel/go-bindata \
		textproc/pandoc

LIB_DEPENDS =	net/rrdtool

USE_GMAKE =	Yes

WRKDIST =	${WRKSRC}

post-install:
	${INSTALL_DATA_DIR} ${PREFIX}/share/examples/facette/
	${SUBST_CMD} -c ${WRKSRC}/docs/examples/facette.yaml \
		${PREFIX}/share/examples/facette/facette.yaml

.include "modules.go.inc"
.include "modules.yarn.inc"

.include <bsd.port.mk>
