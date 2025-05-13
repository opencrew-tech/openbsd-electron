COMMENT=		mock D-Bus objects

MODPY_DISTV=		0.34.3
DISTNAME=		python_dbusmock-${MODPY_DISTV}
PKGNAME=		py-dbusmock-${MODPY_DISTV}

CATEGORIES=		devel

HOMEPAGE=		https://martinpitt.github.io/python-dbusmock/index.html

MAINTAINER=		Fabien Romano <fabien@openbsd.org>

# LGPLv3+
PERMIT_PACKAGE=		Yes

MODULES=		lang/python

MODPY_PI=		Yes
MODPY_PYBUILD=		setuptools

BUILD_DEPENDS=		devel/py-setuptools_scm${MODPY_FLAVOR}

RUN_DEPENDS=		x11/dbus-python${MODPY_FLAVOR}

FLAVORS=		python3
FLAVOR=			python3

.include <bsd.port.mk>
