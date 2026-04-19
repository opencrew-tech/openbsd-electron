# OpenBSD + Electron

<p align="center">
    <img src=".readme/openbsd-electron.png" alt="OpenBSD + Electron logo" width="256"/>
</p>

An effort to port Electron (and, by extension, VS Code) to OpenBSD.
This tree includes custom patches for npm, Yarn (Classic & Berry), and pnpm.

For clarity, Yarn v4 is referred to as `berry`, so Yarn Classic (v1) and Berry can coexist conceptually, though not under a single port.
Each package manager currently has its own ports module.

**Status: work in progress; experiment is still ongoing.**

## Node ecosystem

Supporting Node-based ports on OpenBSD means handling roughly 10,000 upstream packages under strict constraints: offline builds, reproducibility, multi-version support, and isolated packaging.

Package managers do not integrate cleanly with the ports framework out of the box, and porting every dependency individually is not scalable.

This tree therefore relies on:

- patched package managers
- override mechanisms
- prebuilt system modules (native builds, custom Makefiles, or fixes)

The main friction points are `node_modules` layout, override semantics, symlink handling, local file dependencies, and prebuilt artifacts.

Many Node tools assume permanent network access during install or build.
Some packages even download full binaries that are not published as registry modules.

Offline build strategies are limited to:

- using a prebuilt offline cache archive
- populating the manager cache before extract with dedicated helper tools
- extracting directly into `node_modules`

Except for Yarn Classic, all supported package managers currently need patches to accept injected pre-fetched cache entries.
For `npm` and `pnpm`, preparing a cache with `mod*-gen-vendor` is still required.

Each package manager produces a lock file that defines both the dependency graph and the expected install layout.
Each ports module come with a Perl helper that parses the lock file and generates the distfile list.

Unlike cache-only mode, this workflow does not inject registry index metadata.
Lock files must therefore match the cache exactly, because the managers run fully offline and cannot resolve anything from the network.
As a result, the modules generate override-aware config files under `files/` instead of a single `modules.inc`.

`mod*-gen-modules` writes directly into the current port directory.
Existing generated files are moved to `.orig`, and manual cleanup may still be required.
Manager-specific config files are written under `files/mod*_path_relative_to_src` and overlaid early during extract.

Offline system installation without registry metadata still needs more investigation.
The current priority is to make clean builds reliable under `dpb`.

## Package managers

All supported managers use, or mirror, the npm registry.
Node module resolution is complex and manager-specific, so reproducing it in ports is not practical.
A package manager must assemble the build tree.

The resulting install layouts fall into three broad categories:

- hoisted or flat trees
- isolated trees built from relative symlinks
- Plug'n'Play (`.pnp.cjs`)

Modules installs ports in isolation and lets Node resolve the resulting layout, even when shapes are mixed.
Using a single manager for all system installs remains possible in theory, but it would add duplicate caches and configs and would not eliminate file conflicts in `PLIST`.

Ports built with these modules install into `/usr/local/node/$port/node_modules`.
Dependencies remain local to the port; there is no system-wide deduplication beyond shared system libraries.
Depending on the manager and the upstream repository layout, dependencies may live next to the main module or inside nested `node_modules` directories.

To simplify porting, the modules implement three classes of helpers:

- override dependencies with system ports
- pin a specific version or select a WASM alternative
- inject an additional dependency required as a fallback

`modnpm`, `modyarn`, `modberry`, and `modpnpm` share the same general model.
The long-term goal is a unified `modnode` module.

Shared workflow:

- generate distfile lists `.inc` and bundle custom config and lock files under `files/` with `mod*-gen-modules`
- load archives into the manager cache, then run an offline install without scripts during extract to initialize `node_modules`
- apply patches, then rebuild `node_modules` with scripts during pre-build
- pack modules into `wrkdir` during build
- install the generated packages into the fake tree

### berry

`devel/berry` packages Yarn v4.
Renaming it to `berry` avoids conflicts with the official `yarn` port.

A new command, `berry import archive resolution`, was added.

The modules does:
- not support custom gen-modules includes/excludes
- not support force feature (all os/arch), it always load everything by default
- not support gen-modules dev/optional filtering
- use xargs -P to speed up berry import as it load one module at a time
- *not implement system install*
- depends on ENV variables which seems fragile, those could be override by ports
- not support multiple MODBERRY_TARGETS (looks like)
- ignore engines, packageManager and yarnPath configs
- does not specify resolution protocol, it use file: (*force to regen*)

### npm

`devel/npm` installs as `onpm` to avoid conflicts with the official ports tree.

A new command, `onpm cache add resolution|archive`, was added.
The port also uses `gracefulify` from `graceful-fs` to reduce file descriptor pressure.
The target CPU check was relaxed so `wasm32` can run.

System module support was added.
System modules are not rebuilt, existing binaries remain linked, and permissions are left unchanged.
Several install-side issues were fixed as part of that work.

Some lock files still miss fields such as `resolved`, which are required by perl helpers.
Update tooling now patches those cases in place.

The modules does:
- not support force feature (all os/arch), it always filter out invalid os
- require a new *_GEN_BUNDLE configuration to handle system install
- ignore packageManager but also implement a complex engines filtering
- handle override direct dependencies by fixing them on top of overrides config
- implement resolutions using relative links to workdir which link to system

Link preservation across installs may still happen, but this remains untested.

### pnpm

`devel/pnpm` is harder to bootstrap.
It requires manual `esbuild` version alignment and cannot reliably build itself, so the port uses a prebuilt release patched with the local `pnpm`.

A new command, `pnpm cache add resolution|archive`, was added.
System module support was fixed; when the manager tries to change permissions on system binaries, the error is caught and downgraded to a warning.

For GitHub tarballs, cache handling now always uses `integrity.json`.
The alternate `integrity-not-built.json` index only prevented cache reuse during the initial extract phase where scripts are disabled.

The modules does:
- not support gen-modules dev/optional filtering
- implement overrides using link: protocole
- implement overrides using relative links to workdir which link to system

`pnpm` preserves links across installs.

### yarn

`devel/yarn` mostly works with minimal patching.

A new command, `yarn install --rebuild`, was added.
The rebuild phase ignores integrity checks and focuses on running scripts.
The `process.arch` check was changed so `wasm32` can run.

The module does:
- not support custom gen-modules includes/excludes
- not support force feature (all os/arch), it always load everything by default
- not support gen-modules dev/optional filtering
- implement resolutions using relative links to workdir which link to system

Link preservation across installs may still happen, but this remains untested.

## Electron

`www/electron` is built on top of Chromium and reuses the same patch strategy and most of the same feature work.
The port adds OpenBSD-specific support for `pledge` and `unveil`, intended to be tuned per application profile.

Electron is installed as a shared system runtime.
Applications are expected to target that shared runtime instead of bundling Electron privately.
Each application provides its own wrapper to start Electron with application-specific resources and configuration.

[Fuse](https://www.electronjs.org/docs/latest/tutorial/fuses) support isn't done yet, the goal is to define one sensible default profile.

Some Electron releases depend on Chromium revisions that Google does not publish as source tarballs.
The tarball generation script still needs review and currently produces archives larger than the Chromium lite tarballs.

PGO is not enabled yet.
Profile generation and reuse still need implementation.

The Electron module currently focuses on wrapper generation and `electron-builder` integration.
System-wide rebuild handling still needs work and currently relies on `REV` rather than `_PKG_ARGS_VERSION` from `mk/arch-defines.mk`.

### Included libraries and tools

- `archivers/node-7zip-bin`: convenience module wrapping `archivers/p7zip`
- `devel/app-builder`: helper for legacy `electron-builder` support
- `devel/esbuild`: convenience system module
- `devel/gclient`: Google's repository sync tool for `DEPS`
- `devel/gn`: originally added for Electron builds, likely removable now
- `devel/go-bindata`: required by `sysutils/facette`
- `devel/node-graceful-fs`: hardened `gracefulify` for promise-heavy workloads; helps with `_pbuild` limits
- `devel/parcel-watcher`: convenience module, N-API prebuilt, `kqueue`-only; OpenBSD behavior fixes added, tests still failing
- `devel/py-dbusmock`: test dependency for `www/electron`
- `devel/rollup`: convenience module, N-API prebuilt
- `games/butler`: command-line helper for `games/itch`
- `lang/typescript`: convenience module; adds `gracefulify(fs)` support, possibly no longer needed
- `www/electron-builder`: convenience module with system override support fixes
- `www/puppeteer`: convenience module with OpenBSD Chromium fixes, tests still failing
- `www/tailwindcss`: convenience module, N-API prebuilt

### Included applications

- `comms/zigbee2mqtt`: existing port migrated to `modpnpm`; needs testing
- `editors/grist-desktop`: lightly tested
- `editors/vscode`: appears functional; Kerberos support is untested; ESM plugin freezes are still under investigation and may be Electron-related
- `games/bar-lobby`: OK
- `games/byar-chobby`: OK
- `games/itch`: installs and runs as `kitch`; some runtime dependencies are still missing
- `net/ferdium`: appears functional
- `net/signal-desktop`: screen sharing, webcam, and audio tested successfully
- `net/teams-for-linux`: screen sharing, webcam, and audio tested successfully
- `productivity/stretchly`: OK
- `sysutils/facette`: existing port migrated to `modyarn`; needs testing
- `www/pm2`: existing port migrated to `modnpm`; OK
- `www/uptime-kuma`: existing port proposal migrated to `modnpm`; OK
