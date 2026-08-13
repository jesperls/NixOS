pragma Singleton
pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import Quickshell.Io
import qs.config

Singleton {
    id: root

    property string desktopDir: ""
    property bool initialLoadComplete: false
    property int maxRowsHint: 15
    property int maxColumnsHint: 10
    property bool gridReady: false

    onMaxRowsHintChanged: checkGridReady()
    onMaxColumnsHintChanged: checkGridReady()

    function checkGridReady() {
        if (maxRowsHint > 0 && maxColumnsHint > 0 && !gridReady) {
            gridReady = true;
            if (tempItems.length > 0 || tempDesktopFiles.length > 0) {
                finalizeItems();
            }
        }
    }

    property ListModel items: ListModel {
        id: itemsModel
    }

    function getDesktopDir() {
        getDesktopDirProcess.running = true;
    }

    function generateThumbnails() {
        if (desktopDir) {
            thumbnailProcess.running = true;
        }
    }

    function scanDesktop() {
        if (desktopDir) {
            if (parsingInProgress) {
                needsRescan = true;
            } else {
                scanProcess.running = true;
            }
        }
    }

    function executeDesktopFile(filePath) {
        var escapedPath = filePath.replace(/'/g, "'\\''");
        runInActiveWorkspace("gio launch '" + escapedPath + "'");
    }

    function openFile(filePath) {
        var escapedPath = filePath.replace(/'/g, "'\\''");
        runInActiveWorkspace("xdg-open '" + escapedPath + "'");
    }

    function runInActiveWorkspace(command) {
        var processComponent = Qt.createQmlObject('import Quickshell.Io; Process { }', root);
        processComponent.command = ["bash", "-c", "cd ~ && env -u HL_INITIAL_WORKSPACE_TOKEN setsid " + command + " < /dev/null > /dev/null 2>&1 &"];
        processComponent.onExited.connect(() => processComponent.destroy());
        processComponent.running = true;
    }

    function trashFile(filePath) {
        var escapedPath = filePath.replace(/'/g, "'\\''");
        var processComponent = Qt.createQmlObject('
            import Quickshell
            import Quickshell.Io
            Process {
                running: true
                command: ["bash", "-c", "gio trash \'' + escapedPath + '\'"]

                stdout: StdioCollector {
                    onStreamFinished: {
                        if (text.length > 0) {
                            console.log("File moved to trash:", text);
                        }
                    }
                }

                stderr: StdioCollector {
                    onStreamFinished: {
                        if (text.length > 0) {
                            console.warn("Error moving file to trash:", text);
                        }
                    }
                }

                onRunningChanged: {
                    if (!running) {
                        destroy();
                    }
                }
            }
        ', root);
    }

    function moveItem(fromIndex, toIndex) {
        if (fromIndex === toIndex || fromIndex < 0 || toIndex < 0 || fromIndex >= items.count) {
            return;
        }

        if (toIndex >= items.count) {
            toIndex = items.count - 1;
        }

        var targetIsPlaceholder = items.get(toIndex).isPlaceholder === true;

        if (targetIsPlaceholder) {
            var item = items.get(fromIndex);
            items.setProperty(toIndex, "name", item.name);
            items.setProperty(toIndex, "path", item.path);
            items.setProperty(toIndex, "type", item.type);
            items.setProperty(toIndex, "icon", item.icon);
            items.setProperty(toIndex, "isDesktopFile", item.isDesktopFile);
            items.setProperty(toIndex, "isPlaceholder", false);

            items.setProperty(fromIndex, "name", "");
            items.setProperty(fromIndex, "path", "");
            items.setProperty(fromIndex, "type", "placeholder");
            items.setProperty(fromIndex, "icon", "");
            items.setProperty(fromIndex, "isDesktopFile", false);
            items.setProperty(fromIndex, "isPlaceholder", true);

            var col = Math.floor(toIndex / maxRowsHint);
            var row = toIndex % maxRowsHint;
            items.setProperty(toIndex, "gridX", col);
            items.setProperty(toIndex, "gridY", row);
        } else {
            items.move(fromIndex, toIndex, 1);

            var sourceCol = Math.floor(toIndex / maxRowsHint);
            var sourceRow = toIndex % maxRowsHint;
            items.setProperty(toIndex, "gridX", sourceCol);
            items.setProperty(toIndex, "gridY", sourceRow);

            var targetCol = Math.floor(fromIndex / maxRowsHint);
            var targetRow = fromIndex % maxRowsHint;
            items.setProperty(fromIndex, "gridX", targetCol);
            items.setProperty(fromIndex, "gridY", targetRow);
        }
    }

    function getFileType(fileName) {
        var ext = fileName.toLowerCase().split('.').pop();

        if (['jpg', 'jpeg', 'png', 'gif', 'webp', 'svg', 'bmp'].includes(ext)) {
            return 'image';
        } else if (['mp4', 'webm', 'mov', 'avi', 'mkv', 'mp3', 'wav', 'ogg', 'flac'].includes(ext)) {
            return 'media';
        } else if (['pdf'].includes(ext)) {
            return 'pdf';
        } else if (['txt', 'md', 'log'].includes(ext)) {
            return 'text';
        } else if (['zip', 'tar', 'gz', 'rar', '7z'].includes(ext)) {
            return 'archive';
        } else if (['doc', 'docx', 'odt'].includes(ext)) {
            return 'document';
        }
        return 'file';
    }

    function getIconForType(type) {
        switch (type) {
        case 'folder':
            return 'folder';
        case 'image':
            return 'image-x-generic';
        case 'media':
            return 'video-x-generic';
        case 'pdf':
            return 'application-pdf';
        case 'text':
            return 'text-x-generic';
        case 'archive':
            return 'package-x-generic';
        case 'document':
            return 'x-office-document';
        default:
            return 'text-x-generic';
        }
    }

    property bool _initialized: false

    function initialize() {
        if (_initialized) return;
        _initialized = true;
        Qt.callLater(() => getDesktopDir());
    }

    Process {
        id: getDesktopDirProcess
        running: false
        command: ["sh", "-c", "echo ${XDG_DESKTOP_DIR:-$HOME/Desktop}"]

        stdout: StdioCollector {
            onStreamFinished: {
                root.desktopDir = text.trim();
                scanDesktop();
                directoryWatcher.path = root.desktopDir;
                directoryWatcher.reload();
            }
        }
    }

    FileView {
        id: directoryWatcher
        path: ""
        watchChanges: true
        printErrors: false

        onFileChanged: {
            console.log("Desktop directory changed, rescanning...");
            scanDesktop();
            thumbnailTimer.restart();
        }
    }

    Process {
        id: scanProcess
        running: false
        command: ["sh", "-c", "ls -1ap " + root.desktopDir + " | grep -v '^\\.$' | grep -v '^\\.\\.$'"]

        stdout: StdioCollector {
            onStreamFinished: {
                var entries = text.trim().split("\n").filter(f => f.length > 0);
                var newItems = [];
                var pendingDesktopFiles = [];

                for (var i = 0; i < entries.length; i++) {
                    var entry = entries[i];
                    var isDir = entry.endsWith('/');
                    var name = isDir ? entry.slice(0, -1) : entry;
                    var fullPath = root.desktopDir + "/" + name;

                    if (name.startsWith('.')) {
                        continue;
                    }

                    if (isDir) {
                        newItems.push({
                            name: name,
                            path: fullPath,
                            type: 'folder',
                            icon: 'folder',
                            isDesktopFile: false,
                            sortOrder: 0
                        });
                    } else if (name.endsWith('.desktop')) {
                        pendingDesktopFiles.push({
                            name: name,
                            path: fullPath,
                            type: 'application',
                            icon: 'application-x-executable',
                            isDesktopFile: true,
                            sortOrder: 1
                        });
                    } else {
                        var fileType = root.getFileType(name);
                        newItems.push({
                            name: name,
                            path: fullPath,
                            type: fileType,
                            icon: root.getIconForType(fileType),
                            isDesktopFile: false,
                            sortOrder: 2
                        });
                    }
                }

                if (!parsingInProgress) {
                    tempDesktopFiles = pendingDesktopFiles;
                    tempItems = newItems;

                    if (pendingDesktopFiles.length > 0) {
                        parsingInProgress = true;
                        currentDesktopFileIndex = 0;
                        parseNextDesktopFile();
                    } else {
                        if (gridReady) {
                            finalizeItems();
                        }
                    }
                } else {
                    needsRescan = true;
                }
            }
        }

        stderr: StdioCollector {
            onStreamFinished: {
                if (text.length > 0) {
                    console.warn("Error scanning desktop:", text);
                }
            }
        }
    }

    property var tempDesktopFiles: []
    property var tempItems: []
    property int currentDesktopFileIndex: -1
    property var currentItem: null
    property bool parsingInProgress: false
    property bool needsRescan: false

    function parseNextDesktopFile() {
        if (currentDesktopFileIndex < tempDesktopFiles.length) {
            currentItem = tempDesktopFiles[currentDesktopFileIndex];
            parseDesktopFileProcess.command = ["cat", currentItem.path];
            parseDesktopFileProcess.running = true;
        } else {
            parsingInProgress = false;
            if (gridReady) {
                finalizeItems();
            }
            if (needsRescan) {
                needsRescan = false;
                scanDesktop();
            }
        }
    }

    function finalizeItems() {
        var allItems = tempItems.concat(tempDesktopFiles);

        allItems.sort((a, b) => {
            if (a.sortOrder !== b.sortOrder) {
                return a.sortOrder - b.sortOrder;
            }
            return a.name.localeCompare(b.name);
        });

        items.clear();

        var gridSize = maxRowsHint * maxColumnsHint;

        for (var i = 0; i < gridSize; i++) {
            items.append({
                name: "",
                path: "",
                type: "placeholder",
                icon: "",
                isDesktopFile: false,
                isPlaceholder: true,
                gridX: Math.floor(i / maxRowsHint),
                gridY: i % maxRowsHint
            });
        }

        for (var i = 0; i < allItems.length && i < gridSize; i++) {
            var item = allItems[i];
            var col = Math.floor(i / maxRowsHint);
            var row = i % maxRowsHint;

            items.setProperty(i, "name", item.name);
            items.setProperty(i, "path", item.path);
            items.setProperty(i, "type", item.type);
            items.setProperty(i, "icon", item.icon);
            items.setProperty(i, "isDesktopFile", item.isDesktopFile);
            items.setProperty(i, "isPlaceholder", false);
            items.setProperty(i, "gridX", col);
            items.setProperty(i, "gridY", row);
        }

        root.initialLoadComplete = true;
    }

    Process {
        id: parseDesktopFileProcess
        running: false
        command: []

        onRunningChanged: {
            if (!running && currentDesktopFileIndex >= 0 && currentDesktopFileIndex < tempDesktopFiles.length) {
                currentDesktopFileIndex++;
                if (currentDesktopFileIndex < tempDesktopFiles.length) {
                    Qt.callLater(parseNextDesktopFile);
                } else {
                    parsingInProgress = false;
                    currentDesktopFileIndex = -1;
                    if (gridReady) {
                        finalizeItems();
                    }
                    if (needsRescan) {
                        needsRescan = false;
                        scanDesktop();
                    }
                }
            }
        }

        stdout: StdioCollector {
            onStreamFinished: {
                var item = root.currentItem;
                if (!item)
                    return;

                var lines = text.split("\n");
                var name = "";
                var icon = "application-x-executable";

                for (var i = 0; i < lines.length; i++) {
                    var line = lines[i].trim();
                    if (line.startsWith("Name=")) {
                        name = line.substring(5);
                    } else if (line.startsWith("Icon=")) {
                        icon = line.substring(5);
                    }
                }

                if (name) {
                    item.name = name;
                }
                item.icon = icon;
            }
        }

        stderr: StdioCollector {
            onStreamFinished: {
                if (text.length > 0) {
                    console.warn("Error parsing .desktop file:", text);
                }
            }
        }
    }

    Process {
        id: thumbnailProcess
        running: false
        command: ["python3", Paths.script("desktop_thumbgen.py"), desktopDir, Paths.cachePath("desktop_thumbnails")]

        stdout: StdioCollector {
            onStreamFinished: {
                if (text.length > 0) {
                    console.log("Thumbnail generation:", text);
                }
            }
        }

        stderr: StdioCollector {
            onStreamFinished: {
                if (text.length > 0) {
                    console.log("Thumbnail generation output:", text);
                }
            }
        }
    }

    Timer {
        id: thumbnailTimer
        interval: 1000
        running: false
        onTriggered: generateThumbnails()
    }

    onDesktopDirChanged: {
        if (desktopDir) {
            thumbnailTimer.running = true;
        }
    }
}
