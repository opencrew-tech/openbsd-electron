Index: github.com/microsoft/typescript-go@v0.0.0-20260708042240-2bd066d87f5b/_packages/native-preview/scripts/generateSync.ts
--- github.com/microsoft/typescript-go@v0.0.0-20260708042240-2bd066d87f5b/_packages/native-preview/scripts/generateSync.ts.orig
+++ github.com/microsoft/typescript-go@v0.0.0-20260708042240-2bd066d87f5b/_packages/native-preview/scripts/generateSync.ts
@@ -223,7 +223,6 @@ function removeAsyncAwaitAndPromise(source: string, fi
 // ── Formatting ───────────────────────────────────────────────────
 
 function formatFiles(paths: string[]): void {
-    execaSync("dprint", ["fmt", ...paths]);
 }
 
 // ── Main ─────────────────────────────────────────────────────────
