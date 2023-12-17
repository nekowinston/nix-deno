{pkgs ? import <nixpkgs> {overlays = [(import ./nix)];}}: let
  buildPhase = ''
    mkdir -p $out
    deno run -A ./main.ts > $out/output.txt
  '';
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

  cliffy = pkgs.denoPlatform.mkDenoBinary {
    name = "cliffy";
    src = ./examples/cliffy;

    allow = ["all"];

    entryPoint = "main.ts";
  };
}
