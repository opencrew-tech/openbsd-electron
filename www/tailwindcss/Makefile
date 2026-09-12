COMMENT =	utility-first CSS framework with npm dependencies

DIST_TUPLE =		github tailwindlabs tailwindcss v4.2.2 .

CATEGORIES =		www

HOMEPAGE =		https://tailwindcss.com/

MAINTAINER =		Fabien Romano <fabien@openbsd.org>

# MIT
PERMIT_PACKAGE =	Yes

WANTLIB += ${MODCARGO_WANTLIB} c++ m

# XXX base-gcc ?
COMPILER=base-clang ports-gcc base-gcc

MODULES =		devel/cargo \
			devel/pnpm

# cargo integration
MODCARGO_BUILD =	No
MODCARGO_INSTALL =	No
MAKE_ENV+=		${MODCARGO_ENV}

MODPNPM_TARGETS =	${WRKSRC}
MODPNPM_PACKAGES =	${WRKSRC} ${WRKSRC}/crates/node

MODPNPM_INSTALL =	tailwindcss
MODPNPM_MODS_SKIP+=	tailwindcss
MODPNPM_NO_OPTIONAL =	Yes
MODPNPM_WORKSPACE_ARGS=	-r --filter '!{.}' \
			--filter '!{./packages/internal-example-plugin}'

# drop @tailwindcss/oxide-<os>-<arch> which are missing during build
# note @tailwindcss/oxide is overridden by a custom os/arch agnostic resolver
# see ${FILESDIR}/index.js & post-install target
MODPNPM_gen-configfiles+=\
	jq 'del(.optionalDependencies)' ${MODPNPM_PACKAGE} \
		> tmp.json && mv tmp.json ${MODPNPM_PACKAGE} ; \
	jq 'del(.pnpm.patchedDependencies)' ${MODPNPM_PACKAGE} \
		> tmp.json && mv tmp.json ${MODPNPM_PACKAGE} ;

MODPNPM_MODS+=esbuild
MODPNPM_MODS+=graceful-fs
MODPNPM_MODS+=@parcel/watcher
MODPNPM_MODS+=rollup
MODPNPM_MODS+=lightningcss

# devel/oxc-apps depends on tailwindcss, avoid recursive dependency
MODPNPM_MODS_SKIP+=@oxc-project/runtime
MODPNPM_MODS_SKIP+=@oxc-project/types

# devel/rolldown depends on tailwindcss, avoid recursive dependency
MODPNPM_MODS_SKIP+=rolldown
MODPNPM_MODS_SKIP+=@rolldown/pluginutils

CONFIGURE_STYLE =	cargo

TAILWINDCSS_OXIDE_DIST=	${MODPNPM_INSTALL_DIR}/@tailwindcss/oxide/
TAILWINDCSS_BIN =	@tailwindcss/cli/dist/index.mjs

post-extract:
	# drop standalone, too complex and not required
	mv ${WRKSRC}/packages/@tailwindcss-standalone/package.json{,.bak}
	# drop playgrounds, uneeded and require bun which is not compatible
	mv ${WRKSRC}/playgrounds{,.bak}
	# drop npm prebuilds
	mv ${WRKSRC}/crates/node/npm{,.bak}
	# drop internals, private
	mv ${WRKSRC}/integrations{,.bak}

do-build:
	cd ${WRKSRC} && ${MODPNPM_CMD} ${MODPNPM_ARGS:S/--offline//} \
		${MODPNPM_WORKSPACE_ARGS} run build
	${MODPNPM_BUILD_TARGET}

post-install:
	# override with custom index.js, use generic (not arch specific) .node
	${INSTALL_DATA} ${WRKSRC}/crates/node/tailwindcss-oxide*.node \
		${PREFIX}/${TAILWINDCSS_OXIDE_DIST}/tailwindcss-oxide.node
	${INSTALL_DATA} ${FILESDIR}/index.js \
		${PREFIX}/${TAILWINDCSS_OXIDE_DIST}/
	# link bin to cli
	ln -s ${LOCALBASE}/${MODPNPM_INSTALL_DIR}/${TAILWINDCSS_BIN} \
		${PREFIX}/bin/tailwindcss

modpnpm-pre-gen-modules:
	@cd ${WRKSRC} && \
	yq -y '\
	    .allowBuilds["tree-sitter@0.22.4"] = true | \
	    .allowBuilds["tree-sitter-javascript@0.23.1"] = true | \
	    .allowBuilds["tree-sitter-typescript@0.23.2"] = true' \
	    ${MODPNPM_WORKSPACE} > tmp.yaml && \
	mv tmp.yaml ${MODPNPM_WORKSPACE}

.include "crates.inc"

.include "modules.pnpm.inc"

.include <bsd.port.mk>
