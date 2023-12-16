{
  lib,
  linkFarm,
  writeText,
  fetchurl,
  runCommand,
  deno,
  sqlite,
  ...
}: let
  sqliteShim = runCommand "node_analysis_cache_v1" {buildInputs = [deno sqlite];} ''
    # create a sqlite database with the following tables:
    # - cjsanalysiscache
    #   - specifier
    #   - source_hash
    #   - data
    # - info
    #   - key
    #   - value

    # create the cjsanalysiscache table
    sqlite3 node_analysis_cache_v1 "CREATE TABLE cjsanalysiscache ( specifier TEXT PRIMARY KEY, source_hash TEXT NOT NULL, data TEXT NOT NULL)";
    sqlite3 node_analysis_cache_v1 "CREATE TABLE info ( key TEXT PRIMARY KEY, value TEXT NOT NULL)"

    # fill the info k/v table with
    # CLI_VERSION: $(deno --version)
    sqlite3 node_analysis_cache_v1 "INSERT INTO info (key, value) VALUES ('CLI_VERSION', '$(deno -V | cut -d ' ' -f2)')"

    cp node_analysis_cache_v1 $out
  '';
in
  lockfile: (
    linkFarm "deno_cache"
    {
      deps = linkFarm "deps" (lib.flatten (
        lib.mapAttrsToList
        (
          url: sha256: let
            # -> https://deno.land/std@0.118.0/fmt/colors.ts
            # <- ["https" "deno.land" "/std@0.118.0/fmt/colors.ts"]
            urlPart = url: builtins.elemAt (lib.flatten (builtins.split "://([a-z0-9\.]*)" url));

            # -> https://deno.land/std@0.118.0/fmt/colors.ts
            # <- https/deno.land/{{ sha256sum "/std@0.118.0/fmt/colors.ts" }}
            remoteArtifactPath = url: let
              up = urlPart url;
            in "${up 0}/${up 1}/${builtins.hashString "sha256" (up 2)}";
          in [
            {
              name = remoteArtifactPath url;
              path = builtins.fetchurl {
                inherit url sha256;
                name = lib.strings.sanitizeDerivationName (builtins.baseNameOf url);
              };
            }
            {
              name = remoteArtifactPath url + ".metadata.json";
              path = writeText "metadata.json" (builtins.toJSON {
                inherit url;
                headers = {};
              });
            }
          ]
        )
        (lib.importJSON lockfile).remote or {}
      ));
      "node_analysis_cache_v1" = sqliteShim;
      "dep_analysis_cache_v1" = sqliteShim;
      # TODO: this still doesn't create the correct registry.json
      "npm/registry.npmjs.org" = linkFarm "npm" (lib.flatten (
        lib.mapAttrsToList (
          specifier: data: let
            inherit (builtins) head match elemAt;
            scopeNameVersion = match "(^@?[[:alnum:]/._-]+)@([[:digit:].]+).*" specifier;
            scopeName = head scopeNameVersion;
            name = lib.last (builtins.split "/" scopeName);
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
            packageJson = builtins.trace tarball lib.importJSON "${unpacked}/package.json";
          in [
            {
              name = "${scopeName}/${version}";
              path = unpacked;
            }
            {
              name = "${scopeName}/registry.json";
              path = writeText "registry.json" (builtins.toJSON {
                dist-tags.latest = version;
                name = scopeName;
                versions = {
                  ${version} = {
                    dependencies = {};
                    optionalDependencies = {};
                    peerDependencies = {};
                    peerDependenciesMeta = {};
                    bin = null;
                    os = [];
                    cpu = [];
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
          ]
        )
        (lib.importJSON lockfile).packages.npm or {}
      ));
    }
  )
