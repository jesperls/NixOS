pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property var state: ({})
    property bool initialized: false

    signal stateLoaded

    function get(key, fallback) {
        return root.state[key] !== undefined ? root.state[key] : fallback;
    }

    function set(key, value) {
        if (!root.initialized)
            return;
        root.state[key] = value;
        file.setText(JSON.stringify(root.state, null, 2));
    }

    // Consumers restore from stateLoaded, so re-emitting it would overwrite
    // whatever they have since changed.
    function ready() {
        if (root.initialized)
            return;
        root.initialized = true;
        root.stateLoaded();
    }

    FileView {
        id: file
        path: Quickshell.statePath("states.json")
        preload: true
        atomicWrites: true
        onLoaded: {
            try {
                const loaded = JSON.parse(text());
                if (!loaded || typeof loaded !== "object" || Array.isArray(loaded))
                    throw new Error("Expected a state object");
                root.state = loaded;
            } catch (e) {
                console.warn("StateService: discarding unreadable state file:", e);
                root.state = {};
            }
            root.ready();
        }
        onLoadFailed: root.ready()
    }
}
