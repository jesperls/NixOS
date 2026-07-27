pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import qs.modules.theme

Singleton {
    id: root

    readonly property var profileOrder: ["power-saver", "balanced", "performance"]

    property var availableProfiles: []
    property string currentProfile: ""
    property bool isAvailable: false

    signal profileChanged(string profile)

    property bool _initialized: false

    function initialize() {
        if (_initialized)
            return;
        _initialized = true;
        probeProc.running = true;
    }

    Timer {
        interval: 2000
        running: true
        onTriggered: root.initialize()
    }

    Process {
        id: probeProc
        workingDirectory: "/"
        command: ["powerprofilesctl", "version"]
        running: false
        stdout: SplitParser {}

        onExited: exitCode => {
            root.isAvailable = exitCode === 0;
            if (!root.isAvailable) {
                console.warn("PowerProfile: powerprofilesctl unavailable");
                return;
            }
            getProc.running = true;
            listProc.running = true;
        }
    }

    Process {
        id: getProc
        workingDirectory: "/"
        command: ["powerprofilesctl", "get"]
        running: false
        stdout: SplitParser {
            onRead: data => {
                const profile = data.trim();
                if (!profile)
                    return;
                root.currentProfile = profile;
                root.profileChanged(profile);
            }
        }
    }

    Process {
        id: listProc
        workingDirectory: "/"
        command: ["powerprofilesctl", "list"]
        running: false

        property string buffer: ""

        stdout: SplitParser {
            splitMarker: "\n"
            onRead: data => listProc.buffer += data + "\n"
        }

        onExited: exitCode => {
            const output = listProc.buffer;
            listProc.buffer = "";

            if (exitCode !== 0) {
                console.warn("PowerProfile: could not list profiles");
                return;
            }

            const profiles = [];
            for (const raw of output.split("\n")) {
                const line = raw.trim();
                if (!line.endsWith(":"))
                    continue;
                const name = line.replace("*", "").replace(":", "").trim();
                if (name && profiles.indexOf(name) === -1)
                    profiles.push(name);
            }

            profiles.sort((a, b) => {
                const ia = root.profileOrder.indexOf(a);
                const ib = root.profileOrder.indexOf(b);
                if (ia === -1)
                    return 1;
                if (ib === -1)
                    return -1;
                return ia - ib;
            });
            root.availableProfiles = profiles;
        }
    }

    Process {
        id: setProc
        workingDirectory: "/"
        running: false
        stdout: SplitParser {}
        stderr: SplitParser {
            onRead: data => {
                const err = data.trim();
                if (err)
                    console.warn("PowerProfile:", err);
            }
        }

        onExited: exitCode => {
            if (exitCode !== 0) {
                console.warn("PowerProfile: failed to set profile");
                return;
            }
            Qt.callLater(() => getProc.running = true);
        }
    }

    function updateCurrentProfile() {
        if (isAvailable)
            getProc.running = true;
    }

    function updateAvailableProfiles() {
        if (!isAvailable)
            return;
        availableProfiles = [];
        listProc.running = true;
    }

    function setProfile(profileName) {
        if (!isAvailable) {
            console.warn("PowerProfile: not available");
            return;
        }
        if (availableProfiles.indexOf(profileName) === -1) {
            console.warn("PowerProfile: unknown profile", profileName);
            return;
        }

        currentProfile = profileName;
        setProc.command = ["powerprofilesctl", "set", profileName];
        setProc.running = true;
    }

    function getProfileIcon(profileName) {
        if (profileName === "power-saver")
            return Icons.powerSave;
        if (profileName === "performance")
            return Icons.performance;
        return Icons.balanced;
    }

    function getProfileDisplayName(profileName) {
        if (profileName === "power-saver")
            return "Power Save";
        if (profileName === "balanced")
            return "Balanced";
        if (profileName === "performance")
            return "Performance";
        return profileName;
    }
}
