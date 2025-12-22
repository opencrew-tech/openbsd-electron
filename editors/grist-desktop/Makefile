COMMENT =	easily open and edit Grist spreadsheets

_CORE_ID=383eac8d7fe086fea1a929b1f925190ad964fa2e
DIST_TUPLE =	github gristlabs grist-desktop v0.3.6 .
DIST_TUPLE+=	github gristlabs grist-core ${_CORE_ID} core

CATEGORIES =	editors

HOMEPAGE =	https://www.getgrist.com/

MAINTAINER =	Fabien Romano <fabien@openbsd.org>

# Apache 2.0
PERMIT_PACKAGE=	Yes

WANTLIB += ${COMPILER_LIBCXX} m

# make pyodide-packages
DISTFILES.grist+=\
grist-{}astroid-2.14.2-cp311-none-any.whl \
grist-{}asttokens-2.4.0-cp311-none-any.whl \
grist-{}chardet-5.1.0-cp311-none-any.whl \
grist-{}et_xmlfile-1.0.1-cp311-none-any.whl \
grist-{}executing-1.1.1-cp311-none-any.whl \
grist-{}friendly_traceback-0.7.48-cp311-none-any.whl \
grist-{}iso8601-0.1.12-cp311-none-any.whl \
grist-{}lazy_object_proxy-1.6.0-cp311-cp311-emscripten_3_1_32_wasm32.whl \
grist-{}openpyxl-3.0.10-cp311-none-any.whl \
grist-{}phonenumberslite-8.12.57-cp311-none-any.whl \
grist-{}pure_eval-0.2.2-cp311-none-any.whl \
grist-{}python_dateutil-2.8.2-cp311-none-any.whl \
grist-{}roman-3.3-cp311-none-any.whl \
grist-{}six-1.17.0-cp311-none-any.whl \
grist-{}sortedcontainers-2.4.0-cp311-none-any.whl \
grist-{}stack_data-0.5.1-cp311-none-any.whl \
grist-{}typing_extensions-4.4.0-cp311-none-any.whl \
grist-{}unittest_xml_reporting-2.0.0-cp311-none-any.whl \
grist-{}wrapt-1.15.0-cp311-none-any.whl

PYODIDE=3
SITES.grist=https://s3.amazonaws.com/grist-pynbox/pyodide/packages/v$(PYODIDE)/

# to ln into core/sandbox/pyodide/_build/packages, after post-extract then
EXTRACT_CASES+=		grist-*);;

MODULES =		devel/yarn \
			lang/python \
			www/electron

MODELECTRON_TARGET =	grist
MODELECTRON_APP_NAME=	Grist Desktop
MODELECTRON_UNVEIL=	Yes
MODELECTRON_BUILDER =	Yes
MODELECTRON_WRAPPER =	Yes

MODYARN_TARGETS =	${WRKSRC} \
			${WRKSRC}/core \
			${WRKSRC}/core/sandbox/pyodide/_build/worker
MODYARN_BUILD =		No
MODYARN_INSTALL =	No

MODYARN_MODS+=		esbuild

RUN_DEPENDS+=		devel/desktop-file-utils

# needs unveil tweeks & DISPLAY
NO_TEST =		Yes

do-configure:
	cd ${WRKSRC} && sh scripts/setup.sh
# bundle and follow scripts instead of hacking pyodide to use sys site-packages
	@mkdir -p ${WRKSRC}/core/sandbox/pyodide/_build/packages && \
	cd ${WRKSRC}/core/sandbox/pyodide/_build/packages && \
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
	cd ${WRKSRC} && ${MODYARN_CMD} run build
	${MODELECTRON_BUILDER_BUILD}

post-install:
	# cleanup build detritus
	cd ${PREFIX}/${MODELECTRON_DIST_T}.asar.unpacked/node_modules && \
		rm -rf @gristlabs/sqlite3/build-tmp-napi-v6 && \
		rm -rf msgpackr-extract/build/Release/obj.target && \
		rm -rf nice-napi/build/Release/obj.target && \
		rm -rf nice-napi/prebuilds
	# pregen .pyc
	${MODPY_COMPILEALL} ${PREFIX}/${MODELECTRON_DIST_T}.asar.unpacked
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
	cd ${WRKSRC}/core/sandbox/pyodide/ && sh ./setup.sh

# see core/sandbox/pyodide/ Makefile & preparePackages.js
_TMP=		/tmp/grist-desktop-${V}
_GRIST_GH=	https://raw.githubusercontent.com/gristlabs/grist-core
_GRIST_S3=	${SITES.grist}
pyodide-packages:
	# make pyodide-packages
	@echo "DISTFILES.grist+=\\" ;					\
	mkdir -p ${_TMP} ;						\
	ftp -VMo ${_TMP}/requirements.txt				\
		${_GRIST_GH}/${_CORE_ID}/sandbox/requirements.txt ;	\
	for req in $$(grep '==' ${_TMP}/requirements.txt) ; do		\
		index=$$(echo "$$req" | sed -e 's/==/-/' -e 's/ //').json ; \
		ftp -VMo ${_TMP}/$$index ${_GRIST_S3}$$index ;		\
		filename=$$(grep 'fileName' ${_TMP}/$$index |		\
			awk -F\" '{ print $$4}') ;			\
		echo "grist-{}$$filename \\" ;				\
	done ;

.include "modules.yarn.inc"

.include <bsd.port.mk>
