{ lib, loaders }:

{ pname, envs }:

lib.mapAttrs' (
  envName: cfg:
  lib.nameValuePair "${pname}-${envName}" (
    loaders.${cfg.loader} (removeAttrs cfg [ "loader" ] // { inherit pname; })
  )
) envs
