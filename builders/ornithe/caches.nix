{
  lib,
  stdenv,
  fetchurl,
  unzip,
}:

{ minecraftVersion }:

let
  versions = lib.importJSON ./versions.json;

  version =
    versions.versions.${minecraftVersion}
      or (throw "unknown minecraft version ${minecraftVersion}, add it to loaders/ornithe/versions.json");

  inherit (version) manifest clientJar serverJar;
in
stdenv.mkDerivation {
  name = "ornithe-loom-cache-${minecraftVersion}";

  dontUnpack = true;
  dontPatch = true;
  dontConfigure = true;
  dontBuild = true;
  dontFixup = true;

  versionsManifest = fetchurl versions.manifest;
  client = fetchurl clientJar;
  server = fetchurl serverJar;
  versionInfo = fetchurl manifest;

  # Ornithe resolves through calamus intermediate mappings, which Loom
  # downloads itself; unpack them and place its expected outputs so the
  # provider short-circuits instead of going to the network.
  calamusJar = fetchurl version.calamus;

  calamus = stdenv.mkDerivation {
    name = "${minecraftVersion}-calamus-v2";
    src = fetchurl version.calamus;
    dontPatch = true;
    dontConfigure = true;
    dontBuild = true;
    dontFixup = true;

    unpackCmd = ''${unzip}/bin/unzip "$src" "mappings/mappings.tiny"'';
    sourceRoot = ".";

    installPhase = ''
      mkdir -p $out
      cp mappings/mappings.tiny $out/calamus-v2.tiny
      # calamus ships no nests; an empty file satisfies the provider's
      # existence check so it does not re-download offline.
      : > $out/calamus-v2.nest
    '';
  };

  installPhase = ''
    mkdir -p $out/${minecraftVersion}
    ln -s $versionsManifest $out/version_manifest.json
    ln -s $versionsManifest $out/mojang_versions_manifest.json
    ln -s $versionsManifest $out/versions_manifest.json
    ln -s $client $out/${minecraftVersion}/minecraft-client.jar
    ln -s $server $out/${minecraftVersion}/minecraft-server.jar
    ln -s $versionInfo $out/${minecraftVersion}/minecraft-info.json
    ln -s $versionInfo $out/${minecraftVersion}/mojang_minecraft_info.json
    ln -s $calamus/calamus-v2.tiny $out/${minecraftVersion}/calamus-v2.tiny
    ln -s $calamus/calamus-v2.nest $out/${minecraftVersion}/calamus-v2.nest
  '';
}
