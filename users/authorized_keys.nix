{ lib, ... }:
let
  usersDir = ./.;

  # users/<user>/keys/*.pub
  keyFilesFor =
    user:
    let
      dir = usersDir + "/${user}/keys";
    in
    lib.mapAttrsToList (f: _: dir + "/${f}") (
      lib.filterAttrs (f: t: t == "regular" && lib.hasSuffix ".pub" f) (builtins.readDir dir)
    );

  isUserDir = name: type: type == "directory" && builtins.pathExists (usersDir + "/${name}/keys");
in
{
  users.users = lib.mapAttrs (user: _: { openssh.authorizedKeys.keyFiles = keyFilesFor user; }) (
    lib.filterAttrs isUserDir (builtins.readDir usersDir)
  );
}
