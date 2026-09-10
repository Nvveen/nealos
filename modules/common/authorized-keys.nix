# Scans users/<name>/keys/*.pub for every user directory and wires them up as
# authorized_keys. Lives here (not under users/) because it applies across all
# users, not to one. Imported once by modules/common so every host gets it.
{ lib, ... }:
let
  # Moved from users/authorized_keys.nix: was usersDir = ./.; there, since the
  # file lived inside users/. Now two levels up from modules/common.
  usersDir = ../../users;

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
