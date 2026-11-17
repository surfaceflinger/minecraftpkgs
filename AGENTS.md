# AGENTS.md — minecraftpkgs

Nix-built Minecraft mods, pack assets, and (later) modpacks. Source builds via our `gradle2nix` fork, not prebuilt jars.

## Layout

```
flake.nix                  # nixpkgs-nixos-unstable-small, flake-parts, gradle2nix (nixpkgs follows ours)
loaders/fabric/caches.nix  # Loom offline cache derivation, takes { minecraftVersion }
loaders/fabric/versions.json  # pinned Mojang/Fabric URLs+hashes per MC version
loaders/fabric/build.nix     # fabric env builder: buildGradlePackage + loom cache + --offline
lib/mkMod.nix                # matrix: { pname, envs } -> { "<pname>-<env>" = drv; }, dispatches on env.loader
packages/mods/<mod>/default.nix  # spec only; locks live in locks/<env>.lock
packages/loaders/<name>/      # plain versioned loader packages (fabric-loader done)
packages/datapacks/<name>/ # plain fetchers (PLANNED)
packages/resourcepacks/<name>/  # MC-version table via lib.mkPackAsset (PLANNED)
packages/packs/<pack>/     # assembly only: .mrpack / instance zips (PLANNED)
docs/DEBT.md               # ordered checklist: Ornithe 1.8.9, Cleanroom 1.12.2, shared items
```

New files must be `git add -N` before nix sees them (flake requires tracked files).

## Decisions (do not relitigate without new evidence)

- Build mods from source with `github:surfaceflinger/gradle2nix` (our fork). Do NOT use the `fabric2nix` fork; it is stale (Oct 2024, Gradle 8.10) and upstream has moved on.
- No Kotlin fork of the tool. Pass `minecraftVersion` explicitly from the env table instead of extracting it via a patched plugin.
- Loader-first, flat package names: `sodium-fabric-26_3`. Underscores because dotted versions parse as nested nix paths. `fabric."26.3".sodium` nesting is rejected.
- `packages/mods/<mod>/default.nix` is a spec (`pname` + `envs` table), not a derivation. Columns per env: `loader`, `minecraft`, `src`, `lockFile`, `jdk`. One `gradle.lock` checked in per (mod x loader x mc).
- Loaders (`packages/loaders/*`) are plain versioned packages, no env matrix. Fabric API is a mod (goes through `mkMod`), not loader infra.
- Resourcepacks/datapacks get an MC-version-only table (`mkPackAsset`), no loader axis, no lock, no build. They do cut per-MC releases (pack_format bumps).
- Packs only assemble (jars into `overrides/mods/`); they are leaf derivations, never dependencies of mods. No installers, no launcher integration.
- `nix-fabric` is dead (last push Oct 2024, static 1.21-era snapshot). Its URL/hashes live in our own `loaders/fabric/versions.json`. No extra flake input for MC jars.

## gradle2nix fork knowledge

- Tool has two phases: `gradle2nix` CLI (impure, needs network) writes `gradle.lock` by sniffing resolved artifacts via an injected version-matched plugin shim; `buildGradlePackage` replays the build offline against a prefetched Maven repo.
- Versioned plugin names (`plugin-gradle81.jar`, `...G81`, `gradle-api-81`) are minimum-version floors (`>= 8.1` in `app/src/dist/share/init.gradle`), not ceilings. Do not rename.
- Proven: tool builds on Gradle 8.14.7 and locks Gradle 7.5 through 9.x. No `plugin/gradle90` shim needed.
- JDK matrix: Gradle 8.x runs on Java 8-24 only; Java 25 needs Gradle 9.1+. Fabric Loom 1.19 requires JDK 25 to run. Ornithe example pins Gradle 7.5.1. Cleanroom template pins Gradle 9.8.1.
- Our fork's `nix/init.gradle` carries two generic extras: skip redirecting `file://` repos (toolchain caches) and reproducible archive flags. Keep them loader-agnostic; anything naming "loom" belongs in minecraftpkgs.
- Mods' Gradle must match the wrapper's major line: pin `gradle_8`/`gradle_9` per env (nixpkgs), never the default `pkgs.gradle`. Loom 1.17+ plugins declare `org.gradle.plugin.api-version` 9.5+ and fail variant resolution on Gradle 8.

## Loom cache knowledge (Fabric)

- MC 26.x is unobfuscated (no `client_mappings` in Mojang manifest, no `intermediary` on Fabric maven). Loom 1.19 needs no mappings download.
- Observed offline input set (from a real Loom 1.19 + 26.3 cache): `mojang_versions_manifest.json`, `<ver>/minecraft-client.jar`, `<ver>/minecraft-server.jar`, `<ver>/mojang_minecraft_info.json`. Everything under `minecraftMaven/` and the processed jars are Loom outputs, regenerated offline.
- `caches.nix` output is copied (plain `cp -r`, then `chmod -R u+w`) into `$GRADLE_USER_HOME/caches/fabric-loom` at build time. No symlinks: store files carry 1970 mtimes and read-only modes, and loom re-downloads "outdated" files and writes hashes/lock files next to them. Planned wiring lives in `mkMod` as a `postConfigure` snippet; `loomDependencies` passed through `buildGradlePackage` (it forwards unknown attrs to the derivation).
- `versions.json` pins: live Mojang `version_manifest_v2.json` (moving snapshot, re-pin when adding versions), per-version manifest/client/server URLs+hashes. No generator script yet; see DEBT.md.

## Target environments

- **Fabric 26.3 (focus):** Gradle 9.8.x, Loom 1.17/1.19, JDK 25 to run. Locking proven green; loom cache ready; first full offline mod build green (`fabric-api-fabric-26_3`, 0.166.2).
- **OrnitheMC 1.8.9:** `ornithe-loom` 1.0+, Gradle 7.5.1, JDK 8-18. Covered by the `gradle75` shim for locking; loom cache layer still TBD (needs a normal build + cache inspection; old era likely still uses intermediary mappings, unlike 26.x).
- **CleanroomMC 1.12.2:** CleanroomGradle (modern ForgeGradle rewrite), Gradle 9.8.1, JDK 17+ to run while targeting Java 8 bytecode. Template needs `tokens.properties` stubbed for lock runs. Unknown whether its MC/MCP artifacts ride Maven (lock covers it) or need a cache layer like Loom. See `docs/DEBT.md` for both checklists.

## Workflow

- Long builds/downloads: run in background, never poll.
- Verify with real builds (`nix build`, lock runs against example mods), not reasoning.
- Commit messages: short upstream-style subject, body wrapped at 72 cols, footer `Assisted-by: OpenCode:muse-spark-1.3-contributor`.
- Never push; the human pushes.
- Keep it simple: smallest complete diff, no abstraction for later, `shortcut:` comments for known limits.
