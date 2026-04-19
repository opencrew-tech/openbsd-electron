COMMENT =	next-generation ES module bundler

DIST_TUPLE+=	github rollup rollup v4.59.0 rollup

# need a custom @rollup/plugin-typescript to overcome fd limit issue
DIST_TUPLE+=	github rollup plugins \
	5cc7fc5cb1b7fbff42130a4cd798f709cd6f3158 plugins

CATEGORIES =	devel

HOMEPAGE =	https://rollupjs.org/

MAINTAINER =	Fabien Romano <fabien@openbsd.org>

# MIT
PERMIT_PACKAGE =	Yes

WANTLIB += ${MODCARGO_WANTLIB} m

MODULES =		devel/cargo \
			devel/npm \
			devel/pnpm

MODCARGO_CARGOTOML =	${WRKSRC}/rollup/rust/Cargo.toml

# cargo integration
MODCARGO_INSTALL =	No
MODCARGO_TEST =		No
MODNPM_ENV+=		${MODCARGO_ENV}

MODNPM_TARGETS =	${WRKSRC}/rollup
MODNPM_INSTALL =	rollup
MODNPM_MODS_SKIP+=	rollup

MODNPM_MODS+=esbuild
MODNPM_MODS+=graceful-fs
MODNPM_MODS+=puppeteer
MODNPM_MODS+=tailwindcss

MODPNPM_TARGETS =	${WRKSRC}/plugins
MODPNPM_INSTALL =	rollup
MODPNPM_MODS_SKIP+=	rollup

MODPNPM_MODS+=esbuild
MODPNPM_MODS+=graceful-fs
MODPNPM_MODS+=@swc/core

# we actually only need plugin-typescript to fix it for ressources limits but to
# ease porting we use default pnpm modules directive and thus build all plugins
# problem is some plugins need rollup to build ...
MODPNPM_GEN_OVERRIDES=	rollup "npm:@rollup/wasm-node"

CONFIGURE_STYLE =	cargo

# use custom WRKDIST to build both rollup and @rollup plugins side by side
WRKDIST =		${WRKDIR}/src

pre-patch:
	# instead of @rollup/rollup-openbsd-* use embeded napi lib
	rm -rf ${WRKSRC}/rollup/node_modules/@rollup/rollup-openbsd-*

build-plugins:
	cd ${WRKSRC}/plugins && ${MODPNPM_CMD_BUILD} --recursive \
		--workspace-concurrency 1 --sequential build
	${MODPNPM_BUILD_TARGET}

do-build: build-plugins
# hotfix @rollup/plugin-typescript to allow non-watch build (bellow fd limits)
	rm -rf ${WRKSRC}/rollup/node_modules/@rollup/plugin-typescript/dist
	cp -r ${WRKSRC}/plugins/packages/typescript/dist \
		${WRKSRC}/rollup/node_modules/@rollup/plugin-typescript/dist
# build napi, copy .node into node_modules before build:js
	cd ${WRKSRC}/rollup && \
		${MODNPM_CMD_BUILD} run build:napi -- --release && \
		cp ${WRKSRC}/rollup/rollup.*.node \
			${WRKSRC}/rollup/node_modules/rollup/dist/ && \
		${MODNPM_CMD_BUILD} run build:js:node
	${MODNPM_BUILD_TARGET}

do-install:
	${MODPNPM_INSTALL_TARGET}
	${MODNPM_INSTALL_TARGET}

post-install:
# cleanup detritus
	rm -rf ${PREFIX}/${MODNPM_INSTALL_DIR}/rollup/dist/rollup.*.node
	rm -rf ${PREFIX}/${MODNPM_INSTALL_DIR}/rollup/node_modules/rollup
# skip copy:native and bundle .node here
	cp ${WRKSRC}/rollup/rollup.*.node \
		${PREFIX}/${MODNPM_INSTALL_DIR}/rollup/dist/rollup.node

pre-test:
	ln -fs ${WRKSRC}/rollup/rollup.*.node ${WRKSRC}/rollup/dist/rollup.node

modnpm-pre-gen-modules:
	# drop wasm-pack
	cd ${WRKSRC} && \
	jq 'del(.devDependencies["wasm-pack"])' rollup/${MODNPM_PACKAGE} \
		> tmp.json && mv tmp.json rollup/${MODNPM_PACKAGE} ;

.include "crates.inc"

.include "modules.npm.inc"
.include "modules.pnpm.inc"

.include <bsd.port.mk>
