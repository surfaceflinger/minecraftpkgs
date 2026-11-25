{
  description = "Nix-built Minecraft mods and modpacks";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable-small";
    flake-parts.url = "github:hercules-ci/flake-parts";
    gradle2nix = {
      url = "github:surfaceflinger/gradle2nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = inputs.nixpkgs.lib.systems.flakeExposed;

      perSystem =
        { system, ... }:
        let
          pkgs = import inputs.nixpkgs { inherit system; };
          builders = inputs.gradle2nix.builders.${system};
          loaders = {
            fabric = pkgs.callPackage ./builders/fabric/build.nix {
              inherit (builders) buildGradlePackage;
            };
            ornithe = pkgs.callPackage ./builders/ornithe/build.nix {
              inherit (builders) buildGradlePackage;
            };
            ploceus = pkgs.callPackage ./builders/ploceus/build.nix {
              inherit (builders) buildGradlePackage;
            };
          };
          mkMod = pkgs.callPackage ./lib/mkMod.nix { inherit loaders; };
          gradle7 = pkgs.callPackage ./packages/devel/gradle_7 { };
          gradleJdk21 = pkgs.callPackage ./packages/devel/gradle-jdk {
            jdk = pkgs.jdk21;
            javaVersion = "21";
          };
          gradleJdk25 = pkgs.callPackage ./packages/devel/gradle-jdk {
            jdk = pkgs.jdk25;
            javaVersion = "25";
          };
        in
        {
          packages = {
            inherit (inputs.gradle2nix.packages.${system}) gradle2nix;
            gradle_7 = gradle7;
            neoforge = pkgs.callPackage ./packages/loaders/neoforge {
              inherit (builders) buildGradlePackage;
              inherit gradleJdk21 gradleJdk25;
              neoformArtifacts = pkgs.callPackage ./builders/neoforge/caches.nix { };
            };
            loom-cache-1_20_2 = pkgs.callPackage ./builders/fabric/caches.nix { } {
              minecraftVersion = "1.20.2";
            };
            loom-cache-26_3 = pkgs.callPackage ./builders/fabric/caches.nix { } {
              minecraftVersion = "26.3";
            };
            loom-cache-ornithe-1_8_9 = pkgs.callPackage ./builders/ornithe/caches.nix { } {
              minecraftVersion = "1.8.9";
            };
            fabric-loader = pkgs.callPackage ./packages/loaders/fabric-loader {
              inherit (builders) buildGradlePackage;
              loomCache = pkgs.callPackage ./builders/fabric/caches.nix { } {
                minecraftVersion = "1.20.2";
              };
            };
          }
          // (pkgs.callPackage ./packages/mods/fabric-api { inherit mkMod; }).packages
          // (pkgs.callPackage ./packages/mods/sodium { inherit mkMod; }).packages
          // (pkgs.callPackage ./packages/mods/argentum { inherit mkMod; }).packages
          // (pkgs.callPackage ./packages/mods/ornithe-example-mod {
            inherit mkMod;
            gradle_7' = gradle7;
          }).packages;
        };
    };
}
