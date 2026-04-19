XXX --build ? (don't remember why)

Index: scripts/test.sh
--- scripts/test.sh.orig
+++ scripts/test.sh
@@ -39,5 +39,5 @@ else
 	cd $ROOT ; \
 		ELECTRON_ENABLE_LOGGING=1 \
 		"$CODE" \
-		test/unit/electron/index.js --crash-reporter-directory=$VSCODECRASHDIR "$@"
+		test/unit/electron/index.js --build --crash-reporter-directory=$VSCODECRASHDIR "$@"
 fi
