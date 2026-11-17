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
            fabric = pkgs.callPackage ./loaders/fabric/build.nix {
              inherit (builders) buildGradlePackage;
            };
          };
          mkMod = pkgs.callPackage ./lib/mkMod.nix { inherit loaders; };
        in
        {
          packages = {
            inherit (inputs.gradle2nix.packages.${system}) gradle2nix;
            loom-cache-1_20_2 = pkgs.callPackage ./loaders/fabric/caches.nix { } {
              minecraftVersion = "1.20.2";
            };
            loom-cache-26_3 = pkgs.callPackage ./loaders/fabric/caches.nix { } {
              minecraftVersion = "26.3";
            };
            fabric-loader = pkgs.callPackage ./packages/loaders/fabric-loader {
              inherit (builders) buildGradlePackage;
              loomCache = pkgs.callPackage ./loaders/fabric/caches.nix { } {
                minecraftVersion = "1.20.2";
              };
            };
          }
          // pkgs.callPackage ./packages/mods/fabric-api { inherit mkMod; }
          // pkgs.callPackage ./packages/mods/sodium { inherit mkMod; };
        };
    };
}
