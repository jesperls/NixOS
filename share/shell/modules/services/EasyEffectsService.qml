pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property bool available: false

    property bool bypassed: false

    property var outputPresets: []
    property var inputPresets: []

    property string activeOutputPreset: ""
    property string activeInputPreset: ""

    property int _replyIndex: 2

    function _query() {
        _replyIndex = 0;
        socket.write("get_global_bypass\nget_last_loaded_preset:input\nget_last_loaded_preset:output\n");
        socket.flush();
    }

    function setBypass(enable: bool) {
        if (!socket.connected) return;
        socket.write("global_bypass:" + (enable ? "1" : "0") + "\n");
        _query();
    }

    function loadOutputPreset(name: string) {
        if (!socket.connected) return;
        root.activeOutputPreset = name;  // Optimistic
        socket.write("load_preset:output:" + name + "\n");
        _query();
    }

    function loadInputPreset(name: string) {
        if (!socket.connected) return;
        root.activeInputPreset = name;  // Optimistic
        socket.write("load_preset:input:" + name + "\n");
        _query();
    }

    function refresh() {
        outputPresetsProcess.running = true;
        inputPresetsProcess.running = true;
        if (socket.connected) {
            _query();
        } else {
            socket.connected = true;
        }
    }

    function openApp() {
        Quickshell.execDetached(["easyeffects"]);
    }

    function initialize() {
        refresh();
    }

    Socket {
        id: socket
        path: Quickshell.env("XDG_RUNTIME_DIR") + "/EasyEffectsServer"
        connected: false
        onConnectionStateChanged: {
            root.available = connected;
            if (connected) {
                root._query();
            }
        }
        onError: root.available = false
        parser: SplitParser {
            onRead: data => {
                if (root._replyIndex === 0) {
                    const m = data.match(/^([12])(.*)$/);  // get_global_bypass reply has no newline, fusing it to the next line
                    if (m) {
                        root.bypassed = (m[1] === "1");
                        root.activeInputPreset = m[2];
                    }
                    root._replyIndex = 1;
                } else if (root._replyIndex === 1) {
                    root.activeOutputPreset = data;
                    root._replyIndex = 2;
                }
            }
        }
    }

    Process {
        id: outputPresetsProcess
        command: ["sh", "-c", 'ls -1 "${XDG_DATA_HOME:-$HOME/.local/share}/easyeffects/output" 2>/dev/null']
        running: false
        stdout: StdioCollector {
            onStreamFinished: root.outputPresets = text.split("\n").filter(n => n.endsWith(".json")).map(n => n.slice(0, -5))
        }
    }

    Process {
        id: inputPresetsProcess
        command: ["sh", "-c", 'ls -1 "${XDG_DATA_HOME:-$HOME/.local/share}/easyeffects/input" 2>/dev/null']
        running: false
        stdout: StdioCollector {
            onStreamFinished: root.inputPresets = text.split("\n").filter(n => n.endsWith(".json")).map(n => n.slice(0, -5))
        }
    }
}
