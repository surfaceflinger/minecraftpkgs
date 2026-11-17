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
  buildJdk ? null,
  gradle ? null,
  gradleInstallFlags ? [ "build" ],
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

  # Everything (deps + MC files) is vendored; the sandbox has no network.
  gradleFlags = [ "--offline" ] ++ gradleFlags;

  # Ornithe downloads MC files and calamus mappings outside Maven.
  loomDependencies = callPackage ./caches.nix { } { inherit minecraftVersion; };
  postConfigure = ''
    mkdir -p "$GRADLE_USER_HOME/caches"
    cp -rL "$loomDependencies" "$GRADLE_USER_HOME/caches/ornithe-loom"
    chmod -R u+w "$GRADLE_USER_HOME/caches/ornithe-loom"
  '';
}
