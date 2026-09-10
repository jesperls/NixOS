import QtQuick
import Quickshell.Io
import qs.config

FileView {
    id: root

    required property string name
    property string pathOverride: ""
    property bool ready: false
    property bool reloading: true
    property bool reloadPending: false

    // reload() is a no-op while a write is in flight; without a watchdog the
    // reloading flag could latch and silently disable autosave for this file.
    property Timer reloadWatchdog: Timer {
        interval: 3000
        running: root.reloading
        onTriggered: {
            root.reloading = false;
            root.ready = true;
        }
    }

    path: root.pathOverride !== "" ? root.pathOverride : Config.configDir + "/" + root.name + ".json"
    atomicWrites: true
    watchChanges: true

    function reloadConfig() {
        if (ready && Config.isPaused(name)) {
            reloadPending = true;
            return;
        }
        reloadPending = false;
        reloading = true;
        reload();
    }

    property Connections editWatcher: Connections {
        target: Config
        function onEditGroupsChanged() { if (root.reloadPending) root.reloadConfig(); }
        function onPauseAutoSaveChanged() { if (root.reloadPending) root.reloadConfig(); }
    }

    onLoaded: {
        ready = true;
        reloading = false;
    }
    onLoadFailed: error => {
        reloading = false;
        if (error === FileViewError.FileNotFound) {
            writeAdapter();
            ready = true;
        }
    }
    onFileChanged: reloadConfig()
    onAdapterUpdated: if (ready && !reloading && !Config.isPaused(name)) writeAdapter()
}
