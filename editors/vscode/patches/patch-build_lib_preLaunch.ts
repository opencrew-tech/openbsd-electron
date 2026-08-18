Index: build/lib/preLaunch.ts
--- build/lib/preLaunch.ts.orig
+++ build/lib/preLaunch.ts
@@ -65,7 +65,7 @@ async function ensureCompiled() {
 
 async function main() {
 	await ensureNodeModules();
-	await getElectron();
+	// await getElectron();
 	await ensureCompiled();
 
 	// Can't require this until after dependencies are installed
