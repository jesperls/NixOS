pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import qs.config

Singleton {
    id: root

    readonly property string usageFilePath: Paths.cachePath("usage.json")
    property var usageData: ({})
    property var pendingUsage: []
    property bool dataLoaded: false
    property bool fileReady: false

    signal usageDataReady()
    signal usageChanged()

    readonly property int maxBoostScore: 200
    readonly property int dayInMs: 86400000

    Process {
        id: ensureUsageDirectory
        running: true
        command: ["mkdir", "-p", "--", Paths.cacheDir]
        onExited: code => {
            root.fileReady = code === 0;
            if (!root.fileReady) {
                console.warn("Cannot prepare application usage directory");
                root.finishLoad({});
            }
        }
    }

    FileView {
        id: usageFile
        path: root.fileReady ? root.usageFilePath : ""
        atomicWrites: true
        onLoaded: root.loadUsageData()
        onLoadFailed: error => {
            if (!root.fileReady) return;
            if (error !== FileViewError.FileNotFound)
                console.warn("Cannot read application usage:", error);
            root.finishLoad({});
        }
        onSaveFailed: error => console.warn("Cannot save application usage:", error)
    }

    function finishLoad(data) {
        if (dataLoaded) return;
        const entries = Object.create(null);
        const now = Date.now();
        if (data && typeof data === "object" && !Array.isArray(data)) {
            for (const [id, entry] of Object.entries(data)) {
                if (!entry || !Number.isFinite(entry.count) || entry.count < 1 || !Number.isFinite(entry.lastUsed) || entry.lastUsed < 0)
                    continue;
                entries[id] = {count: Math.min(Number.MAX_SAFE_INTEGER, Math.floor(entry.count)), lastUsed: Math.min(now, entry.lastUsed)};
            }
        }
        usageData = entries;
        dataLoaded = true;
        const pending = pendingUsage;
        pendingUsage = [];
        for (const id of pending) recordUsage(id);
        usageDataReady();
    }

    function loadUsageData() {
        try {
            finishLoad(JSON.parse(usageFile.text()));
        } catch (error) {
            console.warn("Invalid application usage file:", error);
            finishLoad({});
        }
    }

    function recordUsage(appId) {
        if (typeof appId !== "string" || !appId) return;
        if (!dataLoaded) {
            pendingUsage = pendingUsage.concat(appId);
            return;
        }
        const previous = Object.prototype.hasOwnProperty.call(usageData, appId) ? usageData[appId] : null;
        const next = Object.assign(Object.create(null), usageData);
        next[appId] = {
            count: Math.min(Number.MAX_SAFE_INTEGER, (previous ? previous.count : 0) + 1),
            lastUsed: Date.now()
        };
        usageData = next;
        if (fileReady) saveTimer.restart();
        usageChanged();
    }

    function getUsageScore(appId) {
        if (!Object.prototype.hasOwnProperty.call(usageData, appId)) return 0;
        const data = usageData[appId];
        const daysSinceLastUse = Math.max(0, (Date.now() - data.lastUsed) / dayInMs);
        return maxBoostScore * Math.exp(-daysSinceLastUse / 7) + Math.log(data.count + 1) * 20;
    }

    Timer {
        id: saveTimer
        interval: 100
        onTriggered: usageFile.setText(JSON.stringify(root.usageData, null, 2))
    }
}
