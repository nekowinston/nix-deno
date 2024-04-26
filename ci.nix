{pkgs ? import <nixpkgs> {overlays = [(import ./nix)];}}: let
  nvfetcher = pkgs.callPackage ./_sources/generated.nix {};
  esbuild = nvfetcher."esbuild-${pkgs.stdenv.hostPlatform.system}";
in {
  # simple deno.land imports
  remote-simple = pkgs.denoPlatform.mkDenoPackage {
    name = "remote-simple";
    src = ./examples/remote;
  };

  # with esm.sh dependencies
  esm-simple = pkgs.denoPlatform.mkDenoPackage {
    name = "esm-simple";
    src = ./examples/esm-simple;
  };

  # with npm dependencies
  npm-simple = pkgs.denoPlatform.mkDenoPackage {
    name = "npm-simple";
    src = ./examples/npm-simple;
  };

  # with npm dependencies + custom registry
  npm-simple-custom-npm-registry = pkgs.denoPlatform.mkDenoPackage {
    name = "npm-simple-custom-npm-registry";
    src = ./examples/npm-simple;

    npmRegistryUrl = "http://localhost:4873";
  };

  # Fresh project heavily utilizing esm.sh dependencies
  fresh = pkgs.denoPlatform.mkDenoPackage {
    name = "fresh";
    src = ./examples/fresh;

    env.ESBUILD_BINARY_PATH = "${esbuild.src}/bin/esbuild";
  };

  # Lume project with mixed dependencies, building a simple static site
  lume = pkgs.denoPlatform.mkDenoDerivation {
    name = "lume";
    src = ./examples/lume;

    stdenv = pkgs.stdenvNoCC;
    installPhase = "cp -r _site $out";
  };

  cliffy = pkgs.denoPlatform.mkDenoPackage {
    name = "cliffy-runtime";
    src = ./examples/cliffy;

    permissions.allow.net = "localhost:8080";
  };

  webview = pkgs.denoPlatform.mkDenoBinary {
    name = "webview";
    src = ./examples/webview;

    permissions.allow = {
      env = ["PLUGIN_URL" "DENO_DIR" "HOME"];
      ffi = true;
      net = ["127.0.0.1:8000"];
      read = true;
      write = true;
    };
    unstable = true;
    include = ["worker.tsx"];

    nativeBuildInputs = [pkgs.makeWrapper];
    postInstall = let
      hash =
        {
          "aarch64-darwin" = {
            url = "https://github.com/webview/webview_deno/releases/download/0.7.4/libwebview.aarch64.dylib";
            sha256 = "06zr23pfzz71q01dvzks23n6maj6g82irj7scp3arydfi0lk0ys6";
          };
          "x86_64-darwin" = {
            url = "https://github.com/webview/webview_deno/releases/download/0.7.4/libwebview.x86_64.dylib";
            sha256 = "1r321sd3h12qx1ql5bgbn8bnpvsmfd0dzvv6g23w95zalqz5jifk";
          };
          "x86_64-linux" = {
            url = "https://github.com/webview/webview_deno/releases/download/0.7.4/libwebview.so";
            sha256 = "0gmcb4ky2bhk3inh45wdgxab0l95xgd3h4zgqcw4iccxq638mca3";
          };
        }
        .${pkgs.stdenv.hostPlatform.system};
      ffiLib = pkgs.fetchurl {inherit (hash) url sha256;};
    in ''
      mkdir -p $out/lib
      cp ${ffiLib} $out/lib/${baseNameOf ffiLib.url}
      wrapProgram $out/bin/webview --set PLUGIN_URL "$out/lib/"
    '';
  };
}
