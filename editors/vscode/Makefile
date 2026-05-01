# XXX security/heimdal patches, kerberos test ?
# XXX ONLY_FOR_ARCHS, too restrictive ?
ONLY_FOR_ARCHS=		amd64

# XXX portroach should check commit id date for tags ordering ?
PORTROACH =		skipv:1.999.0

COMMENT=		Visual Studio Code - Open Source ("Code - OSS")

V=			1.117.0
COMMIT=			10c8e557c8b9f9ed0a87f61f1c9a44bde731c409
PKGNAME=		vscode-${V}

DIST_TUPLE=		github microsoft vscode ${V} .

CATEGORIES=		editors

HOMEPAGE=		https://code.visualstudio.com/

MAINTAINER=		Fabien Romano <fabien@openbsd.org>

# MIT
PERMIT_PACKAGE=		Yes

# check builtInExtensions from product.json, use pre-build .vsix (.zip)
VSCODE_EXTENSIONS=	js-debug-companion js-debug-companion 1.1.3 \
			js-debug js-debug 1.117.0 \
			js-profile-visualizer vscode-js-profile-table 1.0.10
.for _git _ext _v in ${VSCODE_EXTENSIONS}
DISTFILES.exts+= \
	vscode-${_git}/releases/download/v${_v}/ms-vscode.${_ext}.${_v}.vsix
.endfor
SITES.exts=		https://github.com/microsoft/

# git depends ramya-rao-a/css-parser#vscode needs rebuild during CI
# bring in as a separate target to be built by modnpm
# see custom MODNPM_GEN_OVERRIDES bellow
CSS_PARSER_H=		370c480ac103bd17c7bcfb34bf5d577dc40d3660
DIST_TUPLE+=		github ramya-rao-a css-parser ${CSS_PARSER_H} css-parser

EXTRACT_CASES+=		*.vsix) \
	_filename=$${archive\#\#*/} && \
	${UNZIP} -oq ${FULLDISTDIR}/$$archive \
		-d ${WRKDIR}/$${_filename%.vsix} ;;

WANTLIB += ${COMPILER_LIBCXX} m

COMPILER=		base-clang ports-gcc

MODULES=		devel/npm \
			lang/python \
			www/electron

# XXX drop MODULES security/heimdal and select minimum depends ?
MODULES+=		security/heimdal
#WANTLIB+= 		heimdal/lib/gssapi heimdal/lib/krb5
#LIB_DEPENDS+=		security/heimdal,-libs

MODPY_RUNDEP=		No

MODNPM_TARGETS=		${WRKSRC}/css-parser \
			${WRKSRC} \
			${VSCODE_TARGETS:=${WRKSRC}/%}

# optional depends keytar for @vscode/vsce, which is not installed
# keytar needs x11/gnome/libsecret to build
MODNPM_GEN_EXCLUDES+=	keytar
# optional depends bare-* for tar-fs, which need bare-make and custom build
# it bundles prebuild for all os/arch and generates .bare instead of .node
# rather avoid it
MODNPM_GEN_EXCLUDES+=	bare-events \
			bare-fs \
			bare-os \
			bare-path \
			bare-stream

# override for .extensions/emmet depends, use relative path
MODNPM_GEN_OVERRIDES+=	@emmetio/css-parser file:../../css-parser

# node-ovsx-sign brings in archiver which depends on bare-fs (harder to build)
MODNPM_GEN_OVERRIDES+=	archiver npm:noop-package

MODNPM_MODS+=esbuild
MODNPM_MODS+=graceful-fs
MODNPM_MODS+=@parcel/watcher
MODNPM_MODS+=rollup
MODNPM_MODS+=@typescript/native-preview
MODNPM_MODS+=lightningcss

MODELECTRON_TARGET=	code-oss
MODELECTRON_APP_NAME=	Code - OSS
MODELECTRON_UNVEIL=	Yes
MODELECTRON_BUILD=	No
MODELECTRON_INSTALL=	No

BUILD_DEPENDS=		archivers/unzip \
			archivers/zip \
			lang/node
RUN_DEPENDS=		devel/desktop-file-utils \
			devel/xdg-utils \
			shells/bash \
			textproc/ripgrep
LIB_DEPENDS=		devel/libnotify \
			security/openssl/3.5

USE_GMAKE=		Yes

CXXFLAGS+=		-I${LOCALBASE}/include/inotify \
			-I${LOCALBASE}/include/eopenssl35
LDFLAGS+=		-L${LOCALBASE}/lib \
			-L${LOCALBASE}/lib/eopenssl35

MAKE_ENV+=		BUILD_SOURCEVERSION=${COMMIT}

# Don't download browser binaries on playwright node_modules installation
MAKE_ENV+=		PLAYWRIGHT_BROWSERS_PATH=${WRKDIR}/pw-browsers \
			PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD=1

MAKE_ENV+=		CXXFLAGS="${CXXFLAGS}" LDFLAGS="${LDFLAGS}"

TEST_ENV+=		DISPLAY=:1 \
			VSCODE_SKIP_PRELAUNCH=1

# make gen-targets > Makefile.inc
.include "Makefile.inc"

post-patch:
	# inject LOCALBASE for system path
	cd ${WRKSRC} && ${SUBST_CMD} node_modules/@vscode/ripgrep/lib/index.js
	cd ${WRKSRC}/src/vs/workbench/contrib && ${SUBST_CMD} \
		mcp/common/mcpSandboxService.ts \
		terminalContrib/chatAgentTools/common/terminalSandboxService.ts
	# copy duplicate node_modules patched
	cd ${WRKSRC} && \
		cp {,remote/}node_modules/@vscode/deviceid/dist/index.js && \
		cp {,remote/}node_modules/@vscode/deviceid/dist/storage.js && \
		cp {,build/}node_modules/@vscode/ripgrep/lib/index.js && \
		cp {,remote/}node_modules/@vscode/ripgrep/lib/index.js && \
		cp {,build/}node_modules/@vscode/vsce-sign/package.json && \
		cp {,remote/}node_modules/kerberos/binding.gyp && \
		cp {,remote/}node_modules/kerberos/src/kerberos_common.h && \
		cp {,remote/}node_modules/kerberos/src/unix/kerberos_gss.cc && \
		cp {,remote/}node_modules/kerberos/src/unix/kerberos_gss.h && \
		cp {,remote/}node_modules/node-pty/src/unix/pty.cc

post-extract:
	cp ${WRKSRC}/build/.moduleignore{.linux,.openbsd}

do-configure:
	# preset desktop files
	sed -i.bak \
		's/@@NAME_LONG@@/${MODELECTRON_APP_NAME}/; \
		s/@@NAME_SHORT@@/${MODELECTRON_APP_NAME}/; \
		s/@@PRODNAME@@/${MODELECTRON_APP_NAME}/; \
		s/@@NAME@@/${MODELECTRON_TARGET}/g; \
		s|@@EXEC@@|${PREFIX}/bin/vscode|; \
		s/@@ICON@@/${MODELECTRON_TARGET}/; \
		s/@@URLPROTOCOL@@/${MODELECTRON_TARGET}/; \
		s/@@LICENSE@@/MIT/; \
		s/@@APPNAME@@/${MODELECTRON_TARGET}/g; \
		s|/usr/share|${PREFIX}/share|' \
		${WRKSRC}/resources/linux/code.appdata.xml \
		${WRKSRC}/resources/linux/code.desktop \
		${WRKSRC}/resources/linux/code-url-handler.desktop

pre-build:
	# see package.json patch, skip build/npm/postinstall.js, custom build
	# rebuild native node modules in subdirectories
.for _DIR in ./ ${VSCODE_TARGETS}
	@if [ "`echo ${_DIR} | grep -e test -e .vscode`" ]; then \
		echo "===>  SKIP test ${_DIR}" ; \
	elif [ "`echo ${_DIR} | grep -e build -e remote -e ./$$`" ]; then \
		echo "===>  Rebuild native node modules in ${_DIR}" ; \
		cd ${WRKSRC}/${_DIR} && \
		${MODNPM_CMD_BUILD} ${MODNPM_ARGS_REBUILD} ; \
	else \
		echo "===>  Rebuild native electron modules in ${_DIR}" ; \
		cd ${WRKSRC}/${_DIR} && \
		${SETENV} ${MAKE_ENV} ${MODNPM_ENV} ${ELECTRON_REBUILD_ENV} \
			${MODNPM_BIN} ${MODNPM_ARGS_REBUILD} ; \
	fi
.endfor
	# remove duplicate kerberos.node
	rm -rf ${WRKSRC}/node_modules/kerberos/build/Release/obj.target

do-build:
	# force graceful-fs to overcome fd limits
	echo "require('graceful-fs').gracefulify(require('fs'));" \
		> ${WRKSRC}/use-graceful-fs.cjs
	# build and package vscode
	cd ${WRKSRC} && \
	${SETENV} ${MAKE_ENV} ${MODNPM_ENV} \
		NODE_OPTIONS="--require ${WRKSRC}/use-graceful-fs.cjs" \
		${MODNPM_BIN} run compile && \
	${SETENV} ${MAKE_ENV} ${MODNPM_ENV} \
		NODE_OPTIONS="--require ${WRKSRC}/use-graceful-fs.cjs" \
		${MODNPM_BIN} run gulp vscode-linux-${ELECTRON_ARCH}-min
	# copy marketplace extensions
.for _git _ext _v in ${VSCODE_EXTENSIONS}
	_dst='${WRKDIR}/VSCode-linux-${ELECTRON_ARCH}/extensions' && \
	mkdir -p $${_dst}/ms-vscode.${_ext} && \
	cp -Rp ${WRKDIR}/ms-vscode.${_ext}*${_v}/extension/* \
		$${_dst}/ms-vscode.${_ext}
.endfor

do-install:
	# unveil
	${MODELECTRON_UNVEIL_INSTALL}
	# resources
	${INSTALL_DATA_DIR} ${PREFIX}/${MODELECTRON_DIST_T}
	@cp -Rp ${WRKDIR}/VSCode-linux-${ELECTRON_ARCH}/* \
		${PREFIX}/${MODELECTRON_DIST_T}/
	@chown -R ${SHAREOWN}:${SHAREGRP} ${PREFIX}/${MODELECTRON_DIST_T}
	@rm -rf ${PREFIX}/${MODELECTRON_DIST_T}/bin
	@rm -rf ${PREFIX}/${MODELECTRON_DIST_T}/resources/completions
	# wraper
	${SUBST_PROGRAM} ${FILESDIR}/vscode ${PREFIX}/bin/vscode
	# menu
	${INSTALL_DATA_DIR} ${PREFIX}/share/appdata
	${INSTALL_DATA} ${WRKSRC}/resources/linux/code.appdata.xml \
		${PREFIX}/share/appdata/${MODELECTRON_TARGET}.appdata.xml
	${INSTALL_DATA_DIR} ${PREFIX}/share/applications
.for f in code.desktop code-url-handler.desktop
	${INSTALL_DATA} ${WRKSRC}/resources/linux/${f} \
		${PREFIX}/share/applications/${f:S/code/${MODELECTRON_TARGET}/}
.endfor
	${INSTALL_DATA_DIR} ${PREFIX}/share/pixmaps
	${INSTALL_DATA} ${WRKSRC}/resources/linux/code.png \
		${PREFIX}/share/pixmaps/${MODELECTRON_TARGET}.png

pre-test:
	# rebuild native node modules (including tests)
.for _DIR in ./ ${VSCODE_TARGETS}
	@if [ "`echo ${_DIR} | grep -e test -e .vscode`" ]; then \
		echo "===>  Rebuild native electron modules in ${_DIR}" ; \
		cd ${WRKSRC}/${_DIR} && ${SETENV} ${MAKE_ENV} \
			${ELECTRON_REBUILD_ENV} npm rebuild ${MODNPM_ARGS} ; \
	fi
.endfor
# build/azure-pipelines/linux/steps/product-build-linux-compile.yml
	# force graceful-fs to overcome fd limits during test builds
	echo "require('graceful-fs').gracefulify(require('fs'));" \
		> ${WRKSRC}/use-graceful-fs.cjs
# XXX run core-ci instead of gulp compile-build-without-mangling ?
	# Compile
	cd ${WRKSRC} && ${SETENV} ${MAKE_ENV} \
		NODE_OPTIONS="--require ${WRKSRC}/use-graceful-fs.cjs" \
		ESBUILD_MAX_THREADS=1 \
		${MODNPM_BIN} run gulp compile-build-without-mangling
	# Compile test suites
	cd ${WRKSRC} && ${SETENV} ${MAKE_ENV} \
		${MODNPM_BIN} run compile --prefix test/smoke
	cd ${WRKSRC} && ${SETENV} ${MAKE_ENV} \
		${MODNPM_BIN} run compile --prefix test/integration/browser
	# compile integration test extensions
	cd ${WRKSRC} && ${SETENV} ${MAKE_ENV} \
		NODE_OPTIONS="--require ${WRKSRC}/use-graceful-fs.cjs" \
		ESBUILD_MAX_THREADS=1 \
		${MODNPM_BIN} run gulp \
			compile-extension:configuration-editing \
			compile-extension:css-language-features-server \
			compile-extension:emmet \
			compile-extension:git \
			compile-extension:github-authentication \
			compile-extension:html-language-features-server \
			compile-extension:ipynb \
			compile-extension:notebook-renderers \
			compile-extension:json-language-features-server \
			compile-extension:markdown-language-features \
			compile-extension-media \
			compile-extension:microsoft-authentication \
			compile-extension:typescript-language-features \
			compile-extension:vscode-api-tests \
			compile-extension:vscode-colorize-tests \
			compile-extension:vscode-colorize-perf-tests \
			compile-extension:vscode-test-resolver
.for _git _ext _v in ${VSCODE_EXTENSIONS}
	_dst='${WRKSRC}/.build/builtInExtensions' && \
	mkdir -p $${_dst}/ms-vscode.${_ext} && \
	cp -Rp ${WRKDIR}/ms-vscode.${_ext}*${_v}/extension/* \
		$${_dst}/ms-vscode.${_ext}
.endfor
# openbsd glue for test
	# setup electron dependency for unit tests
	mkdir -p ${WRKSRC}/.build/electron
	mkdir -p ${WRKDIR}/.config/electron
# XXX not ok 95 app module sandbox options
# Unhandled exception in main spec runner:... to not include '--no-sandbox'
# XXX "<args>" break tests ?
	cat ${LOCALBASE}/electron/${ELECTRON_V}/electron_nosandbox.sh \
		| sed -e 's/"$${@}"/$${@}/' \
		> ${WRKSRC}/.build/electron/${MODELECTRON_TARGET}
# 	cat ${TRUEPREFIX}/bin/electron \
# 		| sed -e 's/"$${@}"/$${@}/' \
# 		> ${WRKSRC}/.build/electron/${MODELECTRON_TARGET}

APP_ROOT=${WRKDIR}/VSCode-linux-${ELECTRON_ARCH}
APP_NAME=${MODELECTRON_TARGET}

# XXX Xvfb :1 &
# XXX nosandbox || unveil /
do-test:
# build/azure-pipelines/linux/steps/product-build-linux-test.yml
# XXX no brower or remote version built
	# Run unit tests (Electron)
	cd ${WRKSRC} && ${SETENV} ${TEST_ENV} VSCODE_PID=1 \
		./scripts/test.sh --build
	# Run unit tests (node.js)
	cd ${WRKSRC} && ${MODNPM_CMD_TEST} run test-node -- --build
	# Run integration tests (Electron)
	cd ${WRKSRC} && ${SETENV} ${TEST_ENV} \
		INTEGRATION_TEST_APP_NAME="${APP_NAME}" \
		INTEGRATION_TEST_ELECTRON_PATH="${APP_ROOT}/${APP_NAME}" \
		./scripts/test-integration.sh --build
	# Run smoke tests (Electron)
# XXX Error: Unsupported platform: openbsd
# node_modules/playwright-core/lib/server/registry/index.js
#	cd ${WRKSRC} && ${SETENV} ${TEST_ENV} DISPLAY=:1 \
#		ELECTRON_PATH=${LOCALBASE}/bin/electron \
#		npm run smoketest

### targets for port maintainer(s)

modnpm-pre-gen-modules:
	cd ${WRKSRC} && \
		${MODNPM_CMD_GEN} install --ignore-script node-ovsx-sign

### targets for port maintainer(s)

gen-targets: extract
	# make gen-targets
	@grep "'," ${WRKSRC}/build/npm/dirs.ts | \
		cut -f 2 -d "'" | \
		xargs -L1 printf 'VSCODE_TARGETS+=%s\n'

.include "modules.npm.inc"

.include <bsd.port.mk>
