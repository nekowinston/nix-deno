{pkgs ? import <nixpkgs> {overlays = [(import ./nix)];}}: let
  buildPhase = ''
    mkdir -p $out
    deno run -A ./main.ts > $out/output.txt
  '';
  nvfetcher = pkgs.callPackage ./_sources/generated.nix {};
  esbuild = nvfetcher."esbuild-${pkgs.hostPlatform.system}";
in {
  # simple imports, following the `deps.ts` convention
  remote-simple = pkgs.denoPlatform.mkDenoDerivation {
    name = "remote-simple";

    src = ./examples/remote;

    inherit buildPhase;
  };

  # with npm dependencies
  npm-simple = pkgs.denoPlatform.mkDenoDerivation {
    name = "npm-simple";

    src = ./examples/npm-simple;

    inherit buildPhase;
  };

  # with npm dependencies + custom registry
  npm-simple-custom-npm-registry = pkgs.denoPlatform.mkDenoDerivation {
    name = "npm-simple-custom-npm-registry";

    src = ./examples/npm-simple;

    npmRegistryUrl = "http://localhost:4873";

    inherit buildPhase;
  };

  # with esm.sh dependencies
  esm-simple = pkgs.denoPlatform.mkDenoDerivation {
    name = "esm-simple";

    src = ./examples/esm-simple;

    inherit buildPhase;
  };

  # Fresh project heavily utilizing esm.sh dependencies
  fresh = pkgs.denoPlatform.mkDenoDerivation {
    name = "fresh";

    src = ./examples/fresh;

    buildPhase = ''
      deno task build
    '';

    env.ESBUILD_BINARY_PATH = "${esbuild.src}/bin/esbuild";

    installPhase = ''
      cp -r _fresh $out
    '';
  };

  # Lume project with mixed dependencies
  lume = pkgs.denoPlatform.mkDenoDerivation {
    name = "lume";
    stdenv = pkgs.stdenvNoCC;

    src = ./examples/lume;

    buildPhase = ''
      deno task build
    '';

    installPhase = ''
      mkdir -p $out
      cp -r _site/* $out
    '';
  };

  cliffy-runtime = pkgs.denoPlatform.mkDenoPackage {
    name = "cliffy-runtime";
    src = ./examples/cliffy;

    permissions.allow.all = true;
  };

  cliffy-binary = pkgs.denoPlatform.mkDenoBinary {
    name = "cliffy";
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

    entryPoint = "main.ts";
  };
}
