{
  pkgs ?
    import <nixpkgs> {
      overlays = [
        (self: super: {
          denoPlatform = self.callPackage ./nix {};
        })
      ];
    },
}: let
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

  # deno.json `imports` importMap
  remote-imports = pkgs.denoPlatform.mkDenoDerivation {
    name = "remote-imports";

    src = ./examples/remote-imports;

    inherit buildPhase;
  };

  # with npm dependencies
  npm-simple = pkgs.denoPlatform.mkDenoDerivation {
    name = "npm-simple";

    src = ./examples/npm-simple;
    lockFile = ./examples/npm-simple/deno.lock;

    inherit buildPhase;
  };
}
