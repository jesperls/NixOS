pragma Singleton

import QtQuick
import Quickshell

// Gating IdleService is the whole of it: Wayland's inhibitor protocol is
// per-surface and cannot express a global toggle.
Singleton {
    id: root

    property bool inhibit: false

    function toggleInhibit() {
        root.inhibit = !root.inhibit;
    }

    onInhibitChanged: if (StateService.initialized) StateService.set("caffeine", root.inhibit)

    Component.onCompleted: if (StateService.initialized) restore()

    function restore() {
        root.inhibit = StateService.get("caffeine", false);
    }

    Connections {
        target: StateService
        function onStateLoaded() {
            root.restore();
        }
    }
}
