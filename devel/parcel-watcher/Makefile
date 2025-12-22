COMMENT =	native C++ Node module for moniroting filesystem events

V=		2.5.1
PKGNAME =	parcel-watcher-${V}
DIST_TUPLE =	github parcel-bundler watcher v${V} .

CATEGORIES =	devel

MAINTAINER =	Fabien Romano <fabien@openbsd.org>

# MIT
PERMIT_PACKAGE =	Yes

WANTLIB += ${COMPILER_LIBCXX} m

# C++11 or newer
COMPILER =		base-clang ports-gcc

MODULES =		devel/yarn

MODYARN_MODS+=		esbuild

MODYARN_INSTALL =	parcel-watcher

.include "modules.yarn.inc"

.include <bsd.port.mk>
