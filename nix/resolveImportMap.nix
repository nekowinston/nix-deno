{lib, ...}: {
  src,
  config,
  importMap,
}: let
  denoConfig = src + "/${config}";
in
  if denoConfig.hasKey "importMap"
  then lib.importJSON denoConfig.importMap
  else {
    imports = denoConfig.imports or {};
    scopes = denoConfig.scopes or {};
  }
