{ inputs, pkgs, ... }:
let
  noctalia = inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default;
in
{
  home.file.".mozilla/native-messaging-hosts/pywalfox.json".text = builtins.toJSON {
    allowed_extensions = [ "pywalfox@frewacom.org" ];
    description = "Noctalia firefox theme native messaging host";
    name = "pywalfox";
    path = "${noctalia}/bin/.noctalia-wrapped";
    type = "stdio";
  };
}
