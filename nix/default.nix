final: prev: {
  denoPlatform = {
    mkDenoBinary = final.callPackage ./mkDenoBinary.nix {};
    mkDenoDerivation = final.callPackage ./mkDenoDerivation.nix {};
    mkDenoDir = final.callPackage ./mkDenoDir.nix {};
    mkDenoPackage = final.callPackage ./mkDenoPackage.nix {};

    hooks = final.callPackage ./hooks {};
    lib = final.callPackage ./lib {};
    resolveImportMap = final.callPackage ./resolveImportMap.nix {};
  };
}
