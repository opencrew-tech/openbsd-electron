COMMENT=	generic helper tool to build app in a distributable format

MODGO_MODNAME=	github.com/develar/app-builder
MODGO_VERSION=	v0.0.0-20241212193511-580c34f2e193

DISTNAME=	app-builder-v5.0.0pl20241212193511
REVISION=	1
PORTROACH=	limit:^5\.

CATEGORIES=	devel

HOMEPAGE=	https://github.com/develar/app-builder

MAINTAINER=	Fabien Romano <fabien@openbsd.org>

# MIT
PERMIT_PACKAGE=	Yes

WANTLIB += c pthread

MODULES=	lang/go

# test need internet access and isn't that useful
# best test is to build electron's ports which depend on electron-builder
NO_TEST = Yes

WRKDIST=	${WRKSRC}

.include "modules.inc"

.include <bsd.port.mk>
