COMMENT=	Zigbee to MQTT bridge

DIST_TUPLE=	github Koenkk zigbee2mqtt 2.9.2 .
REVISION=	0

CATEGORIES=	comms

HOMEPAGE=	https://www.zigbee2mqtt.io/

MAINTAINER=	Stuart Henderson <stu.ports@spacehopper.org>

# GPLv3
PERMIT_PACKAGE=	Yes

WANTLIB += ${COMPILER_LIBCXX} m

COMPILER=	base-clang

MODULES=	devel/pnpm

MODPNPM_INSTALL=zigbee2mqtt

MODPNPM_MODS+=rollup
MODPNPM_MODS+=esbuild

RUN_DEPENDS+=	lang/node

post-install:
	mv ${PREFIX}/${MODPNPM_INSTALL_DIR}/zigbee2mqtt/data \
		${PREFIX}/share/examples/zigbee2mqtt
	ln -s ${LOCALSTATEDIR}/db/zigbee2mqtt \
		${PREFIX}/${MODPNPM_INSTALL_DIR}/zigbee2mqtt/data
	ln -s ${LOCALBASE}/${MODPNPM_INSTALL_DIR}/zigbee2mqtt/cli.js \
		${PREFIX}/bin/zigbee2mqtt
# cleanup
	cd ${PREFIX}/${MODPNPM_INSTALL_DIR}/zigbee2mqtt/node_modules/.pnpm/ && \
		delete=$$(find . -type d \
			-path '*/@serialport/bindings-cpp/prebuilds') && \
		rm -rf $$delete

do-test:
	cd ${WRKSRC} && ${MODPNPM_CMD} run test:coverage

.include "modules.pnpm.inc"

.include <bsd.port.mk>
