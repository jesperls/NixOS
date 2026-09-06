import QtQuick
import Quickshell.Io

FileView {
    id: root
    preload: false
    atomicWrites: true

    property bool directoryReady: false
    property bool saving: false
    property var pendingText: null
    property var savedText: null
    property string writingText: ""
    signal written()

    function write(text) {
        pendingText = text;
        startWrite();
    }

    function startWrite() {
        if (saving || pendingText === null)
            return;
        if (!directoryReady) {
            prepareDirectory.running = true;
            return;
        }
        if (pendingText === savedText) {
            pendingText = null;
            return;
        }
        saving = true;
        writingText = pendingText;
        pendingText = null;
        setText(writingText);
    }

    function finishWrite(success) {
        if (success)
            savedText = writingText;
        saving = false;
        if (success && (pendingText === null || pendingText === savedText))
            written();
        Qt.callLater(root.startWrite); // FileView must finish its saved signal before starting another write.
    }

    onSaved: finishWrite(true)
    onSaveFailed: error => {
        console.warn("Theme export failed:", path, error);
        finishWrite(false);
    }

    property Process prepareDirectory: Process {
        id: prepareDirectory
        command: ["mkdir", "-p", "--", root.path.slice(0, root.path.lastIndexOf("/"))]
        onExited: code => {
            root.directoryReady = code === 0;
            if (root.directoryReady)
                Qt.callLater(root.startWrite);
            else
                console.warn("Cannot create theme export directory:", root.path);
        }
    }
}
