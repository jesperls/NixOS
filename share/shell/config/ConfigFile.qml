import QtQuick
import Quickshell.Io
import qs.config

FileView {
    id: root

    required property string name
    property bool ready: false
    property bool reloading: true
    property bool reloadPending: false

    path: Config.configDir + "/" + name + ".json"
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
