{
  lib,
  stdenv,
  fetchurl,
  runCommand,
  jq,
  unzip,
}:

{ minecraftVersion, oslVersion }:

let
  versions = lib.importJSON ./versions.json;
  mc = lib.importJSON ../ornithe/versions.json;

  version =
    versions.versions.${minecraftVersion}
      or (throw "unknown minecraft version ${minecraftVersion}, add it to builders/ploceus/versions.json");

  osl =
    versions.osl.${oslVersion}
      or (throw "unknown OSL version ${oslVersion}, add it to builders/ploceus/versions.json");

  minecraft =
    mc.versions.${minecraftVersion}
      or (throw "unknown minecraft version ${minecraftVersion}, add it to builders/ornithe/versions.json");

  calamus = stdenv.mkDerivation {
    name = "${minecraftVersion}-calamus-gen2-intermediary";
    src = fetchurl version.calamus;
    dontPatch = true;
    dontConfigure = true;
    dontBuild = true;
    dontFixup = true;

    unpackCmd = ''${unzip}/bin/unzip "$src" "mappings/mappings.tiny"'';
    sourceRoot = ".";

    installPhase = ''
      cp mappings/mappings.tiny $out
    '';
  };

  manifest = fetchurl versions.manifest;
  info = fetchurl version.info;
  details = fetchurl version.details;

  # The meta endpoints return raw lists; Ploceus caches derived shapes.
  libraries = runCommand "library-upgrades.json" { nativeBuildInputs = [ jq ]; } ''
    jq '{ "gen2": map(.name) }' ${fetchurl version.libraries} > $out
  '';

  oslBase = runCommand "osl-base-versions.json" { nativeBuildInputs = [ jq ]; } ''
    jq --arg ver "${oslVersion}" '
      { "gen2": { ($ver): (map({ (.maven | split(":")[1]): .version }) | add) } }
    ' ${fetchurl osl} > $out
  '';
  client = fetchurl minecraft.clientJar;
  server = fetchurl minecraft.serverJar;
in
stdenv.mkDerivation {
  name = "ploceus-loom-cache-${minecraftVersion}";

  dontUnpack = true;
  dontPatch = true;
  dontConfigure = true;
  dontBuild = true;
  dontFixup = true;

  inherit
    manifest
    info
    details
    libraries
    oslBase
    client
    server
    calamus
    ;

  installPhase = ''
    mkdir -p $out/${minecraftVersion}

    # Ornithe gen2 version manifest and the per-version files Ploceus reads.
    ln -s $manifest $out/ornithe-gen2_versions_manifest.json
    ln -s $info $out/${minecraftVersion}/ornithe-gen2_minecraft_info.json
    ln -s $details $out/${minecraftVersion}/minecraft-details.json
    ln -s $libraries $out/${minecraftVersion}/library-upgrades.json
    ln -s $oslBase $out/osl-base-versions.json
    ln -s $calamus $out/${minecraftVersion}/calamus-gen2-intermediary-v2.tiny
    ln -s $client $out/${minecraftVersion}/minecraft-client.jar
    ln -s $server $out/${minecraftVersion}/minecraft-server.jar

    # Ploceus aggregates per-module OSL lookups into this file; there is no
    # single endpoint for it, so it is vendored (regenerate by running a
    # networked build and copying $GRADLE_USER_HOME/caches/fabric-loom).
    ln -s ${./osl-versions/1.8.9.json} $out/${minecraftVersion}/osl-versions.json
  '';
}
