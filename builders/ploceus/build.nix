{
  lib,
  buildGradlePackage,
  callPackage,
}:

{
  pname,
  version,
  src,
  lockFile,
  minecraftVersion,
  oslVersion,
  buildJdk ? null,
  gradle ? null,
  gradleInstallFlags ? [ "assemble" ],
  gradleFlags ? [ ],
  postPatch ? "",
  postInstall,
}:

buildGradlePackage {
  inherit
    pname
    version
    src
    lockFile
    gradleInstallFlags
    buildJdk
    gradle
    postPatch
    postInstall
    ;

  gradleFlags = [ "--offline" ] ++ gradleFlags;

  # Ploceus teaches modern Loom about legacy versions; it reads Ornithe's
  # gen2 manifest, calamus mappings and OSL metadata from Loom's cache.
  loomDependencies = callPackage ./caches.nix { } { inherit minecraftVersion oslVersion; };
  postConfigure = ''
    mkdir -p "$GRADLE_USER_HOME/caches"
    cp -rL "$loomDependencies" "$GRADLE_USER_HOME/caches/fabric-loom"
    chmod -R u+w "$GRADLE_USER_HOME/caches/fabric-loom"
  '';
}
