MODNPM_DIST=	npm_modules

MODNPM_TARGETS?=	${WRKSRC}
MODNPM_LOCKS?=		${MODNPM_TARGETS:=%/package-lock.json}

MODNPM_OMITDEV?=	No # omit dev depends
MODNPM_OMITOPTIONAL?=	No # omit optional depends
MODNPM_INCLUDES?= 	# include modules
MODNPM_EXCLUDES?= 	# exclude modules

.if ${NO_BUILD:L} == "no"
MODNPM_BUILDDEP?=	Yes
.else
MODNPM_BUILDDEP?=	No
.endif

MODNPM_RUNDEP?=		Yes
.if ${NO_TEST:L} == "no"
MODNPM_TESTDEP?=	Yes
.else
MODNPM_TESTDEP?=	No
.endif

MODNPM_BUILD?=		Yes
MODNPM_INSTALL?=	Yes
MODNPM_INSTALL_TARGET?=	${WRKSRC}
MODNPM_INSTALL_DIR?=	lib/node_modules

# to run node-gyp in custom build
MODNPM_NODE_MODULES=${LOCALBASE}/lib/node_modules/npm
MODNPM_GYP_BIN=${MODNPM_NODE_MODULES}/node_modules/node-gyp/bin/node-gyp.js

# to run npm rebuild
MODNPM_CMD?=	${SETENV} ${MAKE_ENV} ${MODNPM_REBUILD_ENV} HOME=${WRKDIR} npm
MODNPM_ARGS?=	--offline --verbose --foreground-scripts

MODNPM_REBUILD_ENV?=	npm_config_nodedir=${LOCALBASE}

SITES.npm?=		https://registry.npmjs.org/

# see post-extract
EXTRACT_CASES+=		${MODNPM_DIST}/*.tgz) ;;

.if ${MODNPM_BUILDDEP:L} == "yes"
BUILD_DEPENDS +=	lang/node
.endif
.if ${MODNPM_RUNDEP:L} == "yes"
RUN_DEPENDS +=		lang/node
.endif
.if ${MODNPM_TESTDEP:L} == "yes"
TEST_DEPENDS +=		lang/node
.endif

# check MODNPM_TREE for actual stuff to install
.if !empty(MODNPM_TREE) && empty(_GEN_MODULES)
# note _dst;_tgz because list is sorted to let shorter _dst path come first
MODNPM_post-extract+= \
	for _module in $$(echo "${MODNPM_TREE}"); do \
		_dst=$${_module%;*} ; _tgz=$${_module\#*;} ; \
		[ -d ${WRKDIR}/$${_dst} ] || mkdir -p ${WRKDIR}/$${_dst} ; \
		tar -xzf ${DISTDIR}/${MODNPM_DIST}/$${_tgz} \
			-s '/^[^\/]*$$//' -s '/[^\/]*\///' \
			-C ${WRKDIR}/$${_dst} ; \
	done ;
.endif

.if !target(do-build) && ${MODNPM_BUILD:L} == "yes"
do-build:
	@for _target in $$(echo "${MODNPM_TARGETS}"); do \
		echo "MODNPM: build $${_target}" ; \
		cd $${_target} && ${MODNPM_CMD} rebuild ${MODNPM_ARGS} ; \
	done
.endif

.if !target(do-install) && ${MODNPM_INSTALL:L} == "yes"
do-install:
# without cache, npm install can't work, hard to workaround
# 1. get rid of dev: bundledDependencies, npm pack --omit=dev, tar -x
# 2. if needed, copy libs .node into fake
# 3. if needed, link bin
	@echo "MODNPM: install ${MODNPM_INSTALL_TARGET}" ; \
	_target=${MODNPM_INSTALL_TARGET} ; \
	_distname=$${_target##*/} ; \
	_module=$${_distname%-*} ; \
	_dist=${PREFIX}/${MODNPM_INSTALL_DIR}/$${_module} ; \
	\
	echo "MODNPM: bundle $${_module} in $${_dist}" ; \
	sed -i '1s/^{$$/{"bundledDependencies":true,/' \
		$${_target}/package.json ; \
	cd $${_target} && ${SETENV} HOME=${WRKDIR} npm pack \
		${MODNPM_OMITOPTIONAL:L:S/yes/--omit=optional/:S/no//} \
		--omit=dev --pack-destination=${WRKDIR} ; \
	${INSTALL_DATA_DIR} $${_dist} ; \
	tar -xzf ${WRKDIR}/$${_distname}.tgz -s '/[^\/]*\///' \
		-C $${_dist} ; \
	\
	cd $${_target} && \
	for _node in $$(find ./ -name '*.node' \
	    -and ! -path '*/build-tmp-napi-v*' \
	    -and ! -path '*/obj.target*' ); do \
		_dir=`dirname $${_node}` ; \
		echo "MODNPM: bundle $${_node}" ; \
		${INSTALL_DATA_DIR} $${_dist}/$${_dir} ; \
		cp -p $${_node} $${_dist}/$${_dir}/ ; \
	done ; \
	\
	for _bin in $$(echo "${MODNPM_BIN}"); do \
		echo "MODNPM: link bin/$${_bin#*;}" ; \
		ln -s ../${MODNPM_INSTALL_DIR}/$${_module}/$${_bin%;*} \
			${PREFIX}/bin/$${_bin#*;} ; \
	done
.endif

.if !target(modnpm-gen-modules)
modnpm-gen-modules:
	# make -D _GEN_MODULES extract
	@make -D _GEN_MODULES extract >/dev/null 2>&1
	# make modnpm-gen-modules > modules.inc
	# MODNPM_OMITDEV=${MODNPM_OMITDEV}
	# MODNPM_OMITOPTIONAL=${MODNPM_OMITOPTIONAL}
	# MODNPM_INCLUDES=${MODNPM_INCLUDES}
	# MODNPM_EXCLUDES=${MODNPM_EXCLUDES}
	@${_PBUILD} ${_PERLSCRIPT}/modnpm-gen-modules \
		${MODNPM_OMITDEV:L:S/yes/-d/:S/no//} \
		${MODNPM_OMITOPTIONAL:L:S/yes/-o/:S/no//} \
		${MODNPM_INCLUDES:='-i %'} \
		${MODNPM_EXCLUDES:='-x %'} \
		${WRKDIR} ${MODNPM_INSTALL_TARGET} ${MODNPM_LOCKS}
.endif
