# XXX start apps with --app= instead of a bundle electron copy
# runing command line without args bring a different config, diff ?
# note also some installer use fuses (hotfix into bin)

# https://www.electronjs.org/docs/latest/tutorial/fuses
# * runAsNode (Enabled), needed for vscode, ELECTRON_RUN_AS_NODE=1
# * cookieEncryption (Disabled) -> Enabled, change default ?
# * nodeOptions (Enabled) -> Disabled, change default ?
# * nodeCliInspect (Enabled) -> Disabled, change default ?
# * embeddedAsarIntegrityValidation (Disabled), !openbsd
# * onlyLoadAppFromAsar (Disabled), required on openbsd
# * loadBrowserProcessSpecificV8Snapshot (Disabled), XXX
# * grantFileProtocolExtraPrivileges (Enabled), XXX

# signal-desktop
#// Disables ELECTRON_RUN_AS_NODE
#[FuseV1Options.RunAsNode]: false,
#// Enables cookie encryption
#[FuseV1Options.EnableCookieEncryption]: true,
#// Disables the NODE_OPTIONS environment variable
#[FuseV1Options.EnableNodeOptionsEnvironmentVariable]: false,
#// Disables the --inspect and --inspect-brk family of CLI options
#[FuseV1Options.EnableNodeCliInspectArguments]: enableInspectArguments,
#// Enables validation of the app.asar archive on macOS/Windows
#[FuseV1Options.EnableEmbeddedAsarIntegrityValidation]:
#electronPlatformName === 'darwin' || electronPlatformName === 'win32',
#// Enforces that Electron will only load your app from "app.asar" instead of
#// its normal search paths
#[FuseV1Options.OnlyLoadAppFromAsar]: true,

# teams-for-linux
#[FuseV1Options.EnableCookieEncryption]: true,

# XXX something to consider
#WARNING: --openssl-no-asm will result in binaries that do not take advantage
#         of modern CPU cryptographic instructions and will therefore be slower.
#         Please refer to BUILDING.md
#WARNING: warnings were emitted in the configure phase

# XXX .node detection in pkg tools
# @bin *.node is wrong ?

# XXX services/device/device_service.cc crash
# NOTREACHED_IN_MIGRATION() << "Serial devices not supported on this platform.";

BROKEN-i386=v8/src/compiler/turboshaft/int64-lowering-reducer.h:295:24: error:
# call to member function 'Word32Constant' is ambiguous
# (but will probably run out of memory linking under DPB even if fixed)
BROKEN-powerpc64=Check failed: false. OS architecture not handled. (powerpc64)

USE_WXNEEDED=		Yes

DPB_PROPERTIES=		parallel parallel2
.if ${MACHINE_ARCH:Mi386}
DPB_PROPERTIES+=	lonesome
.endif

COMMENT=		cross-platform desktop applications

# sync with electron.port.mk
ELECTRON_V=		35.3.0

# make update-patches happy
FIX_EXTRACT_PERMISSIONS=Yes

DIST_TUPLE=		github electron electron v${ELECTRON_V} .

CATEGORIES=		www

HOMEPAGE=		https://www.electronjs.org/

MAINTAINER=		Fabien Romano <fabien@openbsd.org>

# MIT
PERMIT_PACKAGE=		Yes

# XXX implement make versions to automate this task
# See electron/DEPS for versions, post-extract & pre-patch
CHROMIUM_V=		134.0.6998.205
NODE_V=			22.14.0
NAN_V=			e14bdcd1f72d62bca1d541b66da43130384ec213
SQUIRREL_MAC_V=		0e5d146ba13101a1302d59ea6e6e0b3cace4ae38
REACTIVEOBJC_V=		74ab5baccc6f7202c8ac69a8d1e152c29dc1ea76
MANTLE_V=		78d3966b3c331292ea29ec38661b25df0a245948
ENGFLOW_V=		955335c30a752e9ef7bff375baab5e0819b6c00d
# See chromium/third_party/node/node_modules.tar.gz.sha1
NODE_MODULES_HASH=	59332695e189485e2e2b06e60e4d49d3d54b8e92

DIST_TUPLE+=		github nodejs node v${NODE_V} .
DIST_TUPLE+=		github nodejs nan ${NAN_V} .
DIST_TUPLE+=		github Squirrel Squirrel.Mac ${SQUIRREL_MAC_V} .
DIST_TUPLE+=		github ReactiveCocoa ReactiveObjC ${REACTIVEOBJC_V} .
DIST_TUPLE+=		github Mantle Mantle ${MANTLE_V} .
DIST_TUPLE+=		github EngFlow reclient-configs ${ENGFLOW_V} .

SITES.chromium=		http://distfiles.opencrew.tech/chromium/
DISTFILES.chromium=	chromium-${CHROMIUM_V}.tgz

SITES.nodemodule=https://commondatastorage.googleapis.com/chromium-nodejs/
DISTFILES.nodemodule=	chromium-nodejs-{}${NODE_MODULES_HASH}

EXTRACT_CASES+=		chromium-nodejs-${NODE_MODULES_HASH});;

# uses pledge()
WANTLIB += EGL FLAC GL Lerc X11 X11-xcb Xau Xcomposite Xcursor
WANTLIB += Xdamage Xdmcp Xext Xfixes Xft Xi Xinerama Xrandr Xrender
WANTLIB += Xtst Xxf86vm aom atk-1.0 atk-bridge-2.0 atspi c cairo
WANTLIB += cairo-gobject cares cbor crc32c crypto cups dav1d dbus-1
WANTLIB += double-conversion drm epoll-shim epoxy event execinfo
WANTLIB += expat ffi fido2 fontconfig freetype fribidi gbm gcrypt
WANTLIB += gdk-3 gdk_pixbuf-2.0 gio-2.0 glib-2.0 gmodule-2.0 gobject-2.0
WANTLIB += gpg-error graphite2 gthread-2.0 gtk-3 harfbuzz harfbuzz-gobject
WANTLIB += harfbuzz-subset icudata icui18n icuuc intl jpeg kvm
WANTLIB += lcms2 lzma m nghttp2 nspr4 nss3 nssutil3 ogg openh264
WANTLIB += opus pango-1.0 pangocairo-1.0 pangoft2-1.0 pcre2-8
WANTLIB += pixman-1 plc4 plds4 png pthread secret-1 sharpyuv smime3
WANTLIB += snappy sndio tiff udev usbhid util vpx wayland-client
WANTLIB += wayland-cursor wayland-egl webp webpdemux webpmux xcb
WANTLIB += xcb-dri2 xcb-glx xcb-render xcb-shm xkbcommon xml2
WANTLIB += xshmfence xslt z zstd

# Electron depends on Chromium and Node which are bundled&patched all together :
# 1. (optionnal) patches/pre-patch, ensure electron patches apply correctly
# 2. pre-patch walk over electron/patches/config.json, apply all .patches files
# 3. apply www/chromium/patches from patches/chromium, see make chromium-patches
# 4. solve any conflicts with electron, apply custom patches in patches/conflict
# 5. apply common *BSD patches from patches/electron
# 6. apply OpenBSD electron's port specific patches
ELECTRON_PATCH=	${WRKSRC}/electron/patches/config.json
.if empty(_GEN_PATCHES)
# pre-patch electron (1-2) > ALL_PATCHFILES(3) > PATCH_LIST(4-6)
ALL_PATCHFILES=	${PATCHDIR}/chromium/patch-*
PATCH_CASES+=	${PATCHDIR}/chromium/patch-*) \
		    ${PATCH} ${PATCH_DIST_ARGS} \
		    -z .orig.chromium \
		    -d ${WRKSRC}/ <$$patchfile ;;
PATCH_LIST=	patch-* electron/patch-* conflict/patch-*
.else # pre-patch only, see targets chromium-patches
ALL_PATCHFILES=
PATCH_LIST=
.endif

COMPILER=	ports-clang

MODULES=	devel/yarn lang/clang lang/python x11/qt5

MODCLANG_VERSION=	19
MODPY_RUNDEP=		No
MODQT5_DEPS=		No
MODYARN_TARGETS=	${WRKSRC}/electron ${WRKSRC}/electron/spec

RUN_DEPENDS+=	devel/desktop-file-utils \
		devel/libnotify \
		devel/xdg-utils \
		fonts/noto/fonts \
		graphics/libexif \
		x11/gtk+3,-main \
		x11/gtk+4,-guic \
		x11/gtk+3,-cups

BUILD_DEPENDS+=	archivers/bzip2 \
		audio/pulseaudio \
		devel/bison \
		devel/gperf \
		devel/gn \
		devel/ninja \
		devel/rust-bindgen \
		lang/node \
		lang/rust \
		shells/bash \
		sysutils/flock \
		sysutils/pciutils \
		x11/py-xcbgen${MODPY_FLAVOR} \
		x11/qt5/qtbase,-main \
		${MODGCC4_CPPDEP} \
		${RUN_DEPENDS}

LIB_DEPENDS+=	archivers/snappy \
		audio/flac \
		audio/opus \
		devel/crc32c \
		devel/epoll-shim \
		devel/highway \
		devel/pango \
		graphics/jpeg \
		graphics/lcms2 \
		graphics/libwebp \
		graphics/openjp2 \
		graphics/png \
		graphics/tiff \
		math/double-conversion \
		multimedia/aom \
		multimedia/dav1d \
		multimedia/libvpx \
		multimedia/openh264 \
		net/libcares \
		print/cups,-libs \
		security/libgcrypt \
		security/libgpg-error \
		security/nss \
		sysutils/libudev-openbsd \
		textproc/icu4c \
		textproc/libxml \
		textproc/libxslt \
		www/nghttp2 \
		x11/gnome/at-spi2-core \
		x11/gnome/libsecret \
		x11/gtk+3,-main \
		x11/xkbcommon \
		${MODGCC4_CPPLIBDEP}

TEST_DEPENDS+=	devel/py-dbusmock \
		x11/dbus-python \
		devel/py-gobject3 \
		devel/glib2

USE_GMAKE=	Yes

# needed in early stage, for porters only ?
DEBUG_PACKAGES=	${BUILD_PACKAGES}

# comment only to test
#NO_TEST=manual test only, see do-test

.include <bsd.own.mk>

SUBST_VARS+=	ELECTRON_V MODCLANG_VERSION WRKDIR WRKSRC

# Collect all DISTS under 'src'
WRKDIST=	${WRKDIR}/src
WRKSRC=		${WRKDIR}/src

BUILD_TARGET=	electron \
		electron:node_headers \
		chromedriver \
		licenses \
		version

DIST_TARGET=	electron/${ELECTRON_V}

# GN_SYSTEM_LIBS : See ${WRKSRC}/build/linux/unbundle/README
# These libraries are used from the system and the build infrastructure
# removes them from the bundled third_party directory and replaces them
# with hooks to use them from the system.
# Note, Some GN_SYSTEM_LIBS just change args, prefer GN_SYSTEM_LIBS to further
# reduce tarball based on this list.
GN_SYSTEM_LIBS=	crc32c \
		dav1d \
		double-conversion \
		flac \
		fontconfig \
		freetype \
		harfbuzz-ng \
		highway \
		icu \
		libaom \
		libdrm \
		libjpeg \
		libpng \
		libsecret \
		libvpx \
		libwebp \
		libxml \
		libxslt \
		openh264 \
		opus \
		snappy \
		zstd

# make gn_args-system, search ${WRKDIR}/gn_args-electron.list use_system/bundled
GN_ARGS=	use_system_cares=true \
		use_system_nghttp2=true
# pdfium only
GN_ARGS+=	use_system_lcms2=true \
		use_system_libopenjpeg2=true \
		use_system_libpng=true \
		use_system_libtiff=true \
		use_system_zlib=true

# make gn_args-check, check www/chromium against ${WRKDIR}/gn_args-electron.list
# C++20 vs. system libc++, use_custom_libcxx=true (default)
# XXX todo, test use_custom_libunwind=false (default), wasm support needed ?
EXTRA_CPPFLAGS=	-I${LOCALBASE}/include/libepoll-shim \
		-idirafter ${LOCALBASE}/include -idirafter ${X11BASE}/include
GN_ARGS+=	clang_use_chrome_plugins=false \
		disable_fieldtrial_testing_config=true \
		enable_backup_ref_ptr_support=false \
		enable_hangout_services_extension=true \
		enable_remoting=false \
		enable_rust=false \
		extra_cppflags=\"${EXTRA_CPPFLAGS}\" \
		fatal_linker_warnings=false \
		icu_use_data_file=false \
		treat_warnings_as_errors=false \
		use_allocator_shim=false \
		use_custom_libunwind=true \
		use_kerberos=false \
		use_pulseaudio=true \
		use_sndio=true \
		use_sysroot=false \
		v8_enable_cet_ibt=true

# rust
RUSTC_VERSION!!=rustc -V
MAKE_ENV+=	RUSTC_BOOTSTRAP=1
GN_ARGS+=	enable_rust=true \
		rust_sysroot_absolute=\"${LOCALBASE}\" \
		rustc_version=\"${RUSTC_VERSION}\"

# XXX chromium, notyet
# Indicates if VA-API-based hardware acceleration is to be used. This
# is typically the case on x86-based ChromeOS devices.
# VA-API should also be compiled by default on x11/wayland linux devices
# using x86/x64.
GN_ARGS+=	use_vaapi=false

_EXTRA_LDFLAGS=-L${LOCALBASE}/lib -L${X11BASE}/lib
.if ${MACHINE_ARCH} == "aarch64"
GN_ARGS+=	extra_ldflags=\"${_EXTRA_LDFLAGS}\"
PKG_ARGS+=	-Dswiftshader=0
FFMPEG_TARGET=	arm64
.elif ${MACHINE_ARCH} == "amd64"
BUILD_DEPENDS+=	devel/nasm
GN_ARGS+=	extra_ldflags=\"${_EXTRA_LDFLAGS}\"
PKG_ARGS+=	-Dswiftshader=1
FFMPEG_TARGET=	x64
.elif ${MACHINE_ARCH} == "i386"
BUILD_DEPENDS+=	devel/nasm
GN_ARGS+=	extra_ldflags=\"${_EXTRA_LDFLAGS} -Wl,--no-keep-memory\"
PKG_ARGS+=	-Dswiftshader=1
FFMPEG_TARGET=	ia32
.else
PKG_ARGS+=	-Dswiftshader=0
.endif

FFMPEG_BRAND=Chrome
FFMPEG_BDIR=${WRKSRC}/third_party/ffmpeg/build.${FFMPEG_TARGET}.openbsd/${FFMPEG_BRAND}
FFMPEG_CDIR=${WRKSRC}/third_party/ffmpeg/chromium/config/${FFMPEG_BRAND}/openbsd/${FFMPEG_TARGET}

GN_ARGS+=	ffmpeg_branding=\"${FFMPEG_BRAND}\" \
		proprietary_codecs=true

# XXX dwz doesn't work with chromium yet
# dwz: .debug/electron.dbg: Too many DIEs, not optimizing
DWZ = :

# always build with symbol, bsd.port.mk will strip
GN_ARGS+=	symbol_level=1

# always link static into bin, no component
GN_ARGS+=	is_component_build=false \
		is_component_ffmpeg=false

# do not use lto, otherwise it needs -fno-ret-protector & -mno-retpoline
GN_ARGS+=	use_thin_lto=false \
		thin_lto_enable_optimizations=true

GN_ARGS+=	override_electron_version=\"${ELECTRON_V}\"

# XXX need chrome-linux-${CHROMIUM_V}-llvm<XX>.profdata${EXTRACT_SUFX}
GN_ARGS+=	chrome_pgo_phase=0

BUILDTYPE=	Release
BUILDDIR=	${WRKSRC}/out/${BUILDTYPE}
ELECTRON_GN=	//electron/build/args/release.gn
MAKE_ENV+=	ELECTRON_OUT_DIR=${BUILDTYPE}
TEST_ENV+=	ELECTRON_OUT_DIR=${BUILDTYPE}

post-extract:
	# setup distfiles into src
	mv ${WRKDIR}/chromium-${CHROMIUM_V} ${WRKSRC}
	mv ${WRKDIR}/electron-${ELECTRON_V} ${WRKSRC}/electron
	mkdir -p ${WRKSRC}/third_party/node/node_modules
	tar -xzf ${DISTDIR}/chromium-nodejs-${NODE_MODULES_HASH} \
		-C ${WRKSRC}/third_party/node/node_modules
	mv ${WRKDIR}/node-${NODE_V} ${WRKSRC}/third_party/electron_node
	mv ${WRKDIR}/nan-${NAN_V} ${WRKSRC}/third_party/nan
	mv ${WRKDIR}/Squirrel.Mac-${SQUIRREL_MAC_V} \
		${WRKSRC}/third_party/squirrel.mac
	mkdir -p ${WRKSRC}/third_party/squirrel.mac/vendor
	mv ${WRKDIR}/ReactiveObjC-${REACTIVEOBJC_V} \
		${WRKSRC}/third_party/squirrel.mac/vendor/ReactiveObjC
	mv ${WRKDIR}/Mantle-${MANTLE_V} \
		${WRKSRC}/third_party/squirrel.mac/vendor/Mantle
	mv ${WRKDIR}/reclient-configs-${ENGFLOW_V} \
		${WRKSRC}/third_party/engflow-reclient-configs
	# tweek some patches to apply cleanly
# XXX call there so we can fix yarn.lock before module's post-extract
	@if cd ${PATCHDIR}/pre-patches 2>/dev/null; then \
		for p in ${PATCHDIR}/pre-patches/patch-*; do \
			${ECHO_MSG} "===>   Applying pre-patch $${p}"; \
			${PATCH} ${PATCH_DIST_ARGS} \
				-z .orig.pre-patch \
				-d ${WRKSRC}/ < $${p} ; \
		done; \
	fi

pre-patch:
	# apply electron patches
	@for pair in $$(grep ':' ${ELECTRON_PATCH} | cut -f 4,8 -d '"' ); do \
		from=${WRKDIR}/$$(echo $${pair} | cut -f 1 -d '"') ; \
		to=${WRKDIR}/$$(echo $${pair} | cut -f 2 -d '"') ; \
		for p in $$(cat $${from}/.patches); do \
			echo "===>   Applying $${from}/$${p} into $${to}"; \
			${PATCH} -p1 -z .orig.electron \
				-d $${to} -i $${from}/$${p}; \
			grep -R '^rename' $${from}/$${p} | \
				cut -f 3 -d ' ' | xargs -r -L2 sh -c \
				"cd $${to} && mv \$$@" mv ; \
		done ; \
	done

pre-configure:
	@ln -sf ${MODPY_BIN} ${WRKDIR}/bin/python
	@ln -sf ${LOCALBASE}/bin/llvm-ar-${MODCLANG_VERSION} ${WRKDIR}/bin/ar
	cd ${WRKSRC}/media/ffmpeg && \
		${MODPY_BIN} scripts/build_ffmpeg.py openbsd ${FFMPEG_TARGET} \
		--config-only --branding=${FFMPEG_BRAND}
	cd ${FFMPEG_BDIR} && ${GMAKE} ffversion.h
	${INSTALL_DATA_DIR} ${FFMPEG_CDIR}
.for f in config.h config.asm config_components.h \
    libavcodec libavformat libavutil
	cp -pR ${FFMPEG_BDIR}/${f} ${FFMPEG_CDIR}
.endfor
	mkdir -p ${WRKSRC}/third_party/node/openbsd/node-openbsd/bin
	ln -sf ${TRUEPREFIX}/bin/node \
		${WRKSRC}/third_party/node/openbsd/node-openbsd/bin/node
.for f in \
    base/process/process_handle_openbsd.cc \
    build/gn_run_binary.py \
    build/rust/rust_bindgen.gni \
    build/rust/rust_bindgen_generator.gni \
    v8/tools/run.py \
    tools/protoc_wrapper/protoc_wrapper.py \
    third_party/blink/renderer/build/scripts/run_with_pythonpath.py \
    third_party/electron_node/src/env.cc
	${SUBST_CMD} ${WRKSRC}/${f}
.endfor

# Configuration consists of two steps:
# 1. replace the specified bundled libraries with hooks to use the system libs
# 2. run gn with the appropriate configuration arguments
do-configure:
	cd ${WRKSRC} && ${SETENV} ${MAKE_ENV} \
		build/linux/unbundle/replace_gn_files.py \
		--system-libraries ${GN_SYSTEM_LIBS}
# XXX how chromium bundle its gn ? see make tarball
#	cd ${WRKSRC}/tools/gn && ${SETENV} ${MAKE_ENV} \
#		LDFLAGS=-L${LOCALBASE}/lib ${MODPY_BIN} \
#		bootstrap/bootstrap.py --no-clean -s --skip-generate-buildfiles
	cd ${WRKSRC} && ${SETENV} ${CONFIGURE_ENV} \
		gn gen out/${BUILDTYPE} \
		--args="import(\"${ELECTRON_GN}\") ${GN_ARGS}"

do-build:
	@cd ${WRKSRC} && ${SETENV} ${MAKE_ENV} \
		ninja -j ${MAKE_JOBS} -C out/${BUILDTYPE} ${BUILD_TARGET}

do-install:
	${INSTALL_DATA_DIR} ${PREFIX}/${DIST_TARGET}
.for f in electron mksnapshot v8_context_snapshot_generator
	${INSTALL_PROGRAM} ${BUILDDIR}/${f} ${PREFIX}/${DIST_TARGET}
.endfor
	${SUBST_PROGRAM} ${FILESDIR}/electron \
		${PREFIX}/${DIST_TARGET}/electron.sh
	${SUBST_PROGRAM} ${FILESDIR}/electron_nosandbox \
		${PREFIX}/${DIST_TARGET}/electron_nosandbox.sh
	ln -s ${TRUEPREFIX}/${DIST_TARGET}/electron.sh \
		${PREFIX}/bin/electron
	${INSTALL_PROGRAM} ${BUILDDIR}/chromedriver.unstripped \
		${PREFIX}/${DIST_TARGET}/chromedriver
	# copy .pak
	${INSTALL_DATA} ${BUILDDIR}/*.pak ${PREFIX}/${DIST_TARGET}
	# copy locales & ressources
	${INSTALL_DATA_DIR} ${PREFIX}/${DIST_TARGET}/locales
	${INSTALL_DATA} ${BUILDDIR}/locales/* ${PREFIX}/${DIST_TARGET}/locales
	${INSTALL_DATA_DIR} ${PREFIX}/${DIST_TARGET}/resources
	cp -Rp ${BUILDDIR}/resources/* ${PREFIX}/${DIST_TARGET}/resources
	@chown -R ${SHAREOWN}:${SHAREGRP} ${PREFIX}/${DIST_TARGET}/resources
	# ANGLE, EGL, Vk, ...
.for f in libEGL libGLESv2 libvk_swiftshader libVkICD_mock_icd
	${INSTALL_DATA} ${BUILDDIR}/${f}.so ${PREFIX}/${DIST_TARGET}
.endfor
	${INSTALL_DATA} ${BUILDDIR}/libvulkan.so.1 \
		${PREFIX}/${DIST_TARGET}/libvulkan.so
.if ${MACHINE_ARCH} != "aarch64"
	# SwiftShader
	${INSTALL_DATA} ${BUILDDIR}/libvk_swiftshader.so \
		${PREFIX}/${DIST_TARGET}
.endif
	# sandbox, unveil & pledge
	${INSTALL_DATA_DIR} ${PREFIX}/share/examples/electron
	${INSTALL_DATA} ${FILESDIR}/unveil.gpu ${PREFIX}/share/examples/electron
.for f in main utility_audio utility_network utility_video
	${INSTALL_DATA} ${FILESDIR}/{pledge,unveil}.${f} \
		${PREFIX}/share/examples/electron
.endfor
	# data
.for f in LICENSE LICENSES.chromium.html protoc snapshot_blob.bin \
    v8_context_snapshot.bin version vk_swiftshader_icd.json
	${INSTALL_DATA} ${BUILDDIR}/${f} ${PREFIX}/${DIST_TARGET}
.endfor
	# electron
	${INSTALL_DATA_DIR} ${PREFIX}/${DIST_TARGET}/node_headers
	cp -Rp ${BUILDDIR}/gen/node_headers/* \
		${PREFIX}/${DIST_TARGET}/node_headers
	@chown -R ${SHAREOWN}:${SHAREGRP} ${PREFIX}/${DIST_TARGET}/node_headers
	${INSTALL_DATA_DIR} ${PREFIX}/${DIST_TARGET}/gen/electron/buildflags
	${INSTALL_DATA} ${BUILDDIR}/gen/electron/buildflags/* \
		${PREFIX}/${DIST_TARGET}/gen/electron/buildflags
	${INSTALL_DATA_DIR} ${PREFIX}/${DIST_TARGET}/gen/v8
	${INSTALL_DATA} ${BUILDDIR}/gen/v8/embedded.S \
		${PREFIX}/${DIST_TARGET}/gen/v8/embedded.S

# Tests requirements :
# ? --no-sandbox (hard to setup, not tested)
# * needs /etc/electron for pledge/unveil :
# -> unveil "/	rwcx" (/etc/electron/unveil.main)
# -> unveil "/	rwcx" (/etc/electron/unveil.utility_network)
# * env DISPLAY=:1
# -> Xvfb :1 &
# * openfiles max 1024 isn't enouch
# -> adjust _pbuild to :openfiles-max=2048: (/etc/login.conf)

# some note about tests :
# * openbsd use a wrapper, skip bin/electron check
# -> electron/spec/api-app-spec.ts
# * test crashReporter, check if its actually disabled from source ?
# -> electron/spec/disabled-tests.json

do-test:
	rm -rf ${WRKDIR}/.config
	mkdir -p ${WRKDIR}/.config
	ulimit -Sn `ulimit -Hn` && \
	cd ${WRKSRC}/electron && ${SETENV} ${TEST_ENV} \
		HOME=${WRKDIR} \
		LD_LIBRARY_PATH=${BUILDDIR} \
		DISPLAY=:1 \
		npm run test -- --ci

### targets for port maintainer(s)

_compile_commands:
# run under _pbuild
	cd ${WRKSRC} && ${MODPY_BIN} tools/clang/scripts/generate_compdb.py \
		-p out/${BUILDTYPE} -o ${WRKSRC}/compile_commands.json \
		${BUILD_TARGET}
	mkdir -p ${WRKSRC}/.cache && chmod a+rwx ${WRKSRC}/.cache

compile_commands:
	${_PBUILD} make _compile_commands

# prepare custom tarball for stable fetch
# XXX need ~20G, usualy run with a custom _SRC
# XXX need custom tar -R (reproducible) diff, use gtar alternative ?
_SRC?=		${WRKDIR}/chromium
_VER?=		${CHROMIUM_V}
_PKG?=		chromium
_FETCH?=	https://chromium.googlesource.com/chromium/src.git \
		+refs/tags/${_VER}
# handmade exclusion list based on manual compare with official tarball
_EXCLUDE+=\
	-path '*/.git/*' \
	-o -path '*/out/*' \
	-o -path '*/chrome/test/data/*' \
	-o -path '*/content/test/data/*' \
	-o -path '*/courgette/testdata/*' \
	-o -path '*/extensions/test/data/*' \
	-o -path '*/media/test/data/*' \
	-o -path '*/third_party/blink/tools/*' \
	-o -path '*/third_party/blink/web_tests/*' \
	-o -path '*/third_party/breakpad/breakpad/src/processor/testdata/*'\
	-o -path '*/third_party/catapult/tracing/test_data/*' \
	-o -path '*/third_party/hunspell/tests/*' \
	-o -path '*/third_party/hunspell_dictionaries/*' \
	-o -path '*/third_party/liblouis/src/tests/braille-specs/*' \
	-o -path '*/third_party/xdg-utils/tests/*' \
	-o -path '*/third_party/depot_tools/*' \
	-o -path '*/__pycache__/*' -o -name '*.pyc' \
	-o -path '*/v8/test*/*'
# third parties not needed to build electron
.for _f in ${GN_SYSTEM_LIBS}
_EXCLUDE+=	-o -path './src/third_party/${_f}/*'
.endfor
# required files to build
_INCLUDE+=\
	-o -path './src/third_party/libxml/chromium/*' \
	-o -path './src/third_party/devtools-frontend/*/out/*' \
	-o -name '*.gn*' -o -name '*.gyp*' \
	-o -name '*.isolate' -o -name '*.tq'
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
	    --with_branch_heads --with_tags && \
	HOME=${_SRC} ${MODPY_BIN} build/util/lastchange.py \
	    -o build/util/LASTCHANGE && \
	HOME=${_SRC} ${MODPY_BIN} build/util/lastchange.py \
	    -m GPU_LISTS_VERSION --revision-id-only \
	    --header gpu/config/gpu_lists_version.h && \
	HOME=${_SRC} ${MODPY_BIN} build/util/lastchange.py \
	    -m SKIA_COMMIT_HASH -s third_party/skia \
	    --header skia/ext/skia_commit_hash.h && \
	HOME=${_SRC} ${MODPY_BIN} build/util/lastchange.py \
	    -s third_party/dawn \
	    --revision gpu/webgpu/DAWN_VERSION \
	)
	# how google generated its tarball in the past ?
	cd ${_SRC} && \
	find ./src -type f -a \( ! \( ${_EXCLUDE} \) ${_INCLUDE} \) \
	    | sort > files && \
	tar -cRzf ${_PKG}-${_VER}.tgz -I files \
	    -s '|src/|${_PKG}-${_VER}/|' && \
	sha256 -b ${_PKG}-${_VER}.tgz

_TMP = /tmp/electron-${ELECTRON_V}
chromium-patches:
	make -D _GEN_PATCHES patch
	# remember to update cvs co -D "..." if you change targeted version
	if [ -d ${_TMP}/chromium ]; then \
		echo "${_TMP}/chromium exists, skip cvs co" ; \
	else \
		mkdir -p ${_TMP} && cd ${_TMP} && \
		cvs co -D '2025/03/23' -d chromium ports/www/chromium ; \
	fi
	# test chromium patches on top of electron patch (pre-patch)
	rm -rf ${_TMP}/patches/chromium*
	mkdir -p ${_TMP}/patches/chromium{,.rej,.miss,.new}
	for p in ${_TMP}/chromium/patches/patch-*; do \
		f=$$(grep -m1 'Index: ' $$p | sed -e 's/.*: //' ) ; \
		if grep -q "@@ -0,0" $$p; then \
			cp $${p} ${_TMP}/patches/chromium/ ; \
			cp $${p} ${_TMP}/patches/chromium.new/ ; \
		elif [ -f "${WRKSRC}/$$f" ]; then \
			${PATCH} ${PATCH_DIST_ARGS} -sfC -z .orig.chromium \
				-d ${WRKSRC} < $${p} && \
			cp $${p} ${_TMP}/patches/chromium/ || \
			cp $${p} ${_TMP}/patches/chromium.rej/ ; \
		else \
			echo "missing ${WRKSRC}/$$f" ; \
			cp $${p} ${_TMP}/patches/chromium.miss/ ; \
		fi ; \
	done
	@echo "rejected:"
	@ls ${_TMP}/patches/chromium.rej
	# if ok, copy ${_TMP}/patches/chromium into port && make clean

_gn_args-electron-list:
# run under _pbuild
	# ${WRKDIR}/gn_args-electron.list
	@if [ ! -e "${WRKDIR}/gn_args-electron.list" ] ; then \
		cd ${WRKSRC} && ${SETENV} ${CONFIGURE_ENV} \
			gn args out/${BUILDTYPE} \
			--list > ${WRKDIR}/gn_args-electron.list ; \
	fi

_gn_args-chromium-list:
# run under _pbuild
	# ${WRKDIR}/gn_args-chromium.list
	@if [ ! -e "${WRKDIR}/gn_args-chromium.list" ] ; then \
		cd ${PORTSDIR}/www/chromium ; \
		_wrksrc=$$(make show=WRKSRC) ; \
		cd $$_wrksrc && ${SETENV} ${CONFIGURE_ENV} \
			$$_wrksrc/out/${BUILDTYPE}/gn args out/${BUILDTYPE} \
			--list > ${WRKDIR}/gn_args-chromium.list ; \
	fi

gn_args-diff:
	make configure
	${_PBUILD} make _gn_args-electron-list
	# configure www/chromium in order to compare
	cd ${PORTSDIR}/www/chromium && make configure ; cd -
	${_PBUILD} make _gn_args-chromium-list
	# ${WRKDIR}/gn_args.diff
	@${_PBUILD} sh -c \
	"diff -uN ${WRKDIR}/gn_args{-chromium,}.list > ${WRKDIR}/gn_args.diff" \
		|| wc -l ${WRKDIR}/gn_args.diff

gn_args-check:
	make configure
	${_PBUILD} make _gn_args-electron-list
	# check GN_ARGS from www/chromium
	@cd ${PORTSDIR}/www/chromium && make show=GN_ARGS \
	    | perl -pe 's/\\"[^"]*\\"(*SKIP)(*F)|\h+/$&\n/g' \
	    | sort \
	    | while IFS=';' read _gn ; do \
		_arg=$${_gn%%=*} ; \
		_value=$${_gn##*=} ; \
		grep -A1 "^$${_arg}$$" ${WRKDIR}/gn_args-electron.list \
		    | grep -q "$$_value" || \
		echo "Wrong" $$( \
		    grep -A1 "^$${_arg}$$" ${WRKDIR}/gn_args-electron.list) \
		    "\nInstead of $$_arg = $$_value"; \
	done

gn_args-system:
	make configure
	${_PBUILD} make _gn_args-electron-list
	@_systems=$$(grep -C0 -e '^[^[:space:]]*use_system_.*' \
		${WRKDIR}/gn_args-electron.list) ; \
	for _system in $$_systems; do \
		grep -A1 "^$$_system" ${WRKDIR}/gn_args-electron.list | \
			grep -q true || echo $$( \
			grep -A1 "^$$_system" ${WRKDIR}/gn_args-electron.list) \
		; \
	done
	@_systems=$$(grep -C0 -e '^[^[:space:]]*use_bundled_.*' \
		${WRKDIR}/gn_args-electron.list) ; \
	for _system in $$_systems; do \
		grep -A1 "^$$_system" ${WRKDIR}/gn_args-electron.list | \
			grep -q false || echo $$( \
			grep -A1 "^$$_system" ${WRKDIR}/gn_args-electron.list) \
		; \
	done

.include "modules.inc"

.include <bsd.port.mk>
