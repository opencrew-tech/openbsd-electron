COMMENT =	fast bundler for the web

V=0.27.1
MODGO_MODNAME =	github.com/evanw/esbuild
MODGO_VERSION =	v${V}

DISTNAME =	esbuild-${MODGO_VERSION}
CATEGORIES =	devel

HOMEPAGE =	https://esbuild.github.io/

MAINTAINER =	Igor Zornik <mocheryl@mocheryl.org>

# MIT
PERMIT_PACKAGE =	Yes

WANTLIB +=	c pthread

MODULES =	lang/go

WRKDIST =	${WRKSRC}

BUILD_DEPENDS+=	lang/node \
		lang/typescript

SUBST_VARS+=	WRKSRC

TEST_ENV+=	ESBUILD_BINARY_PATH=${WRKSRC}/esbuild \
		HOME=${WRKDIR}

ESBUILD_NPM=	npm/esbuild
ESBUILD_TS=	lib/npm
ESBUILD_ARGS=	--bundle \
		--target=node10 \
		--define:ESBUILD_VERSION=\"${V}\" \
		--external:esbuild \
		--platform=node \
		--log-level=warning
ESBUILD_DIST=	lib/node/esbuild/node_modules

pre-build:
	${SUBST_CMD} ${WRKSRC}/lib/npm/node-platform.ts

post-build:
# ${WRKSRC}/scripts/esbuild.js, buildNeutralLib()
	cd ${WRKSRC} && \
		mkdir -p ${ESBUILD_NPM}/lib && \
		mkdir -p ${ESBUILD_NPM}/bin && \
		${MODGO_WORKSPACE}/bin/esbuild ${ESBUILD_TS}/node.ts \
			--outfile=${ESBUILD_NPM}/lib/main.js \
			${ESBUILD_ARGS} --define:WASM=false && \
		${MODGO_WORKSPACE}/bin/esbuild ${ESBUILD_TS}/node-shim.ts \
			--outfile=${ESBUILD_NPM}/bin/esbuild \
			${ESBUILD_ARGS} && \
		cp ${ESBUILD_TS}/../shared/types.ts \
			${ESBUILD_NPM}/lib/main.d.ts

post-install:
	${INSTALL_DATA_DIR} ${PREFIX}/${ESBUILD_DIST}
	cp -rp ${WRKSRC}/${ESBUILD_NPM} ${PREFIX}/${ESBUILD_DIST}/

do-test:
# ${WRKSRC}/Makefile
# test-common: test-go vet-go no-filepath verify-source-map end-to-end-tests
#	js-api-tests plugin-tests register-test node-unref-tests decorator-tests
# skip no-filepath, check use of "path/filepath", untested
# skip verify-source-map, cannot find module 'source-map', keep it simple
	cd ${WRKSRC} ; \
	ln -fs ${MODGO_WORKSPACE}/bin/esbuild ./esbuild ; \
	${MODGO_CMD} test ./internal/... ./pkg/... ; \
	${MODGO_CMD} vet ./cmd/... ./internal/... ./pkg/... ; \
	${SETENV} ${TEST_ENV} node scripts/end-to-end-tests.js ; \
	${SETENV} ${TEST_ENV} node scripts/js-api-tests.js || true ; \
	${SETENV} ${TEST_ENV} node scripts/plugin-tests.js ; \
	${SETENV} ${TEST_ENV} node scripts/register-test.js ; \
	${SETENV} ${TEST_ENV} node scripts/node-unref-tests.js ; \
	${SETENV} ${TEST_ENV} ./esbuild scripts/decorator-tests.ts \
		--target=es2022 --outfile=scripts/decorator-tests.js && \
		node scripts/decorator-tests.js

.include "modules.inc"

.include <bsd.port.mk>
