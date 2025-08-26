# XXX only for arch ports-clang ?

COMMENT=		Signal Desktop links with Signal

V=			7.66.0
DISTNAME=		Signal-Desktop-${V}
PKGNAME=		${DISTNAME:L}

DIST_TUPLE=		github signalapp Signal-Desktop v${V} .

CATEGORIES=		net

HOMEPAGE=		https://signal.org/

MAINTAINER=		Fabien Romano <fabien@openbsd.org>

# BSD 2-Clause
PERMIT_PACKAGE=		Yes

WANTLIB += ${MODCARGO_WANTLIB} c++ m

# make versions
# ELECTRON_V=36.3.2
# NODE_V=22.15.0
# sqlcipher depends
SQLCIPHER_V=	2.2.2
FTS5_ID=	a2a00359b1c0987e9b167855ebf0cd93342fd26e
# libsignal depends
LIBSIGNAL_V=	0.76.7
BORING_ID=	bb42da53b3900aea1936d41decf9403f25c4259c
CURVE_ID=	7c6d34756355a3566a704da84dce7b1c039a6572
SPQR_ID=	d6c10734689ec5844d09c1a054a288d36cde2adc
BORINGSSL_ID=	44b3df6f03d85c901767250329c571db405122d5
# ringrtc depends
RINGRTC_V=	2.56.0
WEBRTC_V=	7204a

# node-sqlcipher, AGPLv3
SQLCIPHER_SRC=	${WRKDIR}/node-sqlcipher-${SQLCIPHER_V}
SQLCIPHER_T=	${WRKSRC}/node_modules/@signalapp/sqlcipher/prebuilds
DIST_TUPLE+=	github signalapp node-sqlcipher v${SQLCIPHER_V} .
SQLCEXT_SRC=	${SQLCIPHER_SRC}/deps/extension
SQLCEXT_TOML=	${SQLCEXT_SRC}/Cargo.toml
# Signal-FTS5-Extension, AGPLv3
FTS5_SRC=	${WRKDIR}/Signal-FTS5-Extension-${FTS5_ID}
FTS5_TOML=	${FTS5_SRC}/Cargo.toml
DIST_TUPLE+=	github signalapp Signal-FTS5-Extension ${FTS5_ID} .

# libsignal, AGPLv3
LIBSIGNAL_SRC=	${WRKDIR}/libsignal-${LIBSIGNAL_V}
LIBSIGNAL_NODE=	${LIBSIGNAL_SRC}/node
LIBSIGNAL_PREB=	@signalapp/libsignal-client/prebuilds/openbsd-${NODE_ARCH}
LIBSIGNAL_TOML=	${LIBSIGNAL_SRC}/Cargo.toml
LIBSIGNAL_T=	${WRKSRC}/node_modules/${LIBSIGNAL_PREB}
DIST_TUPLE+=	github signalapp libsignal v${LIBSIGNAL_V} .
# boring (signalapp fork), Apache-2.0
DIST_TUPLE+=	github signalapp boring ${BORING_ID} boring
# curve25519-dalek (signalapp fork), BSD 3-Clause|MIT|Apache-2.0
DIST_TUPLE+=	github signalapp curve25519-dalek ${CURVE_ID} curve25519-dalek
# SparsePostQuantumRatchet, AGPLv3
DIST_TUPLE+=	github signalapp SparsePostQuantumRatchet ${SPQR_ID} spqr
# boring -> boringssl, OpenSSL/ISC
BORINGSSL_T=	${WRKDIR}/boring-${BORING_ID}/boring-sys/deps
DIST_TUPLE+=	github google boringssl ${BORINGSSL_ID} .

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

# rust bindgen need libclang.so
COMPILER=		ports-clang

MODULES=		devel/cargo \
			devel/cmake \
			devel/npm \
			devel/pnpm \
			lang/clang \
			lang/python \
			www/electron

USE_GMAKE=		Yes
USE_NINJA=		No	# disable MODCMAKE targets

# see custom modcargo-gen-crates
MODCARGO_CARGOS_TOML=	${SQLCEXT_TOML} \
			${FTS5_TOML} \
			${LIBSIGNAL_TOML} \
			${RINGRTC_TOML}

# libsignal/linkme is broken with https://github.com/dtolnay/linkme/commit
# 64e7c63c106848481bea8f66c4885b52c26ca9ec
# It's probably related to https://github.com/dtolnay/linkme/issues/49
MODCARGO_RUSTFLAGS+=	-Clink-dead-code
# rust bindgen need libclang.so
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
MODNPM_REBUILD_ENV=	${ELECTRON_REBUILD_ENV}
MODNPM_TARGETS=		${RINGRTC_NODE} ${LIBSIGNAL_NODE}

MODPNPM_BUILD=		No
MODPNPM_INSTALL=	No
MODPNPM_GEN_UPDATE=	esbuild@0.25.9
MODPNPM_GEN_INSTALL=	@swc/wasm@1.10.16 # fallback for @swc/core
MODPNPM_GEN_OVERRIDES=	"esbuild":"0.25.9"
MODPNPM_REBUILD_ENV=	${ELECTRON_REBUILD_ENV}
MODPNPM_TARGETS=	${WRKSRC} \
			${WRKSRC}/sticker-creator \
			${WRKSRC}/node-sqlcipher

MODPY_RUNDEP=		No

# pledge signal-desktop, avoid sqlcipher_mlock()
CFLAGS+=		-DOMIT_MEMLOCK

BUILD_DEPENDS+=		devel/gn \
			devel/ninja \
			devel/protobuf
RUN_DEPENDS+=		devel/desktop-file-utils

DEBUG_PACKAGES=		${BUILD_PACKAGES}

SUBST_VARS+=		WRKDIR WRKSRC MODCARGO_TARGET_DIR MODCLANG_VERSION

# pre-define source date, no git show -s --format=%ct
MAKE_ENV+=		SOURCE_DATE_EPOCH=$$(date +'%s')
# signal's appbuilder config
MAKE_ENV+=		SIGNAL_ENV=production
# override esbuild & use system bin
MAKE_ENV+=		ESBUILD_BINARY_PATH=${LOCALBASE}/bin/esbuild

TEST_ENV+=		PATH='${PORTPATH}'

# GN webrtc build, see chromium or electron Makefile
# XXX Unrecognized system libraries requested: libavif, libevent
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
			re2 \
			snappy \
			woff2 \
			zstd
# link options
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
# common options
EXTRA_CPPFLAGS=		-I${LOCALBASE}/include/libepoll-shim \
			-idirafter ${LOCALBASE}/include \
			-idirafter ${X11BASE}/include
GN_ARGS+=		clang_use_chrome_plugins=false \
			extra_cppflags=\"${EXTRA_CPPFLAGS}\" \
			fatal_linker_warnings=false \
			treat_warnings_as_errors=false \
			use_custom_libcxx=false \
			use_sysroot=false
# use rust
RUSTC_VERSION!!=	rustc -V
MAKE_ENV+=		RUSTC_BOOTSTRAP=1
GN_ARGS+=		enable_rust=true \
			rust_sysroot_absolute=\"${LOCALBASE}\" \
			rustc_version=\"${RUSTC_VERSION}\"
# see https://github.com/signalapp/ringrtc/blob/main/bin/build-desktop
GN_ARGS+=		rtc_build_examples=false \
			rtc_build_tools=false \
			rtc_disable_metrics=true \
			rtc_disable_trace_events=true \
			rtc_enable_protobuf=false \
			rtc_enable_sctp=false \
			rtc_include_tests=false \
			rtc_libvpx_build_vp9=true \
			rtc_use_x11=false
# webrtc
GN_ARGS+=		is_debug=false \
			is_clang=true \
			extra_cxxflags=\"${CXXFLAGS}\"

post-extract:
	# boring-sys
	mkdir -p ${BORINGSSL_T} && rm -rf ${BORINGSSL_T}/*
	mv ${WRKDIR}/boringssl-${BORINGSSL_ID} ${BORINGSSL_T}/boringssl
	# webrtc
	mkdir -p ${WEBRTC_T} && rm -rf ${WEBRTC_T}/*
	mv ${WRKDIR}/webrtc-${WEBRTC_V} ${WEBRTC_T}/src
	# node-sqlcipher
	mv ${SQLCIPHER_SRC} ${WRKSRC}/node-sqlcipher
	ln -s ${WRKSRC}/node-sqlcipher ${SQLCIPHER_SRC}

pre-patch:
	# link depends into ${WRKSRC} to handle patches
	mv ${FTS5_SRC} ${WRKSRC}/Signal-FTS5-Extension
	ln -s ${WRKSRC}/Signal-FTS5-Extension ${FTS5_SRC}
	mv ${LIBSIGNAL_SRC} ${WRKSRC}/libsignal
	ln -s ${WRKSRC}/libsignal ${LIBSIGNAL_SRC}
	mv ${RINGRTC_SRC} ${WRKSRC}/ringrtc
	ln -s ${WRKSRC}/ringrtc ${RINGRTC_SRC}

pre-configure:
	@ln -sf ${MODPY_BIN} ${WRKDIR}/bin/python
	@ln -sf ${MODPY_BIN} ${WRKDIR}/bin/vpython3
	@ln -sf ${LOCALBASE}/bin/llvm-ar-${MODCLANG_VERSION} ${WRKDIR}/bin/ar
	@mkdir -p ${WRKDIR}/tmp

do-configure:
	${SUBST_CMD} ${LIBSIGNAL_TOML} ${RINGRTC_TOML}
	${MODCARGO_configure}
	${SUBST_DATA} ${FILESDIR}/cargo.toml \
		${WRKDIR}/cargo.toml
	cat ${WRKDIR}/cargo.toml >>${WRKDIR}/.cargo/config

pre-build: node-sqlcipher libsignal ringrtc sticker-creator
	# setup build dir with dns-fallback.json
	mkdir -p ${WRKSRC}/build
	cp ${FILESDIR}/dns-fallback.json ${WRKSRC}/build/dns-fallback.json
	# build signal
	cd ${WRKSRC} && ${MODPNPM_CMD} rebuild -dd
	cd ${WRKSRC} && ${MODPNPM_CMD} run build:acknowledgments
	cd ${WRKSRC} && ${MODPNPM_CMD} run generate
	cd ${WRKSRC} && ${MODPNPM_CMD} run build:esbuild:prod

post-install:
	# menu
	${INSTALL_DATA_DIR} ${PREFIX}/share/applications
	${INSTALL_DATA} ${FILESDIR}/${MODELECTRON_TARGET}.desktop \
		${PREFIX}/share/applications/${MODELECTRON_TARGET}.desktop
	${INSTALL_DATA_DIR} ${PREFIX}/share/pixmaps
	${INSTALL_DATA} ${WRKSRC}/images/signal-logo-desktop-linux.png \
		${PREFIX}/share/pixmaps/${MODELECTRON_TARGET}.png

# XXX test-libwebrtc ?
# XXX test-ringrtc ?
do-test:	test-libsignal \
		test-sticker-creator \
		test-signal-desktop

### custom targets

sqlcipher-extension:
	# build sqlcipher-extension native depends (node-gyp rust build fail)
	cd ${SQLCEXT_SRC} && ${SETENV} ${MAKE_ENV} ${CONFIGURE_ENV} \
		${MODCARGO_ENV} ${MODCARGO_CARGO_BIN} build --release

node-sqlcipher:sqlcipher-extension
	# build node-sqlcipher native depends
	${SUBST_CMD} ${SQLCIPHER_SRC}/deps/sqlcipher/sqlcipher.gyp
	cd ${SQLCIPHER_SRC} && ${SETENV} ${MAKE_ENV} ${ELECTRON_REBUILD_ENV} \
		node ${MODNPM_GYP_BIN} rebuild --verbose
	# install node-sqlcipher prebuild
	mkdir -p ${SQLCIPHER_T}/openbsd-${NODE_ARCH}
	cp ${SQLCIPHER_SRC}/build/Release/node_sqlcipher.node \
		${SQLCIPHER_T}/openbsd-${NODE_ARCH}/@signalapp+sqlcipher.node

libsignal:
	# build libsignal native depends (node-gyp rust build fail)
	cd ${LIBSIGNAL_SRC} && ${SETENV} ${MAKE_ENV} ${CONFIGURE_ENV} \
		${MODCARGO_ENV} ${MODCARGO_CARGO_BIN} build \
		-p libsignal-node --release
	# install libsignal prebuild
	mkdir -p ${LIBSIGNAL_T}
	cp ${MODCARGO_TARGET_DIR}/release/libsignal_node.so \
	    ${LIBSIGNAL_T}/@signalapp+libsignal-client.node

webrtc:
	${SUBST_CMD} ${WEBRTC_SRC}/build/rust/rust_bindgen.gni \
		${WEBRTC_SRC}/build/rust/rust_bindgen_generator.gni
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
		${MODPNPM_CMD} rebuild -dd && \
		${MODPNPM_CMD} build

test-libsignal:
	# install libsignal prebuild for tests
	cd ${LIBSIGNAL_NODE}/node_modules && \
		mkdir -p ${LIBSIGNAL_PREB} && \
		cp ${MODCARGO_TARGET_DIR}/release/libsignal_node.so \
			${LIBSIGNAL_PREB}/@signalapp+libsignal-client.node
	# setup required bin
	cd ${LIBSIGNAL_NODE} && ${MODNPM_CMD} rebuild ${MODNPM_ARGS} mocha
	# build libsignal tests
	cd ${LIBSIGNAL_NODE} && ${MODNPM_CMD} run tsc || true
	cd ${LIBSIGNAL_NODE} && ${MODNPM_CMD} run test || true

test-sticker-creator:
	# run sticker-creator test
	cd ${WRKSRC}/sticker-creator && \
		${MODPNPM_CMD} test || true

# XXX Xvfb :1 &
test-signal-desktop:
	# copy libsignal native lib
	cd `realpath ${WRKSRC}/node_modules/@signalapp/mock-server`/../.. &&\
		mkdir -p ${LIBSIGNAL_PREB} && \
		cp ${MODCARGO_TARGET_DIR}/release/libsignal_node.so \
			${LIBSIGNAL_PREB}/@signalapp+libsignal-client.node
	# run signal-desktop test
	cd ${WRKSRC} && ${SETENV} ${TEST_ENV} DISPLAY=:1 \
		ELECTRON_PATH=${LOCALBASE}/${ELECTRON_NOSANDBOX} \
		npm run test || true

### targets for port maintainer(s)

_webrtc-compile_commands:
# run under _pbuild
	cd ${WEBRTC_SRC} && ${SETENV} ${MAKE_ENV} \
		ninja -j ${MAKE_JOBS} -C out/release \
		-t compdb > compile_commands.json
webrtc-compile_commands:
	${_PBUILD} make _webrtc-compile_commands

# make versions : download, extract then print versions for depends
# make tarball : gen webrtc-${WEBRTC_V}.tgz with gclient
# make modpnpm-gen-modules : override modules.inc, see devel/pnpm
# make modnpm-gen-modules : output >> modules.inc, see devel/npm
# make modcargo-gen-crates : output > crates.inc, handle multiple Cargo.toml
# make chromium-patches : check OpenBSD patches for chromium src (webrtc)
# make dns-fallback : no net during build, pre-made files/dns-fallback.json
# make gn_args-system : helper to list webrtc gn args and display system one

_TMP=		/tmp/signal-desktop-${V}
_SIGNALAPP_GH=	https://raw.githubusercontent.com/signalapp
_BORING_GIT=	https://github.com/signalapp/boring.git
_SIGNAL_GH=	${_SIGNALAPP_GH}/Signal-Desktop/
_SQLCIPHER_GH=	${_SIGNALAPP_GH}/node-sqlcipher/
_SQLCIPHER_LOCK=deps/extension/Cargo.lock
_LIBSIGNAL_GH=	${_SIGNALAPP_GH}/libsignal/
_RINGRTC_GH=	${_SIGNALAPP_GH}/ringrtc/

versions:
	# make versions
	@mkdir -p ${_TMP} ;						\
	ftp -VMo ${_TMP}/package.json ${_SIGNAL_GH}/v${V}/package.json ;\
	_ringrtc_v=$$(grep "@signalapp/ringrtc"				\
		${_TMP}/package.json | awk -F ":" '{print $$2}' |	\
		sed -E 's#("|,| )##g') ;				\
	_libsignal_v=$$(grep "@signalapp/libsignal-client"		\
		${_TMP}/package.json | awk -F ":" '{print $$2}' |	\
		sed -E 's#("|,| )##g') ;				\
	_sqlcipher_v=$$(grep "@signalapp/sqlcipher"			\
		${_TMP}/package.json | awk -F ":" '{print $$2}' |	\
		sed -E 's#("|,| )##g') ;				\
	printf "# ELECTRON_V=%s\n" $$(awk /'"electron":'/'{print $$2}'	\
		${_TMP}/package.json | sed -E 's/("|,)//g') ;		\
	printf "# NODE_V=%s\n" $$(awk /'"node":'/'{print $$2}'		\
		${_TMP}/package.json | sed 's/"//g') ;			\
									\
	printf "# sqlcipher depends\n" ;				\
	printf "SQLCIPHER_V=\t%s\n" $$_sqlcipher_v ;			\
	ftp -VMo ${_TMP}/sqlcipher.Cargo.lock				\
		${_SQLCIPHER_GH}/v$${_sqlcipher_v}/${_SQLCIPHER_LOCK} ;	\
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
	_spqr_v=$$(grep "signalapp/SparsePostQuantumRatchet"		\
		${_TMP}/libsignal.Cargo.lock |				\
		uniq | awk -F '#|"' '{print $$3}') ;			\
	printf "BORING_ID=\t%s\n" $$_boring_v ;				\
	printf "CURVE_ID=\t%s\n" $$_curve_v ;				\
	printf "SPQR_ID=\t%s\n" $$_spqr_v ;				\
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
	@which jq >/dev/null
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

# handle multiple cargo files
modcargo-gen-crates:
	@make extract >/dev/null 2>&1
	@echo '# run: make modcargo-gen-crates-licenses'
	@cat ${MODCARGO_CARGOS_TOML:toml=lock} | awk '\
		/^name = / { n=$$3; gsub("\"", "", n); } \
		/^version = / { v=$$3; gsub("\"", "", v); } \
		/^source = "registry\+.*github.com.*crates\.io-index"/ \
			{ print "MODCARGO_CRATES +=	" n "	" v; }' | \
		sort | uniq

# target chromium <milestone>.0.${WEBRTC_V}
# check https://chromiumdash.appspot.com/branches to know the milestone
# check ports/www/chromium to choose the closest version
# https://cvsweb.openbsd.org/cgi-bin/cvsweb/ports/www/chromium/Makefile
chromium-patches:
	make extract
	@mkdir -p ${_TMP}
	# cvs co -D 20250801 -d chromium ports/www/chromium
	# remember to update cvs co -D "..." if you change targeted version
	@if [ -d ${_TMP}/chromium ]; then \
		echo "${_TMP}/chromium exists, skip cvs co" ; \
	else \
		cd ${_TMP} && \
		cvs co -D 20250801 -d chromium ports/www/chromium ; \
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
		${_PBUILD} ${MODNPM_CMD} run build:dns-fallback && \
		cat ${WRKSRC}/build/dns-fallback.json

_gn_args-list:
# run under _pbuild
	# ${WRKDIR}/gn_args.list
	@if [ ! -e "${WRKDIR}/gn_args.list" ] ; then \
		cd ${WEBRTC_SRC} && ${SETENV} ${CONFIGURE_ENV} ${MAKE_ENV} \
			gn args out/release --list > ${WRKDIR}/gn_args.list ; \
	fi

gn_args-system:
	make configure
	${_PBUILD} make _gn_args-list
	@_systems=$$(grep -C0 -e '^[^[:space:]]*use_system_.*' \
		${WRKDIR}/gn_args.list) ; \
	for _system in $$_systems; do \
		grep -A1 "^$$_system" ${WRKDIR}/gn_args.list | \
			grep -q true || \
			echo $$(grep -A1 "^$$_system" ${WRKDIR}/gn_args.list) \
		; \
	done
	@_systems=$$(grep -C0 -e '^[^[:space:]]*use_bundled_.*' \
		${WRKDIR}/gn_args.list) ; \
	for _system in $$_systems; do \
		grep -A1 "^$$_system" ${WRKDIR}/gn_args.list | \
			grep -q false || \
			echo $$(grep -A1 "^$$_system" ${WRKDIR}/gn_args.list) \
		; \
	done

.include "modules.inc"
.include "crates.inc"

.include <bsd.port.mk>
