{
  lib,
  linkFarm,
  writeText,
  fetchurl,
  runCommand,
}: lockfile: let
  denoLock = lib.importJSON lockfile;

  # -> https://deno.land/std@0.118.0/fmt/colors.ts
  # <- ["https" "deno.land" "/std@0.118.0/fmt/colors.ts"]
  urlPart = url: builtins.elemAt (lib.flatten (builtins.split "://([a-z0-9\.]*)" url));

  # -> https://deno.land/std@0.118.0/fmt/colors.ts
  # <- https/deno.land/{{ sha256sum "/std@0.118.0/fmt/colors.ts" }}
  remoteArtifactPath = url: let up = urlPart url; in "${up 0}/${up 1}/${builtins.hashString "sha256" (up 2)}";

  # handle all remote ESM-style dependencies
  remoteDeps = lib.attrsets.mergeAttrsList (
    lib.mapAttrsToList
    (
      url: sha256: {
        "deps/${remoteArtifactPath url}" = builtins.fetchurl {
          inherit url sha256;
          name = lib.strings.sanitizeDerivationName (builtins.baseNameOf url);
        };
        "deps/${remoteArtifactPath url}.metadata.json" = writeText "metadata.json" (builtins.toJSON {
          inherit url;
          headers = {};
        });
      }
    )
    denoLock.remote or {}
  );

  # handle NPM dependencies
  npmDeps = lib.attrsets.mergeAttrsList (
    lib.mapAttrsToList (
      specifier: data: let
        inherit (builtins) head match elemAt;
        scopeNameVersion = match "(^@?[[:alnum:]/._-]+)@([[:digit:].]+).*" specifier;
        scopeName = head scopeNameVersion;
        name = builtins.baseNameOf scopeName;
        version = elemAt scopeNameVersion 1;
        tarballUrl = "https://registry.npmjs.org/${scopeName}/-/${name}-${version}.tgz";
        tarball = fetchurl {
          name = lib.strings.sanitizeDerivationName (builtins.baseNameOf tarballUrl);
          url = tarballUrl;
          hash = data.integrity;
        };
        unpacked = runCommand (lib.strings.sanitizeDerivationName "deno-npm-${scopeName}-${version}") {} ''
          mkdir -p $out
          tar -xzf ${tarball} -C $out --strip-components=1
        '';
        packageJson = lib.importJSON "${unpacked}/package.json";
      in {
        "npm/registry.npmjs.org/${scopeName}/${version}" = unpacked;
        "npm/registry.npmjs.org/${scopeName}/registry.json" = writeText "registry.json" (builtins.toJSON {
          dist-tags.latest = version;
          name = scopeName;
          versions = {
            ${version} = {
              dependencies = packageJson.dependencies or {};
              optionalDependencies = packageJson.optionalDependencies or {};
              peerDependencies = packageJson.peerDependencies or {};
              peerDependenciesMeta = packageJson.peerDependenciesMeta or {};
              bin = null;
              os = packageJson.os or [];
              cpu = packageJson.cpu or [];
              dist = {
                integrity = data.integrity;
                shasum = builtins.hashFile "sha1" tarball;
                tarball = tarballUrl;
              };
              inherit version;
            };
          };
        });
      }
    ) (denoLock.packages.npm or {})
  );
in
  linkFarm "deno_prefetch" (npmDeps // remoteDeps)
