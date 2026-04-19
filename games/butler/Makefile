COMMENT =	command-line itch.io helper

MODGO_MODNAME =	github.com/itchio/butler
# go mod init tmp && go get github.com/itchio/butler@${H}
MODGO_VERSION =	v1.9.1-0.20260226193558-8557c8e5baf2
V =		15.26.1
# DISTNAME should not include suffix (like .tar.gz .tgz .tar.bz2 etc.)
#DISTNAME =	butler-${V}
# PKGNAME defaults to DISTNAME unless changed
PKGNAME =	butler-${V}

CATEGORIES =	games

HOMEPAGE =	https://github.com/itchio/butler

MAINTAINER=	Fabien Romano <fabien@openbsd.org>

# MIT
PERMIT_PACKAGE =Yes

WANTLIB += c m pthread

MODULES =		lang/go

# keep buildinfo in sync with upstream release/build.js
MODGO_BUILDINFO =	${MODGO_MODNAME}/buildinfo
MODGO_VERSION_TS =	${MODGO_VERSION:C/^.*\.//:C/-.*$//}
MODGO_VERSION_COMMIT =	${MODGO_VERSION:C/^.*-//}
MODGO_BUILT_AT !=	date -ju -f '%Y%m%d%H%M%S' ${MODGO_VERSION_TS} +%s
MODGO_LDFLAGS +=	-X ${MODGO_BUILDINFO}.Version=${V}
MODGO_LDFLAGS +=	-X ${MODGO_BUILDINFO}.BuiltAt=${MODGO_BUILT_AT}
MODGO_LDFLAGS +=	-X ${MODGO_BUILDINFO}.Commit=${MODGO_VERSION_COMMIT}

# Dependencies
#BUILD_DEPENDS =	???
#RUN_DEPENDS =		???
#LIB_DEPENDS =		???
#TEST_DEPENDS =		???

#MAKE_FLAGS =		???
#MAKE_ENV =		???
#FAKE_FLAGS =		???
#TEST_FLAGS =		???

# Is the build automagic or is it interactive
#
#IS_INTERACTIVE =		Yes
#TEST_IS_INTERACTIVE =		Yes

# Things that we don't want to do for this port/package
# Generally, DON'T set anything to No if it's not needed.
# The time gained is not worth it.
#
#NO_BUILD =		Yes
#NO_TEST =		Yes

# Overrides for default values
#
#CFLAGS =		???
#LDFLAGS =		???
#MAKE_FILE =		???
#PKG_ARCH =		??? (* for arch-independent packages)
#WRKDIST =		??? if other than ${WRKDIR}/${DISTNAME}
#WRKSRC =		??? if other than ${WRKDIST}
#WRKBUILD =		??? if other than ${WRKSRC}
#WRKCONF =		??? if other than ${WRKBUILD}

#ALL_TARGET =		???
#INSTALL_TARGET =	???
#TEST_TARGET =		???

post-configure:
	# hotfix github.com/itchio/screw (reuse linux implementation)
	@SCREW_DIR=$$( cd ${WRKSRC} && ${MODGO_LIST_CMD} -f '{{.Dir}}' \
		github.com/itchio/screw ); \
	cp -f $$SCREW_DIR/screw_{linux,unix}.go ; \
	sed -i 's#^//go:build linux$$#//go:build linux || openbsd#' \
		$$SCREW_DIR/screw_unix.go
	# hotfix github.com/itchio/ox (switch default to linux runtime)
	@OX_DIR=$$( cd ${WRKSRC} && ${MODGO_LIST_CMD} -f '{{.Dir}}' \
		github.com/itchio/ox ); \
	sed -i 's/platform = PlatformUnknown/platform = PlatformLinux/g' \
		$$OX_DIR/runtime.go
	# hotfix github.com/itchio/smaug (select runner from host runtime)
	@SMAUG_DIR=$$( cd ${WRKSRC} && ${MODGO_LIST_CMD} -f '{{.Dir}}' \
		github.com/itchio/smaug/runner ); \
	sed -i 's/switch runtime.GOOS {/switch params.Runtime.OS() {/' \
		$$SMAUG_DIR/runner.go
	# hotfix github.com/itchio/sevenzip-go (no libdl, no -ldl)
	@SEVENZIP_DIR=$$( cd ${WRKSRC} && ${MODGO_LIST_CMD} -f '{{.Dir}}' \
		github.com/itchio/sevenzip-go/sz ); \
	sed -i 's#cgo !windows LDFLAGS#cgo linux LDFLAGS#' \
		$$SEVENZIP_DIR/glue.go
	# clean cache
	@rm -rf ${MODGO_GOCACHE}

.include "modules.inc"

.include <bsd.port.mk>
