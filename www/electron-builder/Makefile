COMMENT =	solution to package and build Electron app

V =		26.8.2
DISTNAME =	electron-builder-electron-builder-${V}
PKGNAME =	electron-builder-${V}

DIST_TUPLE =	github electron-userland electron-builder \
		electron-builder@${V} .

CATEGORIES =	www

HOMEPAGE =	https://www.electron.build/

MAINTAINER =	Fabien Romano <fabien@openbsd.org>

# MIT
PERMIT_PACKAGE =	Yes

# To drop unwanted modules which bring in useless bin/dll/exe stuff:
# remove modules from packages (post-extract)
# remove dependencies on those modules (modpnpm-pre-gen-modules)
# bundle fixed package.json (extra CONFIGFILES)
# add a bunch of patches

# python for node-gyp & MODPY_COMPILEALL
MODULES+=		lang/python

MODULES+=		devel/pnpm

MODPNPM_MODS+=7zip-bin
MODPNPM_MODS+=app-builder-bin
MODPNPM_MODS+=esbuild
MODPNPM_MODS+=graceful-fs
MODPNPM_MODS+=@parcel/watcher
MODPNPM_MODS+=rollup

MODPNPM_INSTALL =	electron-builder

MODPNPM_CONFIGFILES+=	packages/app-builder-lib/${MODPNPM_PACKAGE} \
			packages/electron-builder/${MODPNPM_PACKAGE} \
			test/${MODPNPM_PACKAGE}

MODPNPM_ARGS_TEST =	ci:test ${MODPNPM_ARGS}

post-extract:
	cd ${WRKSRC}/packages/ && (\
		rm -rf dmg-builder ; \
		rm -rf electron-builder-squirrel-windows ; \
		rm -rf electron-forge-maker-appimage ; \
		rm -rf electron-forge-maker-nsis ; \
		rm -rf electron-forge-maker-nsis-web ; \
		rm -rf electron-forge-maker-snap ; \
	)
	rm -rf ${WRKSRC}/test/src/{mac,windows,helpers/CheckingPackager.ts}

post-build:
	# drop test packages
	rm -f ${MODPNPM_BUILD_DIST}/electron-builder-test.tgz

do-build:
	cd ${WRKSRC} && ${MODPNPM_CMD} compile
	${MODPNPM_BUILD_TARGET}

post-install:
	${MODPY_COMPILEALL} ${PREFIX}/${MODPNPM_INSTALL_DIR}/node_modules/.pnpm\
		> /dev/null

modpnpm-pre-gen-modules:
	# drop dmg-license from root
	cd ${WRKSRC} && \
	jq 'del(.dependencies["dmg-license"])' ${MODPNPM_PACKAGE} \
		> tmp.json && mv tmp.json ${MODPNPM_PACKAGE} ;
	# drop test depends from app-builder-lib
	cd ${WRKSRC}/packages/app-builder-lib && \
	jq 'del(.peerDependencies,\
		.devDependencies["electron-builder-squirrel-windows"],\
		.devDependencies["dmg-builder"])' ${MODPNPM_PACKAGE} \
		> tmp.json && mv tmp.json ${MODPNPM_PACKAGE} ;
	# drop dmg-builder depends from electron-builder
	cd ${WRKSRC}/packages/electron-builder && \
	jq 'del(.dependencies["dmg-builder"])' ${MODPNPM_PACKAGE} \
		> tmp.json && mv tmp.json ${MODPNPM_PACKAGE} ;
	# drop unwanted test depends
	cd ${WRKSRC}/test && \
	jq 'del(.dependencies["electron-winstaller"],\
		.dependencies["electron-builder-squirrel-windows"],\
		.dependencies["dmg-builder"])' ${MODPNPM_PACKAGE} \
		> tmp.json && mv tmp.json ${MODPNPM_PACKAGE} ;

.include "modules.pnpm.inc"

.include <bsd.port.mk>
