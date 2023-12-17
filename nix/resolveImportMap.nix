{lib}: {
  src,
  configFile,
}: let
  inherit (builtins) head filter pathExists;
  denoConfig = head (filter (f: pathExists /. + "${f}") [configFile "${src}/deno.jsonc"]);
in
  if denoConfig.hasKey "importMap"
  then lib.importJSON denoConfig.importMap
  else {
    imports = denoConfig.imports or {};
    scopes = denoConfig.scopes or {};
  }
