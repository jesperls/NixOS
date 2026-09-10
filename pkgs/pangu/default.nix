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
  ddcutil,
  ffmpeg,
  findutils,
  gawk,
  glib,
  gtk3,
  gnugrep,
  gnused,
  gpu-screen-recorder,
  grim,
  hypridle,
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
  nodejs,
  power-profiles-daemon,
  procps,
  python3,
  slurp,
  socat,
  swappy,
  systemd,
  tesseract,
  tmux,
  wl-clipboard,
  wlsunset,
  wtype,
  xvfb-run,
  xdg-terminal-exec,
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
      nodejs
      quickshell
      gtk3
      xvfb-run
      jq
      qt6.qtdeclarative # qmllint
    ];

    dontConfigure = true;
    dontBuild = true;
    dontWrapQtApps = true; # qtdeclarative is here for qmllint only

    doCheck = true;
    checkPhase = ''
      runHook preCheck

      node tests/test_services.js
      PYTHONDONTWRITEBYTECODE=1 python3 -m unittest discover -s tests -v
      python3 -m compileall -q scripts
      find scripts -type d -name __pycache__ -exec rm -rf {} +
      while IFS= read -r -d $'\0' script; do
        bash -n "$script"
      done < <(find . -name '*.sh' -print0)

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
      rm -rf "$out/tests"
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
    ddcutil
    ffmpeg
    findutils
    gawk
    glib # gsettings
    gtk3 # gtk-launch
    gnugrep
    gnused
    (gpu-screen-recorder.override { wrapperDir = "/run/wrappers/bin"; }) # execs the setcap gsr-kms-server for promptless capture
    grim
    hypridle
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
    swappy
    systemd # systemctl, loginctl
    (tesseract.override { enableLanguages = ocrLanguages; })
    tmux # the dashboard's tmux tab drives real sessions
    wl-clipboard
    wlsunset
    wtype
    xdg-terminal-exec
    xdg-user-dirs
    xdg-utils
    zbar
    zenity
  ];

  text = ''
    shellRoot=${src}
    version=${version}
    export PANGU_VERSION="$version"

    # Tools the shell shells out to re-invoke `pangu` (hypridle lock_cmd,
    # `pangu run ...`); keep the wrapper's own bin on PATH.
    pangu_bin="$(dirname -- "$(readlink -f -- "$0")")"
    export PATH="$pangu_bin''${PATH:+:$PATH}"

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
