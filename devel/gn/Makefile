BROKEN-sparc64= Doesn't support sparc64 as an architecture

COMMENT=	meta build framework for ninja
DPB_PROPERTIES=	parallel

COMMIT=		0c25d1bbde6ef17e1e6d3938011f56a00c02e457
DATE =		20250515
VERSION =	0.0.${DATE}
DISTNAME =	gn-${DATE}
PKGNAME =	gn-${VERSION}

CATEGORIES =	devel

HOMEPAGE =	https://gn.googlesource.com/gn/

# BSD 3-Clause
PERMIT_PACKAGE =	Yes

WANTLIB += ${COMPILER_LIBCXX} c m

# gn.googlesource.com does not provide stable snapshots
SITES =		http://distfiles.opencrew.tech/gn/

COMPILER =	base-clang ports-gcc

MODULES +=	lang/python

BUILD_DEPENDS =	devel/ninja
RUN_DEPENDS =	devel/ninja

CONFIGURE_STYLE =	simple
CONFIGURE_SCRIPT =	${MODPY_BIN} build/gen.py
CONFIGURE_ARGS +=	--platform openbsd
CONFIGURE_ENV +=	GN_VERSION=${DATE}

DOCDIR =	${PREFIX}/share/doc/gn
WRKDIST =	${WRKDIR}/gn

post-patch:
	${SUBST_CMD} ${WRKSRC}/src/util/exe_path.cc \
		${WRKSRC}/src/gn/command_format_unittest.cc

do-build:
	${SETENV} ${MAKE_ENV} ninja -C${WRKSRC}/out -j${MAKE_JOBS} -v

do-install:
	${INSTALL_PROGRAM} ${WRKSRC}/out/gn ${PREFIX}/bin
	${INSTALL_DATA_DIR} ${DOCDIR}
	${INSTALL_DATA} ${WRKSRC}/{LICENSE,README.md} ${DOCDIR}

do-test:
	cd ${WRKBUILD} && \
		out/gn_unittests

### targets for port maintainer(s)

_SRC?=		${WRKDIR}/gn
_FETCH?=	https://gn.googlesource.com/gn ${COMMIT}
tarball:
	mkdir -p ${_SRC}/gn
	cd ${_SRC}/gn && [ -d ".git" ] || ( \
	HOME=${_SRC} git init && \
	HOME=${_SRC} git fetch ${_FETCH} --depth 1 && \
	HOME=${_SRC} git checkout FETCH_HEAD \
	)
	cd ${_SRC} && \
	find ./gn -type f -a ! -path '*/.git/*' | sort > files && \
	tar -cRzf ${DISTNAME}${EXTRACT_SUFX} -I files && \
	sha256 -b ${DISTNAME}${EXTRACT_SUFX}

.include <bsd.port.mk>
