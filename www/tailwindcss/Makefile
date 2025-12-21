COMMENT =	utility-first CSS framework with npm dependencies

DIST_TUPLE =		github tailwindlabs tailwindcss v4.1.16 .

CATEGORIES =		www

HOMEPAGE =		https://tailwindcss.com/

MAINTAINER =		Fabien Romano <fabien@openbsd.org>

# MIT
PERMIT_PACKAGE =	Yes

WANTLIB += ${MODCARGO_WANTLIB} c++ m

# XXX base-gcc ?
COMPILER=base-clang ports-gcc base-gcc

MODULES =		devel/cargo devel/pnpm

MODCARGO_BUILD =	No
MODCARGO_INSTALL =	No

MODPNPM_TARGETS =	${WRKSRC}
MODPNPM_PACKAGES =	${WRKSRC} ${WRKSRC}/crates/node

MODPNPM_INSTALL =	tailwindcss
MODPNPM_NO_OPTIONAL =	Yes
MODPNPM_WORKSPACE_ARGS=	-r --filter '!{.}' \
			--filter '!{./packages/internal-example-plugin}'

# drop @tailwindcss/oxide-<os>-<arch> which are missing during build
# note @tailwindcss/oxide is overridden by a custom os/arch agnostic resolver
# see ${FILESDIR}/index.js & post-install target
MODPNPM_gen-configfiles += \
	jq 'del(.optionalDependencies)' ${MODPNPM_PACKAGE} \
		> tmp.json && mv tmp.json ${MODPNPM_PACKAGE} ; \
	jq 'del(.pnpm.patchedDependencies)' ${MODPNPM_PACKAGE} \
		> tmp.json && mv tmp.json ${MODPNPM_PACKAGE} ;

MODPNPM_MODS+=lightningcss
MODPNPM_MODS+=rollup
MODPNPM_MODS+=@parcel/watcher
MODPNPM_MODS+=esbuild

# detect itself, ignore tailwindcss
MODPNPM_SKIP_GEN_MODS=Yes

# needed to build oxide with pnpm
MAKE_ENV+=		${MODCARGO_ENV}

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

.include "crates.inc"

.include "modules.pnpm.inc"

.include <bsd.port.mk>
