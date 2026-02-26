{
  config,
  lib,
  pkgs,
  ...
}:

let

  lutrisWithDeps = pkgs.lutris.override {
    extraLibraries =
      pkgs: with pkgs; [
        # Audio / media
        libpulseaudio
        pipewire
        openal
        libvorbis
        libogg
        libxkbcommon
        wayland

        # SDL stack (needed by many launchers/installers)
        SDL2
        SDL2_image
        SDL2_mixer
        SDL2_ttf

        # Video / rendering and input helpers
        v4l-utils
        libgudev
        libpng
        libjpeg
        libGL
        libglvnd
        libxcursor
        libxi
        libxinerama
        libxscrnsaver
        libxext
        libxrandr
        libxxf86vm
        libxtst

        # Crypto / TLS and system glue
        openssl
        gnutls
        libgcrypt
        lcms2
        zlib

        # Battle.net / Blizzard launcher dependencies
        freetype
        glib
        openldap
        sqlite
        libgpg-error
        libxml2
        dbus
        cups
        fontconfig
        libunwind
        libopus
        libva

        gst_all_1.gstreamer
        gst_all_1.gst-plugins-base
        gst_all_1.gst-plugins-good
        gst_all_1.gst-plugins-bad
        gst_all_1.gst-plugins-ugly
        gst_all_1.gst-libav
      ];

    extraPkgs =
      pkgs: with pkgs; [
        winetricks
        gamescope
        mangohud
        gamemode
        dxvk
        vkd3d
        cabextract
        unzip
        p7zip
        vulkan-tools
        protontricks
      ];
  };
in
{
  environment.systemPackages = [
    lutrisWithDeps
  ];

  # Prevent Wine/DXVK GPU hangs on NVIDIA that can freeze the system
  environment.sessionVariables = {
    # Disable NVIDIA threaded optimizations for Wine (common cause of hangs)
    __GL_THREADED_OPTIMIZATIONS = "0";
    # Wine large address aware — helps with Battle.net memory usage
    WINE_LARGE_ADDRESS_AWARE = "1";
  };
}
