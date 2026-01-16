{ pkgs, inputs, config, ... }:

{
  imports = [ inputs.noctalia.homeModules.default ];

  programs.noctalia-shell = {
    enable = true;
    systemd.enable = true;
    settings = {
      settingsVersion = 40;

      appLauncher = {
        autoPasteClipboard = false;
        clipboardWrapText = true;
        enableClipPreview = true;
        enableClipboardHistory = false;
        iconMode = "tabler";
        ignoreMouseInput = false;
        pinnedApps = [];
        position = "bottom_center";
        showCategories = true;
        showIconBackground = false;
        sortByMostUsed = true;
        terminalCommand = "xterm -e";
        viewMode = "list";
      };

      audio = {
        cavaFrameRate = 30;
        mprisBlacklist = [];
        visualizerType = "linear";
        volumeOverdrive = false;
        volumeStep = 5;
      };

      bar = {
        backgroundOpacity = 0.93;
        capsuleOpacity = 1;
        density = "comfortable";
        exclusive = true;
        floating = false;
        hideOnOverview = false;
        marginHorizontal = 4;
        marginVertical = 4;
        monitors = [];
        outerCorners = true;
        position = "top";
        showCapsule = true;
        showOutline = false;
        useSeparateOpacity = false;
        widgets = {
          center = [];
          left = [
            { id = "Launcher"; icon = "rocket"; usePrimaryColor = false; }
            {
              id = "Clock";
              formatHorizontal = "HH:mm ddd, MMM dd";
              formatVertical = "HH mm - dd MM";
              tooltipFormat = "HH:mm ddd, MMM dd";
              usePrimaryColor = false;
            }
            {
              id = "SystemMonitor";
              compactMode = true;
              showCpuTemp = true;
              showCpuUsage = true;
              showDiskUsage = false;
              showGpuTemp = false;
              showLoadAverage = false;
              showMemoryAsPercent = false;
              showMemoryUsage = true;
              showNetworkStats = false;
              useMonospaceFont = true;
              usePrimaryColor = false;
            }
            {
              id = "ActiveWindow";
              colorizeIcons = false;
              hideMode = "hidden";
              maxWidth = 145;
              scrollingMode = "hover";
              showIcon = true;
              useFixedWidth = false;
            }
            {
              id = "MediaMini";
              compactMode = false;
              compactShowAlbumArt = true;
              compactShowVisualizer = false;
              hideMode = "hidden";
              hideWhenIdle = false;
              maxWidth = 145;
              panelShowAlbumArt = true;
              panelShowVisualizer = true;
              scrollingMode = "hover";
              showAlbumArt = true;
              showArtistFirst = true;
              showProgressRing = true;
              showVisualizer = false;
              useFixedWidth = false;
              visualizerType = "linear";
            }
          ];
          right = [
            {
              id = "Tray";
              blacklist = [];
              colorizeIcons = false;
              drawerEnabled = true;
              hidePassive = false;
              pinned = [];
            }
            {
              id = "ControlCenter";
              colorizeDistroLogo = false;
              colorizeSystemIcon = "none";
              enableColorization = false;
              icon = "noctalia";
              useDistroLogo = false;
            }
          ];
        };
      };

      brightness = {
        brightnessStep = 5;
        enableDdcSupport = false;
        enforceMinimum = true;
      };

      colorSchemes = {
        darkMode = true;
        manualSunrise = "06:30";
        manualSunset = "18:30";
        matugenSchemeType = "scheme-fruit-salad";
        predefinedScheme = "Tokyo Night";
        schedulingMode = "off";
        useWallpaperColors = false;
      };

      controlCenter = {
        diskPath = "/";
        position = "close_to_bar_button";
        cards = [
          { id = "profile-card"; enabled = true; }
          { id = "shortcuts-card"; enabled = true; }
          { id = "audio-card"; enabled = true; }
          { id = "brightness-card"; enabled = false; }
          { id = "weather-card"; enabled = true; }
          { id = "media-sysmon-card"; enabled = true; }
        ];
        shortcuts = {
          left = [
            { id = "Network"; }
            { id = "Bluetooth"; }
            { id = "WallpaperSelector"; }
          ];
          right = [
            { id = "Notifications"; }
            { id = "PowerProfile"; }
            { id = "KeepAwake"; }
            { id = "NightLight"; }
          ];
        };
      };

      desktopWidgets = {
        enabled = false;
        gridSnap = false;
      };

      dock = {
        animationSpeed = 1;
        backgroundOpacity = 1;
        colorizeIcons = false;
        deadOpacity = 0.6;
        displayMode = "auto_hide";
        enabled = true;
        floatingRatio = 1;
        inactiveIndicators = false;
        monitors = [];
        onlySameOutput = true;
        pinnedApps = [];
        pinnedStatic = false;
        position = "top";
        size = 1;
      };

      general = {
        allowPanelsOnScreenWithoutBar = true;
        animationDisabled = false;
        animationSpeed = 1;
        avatarImage = "${config.home.homeDirectory}/.face";
        boxRadiusRatio = 1;
        compactLockScreen = false;
        dimmerOpacity = 0;
        enableShadows = true;
        forceBlackScreenCorners = false;
        iRadiusRatio = 1;
        lockOnSuspend = true;
        radiusRatio = 1;
        scaleRatio = 1;
        screenRadiusRatio = 1;
        shadowDirection = "bottom_right";
        shadowOffsetX = 2;
        shadowOffsetY = 3;
        showChangelogOnStartup = true;
        showHibernateOnLockScreen = false;
        showScreenCorners = false;
        showSessionButtonsOnLockScreen = true;
        telemetryEnabled = false;
      };

      location = {
        analogClockInCalendar = false;
        firstDayOfWeek = -1;
        hideWeatherCityName = false;
        hideWeatherTimezone = false;
        name = "Tokyo";
        showCalendarEvents = true;
        showCalendarWeather = true;
        showWeekNumberInCalendar = false;
        use12hourFormat = false;
        useFahrenheit = false;
        weatherEnabled = false;
        weatherShowEffects = true;
      };

      nightLight = {
        autoSchedule = true;
        dayTemp = "6500";
        enabled = false;
        forced = false;
        manualSunrise = "06:30";
        manualSunset = "18:30";
        nightTemp = "4000";
      };

      notifications = {
        backgroundOpacity = 1;
        criticalUrgencyDuration = 15;
        enableKeyboardLayoutToast = true;
        enabled = true;
        location = "top_right";
        lowUrgencyDuration = 3;
        monitors = [];
        normalUrgencyDuration = 8;
        overlayLayer = true;
        respectExpireTimeout = false;
        saveToHistory = {
          critical = true;
          low = true;
          normal = true;
        };
        sounds = {
          enabled = false;
          excludedApps = "discord,firefox,chrome,chromium,edge";
          separateSounds = false;
          volume = 0.5;
        };
      };

      osd = {
        autoHideMs = 2000;
        backgroundOpacity = 1;
        enabled = true;
        enabledTypes = [ 0 1 2 null ];
        location = "top_right";
        monitors = [];
        overlayLayer = true;
      };

      sessionMenu = {
        countdownDuration = 10000;
        enableCountdown = true;
        largeButtonsLayout = "grid";
        largeButtonsStyle = false;
        position = "center";
        showHeader = true;
        showNumberLabels = true;
        powerOptions = [
          { action = "lock"; countdownEnabled = true; enabled = true; }
          { action = "suspend"; countdownEnabled = true; enabled = true; }
          { action = "hibernate"; countdownEnabled = true; enabled = true; }
          { action = "reboot"; countdownEnabled = true; enabled = true; }
          { action = "logout"; countdownEnabled = true; enabled = true; }
          { action = "shutdown"; countdownEnabled = true; enabled = true; }
        ];
      };

      templates = {
        activeTemplates = [];
        enableUserTemplates = false;
      };

      ui = {
        bluetoothDetailsViewMode = "grid";
        bluetoothHideUnnamedDevices = false;
        boxBorderEnabled = false;
        fontDefault = "Sans";
        fontDefaultScale = 1;
        fontFixed = "monospace";
        fontFixedScale = 1;
        networkPanelView = "wifi";
        panelBackgroundOpacity = 0.93;
        panelsAttachedToBar = true;
        settingsPanelMode = "attached";
        tooltipsEnabled = true;
        wifiDetailsViewMode = "grid";
      };

      wallpaper = {
        directory = "${config.home.homeDirectory}/Pictures/Wallpapers";
        enableMultiMonitorDirectories = false;
        enabled = true;
        fillColor = "#000000";
        fillMode = "crop";
        hideWallpaperFilenames = false;
        monitorDirectories = [];
        overviewEnabled = false;
        panelPosition = "follow_bar";
        randomEnabled = false;
        randomIntervalSec = 300;
        recursiveSearch = false;
        setWallpaperOnAllMonitors = true;
        solidColor = "#1a1a2e";
        transitionDuration = 1500;
        transitionEdgeSmoothness = 0.05;
        transitionType = "random";
        useSolidColor = false;
        useWallhaven = false;
        wallpaperChangeMode = "random";
      };
    };
  };
}
