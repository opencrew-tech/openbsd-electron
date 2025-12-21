Index: build/gulpfile.extensions.js
--- build/gulpfile.extensions.js.orig
+++ build/gulpfile.extensions.js
@@ -229,14 +229,14 @@ exports.cleanExtensionsBuildTask = cleanExtensionsBuil
 /**
  * brings in the marketplace extensions for the build
  */
-const bundleMarketplaceExtensionsBuildTask = task.define('bundle-marketplace-extensions-build', () => ext.packageMarketplaceExtensionsStream(false).pipe(gulp.dest('.build')));
+//const bundleMarketplaceExtensionsBuildTask = task.define('bundle-marketplace-extensions-build', () => ext.packageMarketplaceExtensionsStream(false).pipe(gulp.dest('.build')));
 
 /**
  * Compiles the non-native extensions for the build
  * @note this does not clean the directory ahead of it. See {@link cleanExtensionsBuildTask} for that.
  */
 const compileNonNativeExtensionsBuildTask = task.define('compile-non-native-extensions-build', task.series(
-	bundleMarketplaceExtensionsBuildTask,
+//	bundleMarketplaceExtensionsBuildTask,
 	task.define('bundle-non-native-extensions-build', () => ext.packageNonNativeLocalExtensionsStream(false, false).pipe(gulp.dest('.build')))
 ));
 gulp.task(compileNonNativeExtensionsBuildTask);
@@ -256,7 +256,7 @@ exports.compileNativeExtensionsBuildTask = compileNati
  */
 const compileAllExtensionsBuildTask = task.define('compile-extensions-build', task.series(
 	cleanExtensionsBuildTask,
-	bundleMarketplaceExtensionsBuildTask,
+//	bundleMarketplaceExtensionsBuildTask,
 	task.define('bundle-extensions-build', () => ext.packageAllLocalExtensionsStream(false, false).pipe(gulp.dest('.build'))),
 ));
 gulp.task(compileAllExtensionsBuildTask);
@@ -268,7 +268,7 @@ gulp.task(task.define('extensions-ci', task.series(com
 
 const compileExtensionsBuildPullRequestTask = task.define('compile-extensions-build-pr', task.series(
 	cleanExtensionsBuildTask,
-	bundleMarketplaceExtensionsBuildTask,
+//	bundleMarketplaceExtensionsBuildTask,
 	task.define('bundle-extensions-build-pr', () => ext.packageAllLocalExtensionsStream(false, true).pipe(gulp.dest('.build'))),
 ));
 gulp.task(compileExtensionsBuildPullRequestTask);
