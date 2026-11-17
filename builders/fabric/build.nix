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
  fabricApiVersion ? null,
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
    postInstall
    postPatch
    ;

  # Everything (deps + MC files) is vendored; the sandbox has no network.
  gradleFlags = [ "--offline" ] ++ gradleFlags;

  # Loom resolves MC outside Maven; feed it the offline cache.
  loomDependencies = callPackage ./caches.nix { } { inherit minecraftVersion fabricApiVersion; };
  postConfigure = ''
    mkdir -p "$GRADLE_USER_HOME/caches"
    cp -r "$loomDependencies" "$GRADLE_USER_HOME/caches/fabric-loom"
    # Plain cp (not -rs): store files carry 1970 mtimes and read-only
    # modes, and loom re-downloads "outdated" files and writes
    # hashes/lock files next to them.
    chmod -R u+w "$GRADLE_USER_HOME/caches/fabric-loom"
  '';
}
