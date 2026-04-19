COMMENT=	generic helper tool to build app in a distributable format

H=		7004925f95d8f034fc88d7e782c9aa7583debb8e
# make commit-date
D=		20250424014413

MODGO_MODNAME=	github.com/develar/app-builder
MODGO_VERSION=	v0.0.0-${D}-${H:C/(.{12}).*/\1/}

DISTNAME=	app-builder-v5.0.0pl${D}
REVISION=	1
PORTROACH=	limit:^5\.

CATEGORIES=	devel

HOMEPAGE=	https://github.com/develar/app-builder

MAINTAINER=	Fabien Romano <fabien@openbsd.org>

# MIT
PERMIT_PACKAGE=	Yes

WANTLIB += c pthread

MODULES=	devel/pnpm \
		lang/go

MODPNPM_MODS+=graceful-fs

MODPNPM_INSTALL=app-builder-bin
MODPNPM_BUILD=	No # let modgo do-build (more complex) then pnpm as post-build

# test need internet access and isn't that useful
# best test is to build electron's ports which depend on electron-builder
# btw, it needs custom do-test, check ${WRKSRC}/Makefile test target
# note also app-builder-bin is now deprecated and use only on legacy build
MODPNPM_ENV_TEST+=CUSTOM_APP_BUILDER_PATH=${WRKDIR}/go/bin/app-builder
NO_TEST = Yes

WRKDIST=	${WRKSRC}

post-build:
	${MODPNPM_BUILD_TARGET}

do-install:
	${MODGO_INSTALL_TARGET}
	${MODPNPM_INSTALL_TARGET}

post-install:
	# cleanup
	rm -rf ${PREFIX}/${MODPNPM_INSTALL_DIR}/app-builder-bin/node_modules
	rm -f ${PREFIX}/${MODPNPM_INSTALL_DIR}/app-builder-bin/${MODPNPM_LOCK}

### targets for port maintainer(s)

_TMP=	/tmp/app-builder
_GIT=	https://github.com/develar/app-builder.git

commit-date:
	# check ${_TMP}/log if needed
	# make commit-date
	@set +e ; rm -rf ${_TMP} ; mkdir -p ${_TMP} ;			\
	cd ${_TMP} &&							\
	git init > log 2>&1 &&						\
	git remote add origin ${_GIT} >> log 2>&1 && 			\
	git fetch --depth 1 origin ${H} >> log 2>&1 &&			\
	git checkout FETCH_HEAD >> log 2>&1 &&				\
	printf "D=\t\t%s\n" $$(TZ=UTC0 git log -n 1 --format=%cd	\
	    --date=format-local:"%Y%m%d%H%M%S" ) &&			\
	rm -rf ${_TMP}

.include "modules.inc"

.include "modules.pnpm.inc"

.include <bsd.port.mk>
