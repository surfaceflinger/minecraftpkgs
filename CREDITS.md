# Credits / prior art

- [tadfisher/gradle2nix](https://github.com/tadfisher/gradle2nix) (v2 branch) — the build tool itself. Our [surfaceflinger/gradle2nix](https://github.com/surfaceflinger/gradle2nix) fork tracks it (merged `v2` to `master`), plus updates and two generic `nix/init.gradle` additions.
- [ashhhleyyy/fabric2nix](https://github.com/ashhhleyyy/fabric2nix) — fork of gradle2nix v2 adding Fabric Loom support. Referenced for the design (offline loom cache symlinked into `GRADLE_USER_HOME`, file-repo guard, reproducible archive flags). Our `loaders/fabric` is a from-scratch rewrite for the Loom 1.17/1.19 layout, not a copy.
- [ashhhleyyy/nix-fabric](https://github.com/ashhhleyyy/nix-fabric) — evaluated as the MC-jar source; rejected (frozen Oct 2024 snapshot, no 26.x). Its `versions.json` split informed our own `builders/fabric/versions.json`.
