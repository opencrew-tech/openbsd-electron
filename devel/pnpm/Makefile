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

COMMENT=	fast, disk space efficient package manager

V=		11.22.0
DIST_TUPLE=	github pnpm pnpm v${V} .

CATEGORIES=	devel

HOMEPAGE=	https://pnpm.io/

MAINTAINER=	Fabien Romano <fabien@openbsd.org>

# MIT
PERMIT_PACKAGE=	Yes

DISTFILES.published=	pnpm-${V}.tgz
SITES.published=	https://registry.npmjs.org/pnpm/-/

# on upates, comments then run make makesum && make modpnpm-gen-vendor
DISTFILES.vendor=	${MODPNPM_VENDOR}
SITES.vendor=		http://distfiles.opencrew.tech/pnpm/

MODULES=		lang/python \
			devel/pnpm

MODPNPM_BIN=		${WRKDIR}/package/bin/pnpm.cjs
MODPNPM_BUILDDEP=	No
MODPNPM_RUNDEP=		No
MODPNPM_TESTDEP=	No

# force install of all os/arch, see pnpm build instructions
MODPNPM_GEN_FORCE=	Yes

#NO_TEST=		Yes # need internet access

BUILD_DEPENDS+=		devel/esbuild \
			lang/node \
			lang/typescript
RUN_DEPENDS+=		lang/node

# to bootstrap we use official pnpm which does not support system module
MODPNPM_SKIP_GEN_MODS=	Yes

# XXX use system esbuild, version to keep in sync manually
# [ERROR] Cannot start service:
# Host version "x.y.z" does not match binary version "x.y.z"
ESBUILD_V=		0.28.2
MODPNPM_GEN_UPDATE=	esbuild@${ESBUILD_V}
MODPNPM_GEN_OVERRIDES=	"esbuild" "${ESBUILD_V}"
MAKE_ENV+=		ESBUILD_BINARY_PATH=${LOCALBASE}/bin/esbuild

TEST_ENV=		${MAKE_ENV} ${MODPNPM_ENV} PNPM_WORKERS=3

post-extract:
	chmod +x ${WRKDIR}/package/bin/pnpm.cjs
	cd ${WRKDIR} && \
	ln -fs ./devel/esbuild/github.com/evanw/esbuild*/npm/esbuild \
		esbuild

pre-configure:
	ln -fs ${WRKDIR}/package/bin/pnpm.cjs ${WRKDIR}/bin/pnpm
	ln -fs ${WRKDIR}/package/bin/pnpm.cjs ${WRKDIR}/bin/pn
	ln -fs ${WRKDIR}/package/bin/pnpx.cjs ${WRKDIR}/bin/pnpx
	ln -fs ${WRKDIR}/package/bin/pnpx.cjs ${WRKDIR}/bin/pnx
# Keep the JavaScript TypeScript 6 compiler as tsc and expose the native
# TypeScript 7 compiler under the tsgo name expected by the pnpm sources.
	ln -fs ../typescript/bin/tsc ${WRKSRC}/node_modules/.bin/tsc
	ln -fs ../@typescript/native-preview/bin/tsc \
		${WRKSRC}/node_modules/.bin/tsgo

do-build:
	cd ${WRKSRC} && ${MODPNPM_CMD} compile

# XXX modpnpm hoisted+bundle+pack / npm install
# XXX pnpm deploy does not work
# XXX publish-packed incompatibility with node v22.x (assertion failed in esm)
# Copy the official package then override pnpm.mjs with the custom build.
do-install:
	${MODPY_COMPILEALL} ${WRKDIR}/package/dist/node_modules/node-gyp/gyp
	${INSTALL_DATA_DIR} ${PREFIX}/lib/node/pnpm
	cp -Rp ${WRKDIR}/package/* ${PREFIX}/lib/node/pnpm
	cp -p ${WRKSRC}/pnpm11/pnpm/dist/pnpm.mjs \
		${PREFIX}/lib/node/pnpm/dist/
	chown -R ${SHAREOWN}:${SHAREGRP} ${PREFIX}/lib/node
	ln -s ../lib/node/pnpm/bin/pnpm.cjs ${PREFIX}/bin/pnpm
	rm -rf ${PREFIX}/lib/node/pnpm/dist/vendor
	rm -rf ${PREFIX}/lib/node/pnpm/dist/reflink*

do-test:
# lint error, skip 'pn lint'
# pnpm run stop on first _test failure, add --no-bail to keep it going
# "test-all": "pn pretest && pn lint && pn test-pkgs-all"
	cd ${WRKSRC} && \
		${SETENV} ${TEST_ENV} ${MODPNPM_BIN} pretest && \
		${SETENV} ${TEST_ENV} ${MODPNPM_BIN} test-pkgs-all

# unrs-resolver: use the bundled WASI binding, avoid the network fallback.
# @eslint-community/eslint-utils: generated artifacts are already shipped.
# @typescript/native-preview: use the portable upstream TypeScript 7 package.
TYPESCRIPT_NATIVE_V=	7.0.2
modpnpm-pre-gen-modules:
	@cd ${WRKSRC} && \
	yq -y '\
		.allowBuilds["unrs-resolver"] = false | \
		.allowBuilds["@eslint-community/eslint-utils"] = false | \
		.catalog["@typescript/native-preview"] = \
		    "npm:typescript@${TYPESCRIPT_NATIVE_V}"' \
	    ${MODPNPM_WORKSPACE} > tmp.yaml && \
	mv tmp.yaml ${MODPNPM_WORKSPACE}

.include <bsd.port.mk>
