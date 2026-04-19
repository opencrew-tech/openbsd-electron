COMMENT =	cli tool for code structural search, lint and rewriting

DIST_TUPLE =	github ast-grep ast-grep 0.41.1 .

CATEGORIES =	devel

HOMEPAGE =	https://ast-grep.github.io/

MAINTAINER=	Fabien Romano <fabien@openbsd.org>

# MIT
PERMIT_PACKAGE =	Yes

WANTLIB += ${MODCARGO_WANTLIB}

MODULES =		devel/cargo \
			devel/yarn

# cargo integration
MODCARGO_INSTALL =	No
MODCARGO_TEST =		No
MODYARN_ENV+=		${MODCARGO_ENV}

MODYARN_TARGETS =	${WRKSRC}/crates/napi
MODYARN_INSTALL =	ast-grep
MODYARN_MODS_SKIP+=	@ast-grep/napi

MODYARN_MODS+=graceful-fs

CONFIGURE_STYLE =	cargo

do-build:
	cd ${MODYARN_TARGETS} && ${MODYARN_CMD_BUILD} build
	${MODYARN_BUILD_TARGET}

modyarn-post-gen-modules:
	cd ${MODYARN_TARGETS} && ${MODYARN_CMD_GEN} remove dprint

post-install:
	cd ${PREFIX}/${MODYARN_INSTALL_DIR}/@ast-grep/napi && \
	cp ${MODYARN_TARGETS}/ast-grep-napi.openbsd*.node \
		./ast-grep-napi.node && \
	cp ${FILESDIR}/crates-napi-index.js ./index.js

pre-test:
	cd ${MODYARN_TARGETS} && \
	ln -sf ./ast-grep-napi.openbsd*.node ./ast-grep-napi.node && \
	cp ${FILESDIR}/crates-napi-index.js ./index.js && \
	cp ./node_modules/@ast-grep/napi/lang/TypeScript.d.ts \
		./lang/TypeScript.d.ts

.include "crates.inc"

.include "modules.yarn.inc"

.include <bsd.port.mk>
