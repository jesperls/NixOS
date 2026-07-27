{
  inputs,
  lib,
  options,
  pkgs,
  ...
}:

let
  keepDeployedKrisp =
    package:
    package.overrideAttrs (
      old:
      let
        inherit (old.passthru) moduleVersions;
        configDirName = lib.replaceStrings [ "-" ] [ "" ] old.pname;
      in
      {
        stageModules = pkgs.writeShellScript "discord-stage-modules" ''
          store_modules="$1"
          modules_dir="''${XDG_CONFIG_HOME:-$HOME/.config}/${configDirName}/${old.version}/modules"
          staged=" ${lib.concatStringsSep " " (lib.attrNames moduleVersions)} "
          mkdir -p "$modules_dir"

          for path in "$modules_dir"/discord_*; do
            [ -e "$path" ] || continue
            case "$staged" in
              *" $(basename "$path") "*) ;;
              *) chmod -R u+w "$path" 2>/dev/null || true; rm -rf "$path" ;;
            esac
          done

          for m in ${lib.concatStringsSep " " (lib.attrNames moduleVersions)}; do
            if [ "$m" = discord_krisp ] && [ -d "$modules_dir/$m" ] && [ ! -L "$modules_dir/$m" ]; then
              continue
            fi
            chmod -R u+w "$modules_dir/$m" 2>/dev/null || true
            rm -rf "$modules_dir/$m"
            ln -sn "$store_modules/$m" "$modules_dir/$m"
          done

          echo '${
            builtins.toJSON (lib.mapAttrs (_: version: { installedVersion = version; }) moduleVersions)
          }' > "$modules_dir/installed.json"
        '';
      }
    );
in
{
  imports = [ inputs.nixcord.homeModules.nixcord ];

  programs.nixcord = {
    enable = true;

    discord = {
      vencord.enable = true;
      openASAR.enable = true;
      krisp.enable = true;
      package = keepDeployedKrisp options.programs.nixcord.discord.package.default;
    };
    config = {
      plugins = {
        alwaysTrust.enable = true;
        betterGifPicker.enable = true;
        biggerStreamPreview.enable = true;
        clearUrls.enable = true;
        crashHandler.enable = true;
        fixYoutubeEmbeds.enable = true;
        gameActivityToggle.enable = true;
        imageZoom.enable = true;
        noTypingAnimation.enable = true;
        readAllNotificationsButton.enable = true;
        sendTimestamps.enable = true;
        volumeBooster.enable = true;
        youtubeAdblock.enable = true;
      };
    };
  };
}
