{pkgs, ...}: rec {
  mkDenoDir = pkgs.callPackage ./mkDenoDir.nix {};
  resolveImportMap = pkgs.callPackage ./resolveImportMap.nix {};
  mkDenoDerivation = pkgs.callPackage ./mkDenoDerivation.nix {inherit mkDenoDir resolveImportMap;};
}
