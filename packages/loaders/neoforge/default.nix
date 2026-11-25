{
  lib,
  fetchFromGitHub,
  gradle_9,
  gradleJdk21,
  gradleJdk25,
  buildGradlePackage,
  neoformArtifacts,
}:

# NeoForge is built from source with NeoForm: it downloads Minecraft, applies
# the patch set, decompiles and compiles. The installer jar is intentionally
# not built.
let
  version = "26.3.0.110";
  javaVersion = "25";
in
buildGradlePackage {
  pname = "neoforge";
  inherit version;

  src = fetchFromGitHub {
    owner = "neoforged";
    repo = "NeoForge";
    rev = "b404a2d93a533984ac5acbdefb82213cb3d51365";
    hash = "sha256-FOWF3rtU50JjvhrCYnBsFjWRZkH3aRoSvw1Z5BrTM8M=";
  };

  lockFile = ./gradle.lock;

  # Project pins Gradle 9.8.x; the 9.x line is what its plugins expect.
  gradle = gradle_9;
  # NeoForm asks for a 21 toolchain for source artifacts and 25 for compiling.
  buildJdk = gradleJdk25;

  gradleFlags = [
    "-Pversion=${version}"
    "-Porg.gradle.java.installations.paths=${gradleJdk21}:${gradleJdk25}"
    # NeoForge enables the configuration cache; it caches toolchain failures
    # and breaks locking when the JDK set changes.
    "--no-configuration-cache"
  ];

  # buildSrc is also resolved standalone when locking, where gradle.parent is
  # null; pin the versions it would otherwise read from the parent settings.
  postPatch = ''
    sed -i \
      -e "s/gradle\.parent\.ext\.moddevgradle_plugin_version/'2.0.148'/" \
      -e "s/gradle\.parent\.ext\.minecraft_version/'26.3'/" \
      -e "s/gradle\.parent\.ext\.diffpatch_version/'2.1.0.43'/" \
      -e "s/gradle\.parent\.ext\.asm_version/'9.11'/" \
      buildSrc/build.gradle
  '';

  # NeoForm Runtime reads Minecraft jars/libraries from this cache; it is
  # outside Gradle's dependency engine, so it is not in gradle.lock.
  neoformArtifacts = neoformArtifacts;
  postConfigure = ''
    mkdir -p "$GRADLE_USER_HOME/caches"
    cp -rL "$neoformArtifacts" "$GRADLE_USER_HOME/caches/neoformruntime-artifacts"
    mkdir -p "$GRADLE_USER_HOME/caches/neoformruntime"
    cp -rL "$neoformArtifacts" "$GRADLE_USER_HOME/caches/neoformruntime/artifacts"
    chmod -R u+w "$GRADLE_USER_HOME/caches/neoformruntime"
  '';

  gradleInstallFlags = [ ":neoforge:universalJar" ];

  postInstall = ''
    mkdir -p $out/share/java
    find projects/neoforge/build/libs -name "*-universal.jar" -exec cp {} $out/share/java/ \;
  '';

  meta = with lib; {
    description = "NeoForge mod loader, built from source";
    homepage = "https://neoforged.net";
    license = licenses.lgpl21Only;
    platforms = platforms.all;
  };
}
