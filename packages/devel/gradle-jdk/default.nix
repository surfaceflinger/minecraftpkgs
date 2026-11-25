# Gradle identifies toolchains by the JDK's `release` file, which nixpkgs
# JDKs only ship under lib/openjdk. Wrap the JDK so Gradle can detect it,
# and make sure JAVA_VERSION (the key it reads) is present.
{
  lib,
  stdenv,
  jdk,
  javaVersion,
}:

stdenv.mkDerivation {
  pname = "gradle-jdk";
  inherit javaVersion;
  version = javaVersion;

  dontUnpack = true;
  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    mkdir -p $out
    cp -rs ${jdk}/. $out/

    if [ -e ${jdk}/release ]; then
      cp ${jdk}/release $out/release
    else
      cp ${jdk}/lib/openjdk/release $out/release
    fi
    chmod u+w $out $out/release
    grep -q '^JAVA_VERSION=' $out/release || echo "JAVA_VERSION=\"${javaVersion}\"" >> $out/release
  '';

  meta = with lib; {
    description = "JDK wrapped for Gradle toolchain detection";
    platforms = platforms.all;
  };
}
