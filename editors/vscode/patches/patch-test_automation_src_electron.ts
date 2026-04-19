Index: test/automation/src/electron.ts
--- test/automation/src/electron.ts.orig
+++ test/automation/src/electron.ts
@@ -137,7 +137,7 @@ export function getDevElectronPath(): string {
 	switch (process.platform) {
 		case 'darwin':
 			return join(buildPath, 'electron', `${product.nameLong}.app`, 'Contents', 'MacOS', `${product.nameShort}`);
-		case 'linux':
+		case 'freebsd': case 'linux': case 'openbsd':
 			return join(buildPath, 'electron', `${product.applicationName}`);
 		case 'win32':
 			return join(buildPath, 'electron', `${product.nameShort}.exe`);
@@ -162,7 +162,7 @@ export function getBuildElectronPath(root: string): st
 				return join(root, 'Contents', 'MacOS', product.nameShort);
 			}
 		}
-		case 'linux': {
+		case 'freebsd': case 'linux': case 'openbsd': {
 			const product = require(join(root, 'resources', 'app', 'product.json'));
 			return join(root, product.applicationName);
 		}
