COMMENT =	7-Zip wrapper (precompiled binaries on other platform)

PKGNAME =	node-sevenzip-bin-0.0.20220516

DIST_TUPLE =	github develar 7zip-bin \
		234abf56ddc2935de44e07d5e3c40eecab95d5af .

CATEGORIES =	archivers

MAINTAINER =	Fabien Romano <fabien@openbsd.org>

# MIT
PERMIT_PACKAGE =	Yes

MODULES =		devel/npm

MODNPM_INSTALL =	7zip-bin

RUN_DEPENDS =		archivers/p7zip

post-extract:
	cd ${WRKSRC} && rm -rf linux mac win

.include <bsd.port.mk>
