{ pkgs, ... }:

let
  lutrisWithDeps = pkgs.lutris.override {
    extraLibraries =
      pkgs: with pkgs; [
        libpulseaudio
        pipewire
        openal
        libvorbis
        libogg
        libxkbcommon
        wayland
        SDL2
        SDL2_image
        SDL2_mixer
        SDL2_ttf
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
        openssl
        gnutls
        libgcrypt
        lcms2
        zlib
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

  # Scope Wine/NVIDIA env vars to Lutris only
  lutrisWrapped = pkgs.symlinkJoin {
    name = "lutris-wrapped";
    paths = [ lutrisWithDeps ];
    buildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      wrapProgram $out/bin/lutris \
        --set __GL_THREADED_OPTIMIZATIONS 0 \
        --set WINE_LARGE_ADDRESS_AWARE 1
    '';
  };
in
{
  environment.systemPackages = [ lutrisWrapped ];
}
