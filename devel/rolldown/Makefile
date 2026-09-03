COMMENT =	Rust bundler for JavaScript/TypeScript Rollup-compatible API

DIST_TUPLE =	github rolldown rolldown v1.2.5 .

CATEGORIES =	devel

HOMEPAGE =	https://rolldown.rs/

MAINTAINER=	Fabien Romano <fabien@openbsd.org>

# MIT
PERMIT_PACKAGE =	Yes

# test depends, git submodule & runtime fetch (patched)
# rollup, module bundler for JavaScript, MIT, ISC, 0BSD
# test262, ECMAScript Conformance Test Suite, BSD-like
DIST_TUPLE+=	github rollup rollup \
		ddc4ffab628944e45dbb8d66d58aae818015440f rollup
DIST_TUPLE+=	github tc39 test262 \
		3655e7464de3d52643ecddd4b5f9f4f3e7f62398 test262

WANTLIB += ${MODCARGO_WANTLIB} m

MODULES =		devel/cargo \
			devel/pnpm

MODCARGO_TEST_ARGS =	--workspace --exclude rolldown_binding

# cargo integration
MODCARGO_INSTALL =	No
MODCARGO_TEST =		No
MODPNPM_ENV+=		${MODCARGO_ENV}

MODPNPM_INSTALL =	rolldown
MODPNPM_MODS_SKIP+=	rolldown
MODPNPM_MODS_SKIP+=	@rolldown/pluginutils

MODPNPM_ARGS_WORKSPACE = -r --filter rolldown

MODPNPM_MODS+=esbuild
MODPNPM_MODS+=graceful-fs
MODPNPM_MODS+=@oxc-node/core
MODPNPM_MODS+=rollup
MODPNPM_MODS+=tailwindcss
MODPNPM_MODS+=@tailwindcss/node
MODPNPM_MODS+=@tailwindcss/oxide
MODPNPM_MODS+=@tailwindcss/vite
MODPNPM_MODS+=lightningcss
MODPNPM_MODS+=yuku-codegen
MODPNPM_MODS+=yuku-parser

# devel/oxc-apps depends on rolldown, avoid recursive dependency
MODPNPM_MODS_SKIP+=oxc-minify
MODPNPM_MODS_SKIP+=oxc-parser
MODPNPM_MODS_SKIP+=@oxc-project/runtime
MODPNPM_MODS_SKIP+=@oxc-project/types
MODPNPM_MODS_SKIP+=oxc-transform
MODPNPM_MODS_SKIP+=oxfmt
MODPNPM_MODS_SKIP+=oxlint
MODPNPM_MODS_SKIP+=@oxlint/plugins

RUN_DEPENDS =		devel/rollup

CONFIGURE_STYLE =	cargo

ROLLDOWN_DIST =		${MODPNPM_INSTALL_DIR}/rolldown/dist/

do-build:
	# build native lib
	cd ${WRKSRC} && \
	${MODPNPM_CMD_BUILD} --filter rolldown build-binding:release
	# hotfix/hack native binding
	cp -p ${WRKSRC}/packages/rolldown/src/rolldown-binding.openbsd-*.node \
		${WRKSRC}/packages/rolldown/src/rolldown-binding.node && \
	echo "const nativeBinding = require('./rolldown-binding.node')" \
		> ${WRKSRC}/packages/rolldown/src/binding.cjs.openbsd
	grep -A 999 "^module\\.exports = nativeBinding$$" \
		${WRKSRC}/packages/rolldown/src/binding.cjs \
		>> ${WRKSRC}/packages/rolldown/src/binding.cjs.openbsd
	mv ${WRKSRC}/packages/rolldown/src/binding.cjs{.openbsd,}
	# build js component
	cd ${WRKSRC} && \
	${MODPNPM_CMD_BUILD} --filter rolldown build-js-glue
	# pack
	${MODPNPM_BUILD_TARGET}

post-install:
	# bundle rolldown-binding.node
	cp -p ${WRKSRC}/packages/rolldown/src/rolldown-binding.openbsd-*.node \
		${PREFIX}/${ROLLDOWN_DIST}/rolldown-binding.node
	# expose pluginutils at the path expected by module overrides
	${INSTALL_DATA_DIR} ${PREFIX}/${MODPNPM_INSTALL_DIR}/@rolldown
	ln -s ../rolldown/node_modules/@rolldown/pluginutils \
		${PREFIX}/${MODPNPM_INSTALL_DIR}/@rolldown/pluginutils

pre-test:
# XXX rolldown needs rolldown to run tests
# Note, we blindly replace depends by the one we just built but this may break
# if port version is not compatible with the one needed from depends.
	# hotfix rolldown (!= version may cause issues) to run tests
	cd ${WRKSRC}/node_modules/.pnpm/ && \
	for dir in $$(find . \( -path "*/rolldown/dist/shared/binding-*.mjs" \
	    -o -path "*/dist/rolldown/shared/binding-*.mjs" \) \
	    -execdir sh -c 'cd ..; pwd' \;) ; do \
		rm -rf $$dir && \
		cp -rp ${WRKSRC}/packages/rolldown/dist $$dir && \
		cp -p ${WRKSRC}/packages/rolldown/src/rolldown-binding.*.node \
		    $$dir/rolldown-binding.node ; \
	done
# XXX needed for basic rolldown test ?
#	cd ${WRKSRC} && \
#	${MODPNPM_CMD_BUILD} --filter '@rolldown/test-dev-server' build

# make clean test (pnpm prune during fake)
do-test:
	# cargo test
# XXX rebuild everything ? --manifest-path ${MODCARGO_CARGOTOML} --release
#	${MODCARGO_TEST_TARGET}
# XXX prefer which one ? offical test build in debug (no --release)
	-${MODCARGO_CARGO_RUN} test ${MODCARGO_TEST_ARGS}
	# rolldown node test
	-cd ${WRKSRC} && \
	${MODPNPM_CMD_TEST} --filter rolldown-tests test:main && \
	${MODPNPM_CMD_TEST} --filter rolldown-tests test:watcher && \
	${MODPNPM_CMD_TEST} --filter rolldown-tests test:stability
	# rollup test - KO, need oxc-transform native binding
# XXX ? SKIP_PASS_DIFF: ${{ inputs.node-version != 24 && '1' || '' }}
# XXX oxc-transform native binding missing (recursive dependency)
# 	-cd ${WRKSRC} && \
# 	${MODPNPM_CMD_TEST} --filter rollup-tests test
	# build examples (test) - KO, need oxc-parser native binding
# XXX oxc-parser native binding missing (recursive dependency)
# 	-cd ${WRKSRC} && \
# 	${MODPNPM_CMD_TEST} --filter '@example/**' build
	# dev server test - KO, untested, need playwright support
# XXX playwright needed
# XXX pre-build test-dev-server
# 	-cd ${WRKSRC} && \
# 	${MODPNPM_CMD_TEST} --filter '@rolldown/test-dev-server-tests' test
	# vite test - KO, fetch with git + pnpm install, need playwright support
#	-cd ${WRKSRC} && \
#	${MODPNPM_CMD_TEST} --filter vite-tests test
	# `@rolldown/pluginutils` test
	-cd ${WRKSRC} && \
	${MODPNPM_CMD_TEST} --filter '@rolldown/pluginutils' test

.include "crates.inc"

.include "modules.pnpm.inc"

.include <bsd.port.mk>
