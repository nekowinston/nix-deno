{
  lib,
  linkFarm,
  writeText,
  fetchurl,
  runCommand,
}: lockfile: let
  inherit (lib.strings) sanitizeDerivationName;
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
      url: sha256: let
        linkName = remoteArtifactPath url;
        name = let
          up = urlPart url;
        in
          sanitizeDerivationName (lib.concatStringsSep "-" [(up 1) (lib.strings.removePrefix "/" (up 2))]);
      in {
        "deps/${linkName}" = builtins.fetchurl {inherit url sha256 name;};
        "deps/${linkName}.metadata.json" = writeText "${name}.metadata.json" (builtins.toJSON {
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
        pkgNameAndVersion = match "(^@?[[:alnum:]/._-]+)@([[:digit:].]+).*" specifier;
        pkgName = head pkgNameAndVersion;
        version = elemAt pkgNameAndVersion 1;
        tarballUrl = "https://registry.npmjs.org/${pkgName}/-/${builtins.baseNameOf pkgName}-${version}.tgz";
        drvName = sanitizeDerivationName "deno-npm-${pkgName}-${version}";
        tarball = fetchurl {
          name = "${drvName}.tgz";
          url = tarballUrl;
          hash = data.integrity;
        };
        unpacked = runCommand drvName {} ''
          mkdir -p $out
          tar -xzf ${tarball} -C $out --strip-components=1
        '';
        packageJson = lib.importJSON "${unpacked}/package.json";
      in {
        "npm/registry.npmjs.org/${pkgName}/${version}" = unpacked;
        "npm/registry.npmjs.org/${pkgName}/registry.json" = writeText "registry.json" (builtins.toJSON {
          dist-tags.latest = version;
          name = pkgName;
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
