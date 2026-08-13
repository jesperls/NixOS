pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import qs.config

Singleton {
    id: root

    property bool active: StateService.get("nightLight", false)
    property bool stopping: false
    property int restartFailures: 0

    readonly property int temperature: Config.system.nightLight?.temperature ?? 4500

    onTemperatureChanged: {
        if (active) {
            root.stopping = true;
            killProcess.running = true;
            restartTimer.restart();
        }
    }

    property Timer restartTimer: Timer {
        interval: 300
        onTriggered: wlsunsetProcess.running = true
    }

    property Process wlsunsetProcess: Process {
        command: ["wlsunset", "-t", String(root.temperature - 1), "-T", String(root.temperature)]
        running: false
        stdout: SplitParser {
            onRead: (data) => {
                if (data) {
                    root.active = true
                }
            }
        }
        onStarted: {
            root.active = true
            root.restartFailures = 0
        }
        onExited: (code) => {
            if (root.stopping) {
                root.stopping = false
            } else {
                root.restartFailures++
                console.warn("NightLightService: wlsunset exited with code " + code + ". Restarting...")
                restartTimer.interval = Math.min(30000, 300 * root.restartFailures)
                restartTimer.start()
            }
        }
    }
    
    property Process killProcess: Process {
        command: ["pkill", "wlsunset"]
        running: false
        onExited: (code) => {
            root.active = false
        }
    }
    
    property Process checkRunningProcess: Process {
        command: ["pgrep", "wlsunset"]
        running: false
        onExited: (code) => {
            const isRunning = code === 0
            
            if (root.active && !isRunning) {
                console.log("NightLightService: Starting wlsunset (state was active but not running)")
                wlsunsetProcess.running = true
            } 
            else if (!root.active && isRunning) {
                console.log("NightLightService: Stopping wlsunset (state was inactive but running)")
                root.stopping = true;
                killProcess.running = true
            }
        }
    }

    function toggle() {
        if (active) {
            root.stopping = true;
            killProcess.running = true
        } else {
            wlsunsetProcess.running = true
        }
    }
    
    function syncState() {
        checkRunningProcess.running = true
    }

    onActiveChanged: {
        if (StateService.initialized) {
            StateService.set("nightLight", active);
        }
    }

    Connections {
        target: StateService
        function onStateLoaded() {
            root.active = StateService.get("nightLight", false);
            root.syncState();
        }
    }

    Timer {
        interval: 100
        running: true
        repeat: false
        onTriggered: {
            if (StateService.initialized) {
                root.active = StateService.get("nightLight", false);
                root.syncState();
            }
        }
    }
}
