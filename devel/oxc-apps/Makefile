COMMENT =	collection of high-performance JavaScript tools

V =		1.79.0
PKGNAME =	oxc-apps-${V}
DIST_TUPLE =	github oxc-project oxc apps_v${V} .

CATEGORIES =	devel

HOMEPAGE =	https://oxc.rs/

MAINTAINER=	Fabien Romano <fabien@openbsd.org>

# MIT
PERMIT_PACKAGE =	Yes

#https://github.com/oxc-project/oxc/blob/main/.github/scripts/clone-parallel.mjs
TEST262_SHA = be13516fb6441b950ba8a3df97eb34062c186972
BABEL_SHA = 1eac4481473df52fbbcb452c4dca8d79039dbb63
TYPESCRIPT_SHA = b465fdbfe175304d9b977da137b2c178ae1091d3
ESTREE_CONFORMANCE_SHA = 8d4e1faac9f350f914af9b8a6ec02c2d31ca799c
NODE_COMPAT_TABLE_SHA = 499beb6f1daa36f10c26b85a7f3ec3b3448ded23
# test262, Official ECMAScript Conformance Test Suite, BSD
DIST_TUPLE+=	github tc39 test262 ${TEST262_SHA} tasks/coverage/test262
# bable, compiler for writing JavaScript, MIT
DIST_TUPLE+=	github babel babel ${BABEL_SHA} tasks/coverage/babel
# typescript, superset of JavaScript, Apache-2.0
DIST_TUPLE+=	github microsoft TypeScript ${TYPESCRIPT_SHA} \
		tasks/coverage/typescript
# pretier, opinionated code formatter, MIT
# ESTree Conformance Test Suite, MIT
DIST_TUPLE+=	github oxc-project estree-conformance \
		${ESTREE_CONFORMANCE_SHA} \
		tasks/coverage/estree-conformance
# Node.js ECMAScript compatibility tables, MIT
DIST_TUPLE+=	github compat-table node-compat-table \
		${NODE_COMPAT_TABLE_SHA} \
		tasks/coverage/node-compat-table

WANTLIB += ${MODCARGO_WANTLIB} m

# XXX should be set in all the rust ports ?
COMPILER_LANGS =	c

MODULES =		devel/cargo \
			devel/pnpm

# cargo integration
MODCARGO_INSTALL =	No
MODCARGO_TEST =		No
MODPNPM_ENV+=		${MODCARGO_ENV}

MODPNPM_INSTALL =	oxc-apps
MODPNPM_MODS_SKIP+=oxc-parser
MODPNPM_MODS_SKIP+=@oxc-project/types
MODPNPM_MODS_SKIP+=@oxc-project/runtime
MODPNPM_MODS_SKIP+=oxfmt
MODPNPM_MODS_SKIP+=oxlint
MODPNPM_MODS_SKIP+=@oxlint/plugins

MODPNPM_MODS+=esbuild
MODPNPM_MODS+=lightningcss
MODPNPM_MODS+=rolldown
MODPNPM_MODS+=@rolldown/pluginutils
MODPNPM_MODS+=rollup
MODPNPM_MODS+=tailwindcss
MODPNPM_MODS+=yuku-codegen
MODPNPM_MODS+=yuku-parser

MODPNPM_ARGS_WORKSPACE = -r \
	--filter './napi/minify' \
	--filter './napi/parser' \
	--filter './napi/transform' \
	--filter './npm/*'

# random things to reduce pressure during tests, see patches also
MODPNPM_ENV_TEST =	UV_THREADPOOL_SIZE=1 \
			NODE_OPTIONS=--v8-pool-size=1 \
			RAYON_NUM_THREADS=1 \
			NO_COLOR=1
MODPNPM_ARGS_TEST =	test

CONFIGURE_STYLE =	cargo

# pnpm --filter "./napi/*" --filter "!./napi/playground" --filter "./apps/*" \
# 	list -r --depth -1
TARGET_OXLINT =		apps/oxlint src-js/bindings.js src-js oxlint
TARGETS =		napi/minify index.js . minify \
			napi/parser src-js/bindings.js src-js parser \
			napi/transform index.js . transform  \
			apps/oxfmt src-js/bindings.js src-js oxfmt \
			${TARGET_OXLINT}

do-build:
.for _dir _binding _subdir _node in ${TARGETS}
	# build ${_dir}
	cd ${WRKSRC}/${_dir} ; \
	${MODPNPM_CMD_BUILD} run build ; \
	[ -f ${_binding}.bak ] || cp ${_binding}{,.bak} ; \
	cp ${FILESDIR}/${_dir:S/\//_/}_${_binding:S/\//_/} ${_binding} ; \
	cd ${_subdir} && mv ${_node}.*.node ${_node}.node
.  if "${_dir:Mapps/*}" != ""
	# build-js ${_dir}
	cd ${WRKSRC}/${_dir} ; \
	${MODPNPM_CMD_BUILD} run build-js
.  endif
.  if "${_node}" == "parser"
	# override ${_dir} into apps/oxlint/node_modules/oxc-parser
	cd ${WRKSRC}/apps/oxlint/node_modules/oxc-parser && \
	rm -rf src-js && \
	cp -r ${WRKSRC}/${_dir}/src-js ./
.  endif
.  if "${_node}" == "oxfmt"
	# override ${_dir} into node_modules/oxfmt
	cd ${WRKSRC}/node_modules/oxfmt && \
	rm -rf dist && \
	cp -r ${WRKSRC}/${_dir}/dist ./
.  endif
.endfor
	# prepare npm/* for pack
	cd ${WRKSRC} ; \
	rm -rf npm/oxlint/dist && cp -r apps/oxlint/dist npm/oxlint/dist ; \
	cp apps/oxlint/dist-pkg-plugins/* npm/oxlint-plugins/ ; \
	cp -r apps/oxlint/dist-pkg-plugin-eslint/. npm/oxlint-plugin-eslint/ ; \
	rm -rf npm/oxfmt/dist && cp -r apps/oxfmt/dist npm/oxfmt/dist
	# pack
	${MODPNPM_BUILD_TARGET}

pre-test:
	# rebuild oxlint for test
.for _dir _binding _subdir _node in ${TARGET_OXLINT}
	cd ${WRKSRC}/${_dir} ; \
	${MODPNPM_CMD_BUILD} run build-test ; \
	cp ${FILESDIR}/${_dir:S/\//_/}_${_binding:S/\//_/} ${_binding} ; \
	( cd ${_subdir} && ln -fs ${_node}.*.node ${_node}.node ) ; \
	${MODPNPM_CMD_BUILD} run build-js
.endfor

do-test:
	cd ${WRKSRC}/apps/oxlint && ${MODPNPM_CMD_TEST} test

.include "crates.inc"

.include "modules.pnpm.inc"

.include <bsd.port.mk>
