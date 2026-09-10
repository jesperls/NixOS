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
    property bool resyncing: false
    property int writeFailures: 0
    signal written()

    function write(text) {
        writeFailures = 0;
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
        const text = pendingText;
        pendingText = null;
        if (text === "") {
            // FileView.setText("") is a no-op against its empty initial state, so
            // it would never emit saved(); report success without writing.
            savedText = "";
            written();
            return;
        }
        saving = true;
        writingText = text;
        setText(text);
    }

    function finishResync() {
        if (!resyncing)
            return;
        resyncing = false;
        Qt.callLater(root.startWrite);
    }

    function finishWrite(success) {
        if (success) {
            writeFailures = 0;
            savedText = writingText;
            saving = false;
            if (pendingText === null || pendingText === savedText)
                written();
            Qt.callLater(root.startWrite); // FileView must finish its saved signal before starting another write.
            return;
        }
        // FileView keeps the failed text in memory, so re-writing the same
        // content would be short-circuited; reload from disk to resync first.
        if (writingText !== "")
            pendingText = writingText;
        writingText = "";
        saving = false;
        if (++writeFailures >= 3) {
            console.warn("Giving up on theme export:", path);
            return;
        }
        resyncing = true;
        if (typeof reload === "function")
            reload();
    }

    onSaved: finishWrite(true)
    onSaveFailed: error => {
        console.warn("Theme export failed:", path, error);
        finishWrite(false);
    }
    onLoaded: finishResync()
    onLoadFailed: finishResync()

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
