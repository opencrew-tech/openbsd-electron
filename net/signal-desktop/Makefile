COMMENT=		Signal Desktop links with Signal

V=			7.40.1
DISTNAME=		Signal-Desktop-${V}
PKGNAME=		${DISTNAME:L}

# "node_modules/react-virtualized/dist/commonjs": permission denied
FIX_EXTRACT_PERMISSIONS=Yes

DIST_TUPLE=		github signalapp Signal-Desktop v${V} .

CATEGORIES=		net

HOMEPAGE=		https://signal.org/

MAINTAINER=		Fabien Romano <fabien@openbsd.org>

# BSD 2-Clause
PERMIT_PACKAGE=		Yes

WANTLIB += ${MODCARGO_WANTLIB} c++ m

# make versions
# ELECTRON_V=33.3.1
# NODE_V=20.18.1
# better-sqlite3 deps
# BETTER_SQLITE3_V=9.0.9
SQLCIPHER_H=	9d2afebba9bfd8f18afd36a90a800df84fcf6975defacbfa1e1c5e1e8a6d05f1
SQLCIPHER_URI=	https://build-artifacts.signal.org/desktop/
SQLCIPHER_V=	v2-4.6.1-signal-patch2--0.2.1-${SQLCIPHER_H}
SQLCEXT_V=	0.2.1
FTS5_ID=	a2a00359b1c0987e9b167855ebf0cd93342fd26e
# libsignal depends
LIBSIGNAL_V=	0.65.2
BORING_ID=	1af143f50937bce6a9a9c7405ec824a9153c8ba0
CURVE_ID=	7c6d34756355a3566a704da84dce7b1c039a6572
BORINGSSL_ID=	44b3df6f03d85c901767250329c571db405122d5
# ringrtc depends
RINGRTC_V=	2.49.3
WEBRTC_V=	6834c

# better-sqlite3, MIT
SQLCIPHER_T=	${WRKSRC}/node_modules/@signalapp/better-sqlite3/deps
SITES.sqlc=	${SQLCIPHER_URI}
DISTFILES.sqlc=	sqlcipher-${SQLCIPHER_V}.tar.gz
EXTRACT_CASES+=	${DISTFILES.sqlc});;
# Signal-Sqlcipher-Extension, AGPLv3
SQLCEXT_SRC=	${WRKDIR}/Signal-Sqlcipher-Extension-${SQLCEXT_V}
SQLCEXT_TOML=	${SQLCEXT_SRC}/Cargo.toml
DIST_TUPLE+=	github signalapp Signal-Sqlcipher-Extension v${SQLCEXT_V} .
# Signal-FTS5-Extension, AGPLv3
FTS5_SRC=	${WRKDIR}/Signal-FTS5-Extension-${FTS5_ID}
FTS5_TOML=	${FTS5_SRC}/Cargo.toml
DIST_TUPLE+=	github signalapp Signal-FTS5-Extension ${FTS5_ID} .

# libsignal, AGPLv3
LIBSIGNAL_SRC=	${WRKDIR}/libsignal-${LIBSIGNAL_V}
LIBSIGNAL_NODE=	${LIBSIGNAL_SRC}/node
LIBSIGNAL_TOML=	${LIBSIGNAL_SRC}/Cargo.toml
LIBSIGNAL_T=	${WRKSRC}/node_modules/@signalapp/libsignal-client/prebuilds
DIST_TUPLE+=	github signalapp libsignal v${LIBSIGNAL_V} .
# boring (signalapp fork), Apache-2.0
DIST_TUPLE+=	github signalapp boring ${BORING_ID} boring
# boringssl, OpenSSL/ISC
BORINGSSL_T=	${WRKDIR}/boring-${BORING_ID}/boring-sys/deps
DIST_TUPLE+=	github google boringssl ${BORINGSSL_ID} .
# curve25519-dalek (signalapp fork), XXX LICENCE
DIST_TUPLE+=	github signalapp curve25519-dalek ${CURVE_ID} curve25519-dalek

# ringrtc, AGPLv3
RINGRTC_SRC=	${WRKDIR}/ringrtc-${RINGRTC_V}
RINGRTC_NODE=	${RINGRTC_SRC}/src/node
RINGRTC_TOML=	${RINGRTC_SRC}/Cargo.toml
RINGRTC_T=	${WRKSRC}/node_modules/@signalapp/ringrtc/build
DIST_TUPLE+=	github signalapp ringrtc v${RINGRTC_V} .
# webrtc, BSD-3-Clause
WEBRTC_SRC=	${RINGRTC_SRC}/src/webrtc/src
WEBRTC_T=	${WRKDIR}/ringrtc-${RINGRTC_V}/src/webrtc
SITES.webrtc=	http://distfiles.opencrew.tech/webrtc/
DISTFILES.webrtc=webrtc-${WEBRTC_V}.tgz

ALL_PATCHFILES+=	${PATCHDIR}/chromium/patch-*
PATCH_CASES+=		${PATCHDIR}/chromium/patch-*) \
			    ${PATCH} ${PATCH_DIST_ARGS} \
			    -z .orig.chromium \
			    -d ${WEBRTC_SRC}/ <$$patchfile ;;

COMPILER=		base-clang ports-gcc

MODULES=		devel/cargo \
			devel/cmake \
			devel/npm \
			lang/clang \
			lang/python \
			www/electron

USE_GMAKE=		Yes
USE_NINJA=		No	# disable MODCMAKE targets

# pledge signal-desktop, avoid sqlcipher_mlock()
CFLAGS+=		-DOMIT_MEMLOCK

# see custom modcargo-gen-crates
MODCARGO_CARGOS_TOML=	${FTS5_TOML} \
			${LIBSIGNAL_TOML} \
			${RINGRTC_TOML} \
			${SQLCEXT_TOML}
# libsignal/linkme is broken with https://github.com/dtolnay/linkme/commit
# 64e7c63c106848481bea8f66c4885b52c26ca9ec
# It's probably related to https://github.com/dtolnay/linkme/issues/49
MODCARGO_RUSTFLAGS+=	-Clink-dead-code
# libclang.so
MODCARGO_ENV+=		LIBCLANG_PATH=${LOCALBASE}/llvm${MODCLANG_VERSION}/lib \
			LD_LIBRARY_PATH=${LOCALBASE}/llvm${MODCLANG_VERSION}/lib
MODCARGO_BUILD=		No
MODCARGO_INSTALL=	No
MODCARGO_TEST=		No

MODELECTRON_TARGET=	signal-desktop
MODELECTRON_APP_NAME=	Signal
MODELECTRON_BUILDER=	Yes
MODELECTRON_WRAPPER=	Yes
MODELECTRON_WRAPPER_ENV=NODE_ENV=production

MODNPM_BUILD=		No
MODNPM_INSTALL=		No
MODNPM_TARGETS=		${WRKSRC} \
			${WRKSRC}/sticker-creator \
			${LIBSIGNAL_NODE} \
			${RINGRTC_NODE}

MODPY_RUNDEP=		No

NPM_REBUILD_ENV=	${ELECTRON_REBUILD_ENV}

BUILD_DEPENDS+=		devel/app-builder \
			devel/gn \
			devel/ninja \
			devel/protobuf
RUN_DEPENDS+=		devel/desktop-file-utils

DEBUG_PACKAGES=		${BUILD_PACKAGES}

SUBST_VARS+=		WRKDIR WRKSRC MODCARGO_TARGET_DIR

# pre-define source date, no git show -s --format=%ct
MAKE_ENV+=		SOURCE_DATE_EPOCH=$$(date +'%s')
# signal's appbuilder config
MAKE_ENV+=		SIGNAL_ENV=production

TEST_ENV+=		PATH='${PORTPATH}'

# GN webrtc build, see electron/Makefile
# XXX libringrtc-x64.node: undefined symbol '_ZN3re23RE2...'
#GN_SYSTEM_LIBS+=re2
GN_SYSTEM_LIBS=		brotli \
			crc32c \
			dav1d \
			fontconfig \
			freetype \
			flatbuffers \
			harfbuzz-ng \
			highway \
			icu \
			jsoncpp \
			libaom \
			libavif \
			libevent \
			libjpeg \
			libpng \
			libsecret \
			libusb \
			libvpx \
			libwebp \
			libxml \
			libxslt \
			openh264 \
			opus \
			snappy \
			woff2 \
			zstd
# electron/Makefile link options
GN_ARGS+=		symbol_level=1 \
			is_component_build=false
GN_ARGS+=		use_thin_lto=false \
			thin_lto_enable_optimizations=true
_EXTRA_LDFLAGS=		-L${LOCALBASE}/lib -L${X11BASE}/lib
.if ${MACHINE_ARCH} == "aarch64"
GN_ARGS+=		extra_ldflags=\"${_EXTRA_LDFLAGS}\"
PKG_ARGS+=		-Dswiftshader=0
.elif ${MACHINE_ARCH} == "amd64"
BUILD_DEPENDS+=		devel/nasm
GN_ARGS+=		extra_ldflags=\"${_EXTRA_LDFLAGS}\"
PKG_ARGS+=		-Dswiftshader=1
.elif ${MACHINE_ARCH} == "i386"
BUILD_DEPENDS+=		devel/nasm
GN_ARGS+=		extra_ldflags=\"${_EXTRA_LDFLAGS} -Wl,--no-keep-memory\"
PKG_ARGS+=		-Dswiftshader=1
.else
PKG_ARGS+=		-Dswiftshader=0
.endif
# electron/Makefile common options
_EXTRA_CPPFLAGS=	-idirafter ${LOCALBASE}/include \
			-idirafter ${X11BASE}/include
GN_ARGS+=		clang_use_chrome_plugins=false \
			enable_rust=false \
			extra_cppflags=\"${_EXTRA_CPPFLAGS}\" \
			fatal_linker_warnings=false \
			treat_warnings_as_errors=false \
			use_custom_libcxx=false \
			use_sysroot=false

# see ringrtc/bin/build-electron
# XXX system libvpx, no vp9 support ? rtc_libvpx_build_vp9=true
GN_ARGS+=		rtc_build_examples=false \
			rtc_build_tools=false \
			rtc_include_tests=false \
			rtc_enable_protobuf=false \
			rtc_use_x11=false \
			rtc_enable_sctp=false \
			rtc_disable_metrics=true \
			rtc_disable_trace_events=true

# webrtc
GN_ARGS+=		is_debug=false \
			is_clang=true \
			extra_cxxflags=\"${CXXFLAGS}\"

post-extract:
	# setup boring-sys
	mkdir -p ${BORINGSSL_T}
	rm -rf ${BORINGSSL_T}/*
	mv ${WRKDIR}/boringssl-${BORINGSSL_ID} ${BORINGSSL_T}/boringssl
	# setup webrtc
	mkdir -p ${WEBRTC_T}
	mv ${WRKDIR}/webrtc-${WEBRTC_V} ${WEBRTC_T}/src

pre-patch:
	# link depends into ${WRKSRC} to handle patches
	mv ${FTS5_SRC} ${WRKSRC}/Signal-FTS5-Extension
	ln -s ${WRKSRC}/Signal-FTS5-Extension ${FTS5_SRC}
	mv ${SQLCEXT_SRC} ${WRKSRC}/Signal-Sqlcipher-Extension
	ln -s ${WRKSRC}/Signal-Sqlcipher-Extension ${SQLCEXT_SRC}
	mv ${LIBSIGNAL_SRC} ${WRKSRC}/libsignal
	ln -s ${WRKSRC}/libsignal ${LIBSIGNAL_SRC}
	mv ${RINGRTC_SRC} ${WRKSRC}/ringrtc
	ln -s ${WRKSRC}/ringrtc ${RINGRTC_SRC}
	# apply signal-desktop patches
	# [ $${_p} == "protobufjs+7.3.2.patch" ] && continue;
	cd ${WRKSRC} && for _p in patches/*.patch; do \
		echo "===>  Applying signal-desktop $${_p}" ; \
		${PATCH} -l -f -p1 -z .orig.signal \
		    -d ${WRKSRC} -i ${WRKSRC}/$${_p}; \
	done

pre-configure:
	@ln -sf ${MODPY_BIN} ${WRKDIR}/bin/python
	@ln -sf ${MODPY_BIN} ${WRKDIR}/bin/vpython3
	@ln -sf ${LOCALBASE}/bin/llvm-ar-${MODCLANG_VERSION} ${WRKDIR}/bin/ar
	@mkdir ${WRKDIR}/tmp

do-configure:
	${SUBST_CMD} ${LIBSIGNAL_TOML} ${RINGRTC_TOML}
	${MODCARGO_configure}
	${SUBST_DATA} ${FILESDIR}/cargo.toml \
		${WRKDIR}/cargo.toml
	cat ${WRKDIR}/cargo.toml >>${WRKDIR}/.cargo/config

pre-build: better-sqlite3 libsignal ringrtc sticker-creator
	# setup build dir with dns-fallback.json
	mkdir -p ${WRKSRC}/build
	cp ${FILESDIR}/dns-fallback.json ${WRKSRC}/build/dns-fallback.json
	# setup required bin
	cd ${WRKSRC} && ${NPM_CMD} rebuild ${NPM_ARGS} \
		npm-run-all protobufjs-cli sass
	# build signal
	cd ${WRKSRC} && ${NPM_CMD} run build:acknowledgments ${NPM_ARGS}
	cd ${WRKSRC} && ${NPM_CMD} run generate ${NPM_ARGS}
	cd ${WRKSRC} && ${NPM_CMD} run build:esbuild:prod ${NPM_ARGS}

post-install:
	# menu
	${INSTALL_DATA_DIR} ${PREFIX}/share/applications
	${INSTALL_DATA} ${FILESDIR}/${MODELECTRON_TARGET}.desktop \
		${PREFIX}/share/applications/${MODELECTRON_TARGET}.desktop
	${INSTALL_DATA_DIR} ${PREFIX}/share/pixmaps
	${INSTALL_DATA} ${WRKSRC}/images/signal-logo-desktop-linux.png \
		${PREFIX}/share/pixmaps/${MODELECTRON_TARGET}.png

# XXX test-better-sqlite ?
# XXX test-libwebrtc ?
# XXX test-ringrtc ?
do-test:	test-libsignal \
		test-sticker-creator \
		test-signal-desktop

### custom targets

sqlcipher-extension:
	# build sqlcipher-extension native depends for better-sqlite3
	cd ${SQLCEXT_SRC} && ${SETENV} ${MAKE_ENV} ${CONFIGURE_ENV} \
		${MODCARGO_ENV} ${MODCARGO_CARGO_BIN} build \
		--release

better-sqlite3: sqlcipher-extension
	# build better-sqlite3 native depends
	cp ${DISTDIR}/${DISTFILES.sqlc} ${SQLCIPHER_T}/sqlcipher.tar.gz
	${SUBST_CMD} ${SQLCIPHER_T}/sqlite3.gyp
	cd ${SQLCIPHER_T}/.. && ${SETENV} ${MAKE_ENV} ${ELECTRON_REBUILD_ENV} \
		node ${NPM_GYP_BIN} rebuild

libsignal:
	# build libsignal native depends (fake node-gyp build)
	cd ${LIBSIGNAL_SRC} && ${SETENV} ${MAKE_ENV} ${CONFIGURE_ENV} \
		${MODCARGO_ENV} ${MODCARGO_CARGO_BIN} build \
		-p libsignal-node --release
	# install libsignal prebuild
	mkdir -p ${LIBSIGNAL_T}/openbsd-${NODE_ARCH}
	cp ${MODCARGO_TARGET_DIR}/release/libsignal_node.so \
		${LIBSIGNAL_T}/openbsd-${NODE_ARCH}/node.napi.node

webrtc:
	# configure libwebrtc native depends for ringrtc
	echo "# fake gclient_args" > ${WEBRTC_SRC}/build/config/gclient_args.gni
	cd ${WEBRTC_SRC} && ${SETENV} ${MAKE_ENV} \
		build/linux/unbundle/replace_gn_files.py \
		--system-libraries ${GN_SYSTEM_LIBS}
	cd ${WEBRTC_SRC} && ${SETENV} ${CONFIGURE_ENV} ${MAKE_ENV} \
		gn gen out/release --args="${GN_ARGS}"
	# build libwebrtc native depends for ringrtc
	cd ${WEBRTC_SRC} && ${SETENV} ${MAKE_ENV} \
		ninja -j ${MAKE_JOBS} -C out/release

ringrtc: webrtc
	# build ringrtc native depends
	cd ${RINGRTC_SRC} && ${SETENV} ${MAKE_ENV} ${CONFIGURE_ENV} \
		OUTPUT_DIR=${WEBRTC_SRC}/out \
		${MODCARGO_ENV} ${MODCARGO_CARGO_BIN} build -p ringrtc \
		--features electron --release \
		${MODCARGO_BUILD_ARGS}
	# install ringrtc prebuild
	mkdir -p ${RINGRTC_T}/openbsd
	cp ${MODCARGO_TARGET_DIR}/release/libringrtc.so \
		${RINGRTC_T}/openbsd/libringrtc-${NODE_ARCH}.node

sticker-creator:
	# build sticker-creator
	cd ${WRKSRC}/sticker-creator && \
		${NPM_CMD} rebuild ${NPM_ARGS} && \
		${NPM_CMD} run build

test-libsignal:
	# copy libsignal native lib
	mkdir -p ${LIBSIGNAL_NODE}/build/Release
	cp ${MODCARGO_TARGET_DIR}/release/libsignal_node.so \
		${LIBSIGNAL_NODE}/build/Release/node.napi.node
	# setup required bin
	cd ${LIBSIGNAL_NODE} && ${NPM_CMD} rebuild ${NPM_ARGS} mocha
	# build libsignal tests
	cd ${LIBSIGNAL_NODE} && ${NPM_CMD} run tsc || true
	cd ${LIBSIGNAL_NODE} && ${NPM_CMD} run test || true

test-sticker-creator:
	# run sticker-creator test
	cd ${WRKSRC}/sticker-creator && ${SETENV} ${MAKE_ENV} \
		CI=ci npm run test || true

# XXX Xvfb :1 &
test-signal-desktop:
	# copy libsignal native lib
	cd ${WRKSRC}/node_modules/@signalapp/mock-server/node_modules && \
		mkdir -p @signalapp/libsignal-client/build/Release && \
		cp ${MODCARGO_TARGET_DIR}/release/libsignal_node.so \
			@signalapp/libsignal-client/build/Release/node.napi.node
	# setup required bin
	cd ${WRKSRC} && ${NPM_CMD} rebuild ${NPM_ARGS} \
		npm-run-all cross-env electron-mocha mocha
	# run signal-desktop test
	cd ${WRKSRC} && ${SETENV} ${TEST_ENV} DISPLAY=:1 \
		ELECTRON_PATH=${LOCALBASE}/${ELECTRON_NOSANDBOX} \
		npm run test || true
# XXX fake launch test from system or make one more wraper ?
	cd ${WRKSRC} && ${SETENV} ${TEST_ENV} DISPLAY=:1 \
		ELECTRON_PATH=${LOCALBASE}/${ELECTRON_NOSANDBOX} \
		npm run test-release || true
	cd ${WRKSRC} && ${SETENV} ${TEST_ENV} DISPLAY=:1 \
		ELECTRON_PATH=${LOCALBASE}/${ELECTRON_NOSANDBOX} \
		npm run test-mock || true
	cd ${WRKSRC} && ${SETENV} ${TEST_ENV} DISPLAY=:1 \
		ELECTRON_PATH=${LOCALBASE}/${ELECTRON_NOSANDBOX} \
		ELECTRON_OVERRIDE_DIST_PATH=${WRKSRC}/node_modules/.bin \
		npm run test-node-coverage || true

### targets for port maintainer(s)

user-dev:
	cp ${WRKSRC}/config/{production,local-development}.json
	cd ${WRKSRC} && \
		NODE_ENV=development electron .

# run under _pbuild
_webrtc-compile_commands:
	cd ${WEBRTC_SRC} && ${SETENV} ${MAKE_ENV} \
		ninja -j ${MAKE_JOBS} -C out/release \
		-t compdb > compile_commands.json
webrtc-compile_commands:
	${_PBUILD} make _webrtc-compile_commands

# make versions : download, extract then print versions for depends
# make modnpm-gen-modules : regen modules.inc, see devel/npm
# make modcargo-gen-crates : handle multiple Cargo.toml, regen crates.inc
# make tarball : gen webrtc-${WEBRTC_V}.tgz with gclient
# make chromium-patches : check OpenBSD patches for chromium src (webrtc)
# make dns-fallback : no net during build, pre-made files/dns-fallback.json
# make gn_args-system : helper to list webrtc gn args and display system one

_TMP=		/tmp/signal-desktop-${V}
_SIGNALAPP_GH=	https://raw.githubusercontent.com/signalapp
_BORING_GIT=	https://github.com/signalapp/boring.git
_BSQL_GH=	${_SIGNALAPP_GH}/better-sqlite3/
_LIBSIGNAL_GH=	${_SIGNALAPP_GH}/libsignal/
_RINGRTC_GH=	${_SIGNALAPP_GH}/ringrtc/
_SIGNAL_GH=	${_SIGNALAPP_GH}/Signal-Desktop/
_SSQLE_GH=	${_SIGNALAPP_GH}/Signal-Sqlcipher-Extension
versions:
	# make versions
	@mkdir -p ${_TMP} ;						\
	ftp -VMo ${_TMP}/package.json					\
		${_SIGNAL_GH}/v${V}/package.json ;			\
	_ringrtc_v=$$(grep "@signalapp/ringrtc"				\
		${_TMP}/package.json | awk -F ":" '{print $$2}' |	\
		sed -E 's#("|,| )##g') ;				\
	_libsignal_v=$$(grep "@signalapp/libsignal-client"		\
		${_TMP}/package.json | awk -F ":" '{print $$2}' |	\
		sed -E 's#("|,| )##g') ;				\
	_bsql_v=$$(grep '@signalapp/better-sqlite3'			\
		${_TMP}/package.json | awk -F ":" '{print $$2}' |	\
		sed -E 's#("|,| )##g') ;				\
	printf "# ELECTRON_V=%s\n" $$(awk /'"electron":'/'{print $$2}'	\
		${_TMP}/package.json | sed -E 's/("|,)//g') ;		\
	printf "# NODE_V=%s\n" $$(awk /'"node":'/'{print $$2}'		\
		${_TMP}/package.json | sed 's/"//g') ;			\
									\
	printf "# better-sqlite3 deps\n" ;				\
	printf "# BETTER_SQLITE3_V=%s\n" $$_bsql_v ;			\
	ftp -VMo ${_TMP}/download.js					\
		${_BSQL_GH}/v$${_bsql_v}/deps/download.js ;		\
	printf "SQLCIPHER_H=\t%s\n" $$(grep "const HASH"		\
		${_TMP}/download.js | awk -F '=' '{print $$2}' |	\
		sed -e "s/ '//" -e "s/';//") ;				\
	printf "SQLCIPHER_URI=\t%s/\n" $$(grep "const BASE_URI"		\
		${_TMP}/download.js | awk -F '=' '{print $$2}' |	\
		sed -e "s/ \`//" -e "s/\`;//") ;			\
	_sqlcipher_v=$$(grep "const SQLCIPHER_VERSION"			\
		${_TMP}/download.js | awk -F '=' '{print $$2}' |	\
		sed -e "s/ '//" -e "s/';//") ;				\
	_extension_v=$$(grep "const EXTENSION_VERSION"			\
		${_TMP}/download.js | awk -F '=' '{print $$2}' |	\
		sed -e "s/ '//" -e "s/';//") ;				\
	printf "SQLCIPHER_V=\tv2-%s--%s-\$${SQLCIPHER_H}\n"		\
		$$_sqlcipher_v $$_extension_v ;				\
	printf "SQLCEXT_V=\t%s\n" $$_extension_v ;			\
	ftp -VMo ${_TMP}/sqlcipher.Cargo.lock				\
		${_SSQLE_GH}/v$${_extension_v}/Cargo.lock ;		\
	printf "FTS5_ID=\t%s\n" $$(grep "signalapp/Signal-FTS5-Extension" \
		${_TMP}/sqlcipher.Cargo.lock |				\
		uniq | awk -F '#|"' '{print $$3}') ;			\
									\
	printf "# libsignal depends\n" ;				\
	printf "LIBSIGNAL_V=\t%s\n" $$_libsignal_v ;			\
	ftp -VMo ${_TMP}/libsignal.Cargo.lock				\
		${_LIBSIGNAL_GH}/v$${_libsignal_v}/Cargo.lock ;		\
	_boring_v=$$(grep "signalapp/boring"				\
		${_TMP}/libsignal.Cargo.lock |				\
		uniq | awk -F '#|"' '{print $$3}') ;			\
	_curve_v=$$(grep "signalapp/curve25519-dalek"			\
		${_TMP}/libsignal.Cargo.lock |				\
		uniq | awk -F '#|"' '{print $$3}') ;			\
	printf "BORING_ID=\t%s\n" $$_boring_v ;				\
	printf "CURVE_ID=\t%s\n" $$_curve_v ;				\
	mkdir -p ${_TMP}/boring && cd ${_TMP}/boring &&			\
		git init >/dev/null 2>&1 && git fetch --depth 1		\
		    ${_BORING_GIT} $$_boring_v >/dev/null 2>&1 &&	\
		git checkout FETCH_HEAD >/dev/null 2>&1 &&		\
		_boringssl_v=$$(git submodule |				\
		    awk -F ' |-' '/boringssl$$/ {print $$2}') ;		\
	printf "BORINGSSL_ID=\t%s\n" $$_boringssl_v ;			\
									\
	printf "# ringrtc depends\n" ;					\
	printf "RINGRTC_V=\t%s\n" $$_ringrtc_v ;			\
	ftp -VMo ${_TMP}/version.properties				\
		${_RINGRTC_GH}/v$${_ringrtc_v}/config/version.properties ; \
	printf "WEBRTC_V=\t%s\n" $$(grep "webrtc.version"		\
		${_TMP}/version.properties | awk -F "=" '{print $$2}' ) ;

# handle multiple cargo files and add github depends for libsignal
modcargo-gen-crates:
	@make extract >/dev/null 2>&1
	@echo '# run: make modcargo-gen-crates-licenses'
	@cat ${MODCARGO_CARGOS_TOML:toml=lock} | awk '\
		/^name = / { n=$$3; gsub("\"", "", n); } \
		/^version = / { v=$$3; gsub("\"", "", v); } \
		/^source = "registry\+.*github.com.*crates\.io-index"/ \
			{ print "MODCARGO_CRATES +=	" n "	" v; }' | \
		sort | uniq

# prepare custom tarball for stable fetch
# XXX need ~10G, usualy run with a custom _SRC
# XXX need custom tar -R (reproducible) diff, use gtar alternative ?
_SRC?=		${WRKDIR}/webrtc
_VER?=		${WEBRTC_V}
_PKG?=		webrtc
_FETCH?=	https://github.com/signalapp/webrtc.git \
		+refs/tags/${WEBRTC_V}
# third parties not needed to build ringrtc
.for _f in breakpad ced clang-format colorama depot_tools ffmpeg flatbuffers \
    fontconfig freetype fuzztest google_benchmark googletest grpc \
    gtest-parallel harfbuzz-ng jsoncpp libaom libc++ libc++abi libevent \
    libFuzzer libunwind lss pipewire ${GN_SYSTEM_LIBS}
_EXCLUDE_third_party+=-o \( -path '*/third_party/${_f}/*' -a ! -name '*.gn*' \)
.endfor
tarball:
	ulimit -d `ulimit -dH`
	mkdir -p ${_SRC}/src
	cp ${FILESDIR}/gclient ${_SRC}/.gclient
	cd ${_SRC}/src && [ -d ".git" ] || ( \
	HOME=${_SRC} git init && \
	HOME=${_SRC} git fetch ${_FETCH} --depth 1 && \
	HOME=${_SRC} git checkout FETCH_HEAD && \
	HOME=${_SRC} gclient sync --no-history --shallow \
	    --force --delete_unversioned_trees --reset \
	    --no-bootstrap --nohooks --noprehooks \
	    --with_branch_heads --with_tags \
	)
	cd ${_SRC} && \
	find ./src -type f -a ! \( \
	    -path '*/.git/*' \
	    -o -path '*/out/*' \
	    -o -path '*/buildtools/linux64/*' \
	    -o -path '*/buildtools/reclient/*' \
	    ${_EXCLUDE_third_party} \
	    -o -path '*/third_party/blink/tools/*' \
	    -o -path '*/third_party/blink/web_tests/*' \
	    -o -path '*/third_party/catapult/tracing/test_data/*' \
	    -o -path '*/third_party/hunspell/tests/*' \
	    -o -path '*/tools/luci-go/*' \
	    -o -path '*/tools/resultdb/*' \
	    \) | sort > files && \
	tar -cRzf ${_PKG}-${_VER}.tgz -I files \
	    -s '|src/|${_PKG}-${_VER}/|' && \
	sha256 -b ${_PKG}-${_VER}.tgz

chromium-patches:
	make extract
	@mkdir -p ${_TMP}
	# cvs co -D 20241116 -d chromium ports/www/chromium
	# remember to update cvs co -D "..." if you change targeted version
	@if [ -d ${_TMP}/chromium ]; then \
		echo "${_TMP}/chromium exists, skip cvs co" ; \
	else \
		cd ${_TMP} && \
		cvs co -D 20250107 -d chromium ports/www/chromium ; \
	fi
	# test chromium patches
	rm -rf ${_TMP}/patches
	mkdir -p ${_TMP}/patches/chromium{,.rej,.miss,.new}
	mkdir -p ${_TMP}/patches/webrtc
	mkdir -p ${_TMP}/patches/media.ignore
	@for p in ${_TMP}/chromium/patches/patch-*; do \
		if [[ $$p == *"patch-media"* ]]; then \
			cp $${p} ${_TMP}/patches/media.ignore/$${p##*/} ; \
			continue ; \
		fi ; \
		if [[ $$p == *"third_party_webrtc"* ]]; then \
			cp $${p} ${_TMP}/patches/webrtc/$${p##*/} ; \
			p=${_TMP}/patches/webrtc/$${p##*/} ; \
			sed -i -e 's|third_party/webrtc/||g' $$p ; \
		fi ; \
		f=$$(grep 'Index' $$p | sed -e 's/.*: //' ) ; \
		if grep -q "@@ -0,0" $$p; then \
			cp $${p} ${_TMP}/patches/chromium/ ; \
			cp $${p} ${_TMP}/patches/chromium.new/ ; \
		elif [ -f "${WEBRTC_SRC}/$$f" ]; then \
			${PATCH} ${PATCH_DIST_ARGS} -sfC -z .orig.chromium \
				-d ${WEBRTC_SRC} < $${p} && \
				cp $${p} ${_TMP}/patches/chromium/ || \
				cp $${p} ${_TMP}/patches/chromium.rej/ ; \
		else \
			cp $${p} ${_TMP}/patches/chromium.miss/ ; \
		fi ; \
	done
	@echo "rejected:"
	@ls ${_TMP}/patches/chromium.rej
	# if ok, copy ${_TMP}/patches/chromium into port

dns-fallback:
	@make configure >/dev/null 2>&1
	@cd ${WRKSRC} && \
		${_PBUILD} ${NPM_CMD} run build:dns-fallback && \
		cat ${WRKSRC}/build/dns-fallback.json

.include "modules.inc"
.include "crates.inc"

.include <bsd.port.mk>
