Index: extensions/vscode-api-tests/src/utils.ts
--- extensions/vscode-api-tests/src/utils.ts.orig
+++ extensions/vscode-api-tests/src/utils.ts
@@ -38,7 +38,7 @@ export async function deleteFile(file: vscode.Uri): Pr
 }
 
 export function pathEquals(path1: string, path2: string): boolean {
-	if (process.platform !== 'linux') {
+	if (!['freebsd', 'linux', 'openbsd'].includes(process.platform)) {
 		path1 = path1.toLowerCase();
 		path2 = path2.toLowerCase();
 	}
