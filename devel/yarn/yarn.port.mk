MODYARN_DIST=		yarn_modules
MODNPM_DIST?=		npm_modules

MODYARN_CACHE?=		${WRKDIR}/.yarn
MODYARN_TARGETS?=	${WRKSRC}
MODYARN_LOCKS?=		${MODYARN_TARGETS:=%/yarn.lock}

MODYARN_OMITOPTIONAL?=	No # omit optional depends

.if ${NO_BUILD:L} == "no"
MODYARN_BUILDDEP?=	Yes
.else
MODYARN_BUILDDEP?=	No
.endif

SITES.yarn?=		https://registry.yarnpkg.com/
SITES.npm?=		https://registry.npmjs.org/

# see post-extract
EXTRACT_CASES+=		${MODNPM_DIST}/*.tgz) ;;
EXTRACT_CASES+=		${MODYARN_DIST}/*) ;;

.if ${MODYARN_BUILDDEP:L} == "yes"
BUILD_DEPENDS +=	devel/yarn
.endif

# bring module in yarn cache
EXTRACT_YARN=		${MODYARN_DIST}/*|${MODNPM_DIST}/*.tgz) \
	_filename=$$(echo $${archive\#\#*/} | \
		sed -e '/%/s/${EXTRACT_SUFX.github}//' \
		-e '/%/s/.*%//' -e 's/\.-//') ; \
	ln -fs ${FULLDISTDIR}/$$archive ${MODYARN_CACHE}/$$_filename \
	;;

# re-tarball to match Yarn's expectation
# XXX no consummer atm
EXTRACT_GITHUB=		${MODYARN_DIST}/*.git-*) \
	_filename=$$(echo $${archive\#\#*/} | \
		sed -e '/%/s/${EXTRACT_SUFX.github}//' \
		-e '/%/s/.*%//' -e 's/\.-//') ; \
	_module=$$(${TAR} -ztf ${FULLDISTDIR}/$$archive | \
		awk -F/ '{print $$1}' | uniq) ; \
	${GZIP_CMD} -d <${FULLDISTDIR}/$$archive | ${TAR} -xf - -- && \
	${TAR} -cf ${MODYARN_CACHE}/$$_filename -C $$_module ./ && \
	rm -rf $$_module \
	;;

.if empty(_GEN_MODULES)
MODYARN_post-extract += \
	PATH=${PORTPATH}; set -e; cd ${WRKDIR}; \
	[ -d ${MODYARN_CACHE} ] || mkdir -p ${MODYARN_CACHE}; \
	for archive in ${EXTRACT_ONLY}; do \
		case $$archive in \
		${EXTRACT_GITHUB} \
		${EXTRACT_YARN} \
		esac; \
	done ;
MODYARN_post-extract+= \
	if [ -e ${MODYARN_CACHE} ]; then \
		echo 'yarn-offline-mirror "${MODYARN_CACHE}"' >> \
			${WRKDIR}/.yarnrc ; \
		for _target in ${MODYARN_TARGETS}; do \
			cd $$_target && ${SETENV} ${MAKE_ENV} HOME=${WRKDIR} \
			yarn install --frozen-lockfile --offline \
			--ignore-scripts --ignore-engines \
			${MODYARN_OMITOPTIONAL:S/Yes/--ignore-optional/:S/No//}\
			; \
		done ; \
	fi ;
.endif

MODYARN_post-extract += rm -rf ${MODYARN_CACHE} ;

.if !target(modyarn-gen-modules)
modyarn-gen-modules:
	@make -D _GEN_MODULES extract >/dev/null 2>&1
	# make modyarn-gen-modules > modules.inc
	@${_PERLSCRIPT}/modyarn-gen-modules ${MODYARN_LOCKS}
.endif
