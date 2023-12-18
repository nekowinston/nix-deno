final: prev: {
  denoPlatform = {
    mkDenoBinary = final.callPackage ./mkDenoBinary.nix {};
    mkDenoDerivation = final.callPackage ./mkDenoDerivation.nix {};
    mkDenoDir = final.callPackage ./mkDenoDir.nix {};
    mkDenoPackage = final.callPackage ./mkDenoPackage.nix {};
    resolveImportMap = final.callPackage ./resolveImportMap.nix {};
    hooks = final.callPackage ./hooks {};
    lib = final.callPackage ./lib {};
  };
}
