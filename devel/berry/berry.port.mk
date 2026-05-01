# XXX some variables are set with ?= but others needs += to ease porting
# audit variables and classify into :
# * 'extendable' : defaults needs to be kept, use +=
# * 'configurable' : fallback when port doesn't specify anything, use ?=
# * 'fixed' : internal variable, use =

MODBERRY_DIST=		npm_modules

# modberry-gen-modules will configure TARGETS & PACKAGES then bundle CONFIGFILES
# For each PACKAGES folder, apply MODBERRY_gen-configfiles and GEN_OVERRIDES
# For each TARGETS folder, apply berry commands GEN_LOCK|UPDATE|ADD then
# generate modules.berry.inc which contain DISTFILES
# XXX using patch: in yarn.lock force us to run berry import for each TARGET
# XXX need more work so for now we consider MODBERRY_TARGETS as a single path
MODBERRY_TARGETS?=	${WRKSRC}
MODBERRY_PACKAGES?=	${MODBERRY_TARGETS}

# XXX not supported and looks useless
#MODBERRY_GEN_INCLUDES?=	# include modules
#MODBERRY_GEN_EXCLUDES?=	# exclude modules
# XXX not needed, modberry blindly load all resolution from lock
#https://yarnpkg.com/configuration/yarnrc#supportedArchitectures
#MODBERRY_GEN_FORCE?=	# force all modules even wrong os

# modberry-gen-modules configuration
# berry resolutions: https://yarnpkg.com/configuration/manifest#resolutions
# XXX keep OVERRIDES naming (instead of RESOLUTIONS), future merge into node
MODBERRY_GEN_OVERRIDES?=

# modberry-gen-modules helpers : empty/no, package@version
# rm lock & berry install
MODBERRY_GEN_LOCK?=	No
# berry update
MODBERRY_GEN_UPDATE?=	No
# berry add
MODBERRY_GEN_ADD?=	No

# ignore optional depends during gen-modules & install
MODBERRY_NO_OPTIONAL?=	No
# ignore dev dependencies during gen-modules & install
MODBERRY_NO_DEV?=	No

# remove engines & packageManager requirements from package.json
MODBERRY_GEN_ENGINES?=	Yes

# make show=MODBERRY_MODULES, list of custom modules to handle
MODBERRY_MODS?=

# how many instance of berry xargs can run during extract
MODBERRY_EXTRACT_JOBS?=	$$(sysctl -n hw.ncpu)

.if ${NO_BUILD:L} == "no"
MODBERRY_BUILDDEP?=	Yes
MODBERRY_BUILD?=	Yes
.else
MODBERRY_BUILDDEP?=	No
MODBERRY_BUILD?=	No
.endif

# by default there is no reason a port need a package manager to run itself
MODBERRY_RUNDEP?=	No

.if ${NO_TEST:L} == "no"
MODBERRY_TESTDEP?=	Yes
MODBERRY_TEST?=		Yes
.else
MODBERRY_TESTDEP?=	No
MODBERRY_TEST?=		No
.endif

MODBERRY_LOCK?=		yarn.lock
MODBERRY_PACKAGE?=	package.json
MODBERRY_SETTINGS?=	.yarnrc.yml
MODBERRY_PATCHORIG?=	.orig.modberry

# config files may be extended (ex: to embed sub-folders package.json tweeks)
MODBERRY_CONFIGFILES+=	${MODBERRY_LOCK} \
			${MODBERRY_PACKAGE} \
			${MODBERRY_SETTINGS}

# module port path : modules redirects with system ports
MODBERRY_MODULES+=\
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
MODBERRY_MODULES+=\
	lightningcss . npm:lightningcss-wasm@latest \
# module module . : modules fallback to add
MODBERRY_MODULES+=\
	@swc/core @swc/wasm . \
	unrs-resolver @unrs/resolver-binding-wasm32-wasi .

# bring in module depends
# XXX BUILD_DEPENDS only ? configurable ?
.for _mod _port _override in ${MODBERRY_MODULES}
.if !empty(MODBERRY_MODS:M${_mod}) && "${_override}" != "." && "${_port}" != "."
BUILD_DEPENDS+=		${_port}
.endif
.endfor

# where package are saved during build
MODBERRY_BUILD_DIST?=	${WRKDIR}/packages

# XXX unpack (tar xzf) then run berry install ?
# XXX keep in sync with other npm-like modules
MODBERRY_INSTALL?=	no
MODBERRY_INSTALL_DIST?=	${LOCALBASE}/node
MODBERRY_INSTALL_DIR?=	node/${MODBERRY_INSTALL}

# home needed for berry cache
PORTHOME?=		${WRKDIR}/vendor
MODBERRY_CACHE?=	vendor/.yarn/berry/cache

# without modules.berry.inc, default vendor filename, see modberry-gen-vendor
MODBERRY_VENDOR_REV?=
MODBERRY_VENDOR?=	${PKGNAME}${MODBERRY_VENDOR_REV:%=.%}-vendor.tgz

# env is required and can be extended
MODBERRY_ENV+=		PATH='${PORTPATH}:./node_modules/.bin' \
			TMP=${WRKDIR}/tmp \
			HOME=${PORTHOME}
# specific env are configurable (ex: replace npm_config_nodedir)
MODBERRY_ENV_EXTRACT?=	YARN_ENABLE_NETWORK=0 YARN_ENABLE_SCRIPTS=false
MODBERRY_ENV_BUILD?=	YARN_ENABLE_NETWORK=0 YARN_ENABLE_INLINE_BUILDS=1 \
			npm_config_nodedir=${LOCALBASE}
MODBERRY_ENV_TEST?=
MODBERRY_ENV_GEN?=	YARN_ENABLE_SCRIPTS=false

# cmd
# XXX better way to inject CI=true
# XXX yarn v1 conflict with new version, use berry instead
MODBERRY_BIN?=		berry
MODBERRY_CMD?=\
	${SETENV} ${MODBERRY_ENV} CI=true ${MODBERRY_BIN}
MODBERRY_CMD_EXTRACT?=\
	${SETENV} ${MODBERRY_ENV} CI=true ${MODBERRY_ENV_EXTRACT} \
	    ${MODBERRY_BIN}
MODBERRY_CMD_BUILD?=\
	${SETENV} ${MAKE_ENV} ${MODBERRY_ENV} CI=true ${MODBERRY_ENV_BUILD} \
	    ${MODBERRY_BIN}
MODBERRY_CMD_TEST?=\
	${SETENV} ${MODBERRY_ENV} CI=true ${MODBERRY_ENV_TEST} ${MODBERRY_BIN}
MODBERRY_CMD_GEN?=\
	${SETENV} ${MODBERRY_ENV} ${MODBERRY_ENV_GEN} ${MODBERRY_BIN}

# common args
MODBERRY_ARGS?=
MODBERRY_ARGS_OPTIONAL?=\
	${MODBERRY_NO_OPTIONAL:L:S/no//:S/yes/--ignore-optional/}
MODBERRY_ARGS_DEV?=\
	${MODBERRY_NO_DEV:L:S/no//:S/yes/--production/}
# ports args
MODBERRY_ARGS_EXTRACT?=\
	install ${MODBERRY_ARGS} --immutable --mode=skip-build \
	    ${MODBERRY_ARGS_OPTIONAL} ${MODBERRY_ARGS_DEV}
MODBERRY_ARGS_REBUILD?=\
	rebuild ${MODBERRY_ARGS}
MODBERRY_ARGS_BUILD?=\
	pack ${MODBERRY_ARGS}
MODBERRY_ARGS_FAKE?= # XXX not yet
MODBERRY_ARGS_TEST?=\
	test ${MODBERRY_ARGS}
# maintener args
# XXX add, --dev only ?
MODBERRY_ARGS_GEN?=\
	${MODBERRY_ARGS} --mode=skip-build
MODBERRY_ARGS_INSTALL?=\
	install ${MODBERRY_ARGS_GEN} --refresh-lockfile \
	    ${MODBERRY_ARGS_OPTIONAL} ${MODBERRY_ARGS_DEV}
MODBERRY_ARGS_UPDATE?=\
	update ${MODBERRY_ARGS_GEN}
MODBERRY_ARGS_ADD?=\
	add ${MODBERRY_ARGS_GEN} --dev
MODBERRY_ARGS_VENDOR?=\
	install ${MODBERRY_ARGS} --immutable \
	    ${MODBERRY_ARGS_OPTIONAL} ${MODBERRY_ARGS_DEV}

# SITES{.berry,.github} && EXTRACT_SUFX.github
SITES.berry?=		https://registry.npmjs.org/
# XXX few use cases, better way to avoid duplicates ?
.include "${PORTSDIR}/infrastructure/db/dist-tuple.pattern"
EXTRACT_SUFX.github?=	${TEMPLATE_EXTRACT_SUFX}

# see post-extract
EXTRACT_CASES+=		${MODBERRY_DIST}/*) ;;

.if ${MODBERRY_BUILDDEP:L} == "yes"
BUILD_DEPENDS+=		devel/berry # depends on lang/node which include npm
.endif
.if ${MODBERRY_RUNDEP:L} == "yes"
RUN_DEPENDS+=		devel/berry
.endif
.if ${MODBERRY_TESTDEP:L} == "yes"
TEST_DEPENDS+=		devel/berry
.endif

MODBERRY_post-extract += \
	mkdir -p ${PORTHOME} ; \
	mkdir -p ${WRKDIR}/tmp ; \
	mkdir -p ${MODBERRY_BUILD_DIST} ; \
	ln -fs ${LOCALBASE}/bin/berry ${WRKDIR}/bin/yarn ; \
	ulimit -Sn `ulimit -Hn` ;

.if empty(_GEN_MODULES)

MODBERRY_post-extract += \
	for target in ${MODBERRY_TARGETS} ; do \
		mkdir -p $${target} ; \
		cd $${target} ;
# backup lock files
.for _CONF in ${MODBERRY_CONFIGFILES}
MODBERRY_post-extract += \
		[ -f ${_CONF}${MODBERRY_PATCHORIG} ] || \
			[ -f ${_CONF} ] && \
			cp ${_CONF}{,${MODBERRY_PATCHORIG}} ;
.endfor

MODBERRY_post-extract += \
		cd - >/dev/null ; \
	done ;

# Override locks with those generated by modpberry-gen-modules
MODBERRY_post-extract += \
	for target in ${MODBERRY_PACKAGES} ; do \
		prefix=$$(echo "$${target\#\#${WRKSRC}}" | tr '/' '_') ; \
		prefix=$${prefix\#\#_} ; \
		prefix=$${prefix%%_} ; \
		echo "MODBERRY: update $${target}" ; \
		cd $${target} ;
.for _CONF in ${MODBERRY_CONFIGFILES}
MODBERRY_post-extract += \
		conf=${_CONF:S/\//_/g} ; \
		if [ -f ${FILESDIR}/modberry_$${prefix}_$${conf} ] ; then \
			cp ${FILESDIR}/modberry_$${prefix}_$${conf} ${_CONF} ; \
		fi ;
.endfor
MODBERRY_post-extract += \
		cd - >/dev/null ; \
	done ;

.endif # empty(_GEN_MODULES)

.if empty(_GEN_MODULES) && empty(_GEN_VENDOR)

# import distfiles in store for pnpm use offline
# XXX multiple MODBERRY_TARGETS will fail hard (I suppose)
# XXX this needs test/review as the actual issue wasn't documented during dev.
MODBERRY_post-extract += \
	rm -f ${WRKDIR}/store.list ; \
	for module in $$(echo "${MODBERRY_PKGS}") ; do \
		pkg=$${module%;*} ; res=$${module\#*;} ; \
		echo "${DISTDIR}/${MODBERRY_DIST}/$${pkg} $${res}" \
			>> ${WRKDIR}/store.list ; \
	done ; \
	[ -f ${WRKDIR}/store.list ] && \
		for target in ${MODBERRY_TARGETS}; do \
			echo "MODBERRY: import ***" && \
			cd $${target} && cat ${WRKDIR}/store.list | \
			xargs -L 1 -P ${MODBERRY_EXTRACT_JOBS} \
				${MODBERRY_CMD} import ; \
			cd - >/dev/null ; \
		done ;

# Install node_modules files only, ignore scripts. Then run berry install
# --force during pre-build, after patch, which allows small customization.
# Note, during fake, node_modules folders are pruned (or reinstalled) for
# production without applying any patches.
# Thus patches for devdepends work but not for rundepends.
MODBERRY_post-extract+= \
	for target in ${MODBERRY_TARGETS}; do \
		echo "MODBERRY: install $${target}" ; \
		cd $${target} && \
		${MODBERRY_CMD_EXTRACT} ${MODBERRY_ARGS_EXTRACT} ; \
		cd - >/dev/null ; \
	done ;

.endif # empty(_GEN_MODULES) && empty(_GEN_VENDOR)

MODBERRY_PREBUILD_TARGET=\
	for target in ${MODBERRY_TARGETS} ; do \
		echo "MODBERRY: rebuild $${target}" ; \
		cd $${target} && \
		${MODBERRY_CMD_BUILD} ${MODBERRY_ARGS_REBUILD} ; \
	done

# XXX berry should ignore workspaces root by default but it miss simple option
# XXX --no-private hard coded, btw opposite of npm (--include-workspace-root)
# XXX workspaces foreach -R -A --no-private ?
MODBERRY_BUILD_TARGET=\
	for target in ${MODBERRY_TARGETS} ; do \
		cd $${target} ; \
		target=$$(cat package.json | grep name | \
			awk -F\" '{print $$4}') ; \
		tgz=$$(echo $$target | tr '/' '-' | tr -d '@') ; \
		if ! grep -q '"workspaces"' ${MODBERRY_PACKAGE} ; then \
			echo "MODBERRY: pack $${target} in $${tgz}" ; \
			${MODBERRY_CMD_BUILD} ${MODBERRY_ARGS_BUILD} \
			--filename ${MODBERRY_BUILD_DIST}/$${tgz}.tgz ; \
			continue ; \
		fi ; \
		echo "MODBERRY: pack $${target} in workspace" ; \
		mkdir -p ${MODBERRY_BUILD_DIST}/$${prefix} ; \
		${MODBERRY_CMD_BUILD} workspaces foreach -R -A --no-private \
			${MODBERRY_ARGS_BUILD} \
			--out "${MODBERRY_BUILD_DIST}/$${prefix}/%s-%v.tgz" ; \
	done

# XXX not yet
MODBERRY_INSTALL_TARGET=\
	${INSTALL_DATA_DIR} ${PREFIX}/${MODBERRY_INSTALL_DIR} ; \
	echo "MODBERRY: cleanup" ; \
	find ${PREFIX}/${MODBERRY_INSTALL_DIR} -type f \( \
		-name '*${MODBERRY_PATCHORIG}' \
		-or -name '*${PATCHORIG}' \
		-or -name '*.core' \
		\) -exec rm {} \; ;

MODBERRY_TEST_TARGET=\
	for target in ${MODBERRY_TARGETS} ; do \
		echo "MODBERRY: test $${target}" ; \
		cd $${target} && ${MODBERRY_CMD_TEST} ${MODBERRY_ARGS_TEST} ; \
	done

.if !target(pre-build)
pre-build:
	${MODBERRY_PREBUILD_TARGET}
.endif

.if !target(do-build) && ${MODBERRY_BUILD:L} == "yes"
do-build:
	${MODBERRY_BUILD_TARGET}
.endif

.if !target(do-install) && ${MODBERRY_INSTALL:L} != "no"
do-install:
	${MODBERRY_INSTALL_TARGET}
.endif

.if !target(do-test) && ${MODBERRY_TEST:L} == "yes"
do-test:
	${MODBERRY_TEST_TARGET}
.endif

.if !target(modberry-diff)
modberry-diff:
.for _CONF in ${MODBERRY_CONFIGFILES}
	@for target in ${MODBERRY_TARGETS} ; do \
		cd ${FILESDIR} ; \
		prefix=$$(echo "$${target##"${WRKSRC}/"}" | tr '/' '_') ; \
		prefix=$${prefix##_} ; \
		prefix=$${prefix%%_} ; \
		conf=${_CONF:S/\//_/g} ; \
		if [[ $${target}${_CONF} == *.json ]] ; then \
			[ -f $${target}${_CONF}${MODBERRY_PATCHORIG} ] && \
			jq '.' $${target}${_CONF}${MODBERRY_PATCHORIG} | \
			diff -uN - modberry_$${prefix}_$${conf} || true ; \
		else \
			[ -f $${target}${_CONF}${MODBERRY_PATCHORIG} ] && \
			diff -uN $${target}${_CONF}${MODBERRY_PATCHORIG} \
				modberry_$${prefix}_$${conf} || true ; \
		fi ; \
	done
.endfor
.endif

# OpenBSD use system node, ignore any version requirement
.if ${MODBERRY_GEN_ENGINES:L} != "no"
MODBERRY_gen-configfiles += \
	jq 'del(.engines,.packageManager)' ${MODBERRY_PACKAGE} \
		> tmp.json && mv tmp.json ${MODBERRY_PACKAGE} ;
.endif

# OpenBSD use system berry, ignore yarnPath
MODBERRY_gen-configfiles += \
	yq --yaml-output 'del(.yarnPath)' ${MODBERRY_SETTINGS} \
		> tmp.yml && mv tmp.yml ${MODBERRY_SETTINGS} ;

# Setup overrides customisation before modberry-gen-configfiles (w/patches), ex:
# MODBERRY_GEN_OVERRIDES =	foo npm:foo@x.y.z bar npm:@cutom/bar
.for _mod _spec in ${MODBERRY_GEN_OVERRIDES}
_MODBERRY_OVERRIDES:=${_MODBERRY_OVERRIDES:%=%,}"${_mod}":"${_spec}"
.endfor
.if !empty(_MODBERRY_OVERRIDES)
MODBERRY_gen-configfiles += \
	jq '.resolutions += {${_MODBERRY_OVERRIDES}}' ${MODBERRY_PACKAGE} \
		> tmp.json && mv tmp.json ${MODBERRY_PACKAGE} ;
.endif

# skip generating modules.berry.inc, vendor store in $HOME ($WRKDIR/vendor)
_MODBERRY_VENDOR?=	No
# default env for generating configfiles, modules.berry.inc or vendor store
_MODBERRY_TMP?=		./modberry
_MODBERRY_GEN_VAR?=	BUILD_USER=$$(whoami) WRKOBJDIR=$${t}
_MODBERRY_GEN_DIR?=	$$(realpath `mktemp -d ${_MODBERRY_TMP}.XXXXXXX`)

.if !target(modberry-pre-gen-modules)
modberry-pre-gen-modules:
.endif

.if !target(modberry-post-gen-modules)
modberry-post-gen-modules:
.endif

.if !target(_modberry-gen-modules)
_modberry-gen-modules: modberry-pre-gen-modules
# run with custom BUILD_USER & WRKOBJDIR
# scan for modules to override, update or add
	@rm -f ${WRKDIR}/newmods
	@rm -f ${WRKDIR}/missmods
.  for _mod _port _override in ${MODBERRY_MODULES}
	@for target in ${MODBERRY_PACKAGES} ; do \
		[ -f $${target}/${MODBERRY_LOCK} ] && \
		grep -q '\s*${_mod}@' $${target}/${MODBERRY_LOCK} && \
		echo "${MODBERRY_MODS}" | grep -vq "${_mod}" && \
		echo "${MODBERRY_MODS_SKIP}" | grep -vq "${_mod}" && \
		echo "MODBERRY_MODS+=${_mod}" >> ${WRKDIR}/newmods ; \
		true ; \
	done
.  endfor
# scan for missing mods to remove
.for _mod _port _override in ${MODBERRY_MODULES}
.  if !empty(MODBERRY_MODS:M${_mod})
	@found=0 ; \
	for target in ${MODBERRY_PACKAGES} ; do \
		[ -f $${target}/${MODBERRY_LOCK} ] && \
		if grep -q '\s*${_mod}@' $${target}/${MODBERRY_LOCK} ; then \
			found=1 ; \
		fi ; \
	done ; \
	if [ $${found} == 0 ] ; then \
		echo "${MODBERRY_MODS_SKIP}" | grep -vq "${_mod}" && \
		echo "${_mod} not found" >> ${WRKDIR}/missmods ; \
		true ; \
	fi
.  endif
.endfor
# reports mods to (un)activate
.  if empty(MODBERRY_SKIP_GEN_MODS)
	@if [ -f ${WRKDIR}/newmods ] ; then \
		echo "MODBERRY: either add those mods in your Makefile" ; \
		cat ${WRKDIR}/newmods ; \
		echo "MODBERRY: or run again with MODBERRY_SKIP_GEN_MODS=Yes" ;\
		false ; \
	else \
		true ; \
	fi
	@if [ -f ${WRKDIR}/missmods ] ; then \
		echo "MODBERRY: either remove those mods in your Makefile" ; \
		cat ${WRKDIR}/missmods ; \
		echo "MODBERRY: or run again with MODBERRY_SKIP_GEN_MODS=Yes" ;\
		false ; \
	else \
		true ; \
	fi
.  else
	@[ -f ${WRKDIR}/newmods ] && \
		echo "MODBERRY: maybe add those mods in your Makefile" && \
		cat ${WRKDIR}/newmods || \
		true
	@[ -f ${WRKDIR}/missmods ] && \
		echo "MODBERRY: maybe remove those mods in your Makefile" && \
		cat ${WRKDIR}/missmods || \
		true
.  endif
# config fix
	@for target in ${MODBERRY_PACKAGES} ; do \
		cd $${target} ; \
		echo "MODBERRY: fix config files $${target}" ; \
		${MODBERRY_gen-configfiles} \
		true ; \
	done
# mods triggered overrides
.for _mod _port _override in ${MODBERRY_MODULES}
.  if !empty(MODBERRY_MODS:M${_mod}) && "${_override}" != "."
.    if "${_port}" != "."
	@for target in ${MODBERRY_PACKAGES} ; do \
		grep -q '\s*${_mod}@' $${target}/${MODBERRY_LOCK} || continue ;\
		echo "MODBERRY: mod ${_mod} port ${_port} to $${target}" ; \
		cd $${target} ; \
		override='"${_mod}":"${MODBERRY_INSTALL_DIST}/${_override}"' ; \
		jq ".resolutions += {$${override}}" ${MODBERRY_PACKAGE} \
			> tmp.json && mv tmp.json ${MODBERRY_PACKAGE} ; \
		true ; \
	done
.    else
	@for target in ${MODBERRY_PACKAGES} ; do \
		grep -q '\s*${_mod}@' $${target}/${MODBERRY_LOCK} || continue ;\
		echo "MODBERRY: mod ${_mod} -> ${_override} to $${target}" ; \
		cd $${target} ; \
		override='"${_mod}":"${_override}"' ; \
		jq ".resolutions += {$${override}}" ${MODBERRY_PACKAGE} \
			> tmp.json && mv tmp.json ${MODBERRY_PACKAGE} ; \
		true ; \
	done
.    endif
.  endif
.endfor
# install
.  if !empty(MODBERRY_GEN_LOCK) && ${MODBERRY_GEN_LOCK:L} != "no"
	@for target in ${MODBERRY_TARGETS} ; do \
		cd $${target} ; \
		echo "MODBERRY: regen ${MODBERRY_LOCK} $${target}" ; \
		rm -f ${MODBERRY_LOCK} ; \
		rm -rf node_modules ; \
	done
.  else
	@for target in ${MODBERRY_TARGETS} ; do \
		cd $${target} ; \
		[ -f ${MODBERRY_LOCK} ] && continue ; \
		echo "MODBERRY: missing ${MODBERRY_LOCK} $${target}" ; \
	done
.  endif
	@for target in ${MODBERRY_TARGETS} ; do \
		cd $${target} ; \
		echo "MODBERRY: install $${target}" ; \
		${MODBERRY_CMD_GEN} ${MODBERRY_ARGS_INSTALL} ; \
	done
# update
.  if !empty(MODBERRY_GEN_UPDATE) && ${MODBERRY_GEN_UPDATE:L} != "no"
	@for target in ${MODBERRY_TARGETS} ; do \
		cd $${target} ; \
		echo "MODBERRY: update ${MODBERRY_GEN_UPDATE} $${target}" ; \
		${MODBERRY_CMD_GEN} ${MODBERRY_ARGS_UPDATE} \
			${MODBERRY_GEN_UPDATE} ; \
	done
.  endif
# add
.  if !empty(MODBERRY_GEN_ADD) && ${MODBERRY_GEN_ADD:L} != "no"
	@for target in ${MODBERRY_TARGETS} ; do \
		cd $${target} ; \
		echo "MODBERRY: add ${MODBERRY_GEN_ADD} $${target}" ; \
		${MODBERRY_CMD_GEN} ${MODBERRY_ARGS_ADD} ${MODBERRY_GEN_ADD} ; \
	done
.  endif
# mods triggered add
.  for _mod _port _override in ${MODBERRY_MODULES}
.    if !empty(MODBERRY_MODS:M${_mod}) && "${_override}" == "."
	@for target in ${MODBERRY_TARGETS} ; do \
		grep -q '\s*${_mod}@' $${target}/${MODBERRY_LOCK} || continue ;\
		cd $${target} ; \
		echo "MODBERRY: mod ${_mod} add ${_port} to $${target}" ; \
		${MODBERRY_CMD_GEN} ${MODBERRY_ARGS_ADD} ${_port} ; \
	done
.    endif
.  endfor
# post-gen target
	t=${WRKOBJDIR} ; \
	make -D _GEN_MODULES ${_MODBERRY_GEN_VAR} modberry-post-gen-modules
# distfiles
	@[ -f ${.CURDIR}/modules.berry.inc ] && \
		mv ${.CURDIR}/modules.berry.inc{,.orig} || true
.  if ${_MODBERRY_VENDOR:L} == "no"
	@echo "MODBERRY: generate modules.berry.inc" ; \
	locks="" ; for target in ${MODBERRY_TARGETS} ; do \
		locks="$${locks} $${target}/${MODBERRY_LOCK}" ; \
	done ; \
	echo "" >> ${.CURDIR}/modules.berry.inc ; \
	${_PERLSCRIPT}/modberry-gen-modules \
		$${locks} >> ${.CURDIR}/modules.berry.inc && \
	echo "=> ${.CURDIR}/modules.berry.inc"
.  endif
# config & lock files
	@mkdir -p ${FILESDIR}
	@echo "MODBERRY: bundle configfiles"
.  for _CONF in ${MODBERRY_CONFIGFILES}
	@cd ${FILESDIR} ; \
	for target in ${MODBERRY_PACKAGES} ; do \
		prefix=$$(echo "$${target##${WRKSRC}}" | tr '/' '_') ; \
		prefix=$${prefix##_} ; \
		prefix=$${prefix%%_} ; \
		conf=${_CONF:S/\//_/g} ; \
		if [ -f modberry_$${prefix}_$${conf} ] ; then \
			cp modberry_$${prefix}_$${conf}{,.orig} ; \
		fi ; \
		if [ -f $${target}/${_CONF} ] ; then \
			cp $${target}/${_CONF} \
				modberry_$${prefix}_$${conf} && \
			echo "=> ${FILESDIR}/modberry_$${prefix}_$${conf}" ; \
		fi ; \
	done
.  endfor
.endif # !target(_modberry-gen-modules)

.if !target(modberry-gen-modules)
modberry-gen-modules:
	@which jq >/dev/null
	@which yq >/dev/null
	@t=${_MODBERRY_GEN_DIR} && \
	echo "MODBERRY: extract in $${t} as $$(whoami)" && \
	make -D _GEN_MODULES ${_MODBERRY_GEN_VAR} extract && \
	echo "MODBERRY: gen-modules in $${t} as $$(whoami)" && \
	make -D _GEN_MODULES ${_MODBERRY_GEN_VAR} _modberry-gen-modules && \
	echo "MODBERRY: rm $${t}..." && \
	[ -d "$${t}" ] && rm -rf $${t} && \
	echo "MODBERRY: rm $${t}, done." || (\
	echo "MODBERRY: FAIL, try again with _MODBERRY_GEN_DIR=$${t}" ; \
	false )
.endif

.if !target(_modberry-gen-vendor)
_modberry-gen-vendor:
# run with custom BUILD_USER & WRKOBJDIR
	@for target in ${MODBERRY_TARGETS}; do \
		echo "MODBERRY: install $${target}" ; \
		cd $${target} && ${MODBERRY_CMD_GEN} ${MODBERRY_ARGS_VENDOR} ; \
		cd - >/dev/null ; \
	done ;
	@cd ${WRKDIR} && \
	tar -Rczf ${.CURDIR}/${MODBERRY_VENDOR} ${MODBERRY_CACHE} && \
	echo "=> ${.CURDIR}/${MODBERRY_VENDOR}"

.endif

# If in trouble, use vendor pre-made store
.if !target(modberry-gen-vendor)
modberry-gen-vendor:
	@make _MODBERRY_VENDOR=Yes modberry-gen-modules
	@t=${_MODBERRY_GEN_DIR} && \
	echo "MODBERRY: extract in $${t} as $$(whoami)" && \
	make -D _GEN_VENDOR ${_MODBERRY_GEN_VAR} extract && \
	echo "MODBERRY: gen-vendor in $${t} as $$(whoami)" && \
	make -D _GEN_VENDOR ${_MODBERRY_GEN_VAR} _modberry-gen-vendor && \
	echo "MODBERRY: rm $${t}..." && \
	[ -d "$${t}" ] && rm -rf $${t} && \
	echo "MODBERRY: rm $${t}, done." || \
	echo "MODBERRY: FAIL, try again with _MODBERRY_GEN_DIR=$${t}"
.endif