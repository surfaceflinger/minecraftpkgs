{
  lib,
  stdenv,
  fetchurl,
  unzip,
}:

{
  minecraftVersion,
  fabricApiVersion ? null,
}:

let
  versions = lib.importJSON ./versions.json;

  version =
    versions.versions.${minecraftVersion}
      or (throw "unknown minecraft version ${minecraftVersion}, add it to loaders/fabric/versions.json");

  fabricApi =
    if fabricApiVersion == null then
      null
    else
      versions.fabricApi.${fabricApiVersion}
        or (throw "unknown fabric-api version ${fabricApiVersion}, add it to loaders/fabric/versions.json");

  # Main POM maps current module names; deprecated POM is loom's fallback.
  fabricApiPom = if fabricApi == null then null else fetchurl { inherit (fabricApi) url sha256; };
  fabricApiDeprecatedPom =
    if fabricApi == null || !(fabricApi ? deprecated) then null else fetchurl fabricApi.deprecated;

  manifest = fetchurl versions.manifest;
  clientJar = fetchurl version.clientJar;
  serverJar = fetchurl version.serverJar;
  versionInfo = fetchurl version.manifest;

  # Old-era versions resolve through intermediary mappings; 26.x+ is
  # unobfuscated and needs nothing here.
  intermediary =
    if version ? intermediaryJar then
      stdenv.mkDerivation {
        name = "${minecraftVersion}-intermediary-v2.tiny";
        src = fetchurl version.intermediaryJar;
        dontPatch = true;
        dontConfigure = true;
        dontBuild = true;
        dontFixup = true;

        unpackCmd = ''${unzip}/bin/unzip "$src" "mappings/mappings.tiny"'';

        installPhase = ''
          cp mappings.tiny $out
        '';
      }
    else
      null;
in
stdenv.mkDerivation {
  name = "fabric-loom-cache-${minecraftVersion}";

  dontUnpack = true;
  dontPatch = true;
  dontConfigure = true;
  dontBuild = true;
  dontFixup = true;

  inherit
    manifest
    clientJar
    serverJar
    versionInfo
    intermediary
    fabricApiPom
    fabricApiDeprecatedPom
    ;

  installPhase = ''
    mkdir -p $out/${minecraftVersion}
    # Several names for cross-loom-version compatibility (see fabric2nix).
    ln -s $manifest $out/version_manifest.json
    ln -s $manifest $out/versions_manifest.json
    ln -s $manifest $out/mojang_versions_manifest.json
    ln -s $clientJar $out/${minecraftVersion}/minecraft-client.jar
    ln -s $serverJar $out/${minecraftVersion}/minecraft-server.jar
    ln -s $versionInfo $out/${minecraftVersion}/minecraft-info.json
    ln -s $versionInfo $out/${minecraftVersion}/mojang_minecraft_info.json
  ''
  + lib.optionalString (intermediary != null) ''
    ln -s $intermediary $out/${minecraftVersion}/intermediary-v2.tiny
  ''
  + lib.optionalString (fabricApiPom != null) ''
    mkdir -p $out/fabric-api
    ln -s $fabricApiPom $out/fabric-api/fabric-api-${fabricApiVersion}.pom
  ''
  + lib.optionalString (fabricApiDeprecatedPom != null) ''
    mkdir -p $out/fabric-api
    ln -s $fabricApiDeprecatedPom $out/fabric-api/fabric-api-deprecated-${fabricApiVersion}.pom
  '';
}
