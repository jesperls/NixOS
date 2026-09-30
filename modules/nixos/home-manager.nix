{
  inputs,
  lib,
  pkgs,
  ...
}:

let
  rotatingBackup = pkgs.writeShellApplication {
    name = "hm-rotating-backup";
    runtimeInputs = [ pkgs.coreutils ];
    text = ''
      target="''${1:?target path required}"
      keep=3 # Home Manager's default backup overwrites the previous generation.

      rm -f -- "$target.hm-backup.$keep"
      i=$((keep - 1))
      while [ "$i" -ge 1 ]; do
        src="$target.hm-backup.$i"
        dst="$target.hm-backup.$((i + 1))"
        if [ -e "$src" ] || [ -L "$src" ]; then
          mv -f -- "$src" "$dst"
        fi
        i=$((i - 1))
      done

      mv -f -- "$target" "$target.hm-backup.1"
    '';
  };
in
{
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    backupCommand = lib.getExe rotatingBackup;
    extraSpecialArgs = { inherit inputs; };
  };
}
