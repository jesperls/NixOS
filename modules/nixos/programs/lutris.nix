{ config, lib, pkgs, ... }:

with lib;

let
	cfg = config.mySystem.programs.lutris;

	lutrisWithDeps = pkgs.lutris.override {
		extraLibraries = pkgs: with pkgs; [
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
			xorg.libXcursor
			xorg.libXi
			xorg.libXinerama
			xorg.libXScrnSaver
			xorg.libXext
			xorg.libXrandr
			xorg.libXxf86vm
			xorg.libXtst

			# Crypto / TLS and system glue
			openssl
			gnutls
			libgcrypt
			lcms2
			zlib
			libunwind
			libxml2
			libopus
			libva

			# GStreamer (video/audio decoding for some installers)
			gst_all_1.gstreamer
			gst_all_1.gst-plugins-base
			gst_all_1.gst-plugins-good
			gst_all_1.gst-plugins-bad
			gst_all_1.gst-plugins-ugly
			gst_all_1.gst-libav
		];

		extraPkgs = pkgs: with pkgs; [
			wineWowPackages.staging
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
in {
	options.mySystem.programs.lutris = {
		enable = mkEnableOption "Lutris with common gaming dependencies";
	};

	config = mkIf cfg.enable {
		hardware.graphics = {
			enable = mkDefault true;
			enable32Bit = mkDefault true;
		};

		environment.systemPackages = with pkgs; [
			lutrisWithDeps
			adwaita-icon-theme
		];
	};
}
