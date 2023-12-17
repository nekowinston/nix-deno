{
  description = "nix denoPlatform overlay";

  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

  outputs = {
    self,
    nixpkgs,
  }: let
    systems = ["aarch64-darwin" "aarch64-linux" "x86_64-darwin" "x86_64-linux"];
    eachSystem = fn: nixpkgs.lib.genAttrs systems (system: fn nixpkgs.legacyPackages.${system});
  in {
    devShells = eachSystem (pkgs: {
      default = pkgs.mkShell {
        buildInputs = with pkgs; [alejandra deno nil shellcheck shfmt];
      };
    });

    overlays.default = import ./nix;

    checks = eachSystem (pkgs: (import ./ci.nix {
      pkgs = pkgs.extend self.overlays.default;
    }));
  };
}
