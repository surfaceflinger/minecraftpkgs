{
  fetchFromGitHub,
  jdk25,
  gradle_9,
  mkMod,
}:

{
  packages = mkMod {
    pname = "argentum";
    envs = {
      "ploceus-1_8_9" = {
        loader = "ploceus";
        version = "1.0.2";
        minecraftVersion = "1.8.9";
        oslVersion = "0.22.0";
        src = fetchFromGitHub {
          owner = "QuicksilverMC";
          repo = "Argentum";
          rev = "f2a96a5895bc68651f466638f6a1ededd46e52b8";
          hash = "sha256-y9nOZs8eYSC3sp4iY4cxzJo3yTnYQaBoDMKEjQY7AJw=";
        };
        lockFile = ./locks/ploceus-1_8_9.lock;
        # Modern Loom + ploceus: Gradle 9, Java 25.
        gradle = gradle_9;
        buildJdk = jdk25;
        postInstall = ''
          mkdir -p $out/share/java
          find . -path '*/build/libs/*.jar' -not -name '*-sources.jar' -not -path './buildSrc/*' -exec cp {} $out/share/java/ \;
        '';
      };
    };
  };
}
