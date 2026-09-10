pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io

Singleton {
    id: root

    readonly property QtObject clients: QtObject {
        property var values: []
    }

    readonly property QtObject monitors: QtObject {
        property var values: []
    }

    readonly property QtObject workspaces: QtObject {
        property var values: []
    }

    readonly property var focusedMonitor: root.monitorFor(Hyprland.focusedMonitor)
    readonly property var focusedWorkspace: workspaces.values.find(w => w.active) ?? null
    readonly property var focusedClient: clients.values.find(c => c.is_focused) ?? null

    readonly property var windowList: root.clients.values
    readonly property var workspaceOccupationMap: {
        const map = {};
        for (const win of (root.clients.values ?? []))
            map[win.workspace.id] = true;
        return map;
    }
    readonly property var workspaceWindowsMap: {
        const map = {};
        for (const win of (root.clients.values ?? [])) {
            const id = win.workspace.id;
            if (!map[id])
                map[id] = [];
            map[id].push(win);
        }
        return map;
    }

    // Centered-layout master gap, published per screen by the compositor.
    property var gaps: ({})

    function gapFor(screenName) {
        return root.gaps[screenName] ?? null;
    }

    function handleRawEvent(event) {
        if (event.name !== "custom" || !event.data)
            return;
        const parts = event.data.split(",");
        if (parts.length < 4 || parts[0] !== "centergap")
            return;
        const name = parts[1];
        const x = parseInt(parts[2], 10);
        const width = parseInt(parts[3], 10);
        const square = parts[4] === "1";
        const next = Object.assign({}, root.gaps);
        if (!width || width <= 0) {
            if (!(name in next))
                return;
            delete next[name];
        } else {
            const prev = next[name];
            if (prev && prev.x === x && prev.width === width && prev.square === square)
                return;
            next[name] = {
                x: x,
                width: width,
                square: square
            };
        }
        root.gaps = next;
    }

    function monitorFor(screen) {
        const name = screen && screen.name ? screen.name : screen;
        return root.monitors.values.find(m => m.name === name) ?? null;
    }

    function hasFullscreenWindow(screen) {
        const mon = root.monitorFor(screen);
        if (!mon || !mon.activeWorkspace || !root.clients.values)
            return false;

        const wsId = mon.activeWorkspace.id;
        const monId = mon.id;
        for (let i = 0; i < root.clients.values.length; i++) {
            const c = root.clients.values[i];
            if (c.monitor === monId && c.fullscreen && c.workspace.id === wsId)
                return true;
        }
        return false;
    }

    function dispatch(command) {
        if (!command)
            return;

        const split = command.indexOf(" ");
        const action = (split === -1 ? command : command.slice(0, split)).trim();
        const rest = split === -1 ? "" : command.slice(split + 1).trim();

        const target = str => {
            const match = str.match(/address:([^\s,]+)/);
            const address = match ? match[1] : str.trim();
            return `address:${/^[0-9a-f]+$/i.test(address) ? "0x" + address : address}`;
        };

        switch (action) {
        case "workspace":
            return Hyprland.dispatch(`hl.dsp.focus({ workspace = "${rest}" })`);
        case "focuswindow":
            return Hyprland.dispatch(`hl.dsp.focus({ window = "${target(rest)}" })`);
        case "focusmonitor":
            return Hyprland.dispatch(`hl.dsp.focus({ monitor = "${rest}" })`);
        case "closewindow":
            return Hyprland.dispatch(rest ? `hl.dsp.window.close({ window = "${target(rest)}" })` : "hl.dsp.window.close()");
        case "togglespecialworkspace":
            return Hyprland.dispatch(rest ? `hl.dsp.workspace.toggle_special("${rest}")` : "hl.dsp.workspace.toggle_special()");
        case "movetoworkspacesilent": {
            const parts = rest.split(",");
            const window = parts.length > 1 ? `, window = "${target(parts[1])}"` : "";
            return Hyprland.dispatch(`hl.dsp.window.move({ workspace = "${parts[0].trim()}", follow = false${window} })`);
        }
        case "movepixel": {
            const parts = rest.split(",");
            const coords = parts[0].trim().split(/\s+/);
            const window = parts.length > 1 ? `, window = "${target(parts[1])}"` : "";
            const px = parseInt(coords[0]);
            const py = parseInt(coords[1]);
            if (isNaN(px) || isNaN(py))
                return;
            return Hyprland.dispatch(`hl.dsp.window.move({ x = ${px}, y = ${py}${window} })`);
        }
        case "movewindowpixel": {
            // Overview floating-window drags: "movewindowpixel exact X% Y%, address:..."
            const m = rest.match(/^(?:exact\s+)?(-?\d+(?:\.\d+)?)%\s+(-?\d+(?:\.\d+)?)%,?\s*(address:[^\s,]+)?/);
            const mon = root.focusedMonitor;
            if (!m || !mon)
                return;
            const x = mon.x + Math.round(mon.width * parseFloat(m[1]) / 100);
            const y = mon.y + Math.round(mon.height * parseFloat(m[2]) / 100);
            const window = m[3] ? `, window = "${target(m[3])}"` : "";
            return Hyprland.dispatch(`hl.dsp.window.move({ x = ${x}, y = ${y}${window} })`);
        }
        case "dpms":
            return Hyprland.dispatch(`hl.dsp.dpms({ action = "${rest}" })`);
        case "exit":
            return Hyprland.dispatch("hl.dsp.exit()");
        }

        console.warn("Compositor: no dispatcher mapping for", command);
    }

    // Quickshell's Socket never ends its stream, so a collector on one waits
    // forever; a process exit does close it.
    function request(payload, onReply) {
        const proc = requestComponent.createObject(root, {
            payload: payload,
            handler: onReply ?? (() => {})
        });
        proc.running = true;
    }

    function reloadConfig() {
        root.request("reload");
    }

    Component {
        id: requestComponent

        Process {
            id: proc

            required property string payload
            required property var handler

            command: ["sh", "-c", 'printf %s "$1" | socat - "UNIX-CONNECT:$2"', "sh", payload, Hyprland.requestSocketPath]
            stdout: StdioCollector {
                onStreamFinished: proc.handler(text)
            }
            onExited: proc.destroy()
        }
    }

    function rebuild() {
        root.clients.values = Hyprland.toplevels.values.map(toplevel => {
            const raw = toplevel.lastIpcObject ?? {};
            return {
                nativeToplevel: toplevel,
                address: raw.address ?? toplevel.address,
                class: raw.class ?? "",
                title: raw.title ?? toplevel.title,
                workspace: raw.workspace ?? {
                    id: 0,
                    name: ""
                },
                monitor: raw.monitor ?? 0,
                floating: raw.floating ?? false,
                fullscreen: (raw.fullscreen ?? 0) !== 0,
                hidden: raw.hidden ?? false,
                mapped: raw.mapped ?? true,
                at: raw.at ?? [0, 0],
                size: raw.size ?? [100, 100],
                xwayland: raw.xwayland ?? false,
                pinned: raw.pinned ?? false,
                focusHistoryID: raw.focusHistoryID ?? Infinity,
                is_focused: toplevel === Hyprland.activeToplevel
            };
        });

        root.monitors.values = Hyprland.monitors.values.map(monitor => {
            const raw = monitor.lastIpcObject ?? {};
            return {
                id: monitor.id,
                name: monitor.name,
                focused: monitor === Hyprland.focusedMonitor,
                width: monitor.width,
                height: monitor.height,
                scale: monitor.scale,
                x: monitor.x,
                y: monitor.y,
                refreshRate: raw.refreshRate ?? 0,
                transform: raw.transform ?? 0,
                activeWorkspace: monitor.activeWorkspace ? {
                    id: monitor.activeWorkspace.id,
                    name: monitor.activeWorkspace.name
                } : null
            };
        });

        root.workspaces.values = Hyprland.workspaces.values.map(workspace => ({
            id: workspace.id,
            name: workspace.name,
            monitor: workspace.monitor ? workspace.monitor.name : "",
            active: workspace === Hyprland.focusedWorkspace
        }));
    }

    Timer {
        id: refresh
        interval: 30
        onTriggered: {
            Hyprland.refreshToplevels();
            Hyprland.refreshWorkspaces();
            Hyprland.refreshMonitors();
            snapshot.restart();
        }
    }

    Timer {
        id: snapshot
        interval: 40
        onTriggered: root.rebuild()
    }

    Connections {
        target: Hyprland

        function onRawEvent(event) {
            root.handleRawEvent(event);
            refresh.restart();
        }
        function onFocusedMonitorChanged() {
            snapshot.restart();
        }
        function onFocusedWorkspaceChanged() {
            snapshot.restart();
        }
        function onActiveToplevelChanged() {
            snapshot.restart();
        }
    }

    Connections {
        target: Hyprland.toplevels
        function onValuesChanged() {
            snapshot.restart();
        }
    }

    Connections {
        target: Hyprland.monitors
        function onValuesChanged() {
            snapshot.restart();
        }
    }

    Connections {
        target: Hyprland.workspaces
        function onValuesChanged() {
            snapshot.restart();
        }
    }

    Component.onCompleted: refresh.restart()
}
