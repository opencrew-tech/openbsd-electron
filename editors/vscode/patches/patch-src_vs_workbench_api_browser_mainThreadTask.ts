Index: src/vs/workbench/api/browser/mainThreadTask.ts
--- src/vs/workbench/api/browser/mainThreadTask.ts.orig
+++ src/vs/workbench/api/browser/mainThreadTask.ts
@@ -726,7 +726,7 @@ export class MainThreadTask extends Disposable impleme
 			case 'darwin':
 				platform = Platform.Platform.Mac;
 				break;
-			case 'linux':
+			case 'freebsd': case 'linux': case 'openbsd':
 				platform = Platform.Platform.Linux;
 				break;
 			default:
