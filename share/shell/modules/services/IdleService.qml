pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import qs.config

Singleton {
    id: root

    property string lockCmd: Config.system.idle.general.lock_cmd ?? "pangu lock"
    property string beforeSleepCmd: Config.system.idle.general.before_sleep_cmd ?? "loginctl lock-session"

    property int loginLockRestarts: 0

    property var loginLockProc: Process {
        id: loginLockProc
        running: true
        command: ["bash", Paths.script("loginlock.sh")]
        onExited: exitCode => {
            if (exitCode !== 0) {
                console.warn("loginlock.sh exited with code " + exitCode + ". Restarting...");
                root.loginLockRestarts++;
                loginLockRestartTimer.interval = Math.min(30000, 1000 * root.loginLockRestarts);
                loginLockRestartTimer.start();
            }
        }
    }

    property var loginLockRestartTimer: Timer {
        id: loginLockRestartTimer
        interval: 1000
        repeat: false
        onTriggered: loginLockProc.running = true
    }

    property int sleepMonitorRestarts: 0

    property var sleepMonitorProc: Process {
        id: sleepMonitorProc
        running: true
        command: ["bash", Paths.script("sleep_monitor.sh")]
        
        stdout: SplitParser {
            onRead: data => {
                const signal = data.trim();
                if (signal === "SUSPEND") {
                    root.lockBeforeSleep();
                    SuspendManager.onPrepareForSleep();
                } else if (signal === "WAKE") {
                    SuspendManager.onWakingUp();
                }
            }
        }

        onExited: exitCode => {
            if (exitCode !== 0) {
                console.warn("sleep_monitor.sh exited with code " + exitCode + ". Restarting...");
                root.sleepMonitorRestarts++;
                sleepMonitorRestartTimer.interval = Math.min(30000, 1000 * root.sleepMonitorRestarts);
                sleepMonitorRestartTimer.start();
            }
        }
    }

    property var sleepMonitorRestartTimer: Timer {
        id: sleepMonitorRestartTimer
        interval: 1000
        repeat: false
        onTriggered: sleepMonitorProc.running = true
    }

    property int elapsedIdleTime: 0
    property var triggeredListeners: []

    property var masterMonitor: IdleMonitor {
        id: masterMonitor
        enabled: !CaffeineService.inhibit
        timeout: 1
        respectInhibitors: true

        onIsIdleChanged: {
            if (isIdle) {
                idleTimer.start();
            } else {
                idleTimer.stop();
                root.resetIdleState();
            }
        }
    }

    property var idleTimer: Timer {
        id: idleTimer
        interval: 1000
        repeat: true
        onTriggered: {
            root.elapsedIdleTime += 1;
            root.checkListeners();
        }
    }

    property var caffeineConnections: Connections {
        target: CaffeineService
        function onInhibitChanged() {
            if (CaffeineService.inhibit) {
                idleTimer.stop();
                root.resetIdleState();
            }
        }
    }

    function executeCommand(cmd) {
        if (!cmd) return;
        
        let escapedCmd = cmd.replace(/\\/g, "\\\\").replace(/"/g, '\\"');
        
        try {
            let proc = Qt.createQmlObject(`
                import Quickshell.Io
                Process {
                    command: ["sh", "-c", "${escapedCmd}"]
                    running: true
                    onExited: destroy()
                }
            `, root, "dynamicProc");
        } catch (e) {
            console.error("Failed to create process for command:", cmd, e);
        }
    }

    function shouldUseInternalSleepLock() {
        const cmd = (root.beforeSleepCmd || "").trim();
        return cmd === "loginctl lock-session"
            || cmd === "loginctl lock-sessions"
            || cmd === "pangu lock";
    }

    function lockBeforeSleep() {
        if (root.shouldUseInternalSleepLock()) {
            LockscreenService.lock();
        }
    }

    readonly property var effectiveListeners: {
        const idle = Config.system.idle;
        if (idle.enabled !== true)
            return [];
        const composed = [];
        if (idle.lock.enabled && idle.lock.timeout > 0)
            composed.push({
                timeout: idle.lock.timeout,
                onTimeout: root.lockCmd
            });
        if (idle.screenOff.enabled && idle.screenOff.timeout > 0)
            composed.push({
                timeout: idle.screenOff.timeout,
                onTimeout: "pangu screen off",
                onResume: "pangu screen on"
            });
        if (idle.suspend.enabled && idle.suspend.timeout > 0)
            composed.push({
                timeout: idle.suspend.timeout,
                onTimeout: "pangu suspend"
            });
        return composed.concat(idle.listeners || []);
    }

    onEffectiveListenersChanged: resetIdleState()

    function checkListeners() {
        let listeners = root.effectiveListeners;
        for (let i = 0; i < listeners.length; i++) {
            let listener = listeners[i];
            let tVal = listener.timeout || 60;

            if (root.elapsedIdleTime >= tVal && !root.triggeredListeners.includes(i)) {
                if (listener.onTimeout) {
                    console.log("Idle timer " + tVal + "s reached: " + listener.onTimeout);
                    root.executeCommand(listener.onTimeout);
                }
                root.triggeredListeners.push(i);
            }
        }
    }

    function resetIdleState() {
        let listeners = root.effectiveListeners;

        for (let i = root.triggeredListeners.length - 1; i >= 0; i--) {
            let idx = root.triggeredListeners[i];
            let listener = listeners[idx];

            if (listener && listener.onResume) {
                console.log("Idle resuming (undoing " + (listener.timeout || 0) + "s): " + listener.onResume);
                root.executeCommand(listener.onResume);
            }
        }

        root.elapsedIdleTime = 0;
        root.triggeredListeners = [];
    }
}
