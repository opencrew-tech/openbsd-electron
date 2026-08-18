Index: extensions/emmet/src/test/testUtils.ts
--- extensions/emmet/src/test/testUtils.ts.orig
+++ extensions/emmet/src/test/testUtils.ts
@@ -31,7 +31,7 @@ export function createRandomFile(contents = '', fileEx
 }
 
 export function pathEquals(path1: string, path2: string): boolean {
-	if (process.platform !== 'linux') {
+	if (!['freebsd', 'linux', 'openbsd'].includes(process.platform)) {
 		path1 = path1.toLowerCase();
 		path2 = path2.toLowerCase();
 	}
