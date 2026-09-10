pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io
import qs.config
import qs.modules.globals
import qs.modules.theme

Singleton {
    id: root

    readonly property var builtinPresets: [
        {
            id: "pangu",
            name: "Pangu",
            description: "The stock layout: floating pill bar on top, centered notch.",
            icon: Icons.cube,
            lightMode: false,
            colorPreset: "",
            theme: {
                roundness: 16,
                enableCorners: true,
                font: "Inter",
                srBarBg: { gradient: [["surfaceDim", 0.0], ["surfaceContainerLow", 1.0]], opacity: 1.0, border: ["surfaceBright", 0] }
            },
            bar: { position: "top", height: 0, pillStyle: "default", clockPosition: "right", launcherPosition: "start", flatButtons: false, showWorkspaces: true, launcherIcon: Icons.cube, launcherIconTint: false, launcherIconSize: 24, use12hFormat: false },
            dock: { enabled: false, theme: "default", position: "bottom" },
            notch: { theme: "default", position: "top", keepHidden: false },
            overview: { enabled: true, layout: "standard", rows: 2, columns: 5 },
            lockscreen: { position: "bottom" },
            compositor: { gapsIn: 2, gapsOut: 4, borderSize: 2, syncRoundness: true }
        }
    ]

    ConfigFile {
        id: presetsFile
        name: "layouts"
        pathOverride: Paths.configPath("layouts.json")

        adapter: JsonAdapter {
            property var presets: []
        }
    }

    readonly property var userPresets: (presetsFile.adapter && presetsFile.adapter.presets) ? presetsFile.adapter.presets : []
    readonly property var presets: builtinPresets.concat(userPresets)

    function isBuiltin(id) {
        for (let i = 0; i < builtinPresets.length; i++) {
            if (builtinPresets[i].id === id)
                return true;
        }
        return false;
    }

    function getPreset(id) {
        return presets.find(p => p.id === id) || null;
    }

    function assign(src, dst) {
        if (!src || !dst)
            return;
        for (const key in src) {
            const s = src[key];
            if (s === undefined)
                continue;
            if (Array.isArray(s)) {
                dst[key] = JSON.parse(JSON.stringify(s));
            } else if (s !== null && typeof s === 'object') {
                if (dst[key] === undefined || dst[key] === null) {
                    dst[key] = JSON.parse(JSON.stringify(s));
                } else {
                    assign(s, dst[key]);
                }
            } else {
                dst[key] = s;
            }
        }
    }

    // Simple theme fields only; the sr* variants are captured separately.
    readonly property var _themeKeys: ["oledMode", "dynamicColors", "roundness", "font", "fontSize", "monoFont", "monoFontSize", "tintIcons", "enableCorners", "animDuration", "shadowOpacity", "shadowColor", "shadowXOffset", "shadowYOffset", "shadowBlur"]
    readonly property var _barKeys: Config.adapterKeys("bar")
    readonly property var _dockKeys: Config.adapterKeys("dock")
    readonly property var _notchKeys: Config.adapterKeys("notch")
    readonly property var _workspacesKeys: Config.adapterKeys("workspaces")
    readonly property var _overviewKeys: Config.adapterKeys("overview")
    readonly property var _dashboardKeys: Config.adapterKeys("dashboard")
    readonly property var _launcherKeys: Config.adapterKeys("launcher")
    readonly property var _lockscreenKeys: Config.adapterKeys("lockscreen")
    readonly property var _osdKeys: Config.adapterKeys("osd")
    readonly property var _compositorKeys: Config.adapterKeys("compositor")

    function deepCopy(value) {
        if (value === null || value === undefined)
            return value;
        if (Array.isArray(value))
            return value.map(deepCopy);
        if (typeof value === 'object') {
            // QML list<...> is indexable and supports slice() but is not a JS Array.
            if (typeof value.slice === 'function') {
                const out = [];
                for (let i = 0; i < value.length; i++)
                    out.push(deepCopy(value[i]));
                return out;
            }
            const out = {};
            for (const k in value) {
                if (k.endsWith("Changed") || k === "objectName")
                    continue;
                out[k] = deepCopy(value[k]);
            }
            return out;
        }
        return value;
    }

    function captureSection(adapter, keys) {
        const out = {};
        for (let i = 0; i < keys.length; i++) {
            const k = keys[i];
            if (adapter[k] !== undefined)
                out[k] = deepCopy(adapter[k]);
        }
        return out;
    }

    function captureTheme() {
        const out = captureSection(Config.theme, _themeKeys);
        const keys = Object.keys(Config.theme);
        for (let i = 0; i < keys.length; i++) {
            const k = keys[i];
            if (k.indexOf("sr") === 0)
                out[k] = deepCopy(Config.theme[k]);
        }
        return out;
    }

    function captureCurrent(name, description) {
        const manager = GlobalStates.wallpaperManager;
        return {
            id: slugify(name),
            name: name,
            description: description || "",
            icon: Icons.cube,
            lightMode: Config.theme.lightMode,
            colorPreset: manager ? (manager.activeColorPreset || "") : "",
            theme: captureTheme(),
            bar: captureSection(Config.bar, _barKeys),
            dock: captureSection(Config.dock, _dockKeys),
            notch: captureSection(Config.notch, _notchKeys),
            workspaces: captureSection(Config.workspaces, _workspacesKeys),
            overview: captureSection(Config.overview, _overviewKeys),
            dashboard: captureSection(Config.dashboard, _dashboardKeys),
            launcher: captureSection(Config.launcher, _launcherKeys),
            lockscreen: captureSection(Config.lockscreen, _lockscreenKeys),
            osd: captureSection(Config.osd, _osdKeys),
            compositor: captureSection(Config.compositor, _compositorKeys)
        };
    }

    function slugify(name) {
        const s = String(name || "").toLowerCase().replace(/[^a-z0-9]+/g, "-").replace(/^-+|-+$/g, "");
        return s || "layout";
    }

    function saveCurrent(name, description) {
        const cleaned = String(name || "").trim();
        if (!cleaned)
            return "";

        let id = slugify(cleaned);
        if (isBuiltin(id)) {
            let n = 2;
            while (isBuiltin(id + "-" + n) || userPresets.some(p => p.id === id + "-" + n))
                n++;
            id = id + "-" + n;
        }

        const preset = captureCurrent(cleaned, description);
        preset.id = id;

        let list = userPresets.filter(p => p.id !== id);
        list.push(preset);
        presetsFile.adapter.presets = list;
        presetsFile.writeAdapter();
        return id;
    }

    function deletePreset(id) {
        if (isBuiltin(id))
            return false;
        const list = userPresets.filter(p => p.id !== id);
        presetsFile.adapter.presets = list;
        presetsFile.writeAdapter();
        return true;
    }

    function apply(id) {
        const preset = getPreset(id);
        if (!preset) {
            console.warn("LayoutPresets: unknown preset", id);
            return;
        }

        Config.pauseAutoSave = true;

        try {
            assign(preset.bar, Config.bar);
            assign(preset.dock, Config.dock);
            assign(preset.notch, Config.notch);
            assign(preset.workspaces, Config.workspaces);
            assign(preset.overview, Config.overview);
            assign(preset.dashboard, Config.dashboard);
            assign(preset.launcher, Config.launcher);
            assign(preset.lockscreen, Config.lockscreen);
            assign(preset.osd, Config.osd);
            assign(preset.compositor, Config.compositor);

            if (preset.colorPreset !== undefined) {
                const manager = GlobalStates.wallpaperManager;
                if (manager)
                    manager.setColorPreset(preset.colorPreset);
            }

            assign(preset.theme, Config.theme);

            if (preset.lightMode !== undefined)
                Config.theme.lightMode = preset.lightMode;
        } finally {
            Config.pauseAutoSave = false;
        }

        for (const name of ["theme", "bar", "dock", "notch", "workspaces", "overview", "dashboard", "launcher", "lockscreen", "osd", "compositor"])
            Config.save(name);

        GlobalStates.resetChangeTracking();
    }
}
