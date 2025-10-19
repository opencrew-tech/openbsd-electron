# Chicken-and-egg, pnpm monorepo use specific pnpm features.
# https://github.com/orgs/pnpm/discussions/8602

# As pnpm (the published version) come as a standalone, pre-built package, we
# can copy it. Problem arises when we need to build from source and carry some
# patches which are designed to overcome offline build issues with pnpm.

# Using the bundle pnpm we can build pnpm but to work around offline issues we
# have to provide a pre-made store (same issue as npm, there isn't a way to
# list files and populate the cache for offline use).

# We need a pre-made cache, but this cache may depend on targeted installs.
# It looks like pnpm is not concerned when using --force.

# The list of depends must be known in advance and the only solution is to use
# a frozen lockfile. Thus, ports may have to override such locks.
# See net/signal-desktop for such example using system esbuild.

COMMENT=	fast, disk space efficient package manager

V=		10.18.3
DIST_TUPLE=	github pnpm pnpm v${V} .

CATEGORIES=	devel

HOMEPAGE=	https://pnpm.io/

MAINTAINER=	Fabien Romano <fabien@openbsd.org>

# MIT
PERMIT_PACKAGE=	Yes

SITES.published=	https://registry.npmjs.org/pnpm/-/
DISTFILES.published=	pnpm-${V}.tgz

# on upates, comments then run make makesum && make modpnpm-gen-vendor
SITES.vendor=		http://distfiles.opencrew.tech/pnpm/
DISTFILES.vendor=	${MODPNPM_VENDOR}

MODULES=	lang/python \
		devel/pnpm

MODPNPM_BIN=		${WRKDIR}/package/bin/pnpm.cjs
MODPNPM_UPDATE=		No
MODPNPM_INSTALL=	No
MODPNPM_BUILDDEP=	No
MODPNPM_RUNDEP=		No
MODPNPM_TESTDEP=	No
MODPNPM_GEN_FORCE=	Yes

NO_TEST=	Yes # need internet access

BUILD_DEPENDS+=	lang/node \
		lang/typescript
RUN_DEPENDS+=	lang/node

pre-configure:
	ln -fs ${WRKDIR}/package/bin/pnpm.cjs ${WRKDIR}/bin/pnpm

do-build:
	cd ${WRKSRC} && ${MODPNPM_CMD} compile

# XXX modpnpm hoisted+bundle+pack / npm install
# XXX pnpm deploy does not work
# XXX publish-packed incompatibility with node v22.x (assertion failed in esm)
# copy official pakcage then override pnpm.cjs with custom build
do-install:
	${MODPY_COMPILEALL} ${WRKDIR}/package/dist/node_modules/node-gyp/gyp
	${INSTALL_DATA_DIR} ${PREFIX}/lib/node_modules/pnpm
	cp -Rp ${WRKDIR}/package/* ${PREFIX}/lib/node_modules/pnpm
	cp -p ${WRKSRC}/pnpm/dist/pnpm.cjs ${PREFIX}/lib/node_modules/pnpm/dist/
	chown -R ${SHAREOWN}:${SHAREGRP} ${PREFIX}/lib/node_modules
	ln -s ../lib/node_modules/pnpm/bin/pnpm.cjs ${PREFIX}/bin/pnpm
	rm -rf ${PREFIX}/lib/node_modules/pnpm/dist/vendor
	rm -rf ${PREFIX}/lib/node_modules/pnpm/dist/reflink*

TEST_ENV=	${MAKE_ENV} ${MODPNPM_ENV} PNPM_WORKERS=3

do-test:
# lint error, skip 'pnpm lint --quiet'
# pnpm run stop on first _test failure, add --no-bail to keep it going
# "test-main": "pnpm pretest && pnpm lint --quiet && pnpm run test-pkgs-main"
# "test-pkgs-main": "pnpm remove-temp-dir && pnpm run \
#	--no-sort --workspace-concurrency=1 -r _test"
	cd ${WRKSRC} && \
		${SETENV} ${TEST_ENV} ${MODPNPM_BIN} pretest && \
		${SETENV} ${TEST_ENV} ${MODPNPM_BIN} remove-temp-dir && \
		${SETENV} ${TEST_ENV} ${MODPNPM_BIN} run --no-sort \
			--workspace-concurrency=1 --no-bail -r _test

.include <bsd.port.mk>
