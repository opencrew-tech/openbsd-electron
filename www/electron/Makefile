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
ELECTRON_V=		41.1.1
ELECTRON_DIST=		electron/resources

# make update-patches happy
FIX_EXTRACT_PERMISSIONS=Yes

DIST_TUPLE=		github electron electron v${ELECTRON_V} .

CATEGORIES=		www

HOMEPAGE=		https://www.electronjs.org/

MAINTAINER=		Fabien Romano <fabien@openbsd.org>

# MIT
PERMIT_PACKAGE=		Yes

# make versions
# electron/v41.1.1/DEPS
CHROMIUM_V=	146.0.7680.166
NODE_V=		24.14.0
NAN_V=		675cefebca42410733da8a454c8d9391fcebfbc2
SQUIRREL_MAC_V=	0e5d146ba13101a1302d59ea6e6e0b3cace4ae38
REACTIVEOBJC_V=	74ab5baccc6f7202c8ac69a8d1e152c29dc1ea76
MANTLE_V=	78d3966b3c331292ea29ec38661b25df0a245948
ENGFLOW_V=	955335c30a752e9ef7bff375baab5e0819b6c00d
# chromium/146.0.7680.166/third_party/node/node_modules.tar.gz.sha1
NODE_MODULES_H=	93c8d9925d573861d892cec96b2b6c00fcf4659a

DIST_TUPLE+=	github nodejs node v${NODE_V} .
DIST_TUPLE+=	github nodejs nan ${NAN_V} .
DIST_TUPLE+=	github Squirrel Squirrel.Mac ${SQUIRREL_MAC_V} .
DIST_TUPLE+=	github ReactiveCocoa ReactiveObjC ${REACTIVEOBJC_V} .
DIST_TUPLE+=	github Mantle Mantle ${MANTLE_V} .
DIST_TUPLE+=	github EngFlow reclient-configs ${ENGFLOW_V} .

SITES.chromium=		http://distfiles.opencrew.tech/chromium/
DISTFILES.chromium=	chromium-${CHROMIUM_V}.tgz

SITES.nodemodule=https://commondatastorage.googleapis.com/chromium-nodejs/
DISTFILES.nodemodule=	chromium-nodejs-{}${NODE_MODULES_H}

EXTRACT_CASES+=		chromium-nodejs-${NODE_MODULES_H});;

# uses pledge()
WANTLIB += FLAC GL X11 Xcomposite Xdamage Xext Xfixes
WANTLIB += Xi Xrandr Xrender Xtst atk-1.0 atk-bridge-2.0
WANTLIB += atspi c cairo cairo-gobject cbor crc32c crypto
WANTLIB += cups dav1d dbus-1 double-conversion drm epoll-shim
WANTLIB += execinfo expat fido2 fontconfig freetype
WANTLIB += gbm gdk-3 gdk_pixbuf-2.0 gio-2.0 glib-2.0
WANTLIB += gmodule-2.0 gobject-2.0 gthread-2.0 gtk-3
WANTLIB += harfbuzz harfbuzz-subset intl jpeg kvm lcms2
WANTLIB += m nspr4 nss3 nssutil3 openh264 openjp2 opus
WANTLIB += pango-1.0 pangocairo-1.0 plc4 plds4 pthread
WANTLIB += secret-1 smime3 snappy sndio tiff udev usbhid
WANTLIB += util webp webpdemux webpmux xcb xkbcommon
WANTLIB += xml2 xshmfence xslt z zstd

# Electron depends on Chromium and Node which are bundled&patched all together :
# 1. (optionnal) patches/pre-patch, ensure electron patches apply correctly
# 2. pre-patch walk over electron/patches/config.json, apply all .patches files
# 3. apply www/chromium/patches from patches/chromium, make chromium-patches
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

MODULES=	devel/berry \
		lang/clang \
		lang/python \
		x11/qt5 \
		x11/qt6

MODCLANG_VERSION=	21
MODQT5_DEPS=		No
MODQT6_DEPS=		No
MODPY_RUNDEP=		No

MODBERRY_TARGETS=	${WRKSRC}/electron

MODBERRY_MODS+=graceful-fs

# electron-test-main use dbus-native fork on github:nornagon/dbus-native#master.
# cache import fails because it needs npm to rebuild (pack > cache) this one.
# the fork is only needed to use @nornagon/put in place of put
#https://github.com/sidorares/dbus-native/compare/master...nornagon:dbus-native:master
#https://github.com/carsonmcdonald/node-put/compare/master...nornagon:node-put:master
# @nornagon/put is published on npm, switch to resolution instead of making
# a local override specific to the fork.
# revert dbus-native to use official dbus-native (published) version
MODBERRY_GEN_OVERRIDES = dbus-native npm:dbus-native@latest
# fix put to use the fork @nornagon/put in place
MODBERRY_GEN_OVERRIDES+= put npm:@nornagon/put@latest

# XXX chromium ?
# + sysutils/libudev-openbsd VS LIB_DEPENDS ?
# - devel/libnotify
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
		devel/esbuild \
		devel/gperf \
		devel/ninja \
		devel/rollup \
		devel/rust-bindgen \
		lang/node \
		lang/rust \
		lang/rust,-rustfmt \
		shells/bash \
		sysutils/flock \
		sysutils/pciutils \
		x11/py-xcbgen \
		${MODQT5_LIB_DEPENDS} \
		${MODQT6_LIB_DEPENDS} \
		${MODGCC4_CPPDEP} \
		${RUN_DEPENDS}

# XXX
# LIB_DEPENDS net/libcares not needed for www/electron ?
# LIB_DEPENDS security/libgcrypt not needed for www/electron ?
# LIB_DEPENDS security/libgpg-error not needed for www/electron ?
# LIB_DEPENDS textproc/icu4c not needed for www/electron ?
# LIB_DEPENDS www/nghttp2 not needed for www/electron ?
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
# XXX remember to review strip_binary in .gn files
# (without DEBUG_PACKAGES, ports doesn't strip and the build should handle that)
DEBUG_PACKAGES=	${BUILD_PACKAGES}

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
# Some GN_SYSTEM_LIBS just change args, prefer GN_SYSTEM_LIBS to further reduce
# tarball content/size based on this list.
GN_SYSTEM_LIBS=	crc32c \
		dav1d \
		double-conversion \
		flac \
		fontconfig \
		freetype \
		harfbuzz-ng \
		libdrm \
		libjpeg \
		libpng \
		libsecret \
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

# NOTE. GN_SYSTEM_LIBS & GN_ARGS use_system_* are hard to maintain and also time
# consuming. Some of the depends may work assuming their ports got updated but
# going through some updates (lot of reverse deps) would take times and also
# represent a risk of revert if something goes wrong. On the other end Electron
# and Chromium are moving verry fast with many changes month by month so this
# update requirement isn't possible to acheive atm.
# XXX Ideally we need a way to move those depends just to make sure nothing
# use it when we enable the system shim.
# XXX make an exhaustive list to maintain
# GN_SYSTEM_LIBS+=highway, ports update + last tag < chromium depends
# GN_SYSTEM_LIBS+=icu, check to do (may work)

# XXX drop highway on chromium 146.0.7680.166
# highway 84379d1c73de9681b54fbe1c035a23c7bd5d272d 25/09/2025
# highway 1.3.0 from 14/08/2025, diff to check
# devel/highway 1.2.0, ports to update
# third_party/blink/renderer/platform/wtf/text/string_impl.h:368:5: error:
# unknown type name 'HWY_LANES_CONSTEXPR'
# GN_SYSTEM_LIBS+=highway

# XXX to test again on chromium 144.0.7559.236
# break with ICU 78.1
# ld.lld: error: undefined symbol: icu::UnicodeString::doReplace(
#	int, int, std::__Cr::basic_string_view<char16_t,
#	std::__Cr::char_traits<char16_t>>)
# >>> referenced by unistr.h:2024 (.../include/unicode/unistr.h:2024)
# >>> obj/v8/v8_base_without_compiler/js-date-time-format.o:
# (v8::internal::JSDateTimeFormat::TimeZoneId(
#	v8::internal::Isolate*, icu::TimeZone const&)
# GN_SYSTEM_LIBS+=icu

# make gn_args-check, check www/chromium against ${WRKDIR}/gn_args-electron.list
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
		use_system_libdrm=true \
		v8_enable_cet_ibt=true \
		use_qt5=true \
		use_qt6=true \
		moc_qt5_path=\"${MODQT5_MOC}\" \
		moc_qt6_path=\"${MODQT6_MOC}\"

# XXX disable by electron
# enable_cet_shadow_stack

# rust
MAKE_ENV+=	RUSTC_BOOTSTRAP=1
GN_ARGS+=	enable_rust=true \
		rust_sysroot_absolute=\"${LOCALBASE}\"

# pull in our patched sources for libaom and libvpx
GN_ARGS+=	use_vaapi=true
BUILD_DEPENDS+=	multimedia/aom:patch \
		multimedia/libvpx:patch

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

FFMPEG_BRAND=	Chrome
FFMPEG_SRC=	${WRKSRC}/third_party/ffmpeg
FFMPEG_CONFIG=	${FFMPEG_SRC}/chromium/config
FFMPEG_BDIR=	${FFMPEG_SRC}/build.${FFMPEG_TARGET}.openbsd/${FFMPEG_BRAND}
FFMPEG_CDIR=	${FFMPEG_CONFIG}/${FFMPEG_BRAND}/openbsd/${FFMPEG_TARGET}

GN_ARGS+=	ffmpeg_branding=\"${FFMPEG_BRAND}\" \
		proprietary_codecs=true

# XXX dwz doesn't work with chromium yet
# dwz: .debug/electron.dbg: Too many DIEs, not optimizing
DWZ = :

# always build with symbol, bsd.port.mk will strip
# XXX bsd.port.mk doesn't strip anymore, it does only to split debug-package
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
TEST_ENV+=	ELECTRON_OUT_DIR=${BUILDTYPE} \
		ELECTRON_EXE_PATH=${WRKSRC}/out/${BUILDTYPE}/electron

DEVFRONT_T =	${WRKSRC}/third_party/devtools-frontend/src/

post-extract:
	# setup distfiles into src
	mv ${WRKDIR}/chromium-${CHROMIUM_V} ${WRKSRC}
	mv ${WRKDIR}/electron-${ELECTRON_V} ${WRKSRC}/electron
	mkdir -p ${WRKSRC}/third_party/node/node_modules
	tar -xzf ${DISTDIR}/chromium-nodejs-${NODE_MODULES_H} \
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

pre-patch:
	# tweek some patches to apply cleanly
	@if cd ${PATCHDIR}/pre-patches 2>/dev/null; then \
		for p in ${PATCHDIR}/pre-patches/patch-*; do \
			${ECHO_MSG} "===>   Applying pre-patch $${p}"; \
			${PATCH} ${PATCH_DIST_ARGS} \
				-z .orig.pre-patch \
				-d ${WRKSRC}/ < $${p} ; \
		done; \
	fi
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
	# bundle libaom and libvpx for vaapi (internal header needed)
	mkdir -p ${WRKSRC}/third_party/libaom/source/libaom
	cd ${WRKDIR}/multimedia/aom/libaom-* && \
		pax -rw -s '/^.*${PATCHORIG}$$//' . \
		${WRKSRC}/third_party/libaom/source/libaom
	mkdir -p ${WRKSRC}/third_party/libvpx/source/libvpx
	cd ${WRKDIR}/multimedia/libvpx/libvpx-* && \
		pax -rw -s '/^.*${PATCHORIG}$$//' . \
		${WRKSRC}/third_party/libvpx/source/libvpx

post-patch:
	# force agnostic version of system bin
	ln -sf ${MODPY_BIN} ${WRKDIR}/bin/python
	ln -sf ${LOCALBASE}/bin/llvm-ar-${MODCLANG_VERSION} ${WRKDIR}/bin/ar
	# hotfix node bin into third_party/node
	mkdir -p ${WRKSRC}/third_party/node/openbsd/node-openbsd/bin
	ln -sf ${TRUEPREFIX}/bin/node \
		${WRKSRC}/third_party/node/openbsd/node-openbsd/bin/node
	# hotfix esbuild modules into third_party/devtools-frontend
	rm -rf ${DEVFRONT_T}/node_modules/esbuild
	ln -sf ${MODBERRY_INSTALL_DIST}/esbuild/node_modules/esbuild \
		${DEVFRONT_T}/node_modules/esbuild
	# hotfix esbuild bin
	mkdir -p ${DEVFRONT_T}/third_party/esbuild
	ln -sf ${LOCALBASE}/bin/esbuild \
		${DEVFRONT_T}/third_party/esbuild/esbuild
	# hotfix rollup modules into third_party/devtools-frontend
	rm -rf ${DEVFRONT_T}/node_modules/rollup
	ln -sf ${MODBERRY_INSTALL_DIST}/rollup/node_modules/rollup \
		${DEVFRONT_T}/node_modules/rollup
	# replace system path & variables in patch using SUBST_CMD
.for f in \
    base/base_paths_posix.cc \
    base/process/process_handle_openbsd.cc \
    build/gn_run_binary.py \
    build/rust/rust_bindgen.gni \
    build/rust/rust_bindgen_generator.gni \
    v8/tools/run.py \
    tools/protoc_wrapper/protoc_wrapper.py \
    third_party/blink/renderer/build/scripts/run_with_pythonpath.py \
    third_party/electron_node/src/env.cc \
    third_party/perfetto/src/base/utils.cc \
    third_party/vulkan-loader/src/loader/vk_loader_platform.h
	${SUBST_CMD} ${WRKSRC}/${f}
.endfor

pre-configure:
	# configure ffmpeg
	cd ${WRKSRC}/media/ffmpeg && \
		${MODPY_BIN} scripts/build_ffmpeg.py openbsd ${FFMPEG_TARGET} \
		--config-only --branding=${FFMPEG_BRAND}
	cd ${FFMPEG_BDIR} && ${GMAKE} ffversion.h
	${INSTALL_DATA_DIR} ${FFMPEG_CDIR}
.for f in config.h config.asm config_components.h config_components.asm \
    libavcodec libavformat libavutil
	cp -pR ${FFMPEG_BDIR}/${f} ${FFMPEG_CDIR}
.endfor

# Configuration consists of three steps:
# 1. replace the specified bundled libraries with hooks to use the system libs
# 2. bootstrap gn, the tool to generate ninja files
# 3. run gn with the appropriate configuration arguments
do-configure:
	cd ${WRKSRC} && \
		${SETENV} ${MAKE_ENV} ${MODPY_BIN} \
		build/linux/unbundle/replace_gn_files.py \
		--system-libraries ${GN_SYSTEM_LIBS}
	cd ${WRKSRC}/tools/gn && \
		${SETENV} ${MAKE_ENV} LDFLAGS=-L${LOCALBASE}/lib ${MODPY_BIN} \
		bootstrap/bootstrap.py --no-clean -s --skip-generate-buildfiles
	ln -fs ${WRKSRC}/out/${BUILDTYPE}/gn ${WRKDIR}/bin/gn
	cd ${WRKSRC} && ${SETENV} ${CONFIGURE_ENV} \
		${WRKSRC}/out/${BUILDTYPE}/gn gen out/${BUILDTYPE} \
		--args="import(\"${ELECTRON_GN}\") ${GN_ARGS}"

do-build:
	@cd ${WRKSRC} && ${SETENV} ${MAKE_ENV} \
		ninja -j ${MAKE_JOBS} -C out/${BUILDTYPE} ${BUILD_TARGET}

do-install:
	${INSTALL_DATA_DIR} ${PREFIX}/${DIST_TARGET}
.for f in electron mksnapshot v8_context_snapshot_generator chromedriver
	${INSTALL_PROGRAM} ${BUILDDIR}/${f} ${PREFIX}/${DIST_TARGET}
.endfor
	${SUBST_PROGRAM} ${FILESDIR}/electron \
		${PREFIX}/${DIST_TARGET}/electron.sh
	${SUBST_PROGRAM} ${FILESDIR}/electron_nosandbox \
		${PREFIX}/${DIST_TARGET}/electron_nosandbox.sh
	ln -s ${TRUEPREFIX}/${DIST_TARGET}/electron.sh \
		${PREFIX}/bin/electron
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
	${INSTALL_DATA} ${FILESDIR}/unveil.cdm ${PREFIX}/share/examples/electron
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
	# ports' install location
	${INSTALL_DATA_DIR} ${PREFIX}/${ELECTRON_DIST}

# Tests requires:
# *** Custom pledge/unveil configurations
# mkdir -p /etc/electron
# cp files/unveil* files/pledge* /etc/electron
# echo "/\trwcx" >> /etc/electron/unveil.main
# echo "/\trwcx" >> /etc/electron/unveil.utility_network
# *** Fake display, env DISPLAY=:1
# Xvfb :1 &
# XXX *** Limit openfiles max 1024 isn't enouch
# adjust _pbuild to :openfiles-max=2048: (/etc/login.conf)

# Notes :
# use a wrapper script, skip bin/electron check, electron/spec/api-app-spec.ts
# no crashReporter, electron/spec/disabled-tests.json
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

# extract versions from upstream
_TMP=		/tmp/electron-${ELECTRON_V}
_GITHUB_RAW=	https://raw.githubusercontent.com/
_ELECTRON_RAW=	${_GITHUB_RAW}electron/electron/v${ELECTRON_V}
_CHROMIUM_RAW=	${_GITHUB_RAW}chromium/chromium/
_CHROMIUM_MODH=	third_party/node/node_modules.tar.gz.sha1
versions:
	# make versions
	# electron/v${ELECTRON_V}/DEPS
	@mkdir -p ${_TMP} ;						\
	cd ${_TMP} ;							\
									\
	ftp -VMo DEPS ${_ELECTRON_RAW}/DEPS ;				\
	chromium_v=$$(cat DEPS |					\
		grep -A1 "'chromium_version':" |			\
		awk -F"'" '/,/{print $$2}' ) ;				\
	printf "CHROMIUM_V=\t%s\n" $$chromium_v ;			\
	printf "NODE_V=\t\t%s\n" $$(cat DEPS |				\
		grep -A1 "'node_version':" |				\
		awk -F"'|v" '/,/{print $$3}' ) ;			\
	printf "NAN_V=\t\t%s\n" $$(cat DEPS |				\
		grep -A1 "'nan_version':" |				\
		awk -F"'" '/,/{print $$2}' ) ;				\
	printf "SQUIRREL_MAC_V=\t%s\n" $$(cat DEPS |			\
		grep -A1 "'squirrel.mac_version':" |			\
		awk -F"'" '/,/{print $$2}' ) ;				\
	printf "REACTIVEOBJC_V=\t%s\n" $$(cat DEPS |			\
		grep -A1 "'reactiveobjc_version':" |			\
		awk -F"'" '/,/{print $$2}' ) ;				\
	printf "MANTLE_V=\t%s\n" $$(cat DEPS |				\
		grep -A1 "'mantle_version':" |				\
		awk -F"'" '/,/{print $$2}' ) ;				\
	printf "ENGFLOW_V=\t%s\n" $$(cat DEPS |				\
		grep -A1 "'engflow_reclient_configs_version':" |	\
		awk -F"'" '/,/{print $$2}' ) ;				\
									\
	printf "# chromium/$$chromium_v/${_CHROMIUM_MODH}\n" ;		\
	ftp -VMo modh ${_CHROMIUM_RAW}/$$chromium_v/${_CHROMIUM_MODH} ;	\
	printf "NODE_MODULES_H=\t%s\n" $$(cat modh) ;

# prepare custom tarball for stable fetch
# XXX need ~20G, usualy run with a custom _SRC
# XXX need custom tar -R (reproducible) diff, use gtar alternative ?
_SRC?=		${WRKDIR}/chromium
_VER?=		${CHROMIUM_V}
_PKG?=		chromium
_FETCH?=	https://chromium.googlesource.com/chromium/src.git \
		+refs/tags/${_VER}
_GN_REPO?=	https://gn.googlesource.com/gn.git
_GN_PATH?=	${_SRC}/src/tools/gn

# handmade exclusion list based on manual compare with official tarball
# XXX digging needed to further reduce tarball size
#https://chromium.googlesource.com/chromium/tools/build/+/refs/heads/main/recipes/recipe_modules/chromium/resources/export_tarball.py
#https://chromium.googlesource.com/chromium/tools/build/+/refs/heads/main/recipes/recipes/publish_tarball.py
#https://raw.githubusercontent.com/chromium-linux-tarballs/chromium-tarballs/master/package_chromium.sh
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

# required files to build
_INCLUDE+=\
	-o -path './src/third_party/libxml/chromium/*' \
	-o -path './src/third_party/devtools-frontend/*/out/*' \
	-o -name '*.gn*' -o -name '*.gyp*' \
	-o -name '*.isolate' -o -name '*.tq'

# XXX remove GN_SYSTEM_LIBS not sure its worth the pain ?
# * with	SIZE (chromium-146.0.7680.166.tgz) = 2411592711
# * without+GN	SIZE (chromium-146.0.7680.166.tgz) = 2534731181

# XXX consider moving depends into '.bak' for example, allowing proper
# system-proof builds (making sure nothing else got used) while not being
# such an issue when some things goes wrong (restore .bak before GN configure).

# third parties not needed to build electron
#.for _f in ${GN_SYSTEM_LIBS}
#_EXCLUDE+=	-o -path './src/third_party/${_f}/*'
#.endfor

# XXX custom sources ? those depends may still be needed
# .for _f in ${GN_BUNDLE_LIBS}
# _EXCLUDE+=	-o -path './src/third_party/${_f}/*'
# .endfor
# _INCLUDE+=	-o -path './src/third_party/libvpx/source/config/*'

tarball:
	# setup
	mkdir -p ${_SRC}/src
	cp ${FILESDIR}/gclient ${_SRC}/.gclient
	HOME=${_SRC} git config --global init.defaultBranch master
	HOME=${_SRC} git config --global advice.defaultBranch false
	HOME=${_SRC} git config --global advice.detachedHead false
	# git fetch chromium src
	cd ${_SRC}/src && [ -d ".git" ] || ( \
	HOME=${_SRC} git init && \
	HOME=${_SRC} git fetch ${_FETCH} --depth 1 && \
	HOME=${_SRC} git checkout FETCH_HEAD )
	# gclient
# slow down (err 429 rate limit), GIT_HTTP_MAX_REQUESTS=1 + gclient sync -j1
# CLOUDSDK_*, prevent gsutil querry metadata.google.internal (dns/unwind stuck)
	cd ${_SRC}/src && \
	HOME=${_SRC} CLOUDSDK_CORE_CHECK_GCE_METADATA=0 \
	    CLOUDSDK_CORE_PASS_CREDENTIALS_TO_GSUTIL=0 \
	    GIT_HTTP_MAX_REQUESTS=1 \
	    gclient sync -j1 --no-history --shallow \
	    --force --delete_unversioned_trees --reset \
	    --no-bootstrap --nohooks --noprehooks \
	    --with_branch_heads --with_tags
	# fetch GN sources into tools/gn
	_GN=$$(awk -F"'" \
	    '/gn_version/ {sub(/^git_revision:/, "", $$4); print $$4; exit}' \
	    ${_SRC}/src/DEPS) && \
	rm -rf ${_SRC}/gn && \
	HOME=${_SRC} git clone -q ${_GN_REPO} ${_SRC}/gn && \
	cd ${_SRC}/gn && \
		HOME=${_SRC} git checkout $${_GN} && \
		${MODPY_BIN} build/gen.py && \
		mv out/last_commit_position.h \
		    ${_GN_PATH}/bootstrap/last_commit_position.h && \
		pax -rw -s '!^\./\.git$$!!' -s '!^\./\.git/.*$$!!' \
		    -s '!^\./out$$!!' -s '!^\./out/.*$$!!' . ${_GN_PATH}
	# lastchange.py DEPS hooks
# XXX on updates, grep lastchange.py from DEPS, maybe automate this check ?
	cd ${_SRC}/src && \
	HOME=${_SRC} ${MODPY_BIN} build/util/lastchange.py \
	    -o build/util/LASTCHANGE && \
	HOME=${_SRC} ${MODPY_BIN} build/util/lastchange.py \
	    -m GPU_LISTS_VERSION --revision-id-only \
	    --header gpu/config/gpu_lists_version.h && \
	HOME=${_SRC} ${MODPY_BIN} build/util/lastchange.py \
	    -m SKIA_COMMIT_HASH -s third_party/skia \
	    --header skia/ext/skia_commit_hash.h && \
	HOME=${_SRC} ${MODPY_BIN} build/util/lastchange.py \
	    -m DAWN_COMMIT_HASH -s third_party/dawn \
	    --revision gpu/webgpu/DAWN_VERSION \
	    --header gpu/webgpu/dawn_commit_hash.h
	# custom tarball
	cd ${_SRC} && \
	find ./src -type f -a \( ! \( ${_EXCLUDE} \) ${_INCLUDE} \) \
	    | sort > files && \
	tar -cRzf ${_PKG}-${_VER}.tgz -I files \
	    -s '|src/|${_PKG}-${_VER}/|' && \
	sha256 -b ${_PKG}-${_VER}.tgz

chromium-patches:
	make -D _GEN_PATCHES patch
	# cvs co -D 20260402 -d chromium ports/www/chromium
	# remember to update cvs co -D "..." if you change targeted version
	if [ -d ${_TMP}/chromium ]; then \
		echo "${_TMP}/chromium exists, skip cvs co" ; \
	else \
		mkdir -p ${_TMP} && cd ${_TMP} && \
		cvs co -D 20260402 -d chromium ports/www/chromium ; \
	fi
	# test chromium patches on top of electron patch (pre-patch)
	rm -rf ${_TMP}/patches/chromium*
	mkdir -p ${_TMP}/patches/chromium{,.rej,.miss,.new,.ignore}
	for p in ${_TMP}/chromium/patches/patch-*; do \
		f=$$(grep -m1 'Index: ' $$p | sed -e 's/.*: //' ) ; \
		if grep -q "@@ -0,0" $$p; then \
			cp $${p} ${_TMP}/patches/chromium/ ; \
			cp $${p} ${_TMP}/patches/chromium.new/ ; \
		elif echo "$${p}" | grep -Eq \
		    'third_party_lib(aom.*cpudetect.*|vpx)'; then \
			echo "ignore ${WRKSRC}/$$f" ; \
			cp $${p} ${_TMP}/patches/chromium.ignore/ ; \
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
			gn args out/${BUILDTYPE} --list \
			| sed -E '/^[[:space:]]+From/s/\:[[:digit:]]+$$//' \
			> ${WRKDIR}/gn_args-electron.list ; \
	fi

_gn_args-chromium-list:
# run under _pbuild
	# ${WRKDIR}/gn_args-chromium.list
	@if [ ! -e "${WRKDIR}/gn_args-chromium.list" ] ; then \
		cd ${PORTSDIR}/www/chromium ; \
		_wrksrc=$$(make show=WRKSRC) ; \
		_gn=$$_wrksrc/out/${BUILDTYPE}/gn ; \
		cd $$_wrksrc && ${SETENV} ${CONFIGURE_ENV} \
			$$_gn args out/${BUILDTYPE} --list \
			| sed -E '/^[[:space:]]+From/s/\:[[:digit:]]+$$//' \
			> ${WRKDIR}/gn_args-chromium.list ; \
	fi

gn_args-diff:
	make configure
	${_PBUILD} make _gn_args-electron-list
	# configure www/chromium in order to compare
	cd ${PORTSDIR}/www/chromium && make configure ; cd -
	${_PBUILD} make _gn_args-chromium-list
	# ${WRKDIR}/gn_args.diff
	@${_PBUILD} sh -c \
	"diff -uN ${WRKDIR}/gn_args{-chromium,-electron}.list > \
		${WRKDIR}/gn_args.diff" || wc -l ${WRKDIR}/gn_args.diff

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

gn-system:
	make configure
	${_PBUILD} make _gn_args-electron-list
	@_pkgs=$$(grep -C0 -e '^[^[:space:]]*use_system_.*' \
		${WRKDIR}/gn_args-electron.list) ; \
	echo "# use_system* !true\n" $$_pkgs | fmt ; \
	for _pkg in $$_pkgs; do \
		grep -A1 "^$$_pkg" ${WRKDIR}/gn_args-electron.list | \
			grep -q true || echo $$( \
			grep -A1 "^$$_pkg" ${WRKDIR}/gn_args-electron.list) \
		; \
	done
	@_pkgs=$$(grep -C0 -e '^[^[:space:]]*bundle_.*' \
		${WRKDIR}/gn_args-electron.list) ; \
	echo "# *bundle* !false\n" $$_pkgs | fmt ; \
	for _pkg in $$_pkgs; do \
		grep -A1 "^$$_pkg" ${WRKDIR}/gn_args-electron.list | \
			grep -q false || echo $$( \
			grep -A1 "^$$_pkg" ${WRKDIR}/gn_args-electron.list) \
		; \
	done
	@_pkgs=$$(ls ${WRKSRC}/build/linux/unbundle/ \
		| sed -n /\.gn$$/s/\.gn$$//p) ; \
	echo "# build/linux/unbundle !set\n" $$_pkgs | fmt ; \
	for _pkg in $$_pkgs; do \
		echo "${GN_SYSTEM_LIBS}" | \
			grep -q "$$_pkg" || echo $$_pkg ; \
	done

tarball-useless:
	# look for outdated file access time which could be removed from tarball
	# be carefull to not grep anything in src tree
	# make && make test && make tarball-useless
	find ${WRKSRC} -type d -print | \
		${_PBUILD} tee ${WRKDIR}/src_tree.list >/dev/null
	find ${WRKSRC} -anewer ${_EXTRACT_COOKIE} -type d -print | \
		${_PBUILD} tee ${WRKDIR}/src_tree_access.list >/dev/null
	diff -uN ${WRKDIR}/src_tree_access.list ${WRKDIR}/src_tree.list

.include "modules.berry.inc"

.include <bsd.port.mk>
