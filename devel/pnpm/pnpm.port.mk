MODPNPM_DIST=		npm_modules

# modpnpm-gen-modules will configure TARGETS & PACKAGES then bundle CONFIGFILES
# For each PACKAGES folder, apply MODPNPM_gen-configfiles and GEN_OVERRIDES
# For each TARGETS folder, apply pnpm commands GEN_LOCK|UPDATE|ADD then
# generate modules.pnpm.inc which contain DISTFILES and MODPNPM_PKGS
MODPNPM_TARGETS?=	${WRKSRC}
MODPNPM_PACKAGES?=	${MODPNPM_TARGETS}

# XXX INCLUDES/EXCLUDES/FORCE features looks useless for now
MODPNPM_GEN_INCLUDES?= 	# include modules
MODPNPM_GEN_EXCLUDES?= 	# exclude modules
MODPNPM_GEN_FORCE?=	# force all modules even wrong os

# modpnpm-gen-modules configuration
# pnpm overrides, https://pnpm.io/package_json#pnpmoverrides
MODPNPM_GEN_OVERRIDES?=

# modpnpm-gen-modules helpers : empty/no, package@version
# rm lock & pnpm install
MODPNPM_GEN_LOCK?=	No
# pnpm update
MODPNPM_GEN_UPDATE?=	No
# pnpm add
MODPNPM_GEN_ADD?=	No

# ignore optional dependencies during gen-modules & install
MODPNPM_NO_OPTIONAL?=	No
# ignore dev dependencies during gen-modules & install
MODPNPM_NO_DEV?=	No

# remove engines & packageManager requirements from package.json
MODPNPM_GEN_ENGINES?=	Yes

# make show=MODPNPM_MODULES, list of custom modules to handle
MODPNPM_MODS?=

.if ${NO_BUILD:L} == "no"
MODPNPM_BUILDDEP?=	Yes
MODPNPM_BUILD?=		Yes
.else
MODPNPM_BUILDDEP?=	No
MODPNPM_BUILD?=		No
.endif

# by default there is no reason a port need a package manager to run itself
MODPNPM_RUNDEP?=	No

.if ${NO_TEST:L} == "no"
MODPNPM_TESTDEP?=	Yes
MODPNPM_TEST?=		Yes
.else
MODPNPM_TESTDEP?=	No
MODPNPM_TEST?=		No
.endif

MODPNPM_LOCK?=		pnpm-lock.yaml
MODPNPM_PACKAGE?=	package.json
MODPNPM_SETTINGS?=	.pnpmrc
MODPNPM_WORKSPACE?=	pnpm-workspace.yaml
MODPNPM_PATCHORIG?=	.orig.modpnpm

# config files may be extended (ex: to embed sub-folders package.json tweeks)
MODPNPM_CONFIGFILES+=	${MODPNPM_LOCK} \
			${MODPNPM_PACKAGE} \
			${MODPNPM_SETTINGS} \
			${MODPNPM_WORKSPACE}

# module port path : modules redirects with system ports
MODPNPM_MODULES+=\
	7zip-bin archivers/node-7zip-bin \
		7zip-bin/node_modules/7zip-bin \
	app-builder-bin devel/app-builder \
		app-builder-bin/node_modules/app-builder-bin \
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
		tailwindcss/node_modules/@tailwindcss/vite
# module . override : modules redirects without ports
MODPNPM_MODULES+=\
	lightningcss . npm:lightningcss-wasm \
# module module . : modules fallback to add
MODPNPM_MODULES+=\
	@swc/core @swc/wasm . \
	unrs-resolver @unrs/resolver-binding-wasm32-wasi .

# bring in module depends
# XXX BUILD_DEPENDS only ? configurable ?
.for _mod _port _override in ${MODPNPM_MODULES}
.if !empty(MODPNPM_MODS:M${_mod}) && "${_override}" != "." && "${_port}" != "."
BUILD_DEPENDS+=		${_port}
.endif
.endfor

# where package are saved during build
MODPNPM_BUILD_DIST?=	${WRKDIR}/packages

# unpack (tar xzf) then run pnpm install
# XXX keep in sync with other npm-like modules
MODPNPM_INSTALL?=	no
MODPNPM_INSTALL_DIST?=	${LOCALBASE}/node
MODPNPM_INSTALL_DIR?=	node/${MODPNPM_INSTALL}/node_modules

# home needed for pnpm cache (aka store)
PORTHOME?=		${WRKDIR}/vendor
MODPNPM_CACHE?=		vendor/.local/share/pnpm/store

# without modules.pnpm.inc, default vendor filename, see modpnpm-gen-vendor
MODPNPM_VENDOR_REV?=
MODPNPM_VENDOR?=	${PKGNAME}${MODPNPM_VENDOR_REV:%=.%}-vendor.tgz

# env is required and can be extended
MODPNPM_ENV+=		PATH='${PORTPATH}:./node_modules/.bin' \
			TMP=${WRKDIR}/tmp \
			HOME=${PORTHOME}
# specific build & gen env are configurable (ex: replace npm_config_nodedir)
MODPNPM_ENV_BUILD?=	npm_config_nodedir=${LOCALBASE}
MODPNPM_ENV_TEST?=
MODPNPM_ENV_GEN?=

# cmd
# XXX better way to inject CI=true
MODPNPM_BIN?=		pnpm
MODPNPM_CMD?=\
	${SETENV} ${MODPNPM_ENV} CI=true ${MODPNPM_BIN}
MODPNPM_CMD_BUILD?=\
	${SETENV} ${MAKE_ENV} ${MODPNPM_ENV} CI=true ${MODPNPM_ENV_BUILD} \
	    ${MODPNPM_BIN}
MODPNPM_CMD_TEST?=\
	${SETENV} ${MODPNPM_ENV}  CI=true ${MODPNPM_ENV_TEST} ${MODPNPM_BIN}
MODPNPM_CMD_GEN?=\
	${SETENV} ${MODPNPM_ENV} ${MODPNPM_ENV_GEN} ${MODPNPM_BIN}

# common args
MODPNPM_ARGS?=\
	--verbose --loglevel=info
MODPNPM_ARGS_WORKSPACE?=\
	-r --filter '!{.}'
MODPNPM_ARGS_OPTIONAL?=\
	${MODPNPM_NO_OPTIONAL:L:S/no//:S/yes/--no-optional/}
MODPNPM_ARGS_DEV?=\
	${MODPNPM_NO_DEV:L:S/no//:S/yes/--prod/}
# ports args
# XXX fake, --dangerously-allow-all-builds
MODPNPM_ARGS_EXTRACT?=\
	install ${MODPNPM_ARGS} --offline --frozen-lockfile --ignore-scripts \
	    ${MODPNPM_ARGS_OPTIONAL} ${MODPNPM_ARGS_DEV}
MODPNPM_ARGS_REBUILD?=\
	rebuild ${MODPNPM_ARGS}
MODPNPM_ARGS_BUILD?=\
	pack ${MODPNPM_ARGS}
MODPNPM_ARGS_FAKE?=\
	install ${MODPNPM_ARGS} --offline --prod ${MODPNPM_ARGS_OPTIONAL}
MODPNPM_ARGS_TEST?=\
	test --verbose
# maintener args
# XXX add, --save-dev only ?
MODPNPM_ARGS_GEN?=\
	${MODPNPM_ARGS} --lockfile-only --ignore-scripts
MODPNPM_ARGS_INSTALL?=\
	install ${MODPNPM_ARGS_GEN} ${MODPNPM_ARGS_OPTIONAL} ${MODPNPM_ARGS_DEV}
MODPNPM_ARGS_UPDATE?=\
	update ${MODPNPM_ARGS_GEN}
MODPNPM_ARGS_ADD?=\
	add ${MODPNPM_ARGS_GEN} --save-dev
MODPNPM_ARGS_VENDOR?=\
	install ${MODPNPM_ARGS} --frozen-lockfile --ignore-scripts \
	    ${MODPNPM_ARGS_OPTIONAL} ${MODPNPM_ARGS_DEV} \
	    ${MODPNPM_GEN_FORCE:L:S/yes/--force/:S/no//}

# SITES{.pnpm,.github} && EXTRACT_SUFX.github
SITES.pnpm?=		https://registry.npmjs.org/
# XXX few use cases, better way to avoid duplicates ?
.include "${PORTSDIR}/infrastructure/db/dist-tuple.pattern"
EXTRACT_SUFX.github?=	${TEMPLATE_EXTRACT_SUFX}

# see post-extract
EXTRACT_CASES+=		${MODPNPM_DIST}/*) ;;

.if ${MODPNPM_BUILDDEP:L} == "yes"
BUILD_DEPENDS+=		devel/pnpm # depends on lang/node which include npm
.endif
.if ${MODPNPM_RUNDEP:L} == "yes"
RUN_DEPENDS+=		devel/pnpm
.endif
.if ${MODPNPM_TESTDEP:L} == "yes"
TEST_DEPENDS+=		devel/pnpm
.endif

# link to MODPNPM_INSTALL_DIST needed for modules overrides with ports
MODPNPM_post-extract += \
	mkdir -p ${PORTHOME} ; \
	mkdir -p ${WRKDIR}/tmp ; \
	mkdir -p ${MODPNPM_BUILD_DIST} ; \
	ln -fs ${MODPNPM_INSTALL_DIST} ${WRKDIR}/ ;

.if empty(_GEN_MODULES)

MODPNPM_post-extract += \
	for target in ${MODPNPM_PACKAGES} ; do \
		mkdir -p $${target} ; \
		cd $${target} ;
# backup lock files
.for _CONF in ${MODPNPM_CONFIGFILES}
MODPNPM_post-extract += \
		[ -f ${_CONF}${MODPNPM_PATCHORIG} ] || \
			[ -f ${_CONF} ] && \
			cp ${_CONF}{,${MODPNPM_PATCHORIG}} ;
.endfor

MODPNPM_post-extract += \
		cd - >/dev/null ; \
	done ;

# Override locks with those generated by modpnpm-gen-modules
MODPNPM_post-extract += \
	for target in ${MODPNPM_PACKAGES} ; do \
		prefix=$$(echo "$${target\#\#${WRKSRC}}" | tr '/' '_') ; \
		prefix=$${prefix\#\#_} ; \
		prefix=$${prefix%%_} ; \
		echo "MODPNPM: update $${target}" ; \
		cd $${target} ;
.for _CONF in ${MODPNPM_CONFIGFILES}
MODPNPM_post-extract += \
		conf=${_CONF:S/\//_/g} ; \
		if [ -f ${FILESDIR}/modpnpm_$${prefix}_$${conf} ] ; then \
			cp ${FILESDIR}/modpnpm_$${prefix}_$${conf} ${_CONF} ; \
		fi ;
.endfor
MODPNPM_post-extract += \
		cd - >/dev/null ; \
	done ;

.endif # empty(_GEN_MODULES)

.if empty(_GEN_MODULES) && empty(_GEN_VENDOR)

# import distfiles in store for pnpm use offline
MODPNPM_post-extract += \
	rm -f ${WRKDIR}/store.list ; \
	for module in $$(echo "${MODPNPM_PKGS}") ; do \
		id=$${module%;*} ; pkg=$${module\#*;} ; \
		echo "$${id}|${DISTDIR}/${MODPNPM_DIST}/$${pkg}" \
			>> ${WRKDIR}/store.list ; \
	done ; \
	[ -f ${WRKDIR}/store.list ] && \
		echo "MODPNPM: store add ***" && \
		cd ${WRKDIR} && cat store.list | \
		xargs ${MODPNPM_CMD} store add ;

# Install node_modules files only, ignore scripts. Then run pnpm rebuild during
# pre-build, after patch, which allows small customization.
# Note, during fake, node_modules folders are pruned (or reinstalled) for
# production without applying any patches.
# Thus patches for devdepends work but not for rundepends.
# XXX use the npm pattern with bundledependencies ?
MODPNPM_post-extract += \
	for target in ${MODPNPM_TARGETS} ; do \
		echo "MODPNPM: extract $${target}" ; \
		cd $${target} && \
		${MODPNPM_CMD} ${MODPNPM_ARGS_EXTRACT} ; \
		cd - >/dev/null ; \
	done ;

.endif # empty(_GEN_MODULES) && empty(_GEN_VENDOR)

MODPNPM_PREBUILD_TARGET=\
	for target in ${MODPNPM_TARGETS} ; do \
		echo "MODPNPM: rebuild $${target}" ; \
		cd $${target} && \
		${MODPNPM_CMD_BUILD} ${MODPNPM_ARGS_REBUILD} ; \
	done

MODPNPM_BUILD_TARGET=\
	for target in ${MODPNPM_TARGETS} ; do \
		prefix=$$(echo "$${target\#\#${WRKSRC}}" | tr '/' '_') ; \
		prefix=$${prefix\#\#_} ; \
		prefix=$${prefix%%_} ; \
		echo "MODPNPM: pack $${target}" ; \
		mkdir -p ${MODPNPM_BUILD_DIST}/$${prefix} ; \
		if [ -f $${target}/${MODPNPM_WORKSPACE} ] ; then \
			cd $${target} && \
			${MODPNPM_CMD_BUILD} ${MODPNPM_ARGS_WORKSPACE} \
				${MODPNPM_ARGS_BUILD} --out \
				${MODPNPM_BUILD_DIST}/$${prefix}/%s.tgz ; \
		else \
			cd $${target} && \
			${MODPNPM_CMD_BUILD} ${MODPNPM_ARGS_BUILD} --out \
				${MODPNPM_BUILD_DIST}/$${prefix}/%s.tgz ; \
		fi ; \
	done

# XXX workspace install looks fragile, either drop or find more ports to test
# Note about workspace and copy script:
# Depending on structure, install depth may vary and relative links gets broken.
# Copy node_modules(/.pnpm) into fake dir then link .pnpm to the copy.
# Thus allow source with one subdirectory to install at root instead of @x/y.
# All other source structure are not handled by this custom install.
# Relative links to ../node/* may also be broken by workspace relocation depth,
# scan for those links and relocate them at proper depth level.
MODPNPM_INSTALL_TARGET=\
	${INSTALL_DATA_DIR} ${PREFIX}/${MODPNPM_INSTALL_DIR} ; \
	for target in ${MODPNPM_TARGETS} ; do \
		prefix=$$(echo "$${target\#\#${WRKSRC}}" | tr '/' '_') ; \
		prefix=$${prefix\#\#_} ; \
		prefix=$${prefix%%_} ; \
		if [ -f $${target}/${MODPNPM_WORKSPACE} ]; then \
			echo "MODPNPM: prune $${target}" ; \
			cd $${target} ; \
			rm -rf node_modules ; \
			find . -type d -name node_modules -delete ; \
			${MODPNPM_CMD} ${MODPNPM_ARGS_FAKE} \
				--frozen-lockfile ; \
			cp -pRP node_modules \
				${PREFIX}/${MODPNPM_INSTALL_DIR}/ ; \
			ln -fs ./node_modules/.pnpm \
				${PREFIX}/${MODPNPM_INSTALL_DIR}/.pnpm ; \
		fi ; \
		ln -fs ${MODPNPM_INSTALL_DIST} \
			${PREFIX}/${MODPNPM_INSTALL_DIR}/../ ; \
		echo "MODPNPM: unpack & install $${target}" ; \
		for tgz in ${MODPNPM_BUILD_DIST}/$${prefix}/*.tgz ; do \
			cd ${PREFIX}/${MODPNPM_INSTALL_DIR} ; \
			tar -xzf $$tgz ; \
			pkg=$$(cat package/package.json | \
			    grep -m1 name | awk -F\" '{print $$4}') ; \
			echo "MODPNPM: $$tgz -> $${pkg}" ; \
			mkdir -p $$(dirname $${pkg}) && mv package $${pkg} ; \
			if [ -f $${target}/${MODPNPM_WORKSPACE} ] ; then \
				srcdir=$$(cd $${target} && \
					${MODPNPM_CMD} list -r --depth -1 | \
					grep -m1 "$${pkg}@" | \
					awk '{print $$2}') ; \
				echo "MODPNPM: modules from $${srcdir}" ; \
				[ -d $${srcdir}/node_modules ] && \
				cp -pRP $${srcdir}/node_modules $${pkg}/ ; \
			else \
				cd $${pkg} ; \
				sed \
					-e '/^overrides:/,/^\s*$$/d' \
					-e '/^patchedDependencies:/,/^\s*$$/d' \
					$${target}/${MODPNPM_LOCK} > \
					./${MODPNPM_LOCK} && \
				${MODPNPM_CMD} ${MODPNPM_ARGS_FAKE} ; \
			fi ; \
		done ; \
	done ; \
	echo "MODPNPM: find system link" ; \
	find ${PREFIX}/${MODPNPM_INSTALL_DIR} -type l | while read l ; do \
		[ -e "$$l" ] && continue ; \
		t=$$(readlink "$$l") ; \
		case "$$t" in \
			*node/*) ;; \
			*) continue ;; \
		esac ; \
		suffix=$${t\#*node/} ; \
		[ "$$suffix" = "$$t" ] && continue ; \
		anchor=${PREFIX}/${MODPNPM_INSTALL_DIR}/../node/$$suffix ; \
		[ -e "$$anchor" ] || continue ; \
		from=$$(dirname "$$l") ; \
		rel=$$(perl -MFile::Spec -e \
			'print File::Spec->abs2rel($$ARGV[0], $$ARGV[1])' \
			"$$anchor" "$$from") ; \
		echo "MODPNPM: relink $$l -> $$rel" ; \
		ln -snf "$$rel" "$$l" ; \
	done ; \
	echo "MODPNPM: cleanup" ; \
	find -L ${PREFIX}/${MODPNPM_INSTALL_DIR} -type l -exec rm {} \; ; \
	find ${PREFIX}/${MODPNPM_INSTALL_DIR} -type f -and \( \
		-name '*${MODPNPM_PATCHORIG}' \
		-or -name '*${PATCHORIG}' \
		-or -name '*.core' \
		\) -delete ;

MODPNPM_TEST_TARGET=\
	for target in ${MODPNPM_TARGETS} ; do \
		echo "MODPNPM: test $${target}" ; \
		cd $${target} && ${MODPNPM_CMD_TEST} ${MODPNPM_ARGS_TEST} ; \
	done

.if !target(pre-build)
pre-build:
	@${MODPNPM_PREBUILD_TARGET}
.endif

.if !target(do-build) && ${MODPNPM_BUILD:L} == "yes"
do-build:
	@${MODPNPM_BUILD_TARGET}
.endif

.if !target(do-install) && ${MODPNPM_INSTALL:L} != "no"
do-install:
	@${MODPNPM_INSTALL_TARGET}
.endif

.if !target(do-test) && ${MODPNPM_TEST:L} == "yes"
do-test:
	@${MODPNPM_TEST_TARGET}
.endif

.if !target(modpnpm-diff)
modpnpm-diff:
.for _CONF in ${MODPNPM_CONFIGFILES}
	@for target in ${MODPNPM_PACKAGES} ; do \
		cd ${FILESDIR} ; \
		prefix=$$(echo "$${target\#\#${WRKSRC}}" | tr '/' '_') ; \
		prefix=$${prefix\#\#_} ; \
		prefix=$${prefix%%_} ; \
		conf=${_CONF:S/\//_/g} ; \
		if [[ $${target}/${_CONF} == *.json ]] ; then \
			[ -f $${target}/${_CONF}${MODPNPM_PATCHORIG} ] && \
			jq '.' $${target}/${_CONF}${MODPNPM_PATCHORIG} | \
			diff -uN - modpnpm_$${prefix}_$${conf} || true ; \
		else \
			[ -f $${target}/${_CONF}${MODPNPM_PATCHORIG} ] && \
			diff -uN $${target}/${_CONF}${MODPNPM_PATCHORIG} \
				modpnpm_$${prefix}_$${conf} || true ; \
		fi ; \
	done
.endfor
.endif

# OpenBSD use system node, ignore any version requirement
.if ${MODPNPM_GEN_ENGINES:L} != "no"
MODPNPM_gen-configfiles += \
	jq 'del(.engines,.packageManager)' ${MODPNPM_PACKAGE} \
		> tmp.json && mv tmp.json ${MODPNPM_PACKAGE} ;
.endif

# Setup overrides customisation before modpnpm-gen-configfiles (w/patches), ex:
# MODPNPM_GEN_OVERRIDES =	"foo" "npm:foo@x.y.z" "bar" "npm:@cutom/bar"
.for _mod _spec in ${MODPNPM_GEN_OVERRIDES}
_MODPNPM_OVERRIDES:=${_MODPNPM_OVERRIDES:%=%,}${_mod}:${_spec}
.endfor
.if !empty(_MODPNPM_OVERRIDES)
MODPNPM_gen-configfiles += \
	jq '.pnpm.overrides += {${_MODPNPM_OVERRIDES}}' ${MODPNPM_PACKAGE} \
		> tmp.json && mv tmp.json ${MODPNPM_PACKAGE} ;
.endif

# skip generating modules.pnpm.inc, vendor store in $HOME ($WRKDIR/vendor)
_MODPNPM_VENDOR?=	No
# default env for generating configfiles, modules.pnpm.inc or vendor store
_MODPNPM_TMP?=		./modpnpm
_MODPNPM_GEN_VAR?=	BUILD_USER=$$(whoami) WRKOBJDIR=$${t}
_MODPNPM_GEN_DIR?=	$$(realpath `mktemp -d ${_MODPNPM_TMP}.XXXXXXX`)

.if !target(modpnpm-pre-gen-modules)
modpnpm-pre-gen-modules:
.endif

.if !target(modpnpm-post-gen-modules)
modpnpm-post-gen-modules:
.endif

.if !target(_modpnpm-gen-modules)
_modpnpm-gen-modules: modpnpm-pre-gen-modules
# run with custom BUILD_USER & WRKOBJDIR
# scan for modules to override, update or add
	@rm -f ${WRKDIR}/newmods
	@rm -f ${WRKDIR}/missmods
.  for _mod _port _override in ${MODPNPM_MODULES}
	@for target in ${MODPNPM_PACKAGES} ; do \
		[ -f $${target}/${MODPNPM_LOCK} ] && \
		grep -q '\s*${_mod}@' $${target}/${MODPNPM_LOCK} && \
		echo "${MODPNPM_MODS}" | grep -vq "${_mod}" && \
		echo "${MODPNPM_MODS_SKIP}" | grep -vq "${_mod}" && \
		echo "MODPNPM_MODS+=${_mod}" >> ${WRKDIR}/newmods ; \
		true ; \
	done
.  endfor
# scan for missing mods to remove
.for _mod _port _override in ${MODPNPM_MODULES}
.  if !empty(MODPNPM_MODS:M${_mod})
	@found=0 ; \
	for target in ${MODPNPM_PACKAGES} ; do \
		[ -f $${target}/${MODPNPM_LOCK} ] && \
		if grep -q '\s*${_mod}@' $${target}/${MODPNPM_LOCK} ; then \
			found=1 ; \
		fi ; \
	done ; \
	if [ $${found} == 0 ] ; then \
		echo "${MODPNPM_MODS_SKIP}" | grep -vq "${_mod}" && \
		echo "${_mod} not found" >> ${WRKDIR}/missmods ; \
		true ; \
	fi
.  endif
.endfor
# reports mods to (un)activate
.  if empty(MODPNPM_SKIP_GEN_MODS)
	@if [ -f ${WRKDIR}/newmods ] ; then \
		echo "MODPNPM: either add those mods in your Makefile" ; \
		cat ${WRKDIR}/newmods ; \
		echo "MODPNPM: or run again with MODPNPM_SKIP_GEN_MODS=Yes" ; \
		false ; \
	else \
		true ; \
	fi
	@if [ -f ${WRKDIR}/missmods ] ; then \
		echo "MODPNPM: either remove those mods in your Makefile" ; \
		cat ${WRKDIR}/missmods ; \
		echo "MODPNPM: or run again with MODPNPM_SKIP_GEN_MODS=Yes" ; \
		false ; \
	else \
		true ; \
	fi
.  else
	@[ -f ${WRKDIR}/newmods ] && \
		echo "MODPNPM: maybe add those mods in your Makefile" && \
		cat ${WRKDIR}/newmods || \
		true
	@[ -f ${WRKDIR}/missmods ] && \
		echo "MODPNPM: maybe remove those mods in your Makefile" && \
		cat ${WRKDIR}/missmods || \
		true
.  endif
# config fix
	@for target in ${MODPNPM_PACKAGES} ; do \
		echo "MODPNPM: fix config files $${target}" ; \
		cd $${target} ; \
		${MODPNPM_gen-configfiles} \
	done
# mods triggered overrides
.for _mod _port _override in ${MODPNPM_MODULES}
.  if !empty(MODPNPM_MODS:M${_mod}) && "${_override}" != "."
.    if "${_port}" != "."
# Override modules with relative link to ${WRKDIR}/node which is a symlink
# to system ${LOCALBASE}/node.
	@for target in ${MODPNPM_PACKAGES} ; do \
		grep -q '\s*${_mod}@' $${target}/${MODPNPM_LOCK} || continue ; \
		echo "MODPNPM: mod ${_mod} port ${_port} to $${target}" ; \
		cd $${target} ; \
		wrkdir=$$(echo $${target#${WRKDIR}/} | sed 's:[^/]*:..:g') ; \
		override=$$( \
			echo '"${_mod}":"link:__wrkdir__/node/${_override}"' | \
			sed "s:__wrkdir__:$${wrkdir}:g" ) ; \
		jq ".pnpm.overrides += {$${override}}" ${MODPNPM_PACKAGE} \
			> tmp.json && mv tmp.json ${MODPNPM_PACKAGE} ; \
		true ; \
	done
.    else
	@for target in ${MODPNPM_PACKAGES} ; do \
		grep -q '\s*${_mod}@' $${target}/${MODPNPM_LOCK} || continue ; \
		echo "MODPNPM: mod ${_mod} -> ${_override} to $${target}" ; \
		cd $${target} ; \
		override='"${_mod}":"${_override}"' ; \
		jq ".pnpm.overrides += {$${override}}" ${MODPNPM_PACKAGE} \
			> tmp.json && mv tmp.json ${MODPNPM_PACKAGE} ; \
		true ; \
	done
.    endif
.  endif
.endfor
# install
.  if !empty(MODPNPM_GEN_LOCK) && ${MODPNPM_GEN_LOCK:L} != "no"
	@for target in ${MODPNPM_TARGETS} ; do \
		cd $${target} ; \
		echo "MODPNPM: regen ${MODPNPM_LOCK} $${target}" ; \
		rm -f ${MODPNPM_LOCK} ; \
		rm -rf node_modules ; \
	done
.  else
	@for target in ${MODPNPM_TARGETS} ; do \
		cd $${target} ; \
		[ -f ${MODPNPM_LOCK} ] && continue ; \
		echo "MODPNPM: missing ${MODPNPM_LOCK} $${target}" ; \
	done
.  endif
	@for target in ${MODPNPM_TARGETS} ; do \
		cd $${target} ; \
		echo "MODPNPM: install $${target}" ; \
		${MODPNPM_CMD_GEN} ${MODPNPM_ARGS_INSTALL} ; \
	done
# update
.  if !empty(MODPNPM_GEN_UPDATE) && ${MODPNPM_GEN_UPDATE:L} != "no"
	@for target in ${MODPNPM_TARGETS} ; do \
		cd $${target} ; \
		echo "MODPNPM: update ${MODPNPM_GEN_UPDATE} $${target}" ; \
		${MODPNPM_CMD_GEN} ${MODPNPM_ARGS_UPDATE} \
			${MODPNPM_GEN_UPDATE} ; \
	done
.  endif
# add
.  if !empty(MODPNPM_GEN_ADD) && ${MODPNPM_GEN_ADD:L} != "no"
	@for target in ${MODPNPM_TARGETS} ; do \
		cd $${target} ; \
		echo "MODPNPM: add ${MODPNPM_GEN_ADD} $${target}" ; \
		workspace="" ; \
		[ -f ${MODPNPM_WORKSPACE} ] && workspace="--workspace-root" ; \
		${MODPNPM_CMD_GEN} ${MODPNPM_ARGS_ADD} $${workspace} \
			${MODPNPM_GEN_ADD} ; \
	done
.  endif
# mods triggered add
.  for _mod _port _override in ${MODPNPM_MODULES}
.    if !empty(MODPNPM_MODS:M${_mod}) && "${_override}" == "."
	@for target in ${MODPNPM_TARGETS} ; do \
		grep -q '\s*${_mod}@' $${target}/${MODPNPM_LOCK} || continue ; \
		cd $${target} ; \
		echo "MODPNPM: mod ${_mod} add ${_port} to $${target}" ; \
		workspace="" ; \
		[ -f ${MODPNPM_WORKSPACE} ] && workspace="--workspace-root" ; \
		${MODPNPM_CMD_GEN} ${MODPNPM_ARGS_ADD} $${workspace} \
			${_port} ; \
	done
.    endif
.  endfor
# post-gen target
	t=${WRKOBJDIR} ; \
	make -D _GEN_MODULES ${_MODPNPM_GEN_VAR} modpnpm-post-gen-modules
# distfiles
	@[ -f ${.CURDIR}/modules.pnpm.inc ] && \
		mv ${.CURDIR}/modules.pnpm.inc{,.orig} || true
.  if ${_MODPNPM_VENDOR:L} == "no"
	@echo "MODPNPM: generate modules.pnpm.inc" ; \
	locks="" ; for target in ${MODPNPM_TARGETS} ; do \
		[ -f $${target}/${MODPNPM_LOCK} ] && \
		locks="$${locks} $${target}/${MODPNPM_LOCK}" ; \
	done ; \
	echo "" >> ${.CURDIR}/modules.pnpm.inc ; \
	echo "#INCLUDES=${MODPNPM_GEN_INCLUDES}" >> \
		${.CURDIR}/modules.pnpm.inc ; \
	echo "#EXCLUDES=${MODPNPM_GEN_EXCLUDES}" >> \
		${.CURDIR}/modules.pnpm.inc ; \
	echo "#FORCE=${MODPNPM_GEN_FORCE:L}" >> ${.CURDIR}/modules.pnpm.inc ; \
	echo "" >> ${.CURDIR}/modules.pnpm.inc ; \
	${_PERLSCRIPT}/modpnpm-gen-modules \
		${MODPNPM_GEN_INCLUDES:='-i %'} \
		${MODPNPM_GEN_EXCLUDES:='-x %'} \
		${MODPNPM_GEN_FORCE:L:S/yes/-f/:S/no//} \
		$${locks} >> ${.CURDIR}/modules.pnpm.inc && \
	echo "=> ${.CURDIR}/modules.pnpm.inc"
.  endif
# config & lock files
	@mkdir -p ${FILESDIR}
	@echo "MODPNPM: bundle configfiles"
.  for _CONF in ${MODPNPM_CONFIGFILES}
	@cd ${FILESDIR} ; \
	for target in ${MODPNPM_PACKAGES} ; do \
		prefix=$$(echo "$${target##${WRKSRC}}" | tr '/' '_') ; \
		prefix=$${prefix##_} ; \
		prefix=$${prefix%%_} ; \
		conf=${_CONF:S/\//_/g} ; \
		[ -f modpnpm_$${prefix}_$${conf} ] && \
			cp modpnpm_$${prefix}_$${conf}{,.orig} \
			|| true ; \
		[ -f $${target}/${_CONF} ] && \
			cp $${target}/${_CONF} modpnpm_$${prefix}_$${conf} && \
			echo "=> ${FILESDIR}/modpnpm_$${prefix}_$${conf}" \
			|| true ; \
	done
.  endfor
.endif # !target(_modpnpm-gen-modules)

.if !target(modpnpm-gen-modules)
modpnpm-gen-modules:
	@which jq >/dev/null
	@which yq >/dev/null
	@t=${_MODPNPM_GEN_DIR} && \
	echo "MODPNPM: extract in $${t} as $$(whoami)" && \
	make -D _GEN_MODULES ${_MODPNPM_GEN_VAR} extract && \
	echo "MODPNPM: gen-modules in $${t} as $$(whoami)" && \
	make -D _GEN_MODULES ${_MODPNPM_GEN_VAR} _modpnpm-gen-modules && \
	echo "MODPNPM: rm $${t}..." && \
	[ -d "$${t}" ] && rm -rf $${t} && \
	echo "MODPNPM: rm $${t}, done." || (\
	echo "MODPNPM: FAIL, try again with _MODPNPM_GEN_DIR=$${t}" ; \
	false )
.endif

.if !target(_modpnpm-gen-vendor)
_modpnpm-gen-vendor:
# run with custom BUILD_USER & WRKOBJDIR
	@for target in ${MODPNPM_TARGETS}; do \
		echo "MODPNPM: install $${target}" ; \
		cd $${target} && ${MODPNPM_CMD_GEN} ${MODPNPM_ARGS_VENDOR} ; \
		cd - >/dev/null ; \
	done ;
	@cd ${WRKDIR} && \
	tar -Rczf ${.CURDIR}/${MODPNPM_VENDOR} ${MODPNPM_CACHE} && \
	echo "=> ${.CURDIR}/${MODPNPM_VENDOR}"

.endif

# If in trouble, use vendor pre-made store
.if !target(modpnpm-gen-vendor)
modpnpm-gen-vendor:
	@make _MODPNPM_VENDOR=Yes modpnpm-gen-modules
	@t=${_MODPNPM_GEN_DIR} && \
	echo "MODPNPM: extract in $${t} as $$(whoami)" && \
	make -D _GEN_VENDOR ${_MODPNPM_GEN_VAR} extract && \
	echo "MODPNPM: gen-vendor in $${t} as $$(whoami)" && \
	make -D _GEN_VENDOR ${_MODPNPM_GEN_VAR} _modpnpm-gen-vendor && \
	echo "MODPNPM: rm $${t}..." && \
	[ -d "$${t}" ] && rm -rf $${t} && \
	echo "MODPNPM: rm $${t}, done." || (\
	echo "MODPNPM: FAIL, try again with _MODPNPM_GEN_DIR=$${t}" ; \
	false )
.endif
