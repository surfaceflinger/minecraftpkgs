{
  fetchFromGitHub,
  jdk17,
  gradle_7',
  mkMod,
}:

mkMod {
  pname = "ornithe-example-mod";
  envs = {
    "ornithe-1_8_9" = {
      loader = "ornithe";
      version = "0.0.0";
      minecraftVersion = "1.8.9";
      src = fetchFromGitHub {
        owner = "OrnitheMC";
        repo = "ornithe-example-mod";
        rev = "74efedb182b3f89fa424eae4ad05bf954382d9f5";
        hash = "sha256-CdGgVgxCQcQXncDtXr6sMchNG9V1bE2TzeUJg1CkBgI=";
      };
      lockFile = ./locks/ornithe-1_8_9.lock;
      # Ornithe-era projects pin Gradle 7 and run it on JDK 17.
      gradle = gradle_7';
      buildJdk = jdk17;
      # The template targets 1.7.2; this build pins 1.8.9.
      postPatch = ''
        sed -i 's/minecraft_version = .*/minecraft_version = 1.8.9/' gradle.properties
        sed -i 's/feather_mappings = .*/feather_mappings = 1.8.9+build.1/' gradle.properties
      '';
      postInstall = ''
        mkdir -p $out/share/java
        cp build/libs/*.jar $out/share/java/
      '';
    };
  };
}
