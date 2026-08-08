{
  lib,
  buildEnv,
  stdenvNoCC,
  writeShellApplication,

  quickshell,

  kdePackages,
  qt6,

  bash,
  brightnessctl,
  cava,
  coreutils,
  curl,
  dbus,
  ddcutil,
  ffmpeg,
  gawk,
  glib,
  gnugrep,
  gnused,
  gpu-screen-recorder,
  grim,
  imagemagick,
  inetutils,
  jq,
  kitty,
  libnotify,
  libqalculate,
  linux-wallpaperengine,
  matugen,
  mpvpaper,
  networkmanagerapplet,
  power-profiles-daemon,
  procps,
  python3,
  slurp,
  socat,
  sqlite,
  swappy,
  systemd,
  tesseract,
  tmux,
  util-linux,
  wl-clipboard,
  wlsunset,
  wtype,
  xdg-user-dirs,
  xdg-utils,
  zbar,
  zenity,

  version ? "1.1.5",
  ocrLanguages ? [
    "eng"
    "spa"
    "lat"
    "jpn"
    "chi_sim"
    "chi_tra"
    "kor"
  ],
}:

let
  src = stdenvNoCC.mkDerivation {
    name = "pangu-shell";
    src = lib.cleanSourceWith {
      src = ../../share/shell;
      filter =
        name: type:
        lib.cleanSourceFilter name type && baseNameOf name != "__pycache__" && !lib.hasSuffix ".pyc" name;
    };

    nativeBuildInputs = [
      bash
      python3
      qt6.qtdeclarative # qmllint
    ];

    dontConfigure = true;
    dontBuild = true;
    dontWrapQtApps = true; # qtdeclarative is here for qmllint only

    doCheck = true;
    checkPhase = ''
      runHook preCheck

      command -v qmllint >/dev/null || { echo "qmllint not on PATH" >&2; exit 1; }

      find . -name '*.qml' -exec qmllint {} + >qmllint.log 2>&1 || true
      if grep -F '[syntax]' qmllint.log; then
        echo "pangu: QML syntax errors above" >&2
        exit 1
      fi
      rm -f qmllint.log

      while read -r shader; do
        [ -f "$shader.qsb" ] || { echo "pangu: $shader has no baked .qsb — run pkgs/pangu/rebake-shaders.sh" >&2; missing_shader=1; }
      done < <(find . \( -name '*.frag' -o -name '*.vert' \))
      if [ -n "$missing_shader" ]; then
        exit 1
      fi

      runHook postCheck
    '';

    installPhase = ''
      runHook preInstall
      mkdir -p "$out"
      cp -r . "$out"
      chmod -R u+w "$out"
      chmod +x "$out"/scripts/*
      patchShebangs "$out/scripts"
      runHook postInstall
    '';
  };

  qmlEnv = buildEnv {
    name = "pangu-qml";
    paths = [
      kdePackages.qtmultimedia
      kdePackages.syntax-highlighting
      qt6.qtdeclarative
      qt6.qtimageformats
      qt6.qtsvg
    ];
    pathsToLink = [
      "/lib/qt-6/qml"
      "/lib/qt-6/plugins"
    ];
  };
in
writeShellApplication {
  name = "pangu";

  runtimeInputs = [
    quickshell

    bash # the shell spawns `bash -c` constantly and gets a bare systemd PATH
    brightnessctl
    cava
    coreutils
    curl
    dbus # dbus-monitor, used by the loginlock/sleep watchers
    ddcutil
    ffmpeg
    gawk
    glib # gsettings
    gnugrep
    gnused
    (gpu-screen-recorder.override { wrapperDir = "/run/wrappers/bin"; }) # execs the setcap gsr-kms-server for promptless capture
    grim
    imagemagick
    inetutils # hostname
    jq
    kitty # the dashboard's tmux tab opens sessions in it
    libnotify
    libqalculate
    linux-wallpaperengine
    matugen
    mpvpaper
    networkmanagerapplet # nm-connection-editor for the wifi panel
    power-profiles-daemon
    procps # pgrep/pkill
    python3
    slurp
    socat # mpv IPC sockets for animated wallpapers
    sqlite
    swappy
    systemd # systemctl, loginctl
    (tesseract.override { enableLanguages = ocrLanguages; })
    tmux # the dashboard's tmux tab drives real sessions
    util-linux # setsid, used to detach the wallpaper-engine renderer
    wl-clipboard
    wlsunset
    wtype
    xdg-user-dirs
    xdg-utils
    zbar
    zenity
  ];

  text = ''
    shellRoot=${src}
    version=${version}
    export PANGU_VERSION="$version"

    export QML2_IMPORT_PATH="${qmlEnv}/lib/qt-6/qml''${QML2_IMPORT_PATH:+:$QML2_IMPORT_PATH}"
    export QML_IMPORT_PATH="$QML2_IMPORT_PATH"
    export QT_PLUGIN_PATH="${qmlEnv}/lib/qt-6/plugins''${QT_PLUGIN_PATH:+:$QT_PLUGIN_PATH}"

    if [ -d /run/wrappers/bin ]; then
      # Wrappers first so the setuid gpu-screen-recorder wins over our
      # unprivileged copy.
      export PATH="/run/wrappers/bin:$PATH"
    fi
  ''
  + builtins.readFile ./cli.sh;

  meta = {
    description = "Pangu — the desktop shell for this configuration";
    license = lib.licenses.agpl3Only;
    mainProgram = "pangu";
    platforms = lib.platforms.linux;
  };
}
