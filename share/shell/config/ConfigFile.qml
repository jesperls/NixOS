import Quickshell.Io
import qs.config

FileView {
    id: root

    required property string name
    property bool ready: false

    path: Config.configDir + "/" + name + ".json"
    atomicWrites: true
    watchChanges: true

    onLoaded: ready = true
    // Only a genuinely absent file gets defaults; anything else would clobber
    // settings we merely failed to read. No `ready` guard: the first attempt
    // can lose the race with Config.qml's mkdir.
    onLoadFailed: error => {
        if (error.toString().includes("FileNotFound")) {
            writeAdapter();
            ready = true;
        }
    }
    onFileChanged: {
        Config.pauseAutoSave = true;
        reload();
        Config.pauseAutoSave = false;
    }
    onAdapterUpdated: if (ready && !Config.pauseAutoSave) writeAdapter()
}
