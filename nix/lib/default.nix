{lib}: rec {
  # -> generatePermissionFlagsList { env = true; read = ["$HOME" "/usr"]; }
  # <- ["--allow-env" "--allow-read=$HOME,/usr"]
  generatePermissionFlagsList = {
    kind,
    env ? false,
    sys ? false,
    hrtime ? false,
    net ? false,
    ffi ? false,
    read ? false,
    run ? false,
    write ? false,
    all ? false,
  } @ args:
    builtins.attrValues (lib.mapAttrs (
      name: val: let
        rhs =
          if builtins.isBool val
          then ""
          else if (builtins.isList val || builtins.isString val)
          then "=" + (builtins.concatStringsSep "," (lib.flatten [val]))
          else throw "Valid types for `permission` flags are booleans, lists of strings, or a string";
      in "--${kind}-${name}${rhs}"
    ) (builtins.removeAttrs args ["kind"]));

  # -> fromPermissionsAttrs { allow.env = true; deny.net = true; }
  # <- ["--allow-env --deny-net"]
  fromPermissionsAttrs = permissions: let
    allow = generatePermissionFlagsList ({kind = "allow";} // (permissions.allow or {}));
    deny = generatePermissionFlagsList ({kind = "deny";} // (permissions.deny or {}));
  in
    allow ++ deny;

  generateFlags = {
    entryPoint,
    permissions ? {},
    unstable ? false,
    additionalDenoArgs ? [],
    scriptArgs ? [],
  }:
    builtins.concatStringsSep " " (lib.flatten [
      (
        if unstable
        then "--unstable"
        else ""
      )
      (fromPermissionsAttrs permissions)
      additionalDenoArgs
      entryPoint
      scriptArgs
    ]);
}
