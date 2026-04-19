COMMENT =	small utility which generates Go code from any file

V=4.0.2
MODGO_MODNAME =	github.com/kevinburke/go-bindata/v4
MODGO_VERSION = v${V}

DISTNAME =	go-bindata-${V}

CATEGORIES =	devel

HOMEPAGE =	https://github.com/go-bindata/go-bindata/

MAINTAINER=	Fabien Romano <fabien@openbsd.org>

PERMIT_PACKAGE =Yes

MODULES =	lang/go

do-build:
	cd ${WRKSRC} && ${SETENV} ${MAKE_ENV} \
		go build -o ${MODGO_WORKSPACE}/bin/go-bindata ./go-bindata

.include <bsd.port.mk>
