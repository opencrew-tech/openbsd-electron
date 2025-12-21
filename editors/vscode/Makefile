# XXX security/heimdal patches, kerberos test ?
# XXX ONLY_FOR_ARCHS, too restrictive ?
ONLY_FOR_ARCHS=		amd64

# XXX portroach should check commit id date for tags ordering ?
PORTROACH =		skipv:1.999.0

COMMENT=		Visual Studio Code - Open Source ("Code - OSS")

V=			1.105.1
COMMIT=			7d842fb85a0275a4a8e4d7e040d2625abbf7f084
PKGNAME=		vscode-${V}

DIST_TUPLE=		github microsoft vscode ${V} .

CATEGORIES=		editors

HOMEPAGE=		https://code.visualstudio.com/

MAINTAINER=		Fabien Romano <fabien@openbsd.org>

# MIT
PERMIT_PACKAGE=		Yes

# check builtInExtensions from product.json, use pre-build .vsix (.zip)
VSCODE_EXTENSIONS=	js-debug-companion js-debug-companion 1.1.3 \
			js-debug js-debug 1.105.0 \
			js-profile-visualizer vscode-js-profile-table 1.0.10
SITES.exts=		https://github.com/microsoft/

.for _git _ext _v in ${VSCODE_EXTENSIONS}
DISTFILES.exts+= \
	vscode-${_git}/releases/download/v${_v}/ms-vscode.${_ext}.${_v}.vsix
.endfor

EXTRACT_CASES+=		*.vsix) \
	_filename=$${archive\#\#*/} && \
	${UNZIP} -oq ${FULLDISTDIR}/$$archive \
		-d ${WRKDIR}/$${_filename%.vsix} ;;

WANTLIB += ${COMPILER_LIBCXX} c m notify util

COMPILER=		base-clang ports-gcc

MODULES=		devel/npm \
			lang/python \
			security/heimdal \
			www/electron

# XXX drop MODULES security/heimdal and select minimum depends ?
#WANTLIB+= 		heimdal/lib/gssapi heimdal/lib/krb5
#LIB_DEPENDS+=		security/heimdal,-libs

MODPY_RUNDEP=		No

MODNPM_TARGETS=		${VSCODE_TARGETS:=${WRKSRC}/%}
MODNPM_BUILD=		No
MODNPM_INSTALL=		No
# optional depends keytar for @vscode/vsce, which is not installed
# keytar needs x11/gnome/libsecret to build
MODNPM_EXCLUDES+=	keytar
# optional depends bare-* for tar-fs, which need bare-make and custom build
# it bundles prebuild for all os/arch and generates .bare instead of .node
# rather avoid it
MODNPM_EXCLUDES+=	bare-events \
			bare-fs \
			bare-os \
			bare-path \
			bare-stream

MODELECTRON_TARGET=	code-oss
MODELECTRON_APP_NAME=	Code - OSS
MODELECTRON_UNVEIL=	Yes
MODELECTRON_BUILD=	No
MODELECTRON_INSTALL=	No

BUILD_DEPENDS=		archivers/unzip \
			archivers/zip \
			devel/libinotify \
			lang/node \
			textproc/ripgrep
RUN_DEPENDS=		devel/desktop-file-utils \
			devel/xdg-utils \
			shells/bash
LIB_DEPENDS=		devel/libnotify

USE_GMAKE=		Yes

CXXFLAGS+=		-I${LOCALBASE}/include/inotify
LDFLAGS+=		-L${LOCALBASE}/lib

MAKE_ENV+=		BUILD_SOURCEVERSION=${COMMIT}

# Don't download browser binaries on playwright node_modules installation
MAKE_ENV+=		PLAYWRIGHT_BROWSERS_PATH=${WRKDIR}/pw-browsers \
			PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD=1

MAKE_ENV+=		CXXFLAGS="${CXXFLAGS}" LDFLAGS="${LDFLAGS}"

# make gen-targets
VSCODE_TARGETS+=./
VSCODE_TARGETS+=./build
VSCODE_TARGETS+=./extensions
VSCODE_TARGETS+=./extensions/configuration-editing
VSCODE_TARGETS+=./extensions/css-language-features
VSCODE_TARGETS+=./extensions/css-language-features/server
VSCODE_TARGETS+=./extensions/debug-auto-launch
VSCODE_TARGETS+=./extensions/debug-server-ready
VSCODE_TARGETS+=./extensions/emmet
VSCODE_TARGETS+=./extensions/extension-editing
VSCODE_TARGETS+=./extensions/git
VSCODE_TARGETS+=./extensions/git-base
VSCODE_TARGETS+=./extensions/github
VSCODE_TARGETS+=./extensions/github-authentication
VSCODE_TARGETS+=./extensions/grunt
VSCODE_TARGETS+=./extensions/gulp
VSCODE_TARGETS+=./extensions/html-language-features
VSCODE_TARGETS+=./extensions/html-language-features/server
VSCODE_TARGETS+=./extensions/ipynb
VSCODE_TARGETS+=./extensions/jake
VSCODE_TARGETS+=./extensions/json-language-features
VSCODE_TARGETS+=./extensions/json-language-features/server
VSCODE_TARGETS+=./extensions/markdown-language-features
VSCODE_TARGETS+=./extensions/markdown-math
VSCODE_TARGETS+=./extensions/media-preview
VSCODE_TARGETS+=./extensions/merge-conflict
VSCODE_TARGETS+=./extensions/mermaid-chat-features
VSCODE_TARGETS+=./extensions/microsoft-authentication
VSCODE_TARGETS+=./extensions/notebook-renderers
VSCODE_TARGETS+=./extensions/npm
VSCODE_TARGETS+=./extensions/php-language-features
VSCODE_TARGETS+=./extensions/references-view
VSCODE_TARGETS+=./extensions/search-result
VSCODE_TARGETS+=./extensions/simple-browser
VSCODE_TARGETS+=./extensions/tunnel-forwarding
VSCODE_TARGETS+=./extensions/typescript-language-features
VSCODE_TARGETS+=./extensions/vscode-api-tests
VSCODE_TARGETS+=./extensions/vscode-colorize-tests
VSCODE_TARGETS+=./extensions/vscode-colorize-perf-tests
VSCODE_TARGETS+=./extensions/vscode-test-resolver
VSCODE_TARGETS+=./remote
VSCODE_TARGETS+=./remote/web
VSCODE_TARGETS+=./test/automation
VSCODE_TARGETS+=./test/integration/browser
VSCODE_TARGETS+=./test/monaco
VSCODE_TARGETS+=./test/smoke
VSCODE_TARGETS+=./test/mcp
VSCODE_TARGETS+=./.vscode/extensions/vscode-selfhost-import-aid
VSCODE_TARGETS+=./.vscode/extensions/vscode-selfhost-test-provider

post-extract:
	cp ${WRKSRC}/build/.moduleignore{.linux,.openbsd}

do-configure:
	mkdir -p ${WRKDIR}/tmp
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
	# copy rg binary files to vscode-ripgrep module directory
	mkdir -p ${WRKSRC}/node_modules/@vscode/ripgrep/bin
	cp -p ${LOCALBASE}/bin/rg \
		${WRKSRC}/node_modules/@vscode/ripgrep/bin
	mkdir -p ${WRKSRC}/build/node_modules/@vscode/ripgrep/bin
	cp -p ${LOCALBASE}/bin/rg \
		${WRKSRC}/build/node_modules/@vscode/ripgrep/bin
	mkdir -p ${WRKSRC}/remote/node_modules/@vscode/ripgrep/bin
	cp -p ${LOCALBASE}/bin/rg \
		${WRKSRC}/remote/node_modules/@vscode/ripgrep/bin
	# see package.json patch, skip build/npm/postinstall.js, custom build
	# rebuild native node modules in subdirectories
.for _DIR in ${VSCODE_TARGETS}
	@if [ "`echo ${_DIR} | grep -e test -e .vscode`" ]; then \
		echo "===>  SKIP test ${_DIR}" ; \
	elif [ "`echo ${_DIR} | grep -e build -e remote -e ./$$`" ]; then \
		echo "===>  Rebuild native node modules in ${_DIR}" ; \
		cd ${WRKSRC}/${_DIR} && \
		${MODNPM_CMD} rebuild ${MODNPM_ARGS} ; \
	else \
		echo "===>  Rebuild native electron modules in ${_DIR}" ; \
		cd ${WRKSRC}/${_DIR} && \
		${SETENV} ${MAKE_ENV} \
			${ELECTRON_REBUILD_ENV} npm rebuild ${MODNPM_ARGS} ; \
	fi
.endfor
	# remove duplicate kerberos.node
	rm -rf ${WRKSRC}/node_modules/kerberos/build/Release/obj.target

do-build:
	# build and package vscode
	cd ${WRKSRC} && ${SETENV} ${MAKE_ENV} \
		node ./node_modules/typescript/bin/tsc \
		-p build/tsconfig.build.json
	echo "require('graceful-fs').gracefulify(require('fs'));" \
		> ${WRKSRC}/use-graceful-fs.cjs
	ulimit -d $$(ulimit -Hd) && \
	cd ${WRKSRC} && ${SETENV} ${MAKE_ENV} \
		NODE_OPTIONS="--require ${WRKSRC}/use-graceful-fs.cjs" \
		ESBUILD_MAX_THREADS=1 \
		node --max-old-space-size=8192 \
		./node_modules/gulp/bin/gulp.js \
		vscode-linux-${ELECTRON_ARCH}-min
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
	@cp -Rp ${WRKDIR}/VSCode-linux-x64/* ${PREFIX}/${MODELECTRON_DIST_T}/
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
	# rebuild native node modules
.for _DIR in ${VSCODE_TARGETS}
	@if [ "`echo ${_DIR} | grep -e test -e .vscode`" ]; then \
		echo "===>  Rebuild native electron modules in ${_DIR}" ; \
		cd ${WRKSRC}/${_DIR} && ${SETENV} ${MAKE_ENV} \
			${ELECTRON_REBUILD_ENV} npm rebuild ${MODNPM_ARGS} ; \
	fi
.endfor
	# setup electron dependency for unit tests
	mkdir -p ${WRKSRC}/.build/electron
	mkdir -p ${WRKDIR}/.config/electron
# XXX not ok 95 app module sandbox options
# Unhandled exception in main spec runner:... to not include '--no-sandbox'
	cp ${LOCALBASE}/electron/${ELECTRON_V}/electron_nosandbox.sh \
		${WRKSRC}/.build/electron/${MODELECTRON_TARGET}
#	cp ${TRUEPREFIX}/bin/electron \
#		${WRKSRC}/.build/electron/${MODELECTRON_TARGET}
.for _git _ext _v in ${VSCODE_EXTENSIONS}
	_dst='${WRKSRC}/.build/builtInExtensions' && \
	mkdir -p $${_dst}/ms-vscode.${_ext} && \
	cp -Rp ${WRKDIR}/ms-vscode.${_ext}*${_v}/extension/* \
		$${_dst}/ms-vscode.${_ext}
.endfor

# XXX Xvfb :1 &
# XXX nosandbox || unveil /
do-test:
	# unit tests
	cd ${WRKSRC} && ${SETENV} ${TEST_ENV} \
		DISPLAY=:1 ./scripts/test.sh || true
#	# UI smoke tests
# XXX Error: Unsupported platform: openbsd
# node_modules/playwright-core/lib/server/registry/index.js
#	cd ${WRKSRC} && ${SETENV} ${TEST_ENV} DISPLAY=:1 \
#		ELECTRON_PATH=${LOCALBASE}/bin/electron \
#		npm run smoketest

### targets for port maintainer(s)

gen-targets: extract
	# make gen-targets
	@grep "'," ${WRKSRC}/build/npm/dirs.js | \
		cut -f 2 -d "'" | \
		xargs -L1 printf 'VSCODE_TARGETS+=./%s\n'

.include "modules.inc"

.include <bsd.port.mk>
