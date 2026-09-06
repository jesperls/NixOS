pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property var values: []
    property int bars: 20
    property int refCount: 0
    property bool available: true
    property bool retried: false

    readonly property bool shouldRun: refCount > 0 && MprisController.isPlaying && !SuspendManager.isSuspending

    function acquire() {
        refCount++;
    }

    function release() {
        refCount = Math.max(0, refCount - 1);
    }

    onShouldRunChanged: {
        if (shouldRun) {
            retried = false;
            available = true;
            cavaProc.running = true;
        } else {
            retryTimer.stop();
            cavaProc.running = false;
            values = [];
        }
    }

    Process {
        id: cavaProc

        command: ["bash", "-c", "printf '%s\\n' '[general]' 'bars = " + root.bars + "' 'framerate = 30' '[output]' 'method = raw' 'raw_target = /dev/stdout' 'data_format = ascii' 'ascii_max_range = 100' > \"$XDG_RUNTIME_DIR/pangu/cava.conf\" && exec cava -p \"$XDG_RUNTIME_DIR/pangu/cava.conf\""]

        stdout: SplitParser {
            onRead: data => {
                const parts = data.split(";");
                const next = [];
                for (let i = 0; i < root.bars; i++) {
                    const v = parseInt(parts[i], 10);
                    next.push(isNaN(v) ? 0 : Math.min(1, v / 100));
                }
                root.values = next;
            }
        }

        onExited: (exitCode, exitStatus) => {
            root.values = [];
            if (!root.shouldRun)
                return;
            if (root.retried) {
                root.available = false;
            } else {
                root.retried = true;
                retryTimer.restart();
            }
        }
    }

    Timer {
        id: retryTimer
        interval: 1000
        onTriggered: if (root.shouldRun && root.available) cavaProc.running = true
    }
}
