COMMENT =	easily open and edit Grist spreadsheets

V=		v0.3.13
CORE_ID=0408b156e7e2ea30a84f49392d1984bcd2748e25
DIST_TUPLE =	github gristlabs grist-desktop ${V} .
DIST_TUPLE+=	github gristlabs grist-core ${CORE_ID} core

CATEGORIES =	editors

HOMEPAGE =	https://www.getgrist.com/

MAINTAINER =	Fabien Romano <fabien@openbsd.org>

# Apache 2.0
PERMIT_PACKAGE=	Yes

WANTLIB += ${COMPILER_LIBCXX} m

# make pyodide-packages
DISTFILES.grist+=\
grist-{}astroid-2.14.2-cp313-none-any.whl \
grist-{}asttokens-2.4.0-cp313-none-any.whl \
grist-{}chardet-5.1.0-cp313-none-any.whl \
grist-{}et_xmlfile-1.0.1-cp313-none-any.whl \
grist-{}executing-1.1.1-cp313-none-any.whl \
grist-{}friendly_traceback-0.7.48-cp313-none-any.whl \
grist-{}iso8601-0.1.12-cp313-none-any.whl \
grist-{}lazy_object_proxy-1.12.0-cp313-cp313-pyodide_2025_0_wasm32.whl \
grist-{}openpyxl-3.0.10-cp313-none-any.whl \
grist-{}phonenumberslite-8.12.57-cp313-none-any.whl \
grist-{}pure_eval-0.2.2-cp313-none-any.whl \
grist-{}python_dateutil-2.8.2-cp313-none-any.whl \
grist-{}roman-3.3-cp313-none-any.whl \
grist-{}six-1.17.0-cp313-none-any.whl \
grist-{}sortedcontainers-2.4.0-cp313-none-any.whl \
grist-{}stack_data-0.5.1-cp313-none-any.whl \
grist-{}typing_extensions-4.4.0-cp313-none-any.whl \
grist-{}unittest_xml_reporting-2.0.0-cp313-none-any.whl \
grist-{}wrapt-1.15.0-cp313-none-any.whl

# core/sandbox/pyodide/worker/package.json
PYODIDE_V=	0.28.1
DENO_V=		2.6.3	# XXX DENO_INSTALL_BIN, version mismatch

# core/sandbox/pyodide/Makefile
PYODIDE=	4
PYODIDE_SRC=	${WRKSRC}/core/sandbox/pyodide
SITES.grist=https://s3.amazonaws.com/grist-pynbox/pyodide/packages/v${PYODIDE}/

# to ln into ${PYODIDE_SRC}/_build/packages, after post-extract then
EXTRACT_CASES+=		grist-*);;

MODULES =		devel/yarn \
			lang/python \
			www/electron

MODELECTRON_TARGET =	grist
MODELECTRON_APP_NAME =	Grist Desktop
MODELECTRON_UNVEIL =	Yes
MODELECTRON_BUILDER =	Yes
MODELECTRON_WRAPPER =	Yes
MODELECTRON_WRAPPER_ENV +=\
	DENO_INSTALL_BIN=${TRUEPREFIX}/bin/deno \
	GRIST_USER_ROOT=~/.grist/ \
	TYPEORM_DATABASE=~/.grist/landing.db

MODYARN_TARGETS =	${WRKSRC} \
			${PYODIDE_SRC}/worker
MODYARN_BUILD =		No
MODYARN_INSTALL =	No

MODYARN_ENV_BUILD =	npm_config_nodedir=${LOCALBASE} \
			DENO_INSTALL_BIN=${LOCALBASE}/bin/deno \
			GRIST_SKIP_EXT_AUTOSETUP=1

MODYARN_MODS+=7zip-bin
MODYARN_MODS+=app-builder-bin
MODYARN_MODS+=electron-builder
MODYARN_MODS+=esbuild
MODYARN_MODS+=graceful-fs
MODYARN_MODS+=unrs-resolver

# fix build, to revisit on next update
MODYARN_GEN_OVERRIDES+=	"@gristlabs/sqlite3" "6.0.1-grist.1"

BUILD_DEPENDS+=		lang/deno
RUN_DEPENDS+=		devel/desktop-file-utils \
			lang/deno

# official npm (lang/node) use unlimited Promise.all() and hit openfiles-max
BUILD_DEPENDS+=		devel/npm

# XXX needs unveil tweeks & DISPLAY
#NO_TEST =		Yes

do-configure:
	# Workaround openfiles-max limit hit by electron-builder (npm list)
	ln -s ${LOCALBASE}/bin/onpm ${WRKDIR}/bin/npm
	# Configure source tree layout & bundle pyodide grist's dependencies
	cd ${WRKSRC} && sh scripts/setup.sh
	@mkdir -p ${PYODIDE_SRC}/_build/packages && \
	cd ${PYODIDE_SRC}/_build/packages && \
	for archive in ${EXTRACT_ONLY} ; do \
		case $$archive in \
		grist-*)\
			filename=$$(echo $${archive} | sed -e 's/{.*}//') ; \
			echo "+ $$filename" ; \
			ln -fs ${FULLDISTDIR}/$$filename \
				./$${filename##grist-} \
			;; \
		esac; \
	done ;

do-build:
	# Cleaning pre-build
	cd ${WRKSRC}/node_modules/@gristlabs/sqlite3 && \
		mkdir -p Release && \
		cp -p build/Release/node_sqlite3.node Release/ && \
		rm -rf build
	cd ${WRKSRC}/node_modules/msgpackr-extract && \
		rm -rf build/Release/obj.target
	# Running build
	cd ${WRKSRC} && ${MODYARN_CMD_BUILD} run build
	ulimit -n `ulimit -Hn`; ${MODELECTRON_BUILDER_BUILD}

post-install:
	# menu
	${INSTALL_DATA_DIR} ${PREFIX}/share/applications
	${INSTALL_DATA} ${FILESDIR}/${MODELECTRON_TARGET}.desktop \
		${PREFIX}/share/applications/${MODELECTRON_TARGET}.desktop
	${INSTALL_DATA_DIR} ${PREFIX}/share/pixmaps
	${INSTALL_DATA} ${WRKSRC}/core/static/icons/grist.png \
		${PREFIX}/share/pixmaps/${MODELECTRON_TARGET}.png

do-test:
	cd ${WRKSRC} && ${SETENV} ${MAKE_ENV} DISPLAY=:1 \
		sh ./scripts/smoke-test.sh

modyarn-pre-gen-modules:
# XXX WIP
# pyodide now require deno but it doesn't provide system support (custom bin)
# run custom setup without postinstall & bundle deno
#	cd ${PYODIDE_SRC} && sh ./setup.sh
	mkdir -p ${PYODIDE_SRC}/worker && \
	cd ${PYODIDE_SRC}/worker && \
	yarn init --yes && \
	touch yarn.lock && \
	yarn add pyodide@${PYODIDE_V} --ignore-scripts && \
	yarn add deno@${DENO_V} --ignore-scripts
# yarn version mismatch (?) : keep lru-cache types local to core workspace
# otherwise it bump version to a common hoisted module which is not compatible
	cd ${WRKSRC} && \
	jq '(.workspaces.nohoist //= []) | \
		.workspaces.nohoist += [ \
			"**/lru-cache", \
			"**/lru-cache/**", \
			"**/@types/lru-cache", \
			"**/@types/lru-cache/**" \
		] | \
		.workspaces.nohoist |= unique' ${MODYARN_PACKAGE} \
		> tmp.json && mv tmp.json ${MODYARN_PACKAGE} ;

# see ${PYODIDE_SRC} Makefile & preparePackages.js
_TMP=		/tmp/grist-desktop-${V}
_GRIST_GH=	https://raw.githubusercontent.com/gristlabs/grist-core
_GRIST_S3=	${SITES.grist}
pyodide-packages:
	# make pyodide-packages
	@echo "DISTFILES.grist+=\\" ;					\
	mkdir -p ${_TMP} ;						\
	ftp -VMo ${_TMP}/requirements.txt				\
		${_GRIST_GH}/${CORE_ID}/sandbox/requirements.txt ;	\
	for req in $$(grep '==' ${_TMP}/requirements.txt) ; do		\
		index=$$(echo "$$req" | sed -e 's/==/-/' -e 's/ //').json ; \
		ftp -VMo ${_TMP}/$$index ${_GRIST_S3}$$index ;		\
		filename=$$(grep 'fileName' ${_TMP}/$$index |		\
			awk -F\" '{ print $$4}') ;			\
		echo "grist-{}$$filename \\" ;				\
	done ;

.include "modules.yarn.inc"

.include <bsd.port.mk>
