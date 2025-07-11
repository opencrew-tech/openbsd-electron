# sync with Makefile
ELECTRON_V=		35.7.0

ELECTRON_DIST_APPS=	electron/resources
ELECTRON_WRAPPER=	electron/${ELECTRON_V}/electron.sh
ELECTRON_NOSANDBOX=	electron/${ELECTRON_V}/electron_nosandbox.sh

# rebuild/update depends if version changed
ELECTRON_REV=		${ELECTRON_V:S/.//g}
.if !empty(REVISION)
REV:=			${REVISION}
.endif
REVISION=		${ELECTRON_REV}${REV}

# XXX target based on pkgname ?
# target application's name
MODELECTRON_TARGET?=
MODELECTRON_DIST_T=	${ELECTRON_DIST_APPS}/${MODELECTRON_TARGET}

# custom env, specific to OpenBSD
# APP_NAME required to pre-create, unveil ~/.config and ~/.cache
# UNVEIL required for application defined rules
MODELECTRON_APP_NAME?=	${MODELECTRON_TARGET}
MODELECTRON_UNVEIL?=	No
.if ${MODELECTRON_UNVEIL:L} == "yes"
MODELECTRON_UNVEIL_FILE?=${SYSCONFDIR}/electron/unveil.${MODELECTRON_TARGET}
.else
MODELECTRON_UNVEIL_FILE?=
.endif

MODELECTRON_BUILDER?=	No
# directory to build/install with electron-builder
MODELECTRON_SRC?=	${WRKSRC}
MODELECTRON_BUILDER_DIR?=${MODELECTRON_SRC}/dist/linux-unpacked/resources

MODELECTRON_WRAPPER?=	No
# setup common wrapper during build
MODELECTRON_WRAPPER_APP?=${MODELECTRON_TARGET}
MODELECTRON_WRAPPER_ENV?=
MODELECTRON_WRAPPER_ARG?=

.if ${NO_BUILD:L} == "no"
MODELECTRON_BUILDDEP ?=	Yes
.else
MODELECTRON_BUILDDEP ?=	No
.endif
MODELECTRON_RUNDEP ?=	Yes
.if ${NO_TEST:L} == "no"
MODELECTRON_TESTDEP ?=	Yes
.else
MODELECTRON_TESTDEP ?=	No
.endif

MODELECTRON_BUILD?=	Yes
MODELECTRON_INSTALL?=	Yes

SUBST_VARS+=		ELECTRON_DIST_APPS \
			ELECTRON_V \
			ELECTRON_WRAPPER \
			MODELECTRON_APP_NAME \
			MODELECTRON_DIST_T \
			MODELECTRON_TARGET \
			MODELECTRON_UNVEIL_FILE \
			MODELECTRON_WRAPPER_ARG \
			MODELECTRON_WRAPPER_ENV

.if ${MODELECTRON_BUILDDEP:L} == "yes"
BUILD_DEPENDS +=	www/electron
.  if ${MODELECTRON_BUILDER:L} == "yes"
BUILD_DEPENDS +=	devel/app-builder
.  endif
.endif
.if ${MODELECTRON_RUNDEP:L} == "yes"
RUN_DEPENDS +=		www/electron
.endif
.if ${MODELECTRON_TESTDEP:L} == "yes"
TEST_DEPENDS +=		www/electron
.endif

PORTHOME=		${WRKDIR}
MAKE_ENV+=		USE_SYSTEM_APP_BUILDER=true
MAKE_ENV+=		ELECTRON_SKIP_BINARY_DOWNLOAD=1
TEST_ENV+=		HOME=${PORTHOME}

ELECTRON_ARCH=		${ARCH:S/aarch64/arm64/:S/amd64/x64/:S/i386/ia32/}
# XXX better place for NODE_ARCH
NODE_ARCH=		${ARCH:S/aarch64/arm64/:S/amd64/x64/}

ELECTRON_URL=${SITES.github}electron/electron/releases/download/v${ELECTRON_V}
ELECTRON_URL_HASH=	$$(sha256 -q -s "${ELECTRON_URL}")
ELECTRON_RELEASES=	${LOCALBASE}/electron/${ELECTRON_V}/releases
ELECTRON_NODE_DIR=	${LOCALBASE}/electron/${ELECTRON_V}/node_headers
ELECTRON_REBUILD_ENV=	npm_config_runtime=electron \
			npm_config_target=${ELECTRON_V} \
			npm_config_nodedir=${ELECTRON_NODE_DIR}

MODELECTRON_UNVEIL_INSTALL=\
	${INSTALL_DATA_DIR} ${PREFIX}/share/examples/electron && \
	${INSTALL_DATA} ${FILESDIR}/unveil.${MODELECTRON_TARGET} \
		${PREFIX}/share/examples/electron

# XXX NODE_ENV='production' useless ?
MODELECTRON_BUILDER_BUILD=\
	mkdir -p ${WRKDIR}/electron && \
		ln -fs ${LOCALBASE}/electron/${ELECTRON_V}/electron \
			${WRKDIR}/electron/electron ; \
	cd ${MODELECTRON_SRC} && ${SETENV} ${MAKE_ENV} \
		NODE_ENV='production' \
		./node_modules/electron-builder/cli.js \
		--linux --dir --config.npmRebuild=false \
		--config.electronVersion=${ELECTRON_V} \
		--config.electronDist=${WRKDIR}/electron

MODELECTRON_BUILDER_INSTALL=\
	[ -d ${MODELECTRON_BUILDER_DIR}/app.asar.unpacked ] && \
	${INSTALL_DATA_DIR} ${PREFIX}/${MODELECTRON_DIST_T}.asar.unpacked && \
	cp -Rp ${MODELECTRON_BUILDER_DIR}/app.asar.unpacked/* \
		${PREFIX}/${MODELECTRON_DIST_T}.asar.unpacked ; \
	${INSTALL_DATA_DIR} ${PREFIX}/${ELECTRON_DIST_APPS} && \
	${INSTALL_DATA} ${MODELECTRON_BUILDER_DIR}/app.asar \
		${PREFIX}/${MODELECTRON_DIST_T}.asar
# XXX how/which app use this file ?
#	${INSTALL_DATA} ${BUILDDIR}/app-update.yml \
#		${PREFIX}/${MODELECTRON_DIST_T}-update.yml

ELECTRON_WRAPPER_SCRIPT=\
\#!/bin/sh \n\
${MODELECTRON_WRAPPER_ENV} \
ELECTRON_FORCE_IS_PACKAGED=1 \
ELECTRON_APP_NAME="${MODELECTRON_APP_NAME}" \
ELECTRON_UNVEIL="${MODELECTRON_UNVEIL_FILE}" \
exec ${TRUEPREFIX}/${ELECTRON_WRAPPER} \
${MODELECTRON_WRAPPER_ARG} \
--app="${TRUEPREFIX}/${MODELECTRON_DIST_T}.asar" \
$$@ \n

MODELECTRON_WRAPPER_INSTALL=\
	echo '${ELECTRON_WRAPPER_SCRIPT}' \
		> ${PREFIX}/bin/${MODELECTRON_TARGET} && \
		chmod +x ${PREFIX}/bin/${MODELECTRON_TARGET}

.if !target(do-build) && ${MODELECTRON_BUILD:L} == "yes"
do-build:
.  if ${MODELECTRON_BUILDER:L} == "yes"
	# electron-builder
	${MODELECTRON_BUILDER_BUILD}
.  endif
.endif

.if !target(do-install) && ${MODELECTRON_INSTALL:L} == "yes"
do-install:
.  if ${MODELECTRON_UNVEIL:L} == "yes"
	# unveil
	${MODELECTRON_UNVEIL_INSTALL}
.  endif
.  if ${MODELECTRON_BUILDER:L} == "yes"
	# electron-builder
	${MODELECTRON_BUILDER_INSTALL}
.  endif
.  if ${MODELECTRON_WRAPPER:L} == "yes"
	# wrapper
	${MODELECTRON_WRAPPER_INSTALL}
.  endif
.endif
