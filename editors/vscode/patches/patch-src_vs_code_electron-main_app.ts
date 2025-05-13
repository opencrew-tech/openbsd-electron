Index: src/vs/code/electron-main/app.ts
--- src/vs/code/electron-main/app.ts.orig
+++ src/vs/code/electron-main/app.ts
@@ -989,7 +989,7 @@ export class CodeApplication extends Disposable {
 				services.set(IUpdateService, new SyncDescriptor(Win32UpdateService));
 				break;
 
-			case 'linux':
+			case 'freebsd': case 'linux': case 'openbsd':
 				if (isLinuxSnap) {
 					services.set(IUpdateService, new SyncDescriptor(SnapUpdateService, [process.env['SNAP'], process.env['SNAP_REVISION']]));
 				} else {
