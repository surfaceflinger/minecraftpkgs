# Gradle 7 was dropped from nixpkgs (EOL), but Ornithe-era projects pin it.
# Reuse nixpkgs' own builder so the package keeps their wrapper, JVM default
# and native-platform handling instead of a hand-rolled copy.
{ gradle-packages, jdk17 }:

gradle-packages.mkGradle {
  version = "7.6.6";
  hash = "sha256-Zz2XdvMDvHBI/DMp0jLW6/EFGweJO9nRFhb62ahnO+A=";
  defaultJava = jdk17;
  updateScriptMajorVersion = "7";
}
