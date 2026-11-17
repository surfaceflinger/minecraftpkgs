# Debt / future work: old-MC mod environments

Targets: OrnitheMC 1.8.9, CleanroomMC 1.12.2, current Fabric (26.3).
Focus now is Fabric 26.3; the two older environments are queued below.

Proven so far: our `gradle2nix` fork locks Gradle 7.5 through 9.x
(8.14.7 to build the tool; 9.8.2 + Loom 1.19.4 lock verified green).
No `plugin/gradle90` shim needed. Versioned plugin names (`gradle81`, …)
are minimum-version floors, not ceilings — do not rename.

## OrnitheMC (1.8.9)

- [ ] Lock run: our `gradle2nix` vs `ornithe-example-mod` (Gradle 7.5.1, JDK 8–18) — expect green, confirm
- [ ] Normal (non-nix) build once, inspect `~/.gradle/caches` — list everything ornithe-loom fetches outside Maven (MC jars, intermediary/feather mappings, manifest)
- [ ] Vendor `loaders/ornithe/caches.nix` mirroring `fabric2nix`'s `build-loom-caches.nix`, fed by explicit `minecraftVersion` (no Kotlin fork)
- [ ] Setup-hook snippet symlinking the cache into `GRADLE_USER_HOME` (check dir name ornithe-loom expects — likely same `fabric-loom`)
- [ ] Pin `buildJdk` for the 1.8.9 era (Gradle 7.5 runs 8–18; game wants 8 — verify which actually survives Loom's decompile steps)
- [ ] Sandboxed `nix build` of the example mod, then one real 1.8.9 mod

## CleanroomMC (1.12.2)

- [ ] Lock run vs `CleanroomModTemplate` (Gradle 9.8.1, JDK 17+/21) — stub `tokens.properties` with dummies first
- [ ] Normal build once, inspect caches — determine whether CleanroomGradle routes MC/MCP/SRG through Maven (lock covers it, nothing to do) or custom downloads (cache layer needed)
- [ ] If custom: `loaders/cleanroom/caches.nix` + hook, same pattern as above
- [ ] Pin `buildJdk` (Gradle 9 needs 17+ to run; mod targets Java 8 bytecode — verify)
- [ ] Sandboxed `nix build` of the template, then one real 1.12.2 mod

## Shared (`minecraftpkgs`)

- [ ] `lib/mkMod { loader, minecraftVersion, src, lockFile, ... }` dispatching to `loaders/<loader>/`
- [ ] One `gradle.lock` checked in per (mod × loader × mc)
- [ ] Test matrix: 1.8.9 Ornithe × 1.12.2 Cleanroom × 26.3 Fabric, all three green before adding more mods

## Loaders (plain versioned packages, no env matrix)

Loaders run across MC versions, so no matrix: `version + src + lock`.

- [ ] `packages/loaders/fabric-loader/` (first, easiest)
- [ ] `packages/loaders/quilt-loader/`
- [ ] Forge/NeoForge installers last — likely prebuilt fat jars, so plain
  `fetchurl` packages, not source builds. No installer/launch-wrapping
  scope beyond that.

## Resourcepacks / datapacks (MC-version table, no loader axis, no build)

Correction to the earlier "no matrix" call: packs do cut separate
releases per MC (pack_format / data-format bumps), so each gets a
version table — but keyed by MC version only, no loader, no lock, no
JDK, just fetch/unzip:

```nix
# packages/resourcepacks/faithful/default.nix
{ lib, ... }: lib.mkPackAsset {
  versions = { "26_3" = …src…; "26_1" = …src…; };
}
```

- [ ] `lib/mkPackAsset { versions }` (fetch + unpack only)
- [ ] `packages/resourcepacks/faithful/`, `packages/datapacks/terralith/` as first instances

## Packs (assemble, never build)

Long-term output: `.mrpack` / PrismLauncher instance zips.
`packages/packs/<pack>/default.nix` pins the env once; entries resolve
to that env's derivations. Jars go in `overrides/mods/` (we are the
source — no URLs/hash-chasing). Packs assemble only, and stay leaf
derivations (never dependencies of mods).
