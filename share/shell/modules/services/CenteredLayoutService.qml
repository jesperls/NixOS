pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Hyprland

Singleton {
    id: root

    property var gaps: ({})

    function gapFor(screenName) {
        return root.gaps[screenName] ?? null;
    }

    Connections {
        target: Hyprland

        function onRawEvent(event) {
            if (event.name !== "custom" || !event.data)
                return;
            const parts = event.data.split(",");
            if (parts.length < 4 || parts[0] !== "centergap")
                return;
            const name = parts[1];
            const x = parseInt(parts[2], 10);
            const width = parseInt(parts[3], 10);
            const square = parts[4] === "1";
            const next = Object.assign({}, root.gaps);
            if (!width || width <= 0) {
                if (!(name in next))
                    return;
                delete next[name];
            } else {
                const prev = next[name];
                if (prev && prev.x === x && prev.width === width && prev.square === square)
                    return;
                next[name] = {
                    x: x,
                    width: width,
                    square: square
                };
            }
            root.gaps = next;
        }
    }
}
