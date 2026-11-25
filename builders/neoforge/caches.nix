# NeoForm Runtime (used by moddev-gradle) downloads Minecraft jars, the
# version metadata and native libraries outside Gradle's dependency engine,
# so they never appear in the lock file. This derivation reproduces the
# `caches/neoformruntime/artifacts` tree it expects.
{
  lib,
  stdenv,
  fetchurl,
}:

let
  artifacts = {
    "minecraft_launcher_manifest.json" = {
      url = "https://piston-meta.mojang.com/mc/game/version_manifest_v2.json";
      hash = "sha256-S+P5e8vUuAPVZF61rFaqyxtFpk0Ek6XUUJHG+tG+n0E=";
    };
    "minecraft_26.3_version_manifest.json" = {
      url = "https://piston-meta.mojang.com/v1/packages/9f67e10ed013deeaad20ac3c800652765d493408/26.3.json";
      hash = "sha256-oYMbPl/6R5wC2IpEF5T/CmmBMhXl0OlF7fA6mcdgjC4=";
    };
    "minecraft_26.3_client.jar" = {
      url = "https://piston-data.mojang.com/v1/objects/e877b6a07acd633fb3bb475002175cec036e7b87/client.jar";
      hash = "sha256-RQjQBjI/JPoCh2MQwZLXOa9WUW6yWQAKxQ8JCaaMmi0=";
    };
    "minecraft_26.3_server.jar" = {
      url = "https://piston-data.mojang.com/v1/objects/33680f5f2ac32864d6d7cf5e56a705fdb3e05f4c/server.jar";
      hash = "sha256-0FLxTXoXNzT7pVNxHltXAWLi8qMTJn7jGiG5daZ5vmQ=";
    };
    "com/mojang/jtracy/1.14.38/jtracy-1.14.38-natives-linux.jar" = {
      url = "https://libraries.minecraft.net/com/mojang/jtracy/1.14.38/jtracy-1.14.38-natives-linux.jar";
      hash = "sha256-bGT0VeuqX2YxNhArdfymNQeNee/ihKoKo8YPoxzkggM=";
    };
    "io/netty/netty-transport-native-epoll/4.2.16.Final/netty-transport-native-epoll-4.2.16.Final-linux-aarch_64.jar" =
      {
        url = "https://libraries.minecraft.net/io/netty/netty-transport-native-epoll/4.2.16.Final/netty-transport-native-epoll-4.2.16.Final-linux-aarch_64.jar";
        hash = "sha256-ISzH2BOQ4xtYCh+5G2yNljtD52LtByxVXisJrUR26Sg=";
      };
    "io/netty/netty-transport-native-epoll/4.2.16.Final/netty-transport-native-epoll-4.2.16.Final-linux-x86_64.jar" =
      {
        url = "https://libraries.minecraft.net/io/netty/netty-transport-native-epoll/4.2.16.Final/netty-transport-native-epoll-4.2.16.Final-linux-x86_64.jar";
        hash = "sha256-LgBUjnMZSIgdDHPuedLq11klTnUJKUBqHVlUhHWPAmc=";
      };
    "org/lwjgl/lwjgl/3.4.3/lwjgl-3.4.3-natives-linux.jar" = {
      url = "https://libraries.minecraft.net/org/lwjgl/lwjgl/3.4.3/lwjgl-3.4.3-natives-linux.jar";
      hash = "sha256-1xnlRabbTqh+tk1VYwumKHVVcrtbVtUaFUg0e1NUyts=";
    };
    "org/lwjgl/lwjgl-freetype/3.4.3/lwjgl-freetype-3.4.3-natives-linux.jar" = {
      url = "https://libraries.minecraft.net/org/lwjgl/lwjgl-freetype/3.4.3/lwjgl-freetype-3.4.3-natives-linux.jar";
      hash = "sha256-y8cCqh2cj+zm/kak5gbHwWTrfw98p59mjdlVRNtT+yw=";
    };
    "org/lwjgl/lwjgl-jemalloc/3.4.3/lwjgl-jemalloc-3.4.3-natives-linux.jar" = {
      url = "https://libraries.minecraft.net/org/lwjgl/lwjgl-jemalloc/3.4.3/lwjgl-jemalloc-3.4.3-natives-linux.jar";
      hash = "sha256-HH/CcfEy49YG0wRLJSD8tmNIHlXleDxu9CcuO65zp9k=";
    };
    "org/lwjgl/lwjgl-openal/3.4.3/lwjgl-openal-3.4.3-natives-linux.jar" = {
      url = "https://libraries.minecraft.net/org/lwjgl/lwjgl-openal/3.4.3/lwjgl-openal-3.4.3-natives-linux.jar";
      hash = "sha256-Qzy/GbFrF33RKJfvJMNxF9n//0hza2yBYW78cq1Gkfk=";
    };
    "org/lwjgl/lwjgl-opengl/3.4.3/lwjgl-opengl-3.4.3-natives-linux.jar" = {
      url = "https://libraries.minecraft.net/org/lwjgl/lwjgl-opengl/3.4.3/lwjgl-opengl-3.4.3-natives-linux.jar";
      hash = "sha256-QFboHBF0IB9j6YD3a5lVdGwPE9cS5NMO4Cw4rmvM1M4=";
    };
    "org/lwjgl/lwjgl-sdl/3.4.3/lwjgl-sdl-3.4.3-natives-linux.jar" = {
      url = "https://libraries.minecraft.net/org/lwjgl/lwjgl-sdl/3.4.3/lwjgl-sdl-3.4.3-natives-linux.jar";
      hash = "sha256-4YgGg6SvMymemhuNfsF5m+2PtwkGTqCNzCoVzREBwLM=";
    };
    "org/lwjgl/lwjgl-shaderc/3.4.3/lwjgl-shaderc-3.4.3-natives-linux.jar" = {
      url = "https://libraries.minecraft.net/org/lwjgl/lwjgl-shaderc/3.4.3/lwjgl-shaderc-3.4.3-natives-linux.jar";
      hash = "sha256-Dc7W0zYsvNaNismgfyzgRcYEqavONx4fZsd8+4N/f9c=";
    };
    "org/lwjgl/lwjgl-spvc/3.4.3/lwjgl-spvc-3.4.3-natives-linux.jar" = {
      url = "https://libraries.minecraft.net/org/lwjgl/lwjgl-spvc/3.4.3/lwjgl-spvc-3.4.3-natives-linux.jar";
      hash = "sha256-iJgWWpCRG/1r4KoRaESdkJLxdH9rehbCJw2CZZgXJbM=";
    };
    "org/lwjgl/lwjgl-stb/3.4.3/lwjgl-stb-3.4.3-natives-linux.jar" = {
      url = "https://libraries.minecraft.net/org/lwjgl/lwjgl-stb/3.4.3/lwjgl-stb-3.4.3-natives-linux.jar";
      hash = "sha256-XGai8RsYBiti75xkM/dTcg972tRLGKtAeKCmQEpkpyA=";
    };
    "org/lwjgl/lwjgl-vma/3.4.3/lwjgl-vma-3.4.3-natives-linux.jar" = {
      url = "https://libraries.minecraft.net/org/lwjgl/lwjgl-vma/3.4.3/lwjgl-vma-3.4.3-natives-linux.jar";
      hash = "sha256-+GkHEchC3lqhV1lFm4KU/WguRSRBsGO9f5AnENuAGAQ=";
    };
  };
in
stdenv.mkDerivation {
  name = "neoform-runtime-artifacts";

  dontUnpack = true;
  dontPatch = true;
  dontConfigure = true;
  dontBuild = true;
  dontFixup = true;

  installPhase = lib.concatStringsSep "\n" (
    lib.mapAttrsToList (
      name: artifact:
      let
        file = fetchurl artifact;
      in
      ''
        mkdir -p "$out/$(dirname "${name}")"
        ln -s ${file} "$out/${name}"
      ''
    ) artifacts
  );
}
