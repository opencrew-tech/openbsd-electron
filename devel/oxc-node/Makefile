COMMENT =	Node.js dev tool based on Oxc

V =		0.1.0
DIST_TUPLE =	github oxc-project oxc-node v${V} .

CATEGORIES =	devel

MAINTAINER=	Fabien Romano <fabien@openbsd.org>

# MIT
PERMIT_PACKAGE =	Yes

# test only, maybe install to make sure cli and core version are sync
CLI_PREBUILT =		@oxc-node-cli-${V}.tgz
DISTFILES.pnpm+=	${MODPNPM_DIST}/@oxc-node-{@oxc-node/cli/-/}cli-${V}.tgz

WANTLIB += ${MODCARGO_WANTLIB} m

MODULES =		devel/cargo \
			devel/pnpm

# cargo integration
MODCARGO_INSTALL =	No
MODCARGO_TEST =		No
MODPNPM_ENV+=		${MODCARGO_ENV}

MODPNPM_INSTALL =	oxc-node

MODPNPM_MODS+=esbuild
MODPNPM_MODS+=graceful-fs
MODPNPM_MODS+=@swc/core

# a full build of oxc-node require rolldown but rolldown need oxc-node/core
MODPNPM_ARGS_WORKSPACE =--filter=@oxc-node/core
MODPNPM_MODS_SKIP+=rolldown
MODPNPM_MODS_SKIP+=@rolldown/pluginutils

# devel/oxc-apps depends on devel/rolldown, avoid recursive depends
MODPNPM_MODS_SKIP+=@oxc-project/runtime
MODPNPM_MODS_SKIP+=@oxc-project/types
MODPNPM_MODS_SKIP+=oxfmt
MODPNPM_MODS_SKIP+=oxlint

CONFIGURE_STYLE =	cargo

do-build:
	cd ${WRKSRC} && \
	${MODPNPM_CMD_BUILD} --filter=@oxc-node/core build && \
	${MODPNPM_CMD_BUILD} --filter=@oxc-node/core export-oxc-runtime
	cp ${FILESDIR}/index.js ${WRKSRC}/packages/core/index.js
	${MODPNPM_BUILD_TARGET}

post-install:
	# bundle .node with custom loader
	cp -p ${WRKSRC}/packages/core/oxc-node.*.node \
		${PREFIX}/${MODPNPM_INSTALL_DIR}/@oxc-node/core/oxc-node.node

# XXX node_modules prune during fake, run 'make clean test'
pre-test:
	# bundle .node with custom loader
	ln -fs ${WRKSRC}/packages/core/oxc-node.*.node \
		${WRKSRC}/packages/core/oxc-node.node
	# install prebuild @oxc-node/cli
	rm -rf ${WRKDIR}/cli-prebuilt ${WRKSRC}/packages/cli/dist
	mkdir -p ${WRKDIR}/cli-prebuilt
	tar -C ${WRKDIR}/cli-prebuilt -xzf \
		${DISTDIR}/${MODPNPM_DIST}/${CLI_PREBUILT} package/dist
	cp -pRP ${WRKDIR}/cli-prebuilt/package/dist \
		${WRKSRC}/packages/cli/
	for moddir in . \
	    packages/bench \
	    packages/integrate-module \
	    packages/integrate-module-bundler ; do \
		mkdir -p ${WRKSRC}/$$moddir/node_modules/.bin; \
		ln -fs ../@oxc-node/cli/dist/index.js \
			${WRKSRC}/$$moddir/node_modules/.bin/oxnode; \
	done

.include "crates.inc"

.include "modules.pnpm.inc"

.include <bsd.port.mk>
