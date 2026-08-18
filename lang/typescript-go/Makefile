COMMENT =	native port of TypeScript, JavaScript with syntax for types

# run make go-gen-modules instead of modgo-gen-modules, handle two mods
MODGO_MODNAME =	github.com/microsoft/typescript-go
TOOLS_MODNAME =	${MODGO_MODNAME}/_tools

# https://www.npmjs.com/package/typescript?activeTab=code gitHead
H =		2bd066d87f5bafd315be9f40889d0a60b9e58e0b
# go mod init tmp && go get github.com/microsoft/typescript-go@${H}
# go: downloading github.com/microsoft/typescript-go v...
MODGO_VERSION =	v0.0.0-20260708042240-2bd066d87f5b

DISTNAME =	typescript-go-7.0.2

# main file. see after bsd.port.mk load modgo, reset DISTFILES & EXTRACT_ONLY
# preserve MODGO_MODNAME build but fetch the whole repo including tests
DIST_TUPLE+=	github microsoft typescript-go ${H} \
		${MODGO_MODNAME}@${MODGO_VERSION}

CATEGORIES =	lang

MAINTAINER=	Fabien Romano <fabien@openbsd.org>

# Apache-2.0
PERMIT_PACKAGE =	Yes

WANTLIB += c pthread

# Apache-2.0
DIST_TUPLE+=	github microsoft TypeScript \
		4d4f005c8541e0255a9d8791205fdce326e462bc \
		${MODGO_MODNAME}@${MODGO_VERSION}/_submodules/TypeScript

# Fix dos line-endings in files needing patches
FIX_CRLF_FILES = \
${WRKSRC:S/${WRKDIST}\///}/_packages/native-preview/scripts/generateSync.ts \
${WRKSRC:S/${WRKDIST}\///}/_scripts/generate-encoder.ts \
${WRKSRC:S/${WRKDIST}\///}/_scripts/generate-go-ast.ts \
${WRKSRC:S/${WRKDIST}\///}/_scripts/generate-ts-ast.ts \
${WRKSRC:S/${WRKDIST}\///}/Herebyfile.mjs \
${WRKSRC:S/${WRKDIST}\///}/internal/fourslash/_scripts/convertFourslash.mts \
${WRKSRC:S/${WRKDIST}\///}/internal/lsp/lsproto/_generate/generate.mts

MODULES =		devel/npm \
			lang/go

MODNPM_BUILD =		No
MODNPM_BUILD_DIST =	${WRKSRC}/built/npm
MODNPM_INSTALL =	typescript-go

# test run in sequential order to avoid OOM issues
# thus we enable --timeout=45m to make those pass
MODNPM_ENV_TEST =	CI=1

MODNPM_MODS_SKIP =	typescript

MODNPM_MODS+=esbuild
MODNPM_MODS+=graceful-fs

WRKDIST =		${WRKDIR}

# fix permission on ${MODGO_WORKSPACE} by using default modgo flags
# trimpath brake test as they need build path to locate files
# XXX but we want to trim path for release ... more work needed
MAKE_ENV+=		GOFLAGS="${MODGO_FLAGS:C/-trimpath//}"
TEST_ENV+=		GOFLAGS="${MODGO_FLAGS:C/-trimpath//}"

DIST_TSGO =	${MODNPM_INSTALL_DIR}/typescript/bin/tsgo

SUBST_VARS+=	H

post-patch:
	${SUBST_CMD} ${WRKSRC}/Herebyfile.mjs

post-build:
	cp ${WRKSRC}/_packages/native-preview/lib/getExePath.js{,.orig}
	cp ${FILESDIR}/getExePath.js \
		${WRKSRC}/_packages/native-preview/lib/getExePath.js
	cd ${WRKSRC} && \
		${MODNPM_CMD_BUILD} exec hereby native-preview:pack-packages

do-install:
	${MODNPM_INSTALL_TARGET}
# XXX avoid conflict with lang/typescript ...
	${INSTALL_PROGRAM} ${MODGO_WORKSPACE}/bin/tsgo ${PREFIX}/${DIST_TSGO}
	ln -fs ../${DIST_TSGO} ${PREFIX}/bin/tsgo
	rm ${PREFIX}/bin/tsc

pre-test:
	mkdir -p ${WRKSRC}/built/local
	cp -p ${MODGO_WORKSPACE}/bin/tsgo ${WRKSRC}/built/local/

# XXX modnpm prune node_modules during fake, run 'make clean test'
do-test:
	-cd ${WRKSRC} && \
		${MODNPM_CMD_TEST} exec hereby test
	-cd ${WRKSRC} && \
		${MODNPM_CMD_TEST} exec hereby test:benchmarks
	-cd ${WRKSRC} && \
		${MODNPM_CMD_TEST} exec hereby test:tools
	-cd ${WRKSRC} && \
		${MODNPM_CMD_TEST} exec hereby test:api

modnpm-pre-gen-modules:
	# drop vscode extension
	cd ${WRKSRC} && \
	jq '.workspaces |= map(select(. != "./_extension"))' ${MODNPM_PACKAGE} \
		> tmp.json && mv tmp.json ${MODNPM_PACKAGE} ;

modnpm-post-gen-modules:
	cd ${MODNPM_TARGETS} && ${MODNPM_CMD_GEN} remove dprint

go-gen-modules:
	@${_PERLSCRIPT}/modgo-gen-modules-helper \
		${MODGO_MODNAME} ${MODGO_VERSION} \
		| sed -e 's/ =/+=/g'
	@${_PERLSCRIPT}/modgo-gen-modules-helper \
		${TOOLS_MODNAME} ${MODGO_VERSION} \
		| sed -e 's/ =/+=/g'

.include "modules.inc"

.include "modules.npm.inc"

.include <bsd.port.mk>

# prevent MODGO_MODNAME main fetch/extract, use dist tuple github instead
DISTFILES =
EXTRACT_ONLY =	${ALL_DISTFILES:M*microsoft-TypeScrip*} \
		${ALL_DISTFILES:M*microsoft-typescript-go*}
