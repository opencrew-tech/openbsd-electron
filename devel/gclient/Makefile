COMMENT =	google's tool to sync repository (DEPS)

COMMIT =	077e02a7696bccafcdd169992524830fa65b738e
V =		0.20250912
DISTNAME =	depot_tools-${COMMIT}
PKGNAME =	gclient-${V}

# see cipd_client_version
CIPD_COMMIT =	b1f414539ac10cc67a0250890a38712cc06cf102
CIPD_PLATFORM =	openbsd-${MACHINE_ARCH}

CATEGORIES =	devel

HOMEPAGE =	https://chromium.googlesource.com/chromium/tools/depot_tools.git

MAINTAINER=	Fabien Romano <fabien@openbsd.org>

# BSD-like & Apache 2.0
PERMIT_PACKAGE=	Yes

# googlesource.com does not provide stable snapshots, see make tarball
SITES =		http://distfiles.opencrew.tech/depot_tools/

# XXX devel/cipd port ?
SITES.cipd =	https://chrome-infra-packages.appspot.com/
DISTFILES.cipd=cipd-${CIPD_PLATFORM}-${CIPD_COMMIT}{client?platform=${CIPD_PLATFORM}&version=git_revision:${CIPD_COMMIT}}

EXTRACT_CASES+=cipd-*) \
	cp ${FULLDISTDIR}/$$archive ${WRKSRC}/.cipd_client && \
	chmod +x ${WRKSRC}/.cipd_client ;;

MODULES =		lang/python

# google-cloud-sdk for gsutil
RUN_DEPENDS =		shells/bash \
			sysutils/google-cloud-sdk \
			www/py-httplib2

NO_BUILD =		Yes
NO_TEST =		Yes

TARGET =		${PREFIX}/libexec/gclient

do-install:
	${INSTALL_DATA_DIR} ${TARGET}
	cp -p ${WRKSRC}/cipd ${TARGET}
	cp -p ${WRKSRC}/.cipd_client ${TARGET}
	find ${WRKSRC} -name '*.py' -maxdepth 1 \
	    -exec cp "{}" ${TARGET} \;
	${INSTALL_DATA_DIR} ${TARGET}/third_party
	cp -Rp ${WRKSRC}/third_party/* ${TARGET}/third_party
	${MODPY_COMPILEALL} ${TARGET}
	# wrapper
	${SUBST_PROGRAM} ${FILESDIR}/gclient \
		${PREFIX}/bin/gclient

### targets for port maintainer(s)

_SRC?=	${WRKDIR}/gn
_FETCH_GS?=https://chromium.googlesource.com/chromium/tools/depot_tools.git \
	${COMMIT}
tarball:
	mkdir -p ${_SRC}/${DISTNAME}
	cd ${_SRC}/${DISTNAME} && [ -d ".git" ] || ( \
	HOME=${_SRC} git init && \
	HOME=${_SRC} git fetch ${_FETCH_GS} --depth 1 && \
	HOME=${_SRC} git checkout FETCH_HEAD \
	)
	cd ${_SRC} && \
	find ./${DISTNAME} -type f -a ! -path '*/.git/*' | sort > files && \
	tar -cRzf ${DISTNAME}${EXTRACT_SUFX} -I files && \
	sha256 -b ${DISTNAME}${EXTRACT_SUFX}

.include <bsd.port.mk>
