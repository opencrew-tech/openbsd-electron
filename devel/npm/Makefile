# XXX npm need npm to build

COMMENT =	package manager for JavaScript

V=		11.12.1
PKGNAME =	npm-${V}
DIST_TUPLE =	github npm cli v${V} .

CATEGORIES =	devel

HOMEPAGE =	https://docs.npmjs.com/cli/

MAINTAINER =	Fabien Romano <fabien@openbsd.org>

# The Artistic License 2.0
# https://github.com/npm/cli/tree/latest?tab=License-1-ov-file
PERMIT_PACKAGE =Yes

# make tarball fetch & preinstall official npm, to build custom npm
# make modnpm-gen-vendor bundle pre-made cache for offline use
# on upates, (un)comments one by one then run
# make makesum && make tarball
# make makesum && make modnpm-gen-vendor
SITES.vendor =		http://distfiles.opencrew.tech/npm/
DISTFILES.vendor+=	npm-${V}.tgz
DISTFILES.vendor+=	${MODNPM_VENDOR}

MODULES =		devel/npm \
			lang/python

# gracefull-fs depends on npm, bundle patch in make tarball
MODNPM_SKIP_GEN_MODS=	Yes

# using modnpm workspace install, do not bundle
# XXX root + bundle may be better if this could be done for all ports but in the
# meanwhile prefer modnpm script to serve as a regression test
MODNPM_GEN_BUNDLE=	No

MODNPM_BUILDDEP=	No
MODNPM_TESTDEP=		No

MODNPM_INSTALL=		npm

# pre-made npm to bootstrap npm build, see make tarball
MODNPM_BIN=		node ${WRKDIR}/npm/bin/npm

MODNPM_ARGS_WORKSPACE=	--workspaces --include-workspace-root

post-patch:
	rm -rf ${WRKSRC}/node_modules/graceful-fs ; \
	ln -sf ${WRKDIR}/npm/lib/node_modules/npm/node_modules/graceful-fs \
		${WRKSRC}/node_modules/graceful-fs

post-install:
	mv ${PREFIX}/bin/npm ${PREFIX}/bin/onpm
	mv ${PREFIX}/bin/npx ${PREFIX}/bin/onpx
	${MODPY_COMPILEALL} ${PREFIX}/${MODNPM_INSTALL_DIR}
	rm -rf ${PREFIX}/${MODNPM_INSTALL_DIR}/graceful-fs
	cp -r ${WRKDIR}/npm/lib/node_modules/npm/node_modules/graceful-fs \
		${PREFIX}/${MODNPM_INSTALL_DIR}/graceful-fs

# Prepare pre-build npm to ease building a custom version itself.
# The prebuild version does not include our patches but those are not needed
# for this specific build of npm by itself thus this hack works.
# Note this include a patch for gracefull-fs to better handle ressources limits.
# XXX need custom tar -R (reproducible) diff, use gtar alternative ?
_TMP?=	./
_DIST?=	$$(realpath `mktemp -d ${_TMP}/tarball.XXXXXXX`)
tarball:
# looks-like https://www.npmjs.com/install.sh
	dist="${_DIST}" ; \
	ports_path="${PORTSDIR_PATH}" ; \
	graceful_fs="" ; \
	IFS=: ; \
	for base in $${ports_path} ; do \
		[ -d "$${base}/devel/node-graceful-fs" ] || continue ; \
		graceful_fs="$${base}/devel/node-graceful-fs" ; \
		break ; \
	done ; \
	[ -n "$${graceful_fs}" ] || { \
		echo "Missing devel/node-graceful-fs in PORTSDIR_PATH" 1>&2 ; \
		exit 1 ; } ; \
	cd $${dist} && \
		ftp -o npm.tgz ${SITES.npm}/npm/-/npm-${V}.tgz && \
		tar -xzf npm.tgz && \
		cd package && \
		node bin/npm-cli.js install -gf ../npm.tgz --prefix=../npm && \
		cd ../npm/lib/node_modules/npm/node_modules/graceful-fs && \
		patch < "$${graceful_fs}/patches/patch-graceful-fs_js" && \
	cd $${dist} && \
		tar -cRzf ${.CURDIR}/npm-${V}.tgz npm ; \
	rm -rf $${dist}

.include <bsd.port.mk>
