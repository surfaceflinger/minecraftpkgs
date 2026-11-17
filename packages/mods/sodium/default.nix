{
  fetchFromGitHub,
  jdk25,
  gradle_9,
  mkMod,
}:

{
  packages = mkMod {
    pname = "sodium";
    envs = {
      "fabric-26_3" = {
        loader = "fabric";
        version = "0.9.2+26.3";
        minecraftVersion = "26.3";
        src = fetchFromGitHub {
          owner = "CaffeineMC";
          repo = "sodium";
          rev = "mc26.3-0.9.2";
          hash = "sha256-k85yTFA6vyPazDY9UTggnzBg/f+vio762hHShqhDuK8=";
        };
        lockFile = ./locks/fabric-26_3.lock;
        # Loom 1.17 needs JDK 25 to run, plugins need Gradle 9.5+.
        buildJdk = jdk25;
        gradle = gradle_9;
        # Pinned per BuildConfig.FABRIC_API_VERSION; loom reads module versions from it.
        fabricApiVersion = "0.160.5+26.3";
        # :jar is not the deliverable here; the fabric module assembles it.
        gradleInstallFlags = [ ":fabric:assemble" ];
        # We ship the fabric build only; the neoforge subproject breaks
        # modJar creation under our Gradle and is not needed for it.
        postPatch = ''
          sed -i '/^include("neoforge")$/d' settings.gradle.kts
        '';
        postInstall = ''
          mkdir -p $out/share/java
          cp build/mods/*.jar $out/share/java/
        '';
      };
    };
  };
}
