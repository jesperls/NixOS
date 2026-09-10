pragma Singleton
pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import Quickshell.Io
import qs.modules.services
import qs.config
import qs.modules.widgets.dashboard.wallpapers

Singleton {
    id: root

    readonly property var wallpaperManager: WallpaperService
    property string avatarCacheBuster: ""

    property bool hasAvatar: false

    Process {
        id: avatarProbe
        running: true
        command: ["test", "-f", Paths.avatar]
        onExited: exitCode => {
            root.hasAvatar = exitCode === 0;
        }
    }

    function pickUserAvatar() {
        filePickerProcess.running = true;
    }

    Process {
        id: filePickerProcess
        running: false
        command: ["zenity", "--file-selection", "--title=Select User Icon", "--file-filter=Images | *.png *.jpg *.jpeg *.svg *.webp"]

        stdout: StdioCollector {
            onStreamFinished: {
                const path = text.trim();
                if (path) {
                    console.log("Selected icon:", path);
                    copyIconProcess.command = ["cp", path, Paths.avatar];
                    copyIconProcess.running = true;
                }
            }
        }
    }

    Process {
        id: copyIconProcess
        running: false
        command: []

        onExited: exitCode => {
            if (exitCode === 0) {
                console.log("Icon updated successfully");
                root.hasAvatar = true;
                avatarCacheBuster = Date.now();
            } else {
                console.warn("Failed to update icon");
            }
        }
    }

    Component.onCompleted: void LockscreenService.ipc

    property string launcherSearchText: ""
    property int launcherSelectedIndex: -1
    property int launcherCurrentTab: 0

    function clearLauncherState() {
        launcherSearchText = "";
        launcherSelectedIndex = -1;
    }

    property int dashboardCurrentTab: 0
    
    property int widgetsTabCurrentIndex: 0

    property int wallpaperSelectedIndex: -1

    function getActiveLauncher() {
        let active = Visibilities.getForActive();
        return active ? active.launcher : false;
    }

    function getActiveDashboard() {
        let active = Visibilities.getForActive();
        return active ? active.dashboard : false;
    }

    function getActiveOverview() {
        let active = Visibilities.getForActive();
        return active ? active.overview : false;
    }

    readonly property bool overviewOpen: getActiveOverview()
    readonly property bool launcherOpen: getActiveLauncher()
    readonly property bool dashboardOpen: getActiveDashboard()

    property bool lockscreenVisible: false

    property bool osdVisible: false
    property string osdIndicator: "volume" // volume, mic, brightness

    property bool screenshotToolVisible: false
    property string screenshotCaptureMode: "region" // region, window, screen

    property bool screenRecordToolVisible: false
    property bool screenRecordReplayMode: false

    property bool mirrorWindowVisible: false

    property bool cheatsheetVisible: false

    property bool settingsWindowVisible: false
    property int settingsTargetWorkspaceId: 0
    property string settingsTargetScreenName: ""

    property bool themeHasChanges: false
    property var themeSnapshot: null

    function _getSrVariantNames() {
        var names = [];
        var keys = Object.keys(Config.theme);
        for (var i = 0; i < keys.length; i++) {
            if (keys[i].startsWith("sr")) {
                names.push(keys[i]);
            }
        }
        return names;
    }

    readonly property var _simpleThemeProps: [
        "roundness", "oledMode", "lightMode", "dynamicColors", "font", "fontSize", "monoFont", "monoFontSize",
        "tintIcons", "enableCorners", "animDuration",
        "shadowOpacity", "shadowColor", "shadowXOffset", "shadowYOffset", "shadowBlur"
    ]
    readonly property var _srVariantProps: [
        "gradientType", "gradientAngle", "gradientCenterX", "gradientCenterY",
        "halftoneDotMin", "halftoneDotMax", "halftoneStart", "halftoneEnd",
        "halftoneDotColor", "halftoneBackgroundColor", "itemColor", "opacity"
    ]

    // Deep-copies plain objects, QML lists and JS arrays. JSON.stringify can't
    // round-trip a QML list<...>, so those are walked element by element.
    function _cloneValue(value) {
        if (value === null || value === undefined)
            return value;
        if (Array.isArray(value))
            return value.map(_cloneValue);
        if (typeof value === 'object') {
            if (typeof value.slice === 'function') {
                const out = [];
                for (let i = 0; i < value.length; i++)
                    out.push(_cloneValue(value[i]));
                return out;
            }
            const out = {};
            for (const k in value) {
                if (k.endsWith("Changed") || k === "objectName")
                    continue;
                out[k] = _cloneValue(value[k]);
            }
            return out;
        }
        return value;
    }

    function _copySrVariant(src) {
        var copy = {};
        for (var i = 0; i < _srVariantProps.length; i++) {
            if (src[_srVariantProps[i]] !== undefined) {
                copy[_srVariantProps[i]] = src[_srVariantProps[i]];
            }
        }
        copy.gradient = (src.gradient !== undefined) ? _cloneValue(src.gradient) : [];
        copy.border = (src.border !== undefined) ? _cloneValue(src.border) : [];
        return copy;
    }

    function _restoreSrVariant(src, dest) {
        for (var i = 0; i < _srVariantProps.length; i++) {
            if (src[_srVariantProps[i]] !== undefined) {
                dest[_srVariantProps[i]] = src[_srVariantProps[i]];
            }
        }
        if (src.gradient !== undefined) {
            dest.gradient = _cloneValue(src.gradient);
        }
        if (src.border !== undefined) {
            dest.border = _cloneValue(src.border);
        }
    }

    function createThemeSnapshot() {
        var snapshot = {};
        var theme = Config.theme;
        var srVariantNames = _getSrVariantNames();

        for (var i = 0; i < _simpleThemeProps.length; i++) {
            var prop = _simpleThemeProps[i];
            snapshot[prop] = theme[prop];
        }

        for (var j = 0; j < srVariantNames.length; j++) {
            var name = srVariantNames[j];
            snapshot[name] = _copySrVariant(theme[name]);
        }

        return snapshot;
    }

    function restoreThemeSnapshot(snapshot) {
        if (!snapshot) return;

        var theme = Config.theme;
        var srVariantNames = _getSrVariantNames();

        for (var i = 0; i < _simpleThemeProps.length; i++) {
            var prop = _simpleThemeProps[i];
            theme[prop] = snapshot[prop];
        }

        for (var j = 0; j < srVariantNames.length; j++) {
            var name = srVariantNames[j];
            if (snapshot[name]) {
                _restoreSrVariant(snapshot[name], theme[name]);
            }
        }
    }

    function markThemeChanged() {
        if (!themeHasChanges) {
            themeSnapshot = createThemeSnapshot();
            Config.beginEdit("theme", ["theme"]);
        }
        themeHasChanges = true;
    }

    function applyThemeChanges() {
        if (themeHasChanges) {
            Config.save("theme");
            themeHasChanges = false;
            themeSnapshot = null;
            Config.endEdit("theme");
        }
    }

    function discardThemeChanges() {
        if (themeHasChanges && themeSnapshot) {
            restoreThemeSnapshot(themeSnapshot);
            themeHasChanges = false;
            themeSnapshot = null;
            Config.endEdit("theme");
        }
    }

    property bool shellHasChanges: false
    property var shellSnapshot: null

    readonly property var _shellSections: {
        const names = ["bar", "notch", "workspaces", "overview", "dashboard", "launcher", "dock", "lockscreen", "osd"];
        const sections = {};
        for (const name of names)
            sections[name] = Config.adapterKeys(name);
        return sections;
    }

    function createShellSnapshot() {
        var snapshot = {};
        var sections = Object.keys(_shellSections);
        for (var i = 0; i < sections.length; i++) {
            var section = sections[i];
            var props = _shellSections[section];
            snapshot[section] = {};
            for (var j = 0; j < props.length; j++) {
                var prop = props[j];
                snapshot[section][prop] = _cloneValue(Config[section][prop]);
            }
        }
        return snapshot;
    }

    function _restoreObject(src, dst) {
        for (const key in src) {
            const s = src[key];
            if (s === undefined)
                continue;
            if (Array.isArray(s)) {
                dst[key] = _cloneValue(s);
            } else if (s !== null && typeof s === 'object') {
                if (dst[key] === undefined) {
                    dst[key] = _cloneValue(s);
                } else {
                    _restoreObject(s, dst[key]);
                }
            } else {
                dst[key] = s;
            }
        }
    }

    function restoreShellSnapshot(snapshot) {
        if (!snapshot) return;
        var sections = Object.keys(_shellSections);
        for (var i = 0; i < sections.length; i++) {
            var section = sections[i];
            var props = _shellSections[section];
            for (var j = 0; j < props.length; j++) {
                var prop = props[j];
                var val = snapshot[section][prop];

                if (section === "system") {
                    var dst = Config.system[prop];
                    if (dst === undefined || val === undefined || val === null)
                        continue;
                    if (Array.isArray(val)) {
                        Config.system[prop] = _cloneValue(val);
                    } else if (typeof val === 'object') {
                        _restoreObject(val, dst);
                    } else {
                        Config.system[prop] = val;
                    }
                }
                else if (typeof val === 'object' && val !== null) {
                    Config[section][prop] = _cloneValue(val);
                } else {
                    Config[section][prop] = val;
                }
            }
        }
    }

    function markShellChanged() {
        if (!shellHasChanges) {
            shellSnapshot = createShellSnapshot();
            Config.beginEdit("shell", Object.keys(_shellSections));
        }
        shellHasChanges = true;
    }

    function applyShellChanges() {
        if (shellHasChanges) {
            for (const name of Object.keys(_shellSections))
                Config.save(name);

            shellHasChanges = false;
            shellSnapshot = null;
            Config.endEdit("shell");
        }
    }

    function discardShellChanges() {
        if (shellHasChanges && shellSnapshot) {
            restoreShellSnapshot(shellSnapshot);
            shellHasChanges = false;
            shellSnapshot = null;
            Config.endEdit("shell");
        }
    }

    property bool compositorHasChanges: false
    property var compositorSnapshot: null

    readonly property var _compositorProps: Config.adapterKeys("compositor")

    function createCompositorSnapshot() {
        var snapshot = {};
        for (var i = 0; i < _compositorProps.length; i++) {
            var prop = _compositorProps[i];
            var val = Config.compositor[prop];
            if (Array.isArray(val)) {
                snapshot[prop] = JSON.parse(JSON.stringify(val));
            } else {
                snapshot[prop] = val;
            }
        }
        return snapshot;
    }

    function restoreCompositorSnapshot(snapshot) {
        if (!snapshot) return;
        for (var i = 0; i < _compositorProps.length; i++) {
            var prop = _compositorProps[i];
            if (snapshot[prop] !== undefined) {
                var val = snapshot[prop];
                if (Array.isArray(val)) {
                    Config.compositor[prop] = JSON.parse(JSON.stringify(val));
                } else {
                    Config.compositor[prop] = val;
                }
            }
        }
    }

    function markCompositorChanged() {
        if (!compositorHasChanges) {
            compositorSnapshot = createCompositorSnapshot();
            Config.beginEdit("compositor", ["compositor"]);
        }
        compositorHasChanges = true;
    }

    function applyCompositorChanges() {
        if (compositorHasChanges) {
            Config.save("compositor");
            compositorHasChanges = false;
            compositorSnapshot = null;
            Config.endEdit("compositor");
        }
    }

    function discardCompositorChanges() {
        if (compositorHasChanges && compositorSnapshot) {
            restoreCompositorSnapshot(compositorSnapshot);
            compositorHasChanges = false;
            compositorSnapshot = null;
            Config.endEdit("compositor");
        }
    }

    function resetChangeTracking() {
        themeHasChanges = false;
        themeSnapshot = null;
        shellHasChanges = false;
        shellSnapshot = null;
        compositorHasChanges = false;
        compositorSnapshot = null;
        for (const group of ["theme", "shell", "compositor"]) Config.endEdit(group);
    }

    // Keep the dock and the notch from occupying the same edge.
    Connections {
        target: Config.notch
        function onPositionChanged() {
            if (!Config.initialLoadComplete)
                return;
            if (Config.notch.position === "bottom" && Config.dock.position === "bottom") {
                Config.dock.position = Config.bar.position === "left" ? "right" : "left";
                root.markShellChanged();
            } else if (Config.notch.position === "top" && (Config.dock.position === "left" || Config.dock.position === "right")) {
                Config.dock.position = "bottom";
                root.markShellChanged();
            }
        }
    }

}
