Index: electron/spec/crash-spec.ts
--- electron/spec/crash-spec.ts.orig
+++ electron/spec/crash-spec.ts
@@ -52,7 +52,7 @@ const shouldRunCase = (crashCase: string) => {
       if (process.platform === 'win32') {
         return process.arch !== 'ia32';
       } else {
-        return (process.platform !== 'linux' || (process.arch !== 'arm64' && process.arch !== 'arm'));
+        return (!(['freebsd', 'linux', 'openbsd'].includes(process.platform)) || (process.arch !== 'arm64' && process.arch !== 'arm'));
       }
     }
     default: {
