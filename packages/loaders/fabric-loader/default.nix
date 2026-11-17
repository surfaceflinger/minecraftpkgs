{
  lib,
  fetchFromGitHub,
  jdk8,
  buildGradlePackage,
  loomCache,
}:

buildGradlePackage {
  pname = "fabric-loader";
  version = "0.20.1";

  src = fetchFromGitHub {
    owner = "FabricMC";
    repo = "fabric-loader";
    rev = "0.20.1";
    hash = "sha256-I8nWWRsLtomEYVL+rSPdAL5ZvPiIfpaXt4MGPufvA84=";
  };

  lockFile = ./gradle.lock;

  # :jar is disabled upstream; the deliverable chain is fatJar -> proguardJar -> finalJar.
  gradleInstallFlags = [ ":finalJar" ];

  # Toolchain JDK, nix-provided: the sandbox has no network for auto-provisioning.
  gradleFlags = [
    "-Porg.gradle.java.installations.paths=${jdk8}"
    "--offline"
  ];

  # The build includes a loom-based minecraft test subproject; feed it the
  # offline loom cache. Plain cp (not -rs): store files carry 1970 mtimes
  # and read-only modes, and loom re-downloads "outdated" files and writes
  # hashes/lock files next to them.
  loomDependencies = loomCache;
  postConfigure = ''
    mkdir -p "$GRADLE_USER_HOME/caches"
    cp -r "$loomDependencies" "$GRADLE_USER_HOME/caches/fabric-loom"
    chmod -R u+w "$GRADLE_USER_HOME/caches/fabric-loom"
  '';

  postInstall = ''
    mkdir -p $out/share/java
    cp build/libs/fabric-loader-*.jar $out/share/java/
  '';

  meta = with lib; {
    description = "Mod loader for Fabric mods";
    homepage = "https://fabricmc.net";
    license = licenses.asl20;
    platforms = platforms.all;
  };
}
