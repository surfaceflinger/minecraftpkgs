{
  fetchFromGitHub,
  jdk25,
  gradle_9,
  mkMod,
}:

{
  packages = mkMod {
    pname = "fabric-api";
    envs = {
      "fabric-26_3" = {
        loader = "fabric";
        version = "0.166.2+26.3";
        minecraftVersion = "26.3";
        src = fetchFromGitHub {
          owner = "FabricMC";
          repo = "fabric-api";
          rev = "0.166.2+26.3";
          hash = "sha256-6f9YtWEpHMJP68StDKElrvNGL58gKtNe9YXZ9lFCLSw=";
        };
        lockFile = ./locks/fabric-26_3.lock;
        # Loom 1.17 needs JDK 25 to run, and its plugins need Gradle 9.5+.
        buildJdk = jdk25;
        gradle = gradle_9;
        # assemble runs remapJar without the test suites.
        gradleInstallFlags = [ "assemble" ];
        postInstall = ''
          mkdir -p $out/share/java
          find . -path '*/build/libs/*.jar' -not -name '*-sources.jar' -not -path './build-logic/*' -exec cp {} $out/share/java/ \;
        '';
      };
    };
  };
}
