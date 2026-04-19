MODYARN_DIST=		npm_modules

# modyarn-gen-modules will configure TARGETS & PACKAGES then bundle CONFIGFILES
# For each PACKAGES folder, apply MODYARN_gen-configfiles and GEN_OVERRIDES
# For each TARGETS folder, apply yarn commands GEN_LOCK|UPDATE|ADD then
# generate modules.yarn.inc which contain DISTFILES
MODYARN_TARGETS?=	${WRKSRC}
MODYARN_PACKAGES?=	${MODYARN_TARGETS}

# XXX not supported and looks useless
#MODYARN_GEN_INCLUDES?=	# include modules
#MODYARN_GEN_EXCLUDES?=	# exclude modules
#MODYARN_GEN_FORCE?=	# force all modules even wrong os

# modyarn-gen-modules configuration
# yarn resolutions:
#https://classic.yarnpkg.com/lang/en/docs/selective-version-resolutions/
#https://github.com/yarnpkg/rfcs/blob/master/implemented/0000-selective-versions-resolutions.md
# XXX keep OVERRIDES naming (instead of RESOLUTIONS), future merge into node
MODYARN_GEN_OVERRIDES?=

# modyarn-gen-modules helpers : empty/no, package@version
# rm lock & yarn install
MODYARN_GEN_LOCK?=	No
# yarn update
MODYARN_GEN_UPDATE?=	No
# yarn add
MODYARN_GEN_ADD?=	No

# ignore optional depends during gen-modules & install
MODYARN_NO_OPTIONAL?=	No
# ignore dev dependencies during gen-modules & install
MODYARN_NO_DEV?=	No

# remove engines & packageManager requirements from package.json
MODYARN_GEN_ENGINES?=	Yes

# make show=MODYARN_MODULES, list of custom modules to handle
MODYARN_MODS?=

.if ${NO_BUILD:L} == "no"
MODYARN_BUILDDEP?=	Yes
MODYARN_BUILD?=		Yes
.else
MODYARN_BUILDDEP?=	No
MODYARN_BUILD?=		No
.endif

# by default there is no reason a port need a package manager to run itself
MODYARN_RUNDEP?=	No

.if ${NO_TEST:L} == "no"
MODYARN_TESTDEP?=	Yes
MODYARN_TEST?=		Yes
.else
MODYARN_TESTDEP?=	No
MODYARN_TEST?=		No
.endif

MODYARN_LOCK?=		yarn.lock
MODYARN_PACKAGE?=	package.json
MODYARN_SETTINGS?=	.yarnrc
MODYARN_PATCHORIG?=	.orig.modyarn

# config files may be extended (ex: to embed sub-folders package.json tweeks)
MODYARN_CONFIGFILES+=	${MODYARN_LOCK} \
			${MODYARN_PACKAGE} \
			${MODYARN_SETTINGS}

# module port path : modules redirects with system ports
MODYARN_MODULES+=\
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
		tailwindcss/node_modules/@tailwindcss/vite
# module . override : modules redirects without ports
MODYARN_MODULES+=\
	lightningcss . npm:lightningcss-wasm \
# module module . : modules fallback to add
MODYARN_MODULES+=\
	@swc/core @swc/wasm . \
	unrs-resolver @unrs/resolver-binding-wasm32-wasi .

# bring in module depends
# XXX BUILD_DEPENDS only ? configurable ?
.for _mod _port _override in ${MODYARN_MODULES}
.if !empty(MODYARN_MODS:M${_mod}) && "${_override}" != "." && "${_port}" != "."
BUILD_DEPENDS+=		${_port}
.endif
.endfor

# where package are saved during build
MODYARN_BUILD_DIST?=	${WRKDIR}/packages

# unpack (tar xzf) then run yarn install
# XXX keep in sync with other npm-like modules
MODYARN_INSTALL?=	no
MODYARN_INSTALL_DIST?=	${LOCALBASE}/node
MODYARN_INSTALL_DIR?=	node/${MODYARN_INSTALL}/node_modules

# home needed for yarn cache
PORTHOME?=		${WRKDIR}/vendor
MODYARN_CACHE?=		vendor/.yarn-cache

# without modules.yarn.inc, default vendor filename, see modyarn-gen-vendor
MODYARN_VENDOR_REV?=
MODYARN_VENDOR?=	${PKGNAME}${MODYARN_VENDOR_REV:%=.%}-vendor.tgz

# env is required and can be extended
MODYARN_ENV+=		PATH='${PORTPATH}:./node_modules/.bin' \
			TMP=${WRKDIR}/tmp \
			HOME=${PORTHOME}
# specific build & gen env are configurable (ex: replace npm_config_nodedir)
MODYARN_ENV_BUILD?=	npm_config_nodedir=${LOCALBASE}
MODYARN_ENV_TEST?=
MODYARN_ENV_GEN?=

# cmd
MODYARN_BIN?=		yarn
MODYARN_CMD?=\
	${SETENV} ${MODYARN_ENV} CI=true ${MODYARN_BIN}
MODYARN_CMD_BUILD?=\
	${SETENV} ${MAKE_ENV} ${MODYARN_ENV} ${MODYARN_ENV_BUILD} ${MODYARN_BIN}
MODYARN_CMD_TEST?=\
	${SETENV} ${MAKE_ENV} ${MODYARN_ENV} ${MODYARN_ENV_TEST} ${MODYARN_BIN}
MODYARN_CMD_GEN?=\
	${SETENV} ${MODYARN_ENV} ${MODYARN_ENV_GEN} ${MODYARN_BIN}

# common args
MODYARN_ARGS?=		--verbose
MODYARN_ARGS_OPTIONAL?=\
	${MODYARN_NO_OPTIONAL:L:S/no//:S/yes/--ignore-optional/}
MODYARN_ARGS_DEV?=\
	${MODYARN_NO_DEV:L:S/no//:S/yes/--production/}
# ports args
MODYARN_ARGS_EXTRACT?=\
	install ${MODYARN_ARGS} --offline --frozen-lockfile --ignore-scripts \
	    ${MODYARN_ARGS_OPTIONAL} ${MODYARN_ARGS_DEV}
MODYARN_ARGS_REBUILD?=\
	install ${MODYARN_ARGS} --offline --rebuild
MODYARN_ARGS_BUILD?=\
	pack ${MODYARN_ARGS} --offline
MODYARN_ARGS_FAKE?=\
	global add ${MODYARN_ARGS} --offline --frozen-lockfile --production \
	    ${MODYARN_ARGS_OPTIONAL} --prefix ${PORTHOME}/.config/yarn/global/
MODYARN_ARGS_TEST?=\
	test ${MODYARN_ARGS}
# maintener args
# XXX MODYARN_ARGS_GEN --lockfile-only ?
# XXX install/update/add : ignore-platform (wasm32) ?
# XXX add : dev only ?
MODYARN_ARGS_GEN?=\
	${MODYARN_ARGS} --ignore-scripts
MODYARN_ARGS_INSTALL?=\
	install ${MODYARN_ARGS_GEN} --ignore-platform \
	    ${MODYARN_ARGS_OPTIONAL} ${MODYARN_ARGS_DEV}
MODYARN_ARGS_UPDATE?=\
	upgrade ${MODYARN_ARGS_GEN} --ignore-platform
MODYARN_ARGS_ADD?=\
	add ${MODYARN_ARGS_GEN} --dev --ignore-platform
MODYARN_ARGS_VENDOR?=\
	install ${MODYARN_ARGS} --frozen-lockfile --ignore-scripts \
	    ${MODYARN_ARGS_OPTIONAL} ${MODYARN_ARGS_DEV} \
	    ${MODYARN_GEN_FORCE:L:S/yes/--force/:S/no//}

# SITES{.yarn,.github} && EXTRACT_SUFX.github
SITES.yarn?=		https://registry.npmjs.org/
# XXX few use cases, better way to avoid duplicates ?
.include "${PORTSDIR}/infrastructure/db/dist-tuple.pattern"
EXTRACT_SUFX.github?=	${TEMPLATE_EXTRACT_SUFX}

# see post-extract
EXTRACT_CASES+=		${MODYARN_DIST}/*) ;;

.if ${MODYARN_BUILDDEP:L} == "yes"
BUILD_DEPENDS+=		devel/yarn # depends on lang/node which include npm
.endif
.if ${MODYARN_RUNDEP:L} == "yes"
RUN_DEPENDS+=		devel/yarn
.endif
.if ${MODYARN_TESTDEP:L} == "yes"
TEST_DEPENDS+=		devel/yarn
.endif

MODYARN_post-extract += \
	mkdir -p ${PORTHOME} ; \
	mkdir -p ${WRKDIR}/tmp ; \
	mkdir -p ${MODYARN_BUILD_DIST} ; \
	ln -fs ${MODYARN_INSTALL_DIST} ${WRKDIR}/ ; \
	echo 'yarn-offline-mirror "${WRKDIR}/${MODYARN_CACHE}"' >> \
		${PORTHOME}/${MODYARN_SETTINGS} ;

.if empty(_GEN_MODULES)

MODYARN_post-extract += \
	for target in ${MODYARN_TARGETS} ; do \
		mkdir -p $${target} ; \
		cd $${target} ;
# backup lock files
.for _CONF in ${MODYARN_CONFIGFILES}
MODYARN_post-extract += \
		[ -f ${_CONF}${MODYARN_PATCHORIG} ] || \
			[ -f ${_CONF} ] && \
			cp ${_CONF}{,${MODYARN_PATCHORIG}} ;
.endfor

MODYARN_post-extract += \
		cd - >/dev/null ; \
	done ;

# Override locks with those generated by modpyarn-gen-modules
MODYARN_post-extract += \
	for target in ${MODYARN_PACKAGES} ; do \
		prefix=$$(echo "$${target\#\#${WRKSRC}}" | tr '/' '_') ; \
		prefix=$${prefix\#\#_} ; \
		prefix=$${prefix%%_} ; \
		echo "MODYARN: update $${target}" ; \
		cd $${target} ;
.for _CONF in ${MODYARN_CONFIGFILES}
MODYARN_post-extract += \
		conf=${_CONF:S/\//_/g} ; \
		if [ -f ${FILESDIR}/modyarn_$${prefix}_$${conf} ] ; then \
			cp ${FILESDIR}/modyarn_$${prefix}_$${conf} ${_CONF} ; \
		fi ;
.endfor
MODYARN_post-extract += \
		cd - >/dev/null ; \
	done ;

.endif # empty(_GEN_MODULES)

.if empty(_GEN_MODULES) && empty(_GEN_VENDOR)

# bring module in yarn cache
MODYARN_EXTRACT_YARN=	${MODYARN_DIST}/*) \
	filename=$$(echo $${archive} | sed -e 's/{.*}//') ; \
	module=$$(echo $${filename} | sed -e 's/.*\///' \
		-e '/%/s/${EXTRACT_SUFX.github}//' \
		-e '/%/s/.*%//' -e 's/\.-//') ; \
	echo "+ $$module" ; \
	ln -fs ${FULLDISTDIR}/$$filename ${WRKDIR}/${MODYARN_CACHE}/$$module \
	;;
# re-tarball to match yarn's expectation
MODYARN_EXTRACT_GITHUB=	${MODYARN_DIST}/*.git-*) \
	filename=$$(echo $${archive} | sed -e 's/{.*}//') ; \
	module=$$(${TAR} -ztf ${FULLDISTDIR}/$$filename | \
		awk -F/ '{print $$1}' | uniq) ; \
	echo "+ $$filename -> $$module" ; \
	${GZIP_CMD} -d <${FULLDISTDIR}/$$filename | ${TAR} -xf - -- && \
	${TAR} -cf ${WRKDIR}/${MODYARN_CACHE}/$$module -C $$module ./ && \
	rm -rf $$module \
	;;

MODYARN_post-extract += \
	PATH=${PORTPATH}; set -e; cd ${WRKDIR}; \
	[ -d ${MODYARN_CACHE} ] || mkdir -p ${MODYARN_CACHE}; \
	echo "MODYARN: cache setup" && \
	for archive in ${DISTFILES.yarn} ; do \
		case $$archive in \
		${MODYARN_EXTRACT_YARN} \
		esac; \
	done ; \
	for archive in ${DISTFILES.github} ; do \
		case $$archive in \
		${MODYARN_EXTRACT_GITHUB} \
		${MODYARN_EXTRACT_YARN} \
		esac; \
	done ;

# Install node_modules files only, ignore scripts. Then run yarn install
# --rebuild during pre-build, after patch, which preserves local patching.
# Note, during fake, node_modules folders are pruned (or reinstalled) for
# production without applying any patches.
# Thus patches for devdepends work but not for rundepends.
# XXX use the npm pattern with bundledependencies ?
MODYARN_post-extract+= \
	for target in ${MODYARN_TARGETS}; do \
		echo "MODYARN: install $${target}" ; \
		cd $${target} && \
		${MODYARN_CMD} ${MODYARN_ARGS_EXTRACT} ; \
		cd - >/dev/null ; \
	done ;

.endif # empty(_GEN_MODULES) && empty(_GEN_VENDOR)

# XXX needed to install global ?
#MODYARN_post-extract += rm -rf ${WRKDIR}${MODYARN_CACHE} ;

MODYARN_PREBUILD_TARGET=\
	for target in ${MODYARN_TARGETS} ; do \
		echo "MODYARN: rebuild $${target}" ; \
		cd $${target} && \
		${MODYARN_CMD_BUILD} ${MODYARN_ARGS_REBUILD} ; \
	done

MODYARN_BUILD_TARGET=\
	for target in ${MODYARN_TARGETS} ; do \
		cd $${target} ; \
		target=$$(cat package.json | grep name | \
			awk -F\" '{print $$4}') ; \
		tgz=$$(echo $$target | tr '/' '-' | tr -d '@') ; \
		echo "MODYARN: pack $${target} in $${tgz}" ; \
		${MODYARN_CMD_BUILD} ${MODYARN_ARGS_BUILD} \
			--filename ${MODYARN_BUILD_DIST}/$${tgz}.tgz ; \
		cd - >/dev/null ; \
	done

MODYARN_INSTALL_TARGET=\
	${INSTALL_DATA_DIR} ${PREFIX}/${MODYARN_INSTALL_DIR} ; \
	for tgz in ${MODYARN_BUILD_DIST}/*.tgz ; do \
		echo "MODYARN: global add $$tgz" ; \
		${MODYARN_CMD} ${MODYARN_ARGS_FAKE} \
		file:$$tgz ; \
	done ; \
	echo "MODYARN: install into ${MODYARN_INSTALL_DIR}" ; \
	cp -Rp ${PORTHOME}/.config/yarn/global/node_modules/* \
		${PREFIX}/${MODYARN_INSTALL_DIR}/ ; \
	echo "MODYARN: cleanup" ; \
	find ${PREFIX}/${MODYARN_INSTALL_DIR} -type f \( \
		-name '*${MODYARN_PATCHORIG}' \
		-or -name '*${PATCHORIG}' \
		-or -name '*.core' \
		\) -exec rm {} \; ;

MODYARN_TEST_TARGET=\
	for target in ${MODYARN_TARGETS} ; do \
		echo "MODYARN: test $${target}" ; \
		cd $${target} && ${MODYARN_CMD_TEST} ${MODYARN_ARGS_TEST} ; \
	done

.if !target(pre-build)
pre-build:
	@${MODYARN_PREBUILD_TARGET}
.endif

.if !target(do-build) && ${MODYARN_BUILD:L} == "yes"
do-build:
	@${MODYARN_BUILD_TARGET}
.endif

.if !target(do-install) && ${MODYARN_INSTALL:L} != "no"
do-install:
	@${MODYARN_INSTALL_TARGET}
.endif

.if !target(do-test) && ${MODYARN_TEST:L} == "yes"
do-test:
	@${MODYARN_TEST_TARGET}
.endif

.if !target(modyarn-diff)
modyarn-diff:
.for _CONF in ${MODYARN_CONFIGFILES}
	@for target in ${MODYARN_TARGETS} ; do \
		cd ${FILESDIR} ; \
		prefix=$$(echo "$${target##${WRKSRC}}" | tr '/' '_') ; \
		prefix=$${prefix##_} ; \
		prefix=$${prefix%%_} ; \
		conf=${_CONF:S/\//_/g} ; \
		if [[ $${target}${_CONF} == *.json ]] ; then \
			[ -f $${target}${_CONF}${MODYARN_PATCHORIG} ] && \
			jq '.' $${target}${_CONF}${MODYARN_PATCHORIG} | \
			diff -uN - modyarn_$${prefix}_$${conf} || true ; \
		else \
			[ -f $${target}${_CONF}${MODYARN_PATCHORIG} ] && \
			diff -uN $${target}${_CONF}${MODYARN_PATCHORIG} \
				modyarn_$${prefix}_$${conf} || true ; \
		fi ; \
	done
.endfor
.endif

# OpenBSD use system node, ignore any version requirement
.if ${MODYARN_GEN_ENGINES:L} != "no"
MODYARN_gen-configfiles += \
	jq 'del(.engines,.packageManager)' ${MODYARN_PACKAGE} \
		> tmp.json && mv tmp.json ${MODYARN_PACKAGE} ;
.endif

# Setup overrides customisation before modyarn-gen-configfiles (w/patches), ex:
# MODYARN_GEN_OVERRIDES =	"foo" "npm:foo@x.y.z" "bar" "npm:@cutom/bar"
.for _mod _spec in ${MODYARN_GEN_OVERRIDES}
_MODYARN_OVERRIDES:=${_MODYARN_OVERRIDES:%=%,}${_mod}:${_spec}
.endfor
.if !empty(_MODYARN_OVERRIDES)
MODYARN_gen-configfiles += \
	jq '.resolutions += {${_MODYARN_OVERRIDES}}' ${MODYARN_PACKAGE} \
		> tmp.json && mv tmp.json ${MODYARN_PACKAGE} ;
.endif

# skip generating modules.yarn.inc, vendor store in $HOME ($WRKDIR/vendor)
_MODYARN_VENDOR?=	No
# default env for generating configfiles, modules.yarn.inc or vendor store
_MODYARN_TMP?=		./modyarn
_MODYARN_GEN_VAR?=	BUILD_USER=$$(whoami) WRKOBJDIR=$${t}
_MODYARN_GEN_DIR?=	$$(realpath `mktemp -d ${_MODYARN_TMP}.XXXXXXX`)

.if !target(modyarn-pre-gen-modules)
modyarn-pre-gen-modules:
.endif

.if !target(_modyarn-gen-modules)
_modyarn-gen-modules: modyarn-pre-gen-modules
# run with custom BUILD_USER & WRKOBJDIR
# scan for modules to override, update or add
	@rm -f ${WRKDIR}/newmods
	@rm -f ${WRKDIR}/missmods
.  for _mod _port _override in ${MODYARN_MODULES}
	@for target in ${MODYARN_PACKAGES} ; do \
		[ -f $${target}/${MODYARN_LOCK} ] && \
		grep -q '\s*${_mod}@' $${target}/${MODYARN_LOCK} && \
		echo "${MODYARN_MODS}" | grep -vq "${_mod}" && \
		echo "${MODYARN_MODS_SKIP}" | grep -vq "${_mod}" && \
		echo "MODYARN_MODS+=${_mod}" >> ${WRKDIR}/newmods ; \
		true ; \
	done
.  endfor
# scan for missing mods to remove
.for _mod _port _override in ${MODYARN_MODULES}
.  if !empty(MODYARN_MODS:M${_mod})
	@found=0 ; \
	for target in ${MODYARN_PACKAGES} ; do \
		[ -f $${target}/${MODYARN_LOCK} ] && \
		if grep -q '\s*${_mod}@' $${target}/${MODYARN_LOCK} ; then \
			found=1 ; \
		fi ; \
	done ; \
	if [ $${found} == 0 ] ; then \
		echo "${MODYARN_MODS_SKIP}" | grep -vq "${_mod}" && \
		echo "${_mod} not found" >> ${WRKDIR}/missmods ; \
		true ; \
	fi
.  endif
.endfor
# reports mods to (un)activate
.  if empty(MODYARN_SKIP_GEN_MODS)
	@if [ -f ${WRKDIR}/newmods ] ; then \
		echo "MODYARN: either add those mods in your Makefile" ; \
		cat ${WRKDIR}/newmods ; \
		echo "MODYARN: or run again with MODYARN_SKIP_GEN_MODS=Yes" ; \
		false ; \
	else \
		true ; \
	fi
	@if [ -f ${WRKDIR}/missmods ] ; then \
		echo "MODYARN: either remove those mods in your Makefile" ; \
		cat ${WRKDIR}/missmods ; \
		echo "MODYARN: or run again with MODYARN_SKIP_GEN_MODS=Yes" ; \
		false ; \
	else \
		true ; \
	fi
.  else
	@[ -f ${WRKDIR}/newmods ] && \
		echo "MODYARN: maybe add those mods in your Makefile" && \
		cat ${WRKDIR}/newmods || \
		true
	@[ -f ${WRKDIR}/missmods ] && \
		echo "MODYARN: maybe remove those mods in your Makefile" && \
		cat ${WRKDIR}/missmods || \
		true
.  endif
# config fix
	@for target in ${MODYARN_PACKAGES} ; do \
		cd $${target} ; \
		echo "MODYARN: fix config files $${target}" ; \
		${MODYARN_gen-configfiles} \
		true ; \
	done
# mods triggered overrides
.for _mod _port _override in ${MODYARN_MODULES}
.  if !empty(MODYARN_MODS:M${_mod}) && "${_override}" != "."
.    if "${_port}" != "."
	@for target in ${MODYARN_PACKAGES} ; do \
		grep -q '\s*${_mod}@' $${target}/${MODYARN_LOCK} || continue ; \
		echo "MODYARN: mod ${_mod} port ${_port} to $${target}" ; \
		cd $${target} ; \
		wrkdir=$$(echo $${target#${WRKDIR}/} | sed 's:[^/]*:..:g') ; \
		override=$$( \
			echo '"${_mod}":"__wrkdir__/node/${_override}"' | \
			sed "s:__wrkdir__:$${wrkdir}:g" ) ; \
		jq ".resolutions += {$${override}}" ${MODYARN_PACKAGE} \
			> tmp.json && mv tmp.json ${MODYARN_PACKAGE} ; \
		true ; \
	done
.    else
	@for target in ${MODYARN_PACKAGES} ; do \
		grep -q '\s*${_mod}@' $${target}/${MODYARN_LOCK} || continue ; \
		echo "MODYARN: mod ${_mod} -> ${_override} to $${target}" ; \
		cd $${target} ; \
		override='"${_mod}":"${_override}"' ; \
		jq ".resolutions += {$${override}}" ${MODYARN_PACKAGE} \
			> tmp.json && mv tmp.json ${MODYARN_PACKAGE} ; \
		true ; \
	done
.    endif
.  endif
.endfor
# install
.  if !empty(MODYARN_GEN_LOCK) && ${MODYARN_GEN_LOCK:L} != "no"
	@for target in ${MODYARN_TARGETS} ; do \
		cd $${target} ; \
		echo "MODYARN: regen ${MODYARN_LOCK} $${target}" ; \
		rm -f ${MODYARN_LOCK} ; \
		rm -rf node_modules ; \
	done
.  else
	@for target in ${MODYARN_TARGETS} ; do \
		cd $${target} ; \
		[ -f ${MODYARN_LOCK} ] && continue ; \
		echo "MODYARN: missing ${MODYARN_LOCK} $${target}" ; \
	done
.  endif
	@for target in ${MODYARN_TARGETS} ; do \
		cd $${target} ; \
		echo "MODYARN: install $${target}" ; \
		${MODYARN_CMD_GEN} ${MODYARN_ARGS_INSTALL} ; \
	done
# update
.  if !empty(MODYARN_GEN_UPDATE) && ${MODYARN_GEN_UPDATE:L} != "no"
	@for target in ${MODYARN_TARGETS} ; do \
		cd $${target} ; \
		echo "MODYARN: update ${MODYARN_GEN_UPDATE} $${target}" ; \
		${MODYARN_CMD_GEN} ${MODYARN_ARGS_UPDATE} \
			${MODYARN_GEN_UPDATE} ; \
	done
.  endif
# add
.  if !empty(MODYARN_GEN_ADD) && ${MODYARN_GEN_ADD:L} != "no"
	@for target in ${MODYARN_TARGETS} ; do \
		cd $${target} ; \
		echo "MODYARN: add ${MODYARN_GEN_ADD} $${target}" ; \
		${MODYARN_CMD_GEN} ${MODYARN_ARGS_ADD} ${MODYARN_GEN_ADD} ; \
	done
.  endif
# mods triggered add
.  for _mod _port _override in ${MODYARN_MODULES}
.    if !empty(MODYARN_MODS:M${_mod}) && "${_override}" == "."
	@for target in ${MODYARN_TARGETS} ; do \
		grep -q '\s*${_mod}@' $${target}/${MODYARN_LOCK} || continue ; \
		cd $${target} ; \
		echo "MODYARN: mod ${_mod} add ${_port} to $${target}" ; \
		if grep -q '"workspaces":' ${MODYARN_PACKAGE} ; then \
			${MODYARN_CMD_GEN} ${MODYARN_ARGS_ADD} -W ${_port} ; \
		else \
			${MODYARN_CMD_GEN} ${MODYARN_ARGS_ADD} ${_port} ; \
		fi ; \
	done
.    endif
.  endfor
# post-gen target
	t=${WRKOBJDIR} ; \
	make -D _GEN_MODULES ${_MODYARN_GEN_VAR} modyarn-post-gen-modules
# distfiles
	@[ -f ${.CURDIR}/modules.yarn.inc ] && \
		mv ${.CURDIR}/modules.yarn.inc{,.orig} || true
.  if ${_MODYARN_VENDOR:L} == "no"
	@echo "MODYARN: generate modules.yarn.inc" ; \
	locks="" ; for target in ${MODYARN_TARGETS} ; do \
		locks="$${locks} $${target}/${MODYARN_LOCK}" ; \
	done ; \
	echo "" >> ${.CURDIR}/modules.yarn.inc ; \
	${_PERLSCRIPT}/modyarn-gen-modules \
		$${locks} >> ${.CURDIR}/modules.yarn.inc && \
	echo "=> ${.CURDIR}/modules.yarn.inc"
.  endif
# config & lock files
	@mkdir -p ${FILESDIR}
	@echo "MODYARN: bundle configfiles"
.  for _CONF in ${MODYARN_CONFIGFILES}
	@cd ${FILESDIR} ; \
	for target in ${MODYARN_PACKAGES} ; do \
		prefix=$$(echo "$${target##${WRKSRC}}" | tr '/' '_') ; \
		prefix=$${prefix##_} ; \
		prefix=$${prefix%%_} ; \
		conf=${_CONF:S/\//_/g} ; \
		[ -f modyarn_$${prefix}_$${conf} ] && \
			cp modyarn_$${prefix}_$${conf}{,.orig} \
			|| true ; \
		[ -f $${target}/${_CONF} ] && \
			cp $${target}/${_CONF} modyarn_$${prefix}_$${conf} && \
			echo "=> ${FILESDIR}/modyarn_$${prefix}_$${conf}" \
			|| true ; \
	done
.  endfor
.endif # !target(_modyarn-gen-modules)

.if !target(modyarn-pre-gen-modules)
modyarn-pre-gen-modules:
.endif

.if !target(modyarn-post-gen-modules)
modyarn-post-gen-modules:
.endif

.if !target(modyarn-gen-modules)
modyarn-gen-modules:modyarn-pre-gen-modules
	@which jq >/dev/null
	@which yq >/dev/null
	@t=${_MODYARN_GEN_DIR} && \
	echo "MODYARN: extract in $${t} as $$(whoami)" && \
	make -D _GEN_MODULES ${_MODYARN_GEN_VAR} extract && \
	echo "MODYARN: gen-modules in $${t} as $$(whoami)" && \
	make -D _GEN_MODULES ${_MODYARN_GEN_VAR} _modyarn-gen-modules && \
	echo "MODYARN: rm $${t}..." && \
	[ -d "$${t}" ] && rm -rf $${t} && \
	echo "MODYARN: rm $${t}, done." || (\
	echo "MODYARN: FAIL, try again with _MODYARN_GEN_DIR=$${t}" ; \
	false )
.endif

.if !target(_modyarn-gen-vendor)
_modyarn-gen-vendor:
# run with custom BUILD_USER & WRKOBJDIR
	@for target in ${MODYARN_TARGETS}; do \
		echo "MODYARN: install $${target}" ; \
		cd $${target} && ${MODYARN_CMD_GEN} ${MODYARN_ARGS_VENDOR} ; \
		cd - >/dev/null ; \
	done ;
	@cd ${WRKDIR} && \
	tar -Rczf ${.CURDIR}/${MODYARN_VENDOR} ${MODYARN_CACHE} && \
	echo "=> ${.CURDIR}/${MODYARN_VENDOR}"

.endif

# If in trouble, use vendor pre-made store
.if !target(modyarn-gen-vendor)
modyarn-gen-vendor:
	@make _MODYARN_VENDOR=Yes modyarn-gen-modules
	@t=${_MODYARN_GEN_DIR} && \
	echo "MODYARN: extract in $${t} as $$(whoami)" && \
	make -D _GEN_VENDOR ${_MODYARN_GEN_VAR} extract && \
	echo "MODYARN: gen-vendor in $${t} as $$(whoami)" && \
	make -D _GEN_VENDOR ${_MODYARN_GEN_VAR} _modyarn-gen-vendor && \
	echo "MODYARN: rm $${t}..." && \
	[ -d "$${t}" ] && rm -rf $${t} && \
	echo "MODYARN: rm $${t}, done." || \
	echo "MODYARN: FAIL, try again with _MODYARN_GEN_DIR=$${t}"
.endif
