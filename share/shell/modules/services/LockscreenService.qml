pragma Singleton
pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Io
import QtQuick
import qs.modules.globals
import qs.config

QtObject {
    id: root

    property bool _firstStartOfSession: false

    property Process bootProbe: Process {
        running: true
        command: ["bash", "-c", "marker=\"${XDG_RUNTIME_DIR:-/tmp}/pangu/session-started\"; mkdir -p \"${XDG_RUNTIME_DIR:-/tmp}/pangu\"; if [ -e \"$marker\" ]; then echo repeat; else touch \"$marker\"; echo first; fi"]
        stdout: StdioCollector {
            onStreamFinished: {
                root._firstStartOfSession = text.trim() === "first";
                root.maybeBootLock();
            }
        }
    }

    property Connections configReady: Connections {
        target: Config
        function onInitialLoadCompleteChanged() {
            root.maybeBootLock();
        }
    }

    function maybeBootLock() {
        if (root._firstStartOfSession && Config.initialLoadComplete && Config.lockscreen.lockOnBoot) {
            root._firstStartOfSession = false;
            root.lock();
        }
    }

    function toggle() {
        root.lock();
    }

    function lock() {
        GlobalStates.lockscreenVisible = true;
    }

    property IpcHandler ipc: IpcHandler {
        target: "lockscreen"

        function toggle() {
            root.toggle();
        }

        function lock() {
            root.lock();
        }

    }
}
