final: prev: {
  denoPlatform = {
    mkDenoDerivation = final.callPackage ./mkDenoDerivation.nix {};
    mkDenoDir = final.callPackage ./mkDenoDir.nix {};
    resolveImportMap = final.callPackage ./resolveImportMap.nix {};
    hooks = final.callPackage ./hooks {};
  };
}
