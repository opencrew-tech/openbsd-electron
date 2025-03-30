Index: build/lib/snapshotLoader.ts
--- build/lib/snapshotLoader.ts.orig
+++ build/lib/snapshotLoader.ts
@@ -25,7 +25,7 @@ export namespace snaps {
 			break;
 
 		case 'win32':
-		case 'linux':
+		case 'freebsd': case 'linux': case 'openbsd':
 			loaderFilepath = `VSCode-${process.platform}-${arch}/resources/app/out/vs/loader.js`;
 			startupBlobFilepath = `VSCode-${process.platform}-${arch}/snapshot_blob.bin`;
 			break;
