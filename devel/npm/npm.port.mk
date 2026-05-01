MODNPM_DIST=		npm_modules

# modnpm-gen-modules will configure TARGETS & PACKAGES then bundle CONFIGFILES
# For each PACKAGES folder, apply MODNPM_gen-configfiles and GEN_OVERRIDES
# For each TARGETS folder, apply npm commands GEN_LOCK|UPDATE|ADD then
# generate modules.npm.inc which contain DISTFILES and MODNPM_PKGS
MODNPM_TARGETS?=	${WRKSRC}
MODNPM_PACKAGES?=	${MODNPM_TARGETS}

# XXX MODNPM_GEN_EXCLUDES may not work without further package* stuff ?
# XXX INCLUDES/EXCLUDES/FORCE features looks useless for now
MODNPM_GEN_INCLUDES?= 	# include modules
MODNPM_GEN_EXCLUDES?= 	# exclude modules
# XXX not needed ? what does -f imply for npm, looks different from pnpm
#MODNPM_GEN_FORCE?=	# force all modules even wrong os

# modnpm-gen-modules configuration
# npm overrides:
#https://docs.npmjs.com/cli/v9/configuring-npm/package-json#overrides
MODNPM_GEN_OVERRIDES?=

# modnpm-gen-modules helpers : empty/no, package@version
# rm lock & npm install
MODNPM_GEN_LOCK?=	No
# npm update
MODNPM_GEN_UPDATE?=	No
# npm add
MODNPM_GEN_ADD?=	No

# ignore optional depends during gen-modules & install
MODNPM_NO_OPTIONAL?=	No
# ignore dev dependencies during gen-modules & install
MODNPM_NO_DEV?=		No

# remove engines & packageManager requirements from package.json
MODNPM_GEN_ENGINES?=	Yes
# inject (optional)dependencies as bundleDependencies into package.json
MODNPM_GEN_BUNDLE?=	Yes

# make show=MODNPM_MODULES, list of custom modules to handle
MODNPM_MODS?=

.if ${NO_BUILD:L} == "no"
MODNPM_BUILDDEP?=	Yes
MODNPM_BUILD?=		Yes
.else
MODNPM_BUILDDEP?=	No
MODNPM_BUILD?=		No
.endif

# by default there is no reason a port need a package manager to run itself
MODNPM_RUNDEP?=	No

.if ${NO_TEST:L} == "no"
MODNPM_TESTDEP?=	Yes
MODNPM_TEST?=		Yes
.else
MODNPM_TESTDEP?=	No
MODNPM_TEST?=		No
.endif

MODNPM_LOCK?=		package-lock.json
MODNPM_PACKAGE?=	package.json
MODNPM_SETTINGS?=	.npmrc
MODNPM_PATCHORIG?=	.orig.modnpm

# config files may be extended (ex: to embed sub-folders package.json tweeks)
MODNPM_CONFIGFILES+=	${MODNPM_LOCK} \
			${MODNPM_PACKAGE} \
			${MODNPM_SETTINGS}

# module port path : modules redirects with system ports
MODNPM_MODULES+=\
	7zip-bin archivers/node-7zip-bin \
		7zip-bin/node_modules/7zip-bin \
	app-builder-bin devel/app-builder \
		app-builder-bin/node_modules/app-builder-bin \
	@ast-grep/napi devel/ast-grep \
		ast-grep/node_modules/@ast-grep/napi \
	electron-builder www/electron-builder \
		electron-builder/node_modules/electron-builder \
	esbuild devel/esbuild \
		esbuild/node_modules/esbuild \
	graceful-fs devel/node-graceful-fs \
		graceful-fs/node_modules/graceful-fs \
	@parcel/watcher devel/parcel-watcher \
		parcel-watcher/node_modules/@parcel/watcher \
	puppeteer www/puppeteer \
		puppeteer/node_modules/puppeteer \
	rollup devel/rollup \
		rollup/node_modules/rollup \
	tailwindcss www/tailwindcss \
		tailwindcss/node_modules/tailwindcss \
	@tailwindcss/browser www/tailwindcss \
		tailwindcss/node_modules/@tailwindcss/browser \
	@tailwindcss/cli www/tailwindcss \
		tailwindcss/node_modules/@tailwindcss/cli \
	@tailwindcss/node www/tailwindcss \
		tailwindcss/node_modules/@tailwindcss/node \
	@tailwindcss/oxide www/tailwindcss \
		tailwindcss/node_modules/@tailwindcss/oxide \
	@tailwindcss/postcss www/tailwindcss \
		tailwindcss/node_modules/@tailwindcss/postcss \
	@tailwindcss/upgrade www/tailwindcss \
		tailwindcss/node_modules/@tailwindcss/upgrade \
	@tailwindcss/vite www/tailwindcss \
		tailwindcss/node_modules/@tailwindcss/vite \
	@typescript/api lang/typescript-go \
		typescript-go/node_modules/@typescript/api \
	@typescript/ast lang/typescript-go \
		typescript-go/node_modules/@typescript/ast \
	@typescript/native-preview lang/typescript-go \
		typescript-go/node_modules/@typescript/native-preview
# module . override : modules redirects without ports
MODNPM_MODULES+=\
	lightningcss . npm:lightningcss-wasm \
# module module . : modules fallback to add
MODNPM_MODULES+=\
	@swc/core @swc/wasm . \
	unrs-resolver @unrs/resolver-binding-wasm32-wasi .

# bring in module depends
# XXX BUILD_DEPENDS only ? configurable ?
.for _mod _port _override in ${MODNPM_MODULES}
.if !empty(MODNPM_MODS:M${_mod}) && "${_override}" != "." && "${_port}" != "."
BUILD_DEPENDS+=		${_port}
.endif
.endfor

# where package are saved during build
MODNPM_BUILD_DIST?=	${WRKDIR}/packages

# bundle dependencies and install -g with custom prefix
# XXX unpack (tar xzf) then run npm install (alternative ?)
# XXX keep in sync with other npm-like modules
MODNPM_INSTALL?=	no
MODNPM_INSTALL_DIST?=	${LOCALBASE}/node
MODNPM_INSTALL_DIR?=	node/${MODNPM_INSTALL}/node_modules

# home needed for npm cache (aka store)
PORTHOME?=		${WRKDIR}/vendor
MODNPM_CACHE?=		vendor/.npm/_cacache

# without modules.npm.inc, default vendor filename, see modnpm-gen-vendor
MODNPM_VENDOR_REV?=
MODNPM_VENDOR?=		${PKGNAME}${MODNPM_VENDOR_REV:%=.%}-vendor.tgz

# env is required and can be extended
MODNPM_ENV+=		PATH='${PORTPATH}:./node_modules/.bin' \
			TMP=${WRKDIR}/tmp \
			HOME=${PORTHOME}
# specific build & gen env are configurable (ex: replace npm_config_nodedir)
MODNPM_ENV_BUILD?=	npm_config_nodedir=${LOCALBASE}
MODNPM_ENV_TEST?=
MODNPM_ENV_GEN?=

# cmd
# XXX better way to inject CI=true
# XXX custom npm conflict with node
MODNPM_BIN?=		onpm
MODNPM_CMD?=\
	${SETENV} ${MODNPM_ENV} CI=true ${MODNPM_BIN}
MODNPM_CMD_BUILD?=\
	${SETENV} ${MAKE_ENV} ${MODNPM_ENV} CI=true  ${MODNPM_ENV_BUILD} \
	    ${MODNPM_BIN}
MODNPM_CMD_TEST?=\
	${SETENV} ${MAKE_ENV} ${MODNPM_ENV} CI=true  ${MODNPM_ENV_TEST} \
	    ${MODNPM_BIN}
MODNPM_CMD_GEN?=\
	${SETENV} ${MODNPM_ENV} ${MODNPM_ENV_GEN} ${MODNPM_BIN}

# common args
# XXX useless ? --no-audit --no-fund --legacy-peer-deps
# XXX debug only, --loglevel silly
# XXX workspace ? --include-workspace-root
MODNPM_ARGS?=\
	--verbose --foreground-scripts
MODNPM_ARGS_WORKSPACE?=\
	--workspaces
MODNPM_ARGS_OPTIONAL?=\
	${MODNPM_NO_OPTIONAL:L:S/no//:S/yes/--omit=optional/} \
	    ${MODNPM_NO_OPTIONAL:L:S/no/--include=optional/:S/yes//}
MODNPM_ARGS_DEV?=\
	${MODNPM_NO_DEV:L:S/no//:S/yes/--omit=dev/} \
	    ${MODNPM_NO_DEV:L:S/no/--include=dev/:S/yes//}
# ports args
MODNPM_ARGS_EXTRACT?=\
	ci ${MODNPM_ARGS} --offline --ignore-scripts \
	    ${MODNPM_ARGS_OPTIONAL} ${MODNPM_ARGS_DEV}
MODNPM_ARGS_REBUILD?=\
	rebuild ${MODNPM_ARGS}
MODNPM_ARGS_BUILD?=\
	pack ${MODNPM_ARGS} --omit=dev ${MODNPM_ARGS_OPTIONAL}
MODNPM_ARGS_FAKE?=\
	install ${MODNPM_ARGS} ${MODNPM_ARGS_OPTIONAL} --omit=dev \
	    --ignore-scripts --prefix=${PORTHOME}/ -g
MODNPM_ARGS_PRUNE?=\
	prune ${MODNPM_ARGS} ${MODNPM_ARGS_OPTIONAL} --omit=dev \
	    --ignore-scripts --no-audit
MODNPM_ARGS_TEST?=\
	test ${MODNPM_ARGS}
# maintener args
# XXX MODNPM_ARGS_GEN --package-lock-only, brake some lock with overrides ?
# XXX add, --save-dev only ?
MODNPM_ARGS_GEN?=\
	${MODNPM_ARGS} --ignore-scripts --lockfile-version 3
MODNPM_ARGS_INSTALL?=\
	install ${MODNPM_ARGS_GEN} --no-audit \
	    ${MODNPM_ARGS_OPTIONAL} ${MODNPM_ARGS_DEV}
MODNPM_ARGS_UPDATE?=\
	update ${MODNPM_ARGS_GEN} --no-audit
MODNPM_ARGS_ADD?=\
	add ${MODNPM_ARGS_GEN} --no-audit --save-dev
MODNPM_ARGS_AUDIT?=\
	audit fix ${MODNPM_ARGS_GEN}
MODNPM_ARGS_VENDOR?=\
	ci ${MODNPM_ARGS} --ignore-scripts \
	    ${MODNPM_ARGS_OPTIONAL} ${MODNPM_ARGS_DEV}

# SITES{.npm,.github} && EXTRACT_SUFX.github
SITES.npm?=		https://registry.npmjs.org/
# XXX few use cases, better way to avoid duplicates ?
.include "${PORTSDIR}/infrastructure/db/dist-tuple.pattern"
EXTRACT_SUFX.github?=	${TEMPLATE_EXTRACT_SUFX}

# see post-extract
EXTRACT_CASES+=		${MODNPM_DIST}/*) ;;

.if ${MODNPM_BUILDDEP:L} == "yes"
BUILD_DEPENDS+=		devel/npm # depends on lang/node which include npm
.endif
.if ${MODNPM_RUNDEP:L} == "yes"
RUN_DEPENDS+=		devel/npm
.endif
.if ${MODNPM_TESTDEP:L} == "yes"
TEST_DEPENDS+=		devel/npm
.endif

# link to MODNPM_INSTALL_DIST needed for modules overrides with ports
# link to onpm needed to override missues of npm (w/patch) instead of onpm
# XXX ulimit still needed after gracefull-fs patch on promises ?
MODNPM_post-extract += \
	mkdir -p ${PORTHOME} ; \
	mkdir -p ${WRKDIR}/tmp ; \
	mkdir -p ${MODNPM_BUILD_DIST} ; \
	ln -fs ${MODNPM_INSTALL_DIST} ${WRKDIR}/ ; \
	ln -fs ${LOCALBASE}/bin/onpm ${WRKDIR}/bin/npm ; \
	ulimit -Sn `ulimit -Hn` ;

.if empty(_GEN_MODULES)

MODNPM_post-extract += \
	for target in ${MODNPM_PACKAGES} ; do \
		mkdir -p $${target} ; \
		cd $${target} ;
# backup lock files
.for _CONF in ${MODNPM_CONFIGFILES}
MODNPM_post-extract += \
		[ -f ${_CONF}${MODNPM_PATCHORIG} ] || \
			[ -f ${_CONF} ] && \
			cp ${_CONF}{,${MODNPM_PATCHORIG}} ;
.endfor

MODNPM_post-extract += \
		cd - >/dev/null ; \
	done ;

# Override locks with those generated by modnpm-gen-modules
MODNPM_post-extract += \
	for target in ${MODNPM_PACKAGES} ; do \
		prefix=$$(echo "$${target\#\#${WRKSRC}}" | tr '/' '_') ; \
		prefix=$${prefix\#\#_} ; \
		prefix=$${prefix%%_} ; \
		echo "MODNPM: update $${target}" ; \
		cd $${target} ;
.for _CONF in ${MODNPM_CONFIGFILES}
MODNPM_post-extract += \
		conf=${_CONF:S/\//_/g} ; \
		if [ -f ${FILESDIR}/modnpm_$${prefix}_$${conf} ] ; then \
			cp ${FILESDIR}/modnpm_$${prefix}_$${conf} ${_CONF} ; \
		fi ;
.endfor
MODNPM_post-extract += \
		cd - >/dev/null ; \
	done ;

.endif # empty(_GEN_MODULES)

.if empty(_GEN_MODULES) && empty(_GEN_VENDOR)

# import distfiles in store for npm use offline
MODNPM_post-extract += \
	rm -f ${WRKDIR}/store.list ; \
	for module in $$(echo "${MODNPM_PKGS}") ; do \
		id=$${module%;*} ; pkg=$${module\#*;} ; \
		echo "$${id}|${DISTDIR}/${MODNPM_DIST}/$${pkg}" \
			>> ${WRKDIR}/store.list ; \
	done ; \
	[ -f ${WRKDIR}/store.list ] && \
		echo "MODNPM: store add ***" && \
		cd ${WRKDIR} && cat store.list | \
		xargs ${MODNPM_CMD} ${MODNPM_ARGS} cache add ;

# Install node_modules files only, ignore scripts. Then run npm rebuild during
# pre-build, after patch, which allows small customization.
# Note, during fake, node_modules folders are pruned (or reinstalled) for
# production without applying any patches.
# Thus patches for devdepends work but not for rundepends.
MODNPM_post-extract += \
	for target in ${MODNPM_TARGETS} ; do \
		echo "MODNPM: extract $${target}" ; \
		cd $${target} && \
		${MODNPM_CMD} ${MODNPM_ARGS_EXTRACT} ; \
		cd - >/dev/null ; \
	done ;

.endif # empty(_GEN_MODULES) && empty(_GEN_VENDOR)

MODNPM_PREBUILD_TARGET=\
	for target in ${MODNPM_TARGETS} ; do \
		echo "MODNPM: rebuild $${target}" ; \
		cd $${target} && \
		${MODNPM_CMD_BUILD} ${MODNPM_ARGS_REBUILD} ; \
	done

# XXX --include-workspace-root ?
MODNPM_BUILD_TARGET=\
	for target in ${MODNPM_TARGETS} ; do \
		prefix=$$(echo "$${target\#\#${WRKSRC}}" | tr '/' '_') ; \
		prefix=$${prefix\#\#_} ; \
		prefix=$${prefix%%_} ; \
		echo "MODNPM: pack $${target}" ; \
		cd $${target} ; \
		mkdir -p ${MODNPM_BUILD_DIST}/$${prefix} ; \
		if ! grep -q '"workspaces"' ${MODNPM_PACKAGE}; then \
			${MODNPM_CMD_BUILD} ${MODNPM_ARGS_BUILD} \
			--pack-destination=${MODNPM_BUILD_DIST}/$${prefix} ; \
			continue ; \
		fi ; \
		${MODNPM_CMD_BUILD} ${MODNPM_ARGS_BUILD} \
			${MODNPM_ARGS_WORKSPACE} \
			--pack-destination=${MODNPM_BUILD_DIST}/$${prefix} ; \
	done

# XXX a full rm -rf node_modules then ci is buggy, use prune instead
MODNPM_INSTALL_TARGET=\
	${INSTALL_DATA_DIR} ${PREFIX}/${MODNPM_INSTALL_DIR} ; \
	for target in ${MODNPM_TARGETS} ; do \
		prefix=$$(echo "$${target\#\#${WRKSRC}}" | tr '/' '_') ; \
		prefix=$${prefix\#\#_} ; \
		prefix=$${prefix%%_} ; \
		if ! grep -q '"workspaces"' $${target}/${MODNPM_PACKAGE}; then \
			for tgz in ${MODNPM_BUILD_DIST}/$${prefix}/*.tgz ; do \
				[ -f $$tgz ] || continue ; \
				echo "MODNPM: install $$tgz" ; \
				${MODNPM_CMD} ${MODNPM_ARGS_FAKE} $$tgz ; \
			done ; \
			continue ; \
		fi ; \
		echo "MODNPM: prune $${target}" ; \
		cd $${target} ; \
		${MODNPM_CMD} prune --omit=dev --ignore-scripts ; \
		[ -d node_modules ] && ( \
			echo "MODNPM: bundle node_modules $$(pwd)" ; \
			cd node_modules && \
			pax -rw -pe . ${PREFIX}/${MODNPM_INSTALL_DIR}/ \
		) ; \
		find -L ${PREFIX}/${MODNPM_INSTALL_DIR} -type l -print | \
		while read _link ; do \
			_target=$$(readlink "$${_link}") ; \
			case "$${_target}" in /*) continue ;; esac ; \
			echo "MODNPM: drop invalid symlink $${_link}" ; \
			rm -f "$${_link}" ; \
		done ; \
		echo "MODNPM: unpack & install $${target}" ; \
		for tgz in ${MODNPM_BUILD_DIST}/$${prefix}/*.tgz ; do \
			[ -f $$tgz ] || continue ; \
			cd ${PREFIX}/${MODNPM_INSTALL_DIR} ; \
			tar -xzf $$tgz ; \
			pkg=$$(cat package/package.json | \
			    grep -m1 name | awk -F\" '{print $$4}') ; \
			echo "MODNPM: $$tgz -> $${pkg}" ; \
			pkgdir=$${pkg%/*} ; \
			[ "$$pkgdir" = "$$pkg" ] || mkdir -p $$pkgdir ; \
			mv package $${pkg} ; \
			srcfile=$$( \
				cd $${target} && \
				find . -name package.json \
				    -not -path '*/node_modules/*' -print | \
				xargs grep -l -m1 "\"name\": \"$${pkg}\"" | \
				head -n1) ; \
			srcdir=$${srcfile%/${MODNPM_PACKAGE}} ; \
			if [ "$${srcdir}" = "." ] ; then \
				echo "MODNPM: root package, skip modules" ; \
			else \
				echo "MODNPM: modules from $${srcdir}" ; \
				[ -n "$${srcdir}" ] && \
				[ -d $${target}/$${srcdir}/node_modules ] && (\
				cd $${target}/$${srcdir} && \
				pax -rw -pe node_modules \
				    ${PREFIX}/${MODNPM_INSTALL_DIR}/$${pkg} \
				) ; \
			fi ; \
			pkgpath=${PREFIX}/${MODNPM_INSTALL_DIR}/$${pkg} ; \
			if [ ! -f "$${pkgpath}/package.json" ] ; then \
				echo "MODNPM: no package.json for $${pkg}" ; \
				continue ; \
			fi ; \
			node -e ' \
				const fs = require("fs"); \
				const p = JSON.parse( \
				  fs.readFileSync(process.argv[1], "utf8")); \
				const b = p.bin; \
				if (!b) process.exit(0); \
				if (typeof b === "string") { \
				  const n = (p.name || "").split("/").pop(); \
				  if (n) console.log(n + " " + b); \
				    process.exit(0); \
				} \
				for (const [n, v] of Object.entries(b)) { \
				  console.log(n + " " + v); \
				} \
			' "$${pkgpath}/package.json" | \
			while read _name _path ; do \
				[ -n "$${_name}" ] || continue ; \
				[ -n "$${_path}" ] || continue ; \
				_path=$${_path\#./} ; \
				[ -e "$${pkgpath}/$${_path}" ] || continue ; \
				echo "MODNPM: bin $${_name} from $${pkg}" ; \
				ln -sf \
				    ../${MODNPM_INSTALL_DIR}/$${pkg}/$${_path} \
				    ${PREFIX}/bin/$${_name} ; \
			done ; \
		done ; \
	done ; \
	[ -d ${PORTHOME}/lib/node_modules ] && \
	( cd ${PORTHOME}/lib/node_modules && \
		pax -rw -pe . ${PREFIX}/${MODNPM_INSTALL_DIR}/ ) || true ; \
	[ -d ${PORTHOME}/bin ] && \
	for bin in ${PORTHOME}/bin/* ; do \
		_name=$$(basename $$bin) ; \
		_link=$$(readlink $$bin) ; \
		_link=$${_link\#../lib/node_modules/} ; \
		echo "MODNPM: bin $${_name} link to $${_link}" ; \
		ln -s ../${MODNPM_INSTALL_DIR}/$${_link} \
			${PREFIX}/bin/$${_name} ; \
	done || true ; \
	for target in ${MODNPM_TARGETS} ; do \
		pkg=$$(cat $$target/package.json | \
		    grep -m1 name | awk -F\" '{print $$4}') ; \
		find $$target/node_modules -type f -name '*.node' \
		    -not -path '*tmp*' 2>/dev/null | \
		while read node ; do \
			dst=${MODNPM_INSTALL_DIR}/$$pkg/$${node\#$$target/} ; \
			echo "MODNPM: bundle $${node} into $${dst}" ; \
			${INSTALL_DATA_DIR} $$(dirname ${PREFIX}/$$dst) ; \
			${INSTALL_DATA} $$node ${PREFIX}/$$dst ; \
		done ; \
	done ; \
	echo "MODNPM: cleanup" ; \
	find ${PREFIX}/${MODNPM_INSTALL_DIR} -type f -and \( \
		-name '*${MODNPM_PATCHORIG}' \
		-or -name '*${PATCHORIG}' \
		-or -name '*.core' \
		\) -exec rm {} \; ;

MODNPM_TEST_TARGET=\
	for target in ${MODNPM_TARGETS} ; do \
		echo "MODNPM: test $${target}" ; \
		cd $${target} && ${MODNPM_CMD_TEST} ${MODNPM_ARGS_TEST} ; \
	done

.if !target(pre-build)
pre-build:
	@${MODNPM_PREBUILD_TARGET}
.endif

.if !target(do-build) && ${MODNPM_BUILD:L} == "yes"
do-build:
	@${MODNPM_BUILD_TARGET}
.endif

.if !target(do-install) && ${MODNPM_INSTALL:L} != "no"
do-install:
	@${MODNPM_INSTALL_TARGET}
.endif

.if !target(do-test) && ${MODNPM_TEST:L} == "yes"
do-test:
	@${MODNPM_TEST_TARGET}
.endif

.if !target(modnpm-diff)
modnpm-diff:
.for _CONF in ${MODNPM_CONFIGFILES}
	@for target in ${MODNPM_PACKAGES} ; do \
		cd ${FILESDIR} ; \
		prefix=$$(echo "$${target##${WRKSRC}}" | tr '/' '_') ; \
		prefix=$${prefix##_} ; \
		prefix=$${prefix%%_} ; \
		conf=${_CONF:S/\//_/g} ; \
		if [[ $${target}/${_CONF} == *.json ]] ; then \
			[ -f $${target}/${_CONF}${MODNPM_PATCHORIG} ] && \
			jq '.' $${target}/${_CONF}${MODNPM_PATCHORIG} | \
			diff -uN - modnpm_$${prefix}_$${conf} || true ; \
		else \
			[ -f $${target}/${_CONF}${MODNPM_PATCHORIG} ] && \
			diff -uN $${target}/${_CONF}${MODNPM_PATCHORIG} \
				modnpm_$${prefix}_$${conf} || true ; \
		fi ; \
	done
.endfor
.endif

# XXX too generic
# 	jq 'del(.engines,.packageManager)' ${MODNPM_PACKAGE} \
# 		> tmp.json && mv tmp.json ${MODNPM_PACKAGE} ;
# OpenBSD use system node, ignore any version requirement
.if ${MODNPM_GEN_ENGINES:L} != "no"
MODNPM_gen-configfiles += \
	jq 'del(.packageManager) \
		| if .engines then \
		.engines |= with_entries(select(.key != "node" \
			and .key != "npm" and .key != "yarn" \
			and .key != "pnpm")) \
		| if (.engines | length) == 0 then del(.engines) else . end \
		else . end' ${MODNPM_PACKAGE} \
		> tmp.json && mv tmp.json ${MODNPM_PACKAGE} ;
.endif

# To populate fake root we pack with bundle dependencies then install.
# Note, custom .node are not bundled and workspaces get duplicates depends
# XXX should detect workspaces and fix bundleDependencies without any config ?
.if ${MODNPM_GEN_BUNDLE:L} != "no"
MODNPM_gen-configfiles += \
	jq '.bundleDependencies = (((.dependencies // {}) + \
	    (.optionalDependencies // {})) | keys_unsorted)' ${MODNPM_PACKAGE} \
		> tmp.json && mv tmp.json ${MODNPM_PACKAGE} ;
.else
MODNPM_gen-configfiles += \
	jq 'del(.bundleDependencies)' ${MODNPM_PACKAGE} \
		> tmp.json && mv tmp.json ${MODNPM_PACKAGE} ;
.endif

# Setup overrides customisation before modnpm-gen-configfiles (w/patches), ex:
# MODNPM_GEN_OVERRIDES =	foo npm:foo@x.y.z bar npm:@cutom/bar
.for _mod _spec in ${MODNPM_GEN_OVERRIDES}
MODNPM_gen-configfiles += \
		jq --arg mod "${_mod}" --arg spec "${_spec}" \
			'.overrides += {($$mod): $$spec} \
			| reduce ["dependencies","devDependencies", \
			    "optionalDependencies","peerDependencies"][] as $$k\
			(. ; if .[$$k]?[$$mod] then .[$$k][$$mod]=$$spec end)' \
			${MODNPM_PACKAGE} \
			> tmp.json && mv tmp.json ${MODNPM_PACKAGE} ;
.endfor

# skip generating modules.npm.inc, vendor store in $HOME ($WRKDIR/vendor)
_MODNPM_VENDOR?=	No
# default env for generating configfiles, modules.npm.inc or vendor store
_MODNPM_TMP?=		./modnpm
_MODNPM_GEN_VAR?=	BUILD_USER=$$(whoami) WRKOBJDIR=$${t}
_MODNPM_GEN_DIR?=	$$(realpath `mktemp -d ${_MODNPM_TMP}.XXXXXXX`)

.if !target(modnpm-pre-gen-modules)
modnpm-pre-gen-modules:
.endif

.if !target(modnpm-post-gen-modules)
modnpm-post-gen-modules:
.endif

.if !target(_modnpm-gen-modules)
_modnpm-gen-modules: modnpm-pre-gen-modules
# run with custom BUILD_USER & WRKOBJDIR
# scan for modules to override, update or add
	@rm -f ${WRKDIR}/newmods
	@rm -f ${WRKDIR}/missmods
.  for _mod _port _override in ${MODNPM_MODULES}
	@for target in ${MODNPM_PACKAGES} ; do \
		[ -f $${target}/${MODNPM_LOCK} ] && \
		grep -q '["/]node_modules/${_mod}"' \
			$${target}/${MODNPM_LOCK} && \
		echo "${MODNPM_MODS}" | grep -vq "${_mod}" && \
		echo "${MODNPM_MODS_SKIP}" | grep -vq "${_mod}" && \
		echo "MODNPM_MODS+=${_mod}" >> ${WRKDIR}/newmods ; \
		true ; \
	done
.  endfor
# scan for missing mods to remove
.for _mod _port _override in ${MODNPM_MODULES}
.  if !empty(MODNPM_MODS:M${_mod})
	@found=0 ; \
	for target in ${MODNPM_PACKAGES} ; do \
		[ -f $${target}/${MODNPM_LOCK} ] && \
		if grep -q '["/]node_modules/${_mod}"' \
		    $${target}/${MODNPM_LOCK} ; then \
			found=1 ; \
		fi ; \
	done ; \
	if [ $${found} == 0 ] ; then \
		echo "${MODNPM_MODS_SKIP}" | grep -vq "${_mod}" && \
		echo "${_mod} not found" >> ${WRKDIR}/missmods ; \
		true ; \
	fi
.  endif
.endfor
# reports mods to (un)activate
.  if empty(MODNPM_SKIP_GEN_MODS)
	@if [ -f ${WRKDIR}/newmods ] ; then \
		echo "MODNPM: either add those mods in your Makefile" ; \
		cat ${WRKDIR}/newmods ; \
		echo "MODNPM: or run again with MODNPM_SKIP_GEN_MODS=Yes" ; \
		false ; \
	else \
		true ; \
	fi
	@if [ -f ${WRKDIR}/missmods ] ; then \
		echo "MODNPM: either remove those mods in your Makefile" ; \
		cat ${WRKDIR}/missmods ; \
		echo "MODNPM: or run again with MODNPM_SKIP_GEN_MODS=Yes" ; \
		false ; \
	else \
		true ; \
	fi
.  else
	@[ -f ${WRKDIR}/newmods ] && \
		echo "MODNPM: maybe add those mods in your Makefile" && \
		cat ${WRKDIR}/newmods || \
		true
	@[ -f ${WRKDIR}/missmods ] && \
		echo "MODNPM: maybe remove those mods in your Makefile" && \
		cat ${WRKDIR}/missmods || \
		true
.  endif
# config fix
	@for target in ${MODNPM_PACKAGES} ; do \
		echo "MODNPM: fix config files $${target}" ; \
		cd $${target} ; \
		${MODNPM_gen-configfiles} \
		true ; \
	done
# mods triggered overrides
.for _mod _port _override in ${MODNPM_MODULES}
.  if !empty(MODNPM_MODS:M${_mod}) && "${_override}" != "."
.    if "${_port}" != "."
# Override modules with relative link to ${WRKDIR}/node which is a symlink
# to system ${LOCALBASE}/node.
# XXX only support system override through __wrkdir__ hack
	@for target in ${MODNPM_PACKAGES} ; do \
		grep -q '["/]node_modules/${_mod}"' \
			$${target}/${MODNPM_LOCK} || continue ; \
		echo "MODNPM: mod ${_mod} port ${_port} to $${target}" ; \
		cd $${target} ; \
		wrkdir=$$(echo $${target#${WRKDIR}/} | sed 's:[^/]*:..:g') ; \
		spec=$$( \
			echo 'file:__wrkdir__/node/${_override}' | \
			sed "s:__wrkdir__:$${wrkdir}:g" ) ; \
		jq --arg mod "${_mod}" --arg spec "$${spec}" \
			'.overrides += {($$mod): $$spec} \
			| reduce ["dependencies","devDependencies", \
			    "optionalDependencies","peerDependencies"][] as $$k\
			(. ; if .[$$k]?[$$mod] then .[$$k][$$mod]=$$spec end)' \
			${MODNPM_PACKAGE} \
			> tmp.json && mv tmp.json ${MODNPM_PACKAGE} ; \
		true ; \
	done
.    else
	@for target in ${MODNPM_PACKAGES} ; do \
		grep -q '["/]node_modules/${_mod}"' \
			$${target}/${MODNPM_LOCK} || continue ; \
		echo "MODNPM: mod ${_mod} -> ${_override} to $${target}" ; \
		cd $${target} ; \
		jq --arg mod "${_mod}" --arg spec "${_override}" \
			'.overrides += {($$mod): $$spec} \
			| reduce ["dependencies","devDependencies", \
			    "optionalDependencies","peerDependencies"][] as $$k\
			(. ; if .[$$k]?[$$mod] then .[$$k][$$mod]=$$spec end)' \
			${MODNPM_PACKAGE} \
			> tmp.json && mv tmp.json ${MODNPM_PACKAGE} ; \
		true ; \
	done
.    endif
.  endif
.endfor
# install
.  if !empty(MODNPM_GEN_LOCK) && ${MODNPM_GEN_LOCK:L} != "no"
	@for target in ${MODNPM_TARGETS} ; do \
		cd $${target} ; \
		echo "MODNPM: regen ${MODNPM_LOCK} $${target}" ; \
		rm -f ${MODNPM_LOCK} ; \
		rm -rf node_modules ; \
	done
.  else
	@for target in ${MODNPM_TARGETS} ; do \
		cd $${target} ; \
		[ -f ${MODNPM_LOCK} ] && continue ; \
		echo "MODNPM: missing ${MODNPM_LOCK} $${target}" ; \
	done
.  endif
	@for target in ${MODNPM_TARGETS} ; do \
		cd $${target} ; \
		echo "MODNPM: install $${target}" ; \
		${MODNPM_CMD_GEN} ${MODNPM_ARGS_INSTALL} ; \
	done
# update
.  if !empty(MODNPM_GEN_UPDATE) && ${MODNPM_GEN_UPDATE:L} != "no"
	@for target in ${MODNPM_TARGETS} ; do \
		cd $${target} ; \
		echo "MODNPM: update ${MODNPM_GEN_UPDATE} $${target}" ; \
		${MODNPM_CMD_GEN} ${MODNPM_ARGS_UPDATE} \
			${MODNPM_GEN_UPDATE} ; \
	done
.  endif
# add
.  if !empty(MODNPM_GEN_ADD) && ${MODNPM_GEN_ADD:L} != "no"
	@for target in ${MODNPM_TARGETS} ; do \
		cd $${target} ; \
		echo "MODNPM: add ${MODNPM_GEN_ADD} $${target}" ; \
		${MODNPM_CMD_GEN} ${MODNPM_ARGS_ADD} ${MODNPM_GEN_ADD} ; \
	done
.  endif
# mods triggered add
.  for _mod _port _override in ${MODNPM_MODULES}
.    if !empty(MODNPM_MODS:M${_mod}) && "${_override}" == "."
	@for target in ${MODNPM_TARGETS} ; do \
		grep -q '["/]node_modules/${_mod}"' \
			$${target}/${MODNPM_LOCK} || continue ; \
		cd $${target} ; \
		echo "MODNPM: mod ${_mod} add ${_port} to $${target}" ; \
		${MODNPM_CMD_GEN} ${MODNPM_ARGS_ADD} ${_port} ; \
	done
.    endif
.  endfor
# audit
# XXX fail with link ?
#	@for target in ${MODNPM_TARGETS} ; do \
#		cd $${target} ; \
#		echo "MODNPM: audit $${target}" ; \
#		${MODNPM_CMD_GEN} ${MODNPM_ARGS_AUDIT} || \
#		true ; \
#	done
# post-gen target
	t=${WRKOBJDIR} ; \
	make -D _GEN_MODULES ${_MODNPM_GEN_VAR} modnpm-post-gen-modules
# distfiles
	@[ -f ${.CURDIR}/modules.npm.inc ] && \
		mv ${.CURDIR}/modules.npm.inc{,.orig} || true
.  if ${_MODNPM_VENDOR:L} == "no"
	@echo "MODNPM: generate modules.npm.inc" ; \
	locks="" ; for target in ${MODNPM_TARGETS} ; do \
		[ -f $${target}/${MODNPM_LOCK} ] && \
		locks="$${locks} $${target}/${MODNPM_LOCK}" ; \
	done ; \
	echo "" >> ${.CURDIR}/modules.npm.inc ; \
	echo "#INCLUDES=${MODNPM_GEN_INCLUDES}" >> \
		${.CURDIR}/modules.npm.inc ; \
	echo "#EXCLUDES=${MODNPM_GEN_EXCLUDES}" >> \
		${.CURDIR}/modules.npm.inc ; \
	echo "" >> ${.CURDIR}/modules.npm.inc ; \
	${_PERLSCRIPT}/modnpm-gen-modules \
		${MODNPM_NO_DEV:L:S/yes/-d/:S/no//} \
		${MODNPM_NO_OPTIONAL:L:S/yes/-o/:S/no//} \
		${MODNPM_GEN_INCLUDES:='-i %'} \
		${MODNPM_GEN_EXCLUDES:='-x %'} \
		$${locks} >> ${.CURDIR}/modules.npm.inc && \
	echo "=> ${.CURDIR}/modules.npm.inc"
.  endif
# bundle config & lock files
	@mkdir -p ${FILESDIR}
	@echo "MODNPM: bundle configfiles"
.  for _CONF in ${MODNPM_CONFIGFILES}
	@cd ${FILESDIR} ; \
	for target in ${MODNPM_PACKAGES} ; do \
		prefix=$$(echo "$${target##${WRKSRC}}" | tr '/' '_') ; \
		prefix=$${prefix##_} ; \
		prefix=$${prefix%%_} ; \
		conf=${_CONF:S/\//_/g} ; \
		[ -f modnpm_$${prefix}_$${conf} ] && \
			cp modnpm_$${prefix}_$${conf}{,.orig} \
			|| true ; \
		[ -f $${target}/${_CONF} ] && \
			cp $${target}/${_CONF} modnpm_$${prefix}_$${conf} && \
			echo "=> ${FILESDIR}/modnpm_$${prefix}_$${conf}" \
			|| true ; \
	done
.  endfor
.endif # !target(_modnpm-gen-modules)

.if !target(modnpm-gen-modules)
modnpm-gen-modules:
	@which jq >/dev/null
	@t=${_MODNPM_GEN_DIR} && \
	echo "MODNPM: extract in $${t} as $$(whoami)" && \
	make -D _GEN_MODULES ${_MODNPM_GEN_VAR} extract && \
	echo "MODNPM: gen-modules in $${t} as $$(whoami)" && \
	make -D _GEN_MODULES ${_MODNPM_GEN_VAR} _modnpm-gen-modules && \
	echo "MODNPM: rm $${t}..." && \
	[ -d "$${t}" ] && rm -rf $${t} && \
	echo "MODNPM: rm $${t}, done." || (\
	echo "MODNPM: FAIL, try again with _MODNPM_GEN_DIR=$${t}" ; \
	false )
.endif

.if !target(_modnpm-gen-vendor)
_modnpm-gen-vendor:
# run with custom BUILD_USER & WRKOBJDIR
	for target in ${MODNPM_TARGETS}; do \
		echo "MODNPM: install $${target}" ; \
		cd $${target} && ${MODNPM_CMD_GEN} ${MODNPM_ARGS_VENDOR} && \
		${MODNPM_CMD_GEN} cache verify ; \
		cd - >/dev/null ; \
	done ;
	echo "MODNPM: vendor ${MODNPM_VENDOR}"
	@cd ${WRKDIR} && \
	tar -Rczf ${.CURDIR}/${MODNPM_VENDOR} ${MODNPM_CACHE} && \
	echo "=> ${.CURDIR}/${MODNPM_VENDOR}"

.endif

# If in trouble, use vendor pre-made store
.if !target(modnpm-gen-vendor)
modnpm-gen-vendor:
	@make _MODNPM_VENDOR=Yes modnpm-gen-modules
	@t=${_MODNPM_GEN_DIR} && \
	echo "MODNPM: extract in $${t} as $$(whoami)" && \
	make -D _GEN_VENDOR ${_MODNPM_GEN_VAR} extract && \
	echo "MODNPM: gen-vendor in $${t} as $$(whoami)" && \
	make -D _GEN_VENDOR ${_MODNPM_GEN_VAR} _modnpm-gen-vendor && \
	echo "MODNPM: rm $${t}..." && \
	[ -d "$${t}" ] && rm -rf $${t} && \
	echo "MODNPM: rm $${t}, done." || (\
	echo "MODNPM: FAIL, try again with _MODNPM_GEN_DIR=$${t}" ; \
	false )
.endif
