{
  lib,
  stdenv,
  fetchurl,
}:

let
  version = "26.3.0.110";
in
stdenv.mkDerivation {
  pname = "neoforge";
  inherit version;

  # The loader jar; the installer is the same artifacts plus install logic.
  src = fetchurl {
    url = "https://maven.neoforged.net/releases/net/neoforged/neoforge/${version}/neoforge-${version}-universal.jar";
    hash = "sha256-Twpo1U/ugzu4ARnq5lrSTnlgUz54voW4htS2IPicMxA=";
  };

  dontUnpack = true;
  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    mkdir -p $out/share/java
    cp $src $out/share/java/neoforge-${version}-universal.jar
  '';

  meta = with lib; {
    description = "NeoForge mod loader";
    homepage = "https://neoforged.net";
    license = licenses.lgpl21Only;
    platforms = platforms.all;
  };
}
