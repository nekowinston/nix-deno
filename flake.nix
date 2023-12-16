{
  outputs = {nixpkgs, ...}: let
    systems = ["aarch64-darwin" "aarch64-linux" "x86_64-darwin" "x86_64-linux"];
    eachSystem = fn: nixpkgs.lib.genAttrs systems (system: fn nixpkgs.legacyPackages.${system});
  in {
    devShells = eachSystem (pkgs: {
      default = pkgs.mkShell {
        buildInputs = [pkgs.deno pkgs.nil pkgs.alejandra];
      };
    });
    overlays = eachSystem (pkgs: {
      default = import ./nix {};
    });
  };
}
