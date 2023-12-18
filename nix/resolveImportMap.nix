{lib}: {
  src,
  configFile ? "deno.json",
}: let
  inherit (builtins) head filter pathExists;
  denoConfig = head (filter (f: pathExists (src + "${f}")) [configFile "deno.jsonc"]);
in
  if denoConfig.hasKey "importMap"
  then lib.importJSON denoConfig.importMap
  else {
    imports = denoConfig.imports or {};
    scopes = denoConfig.scopes or {};
  }
