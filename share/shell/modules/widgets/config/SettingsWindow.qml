import QtQuick
import Quickshell
import qs.modules.widgets.dashboard.controls
import qs.modules.components
import qs.modules.globals
import qs.modules.services
import qs.modules.theme
import qs.config

FloatingWindow {
    id: settingsWindow

    implicitWidth: 900
    implicitHeight: 650
    title: "Pangu Settings"
    visible: GlobalStates.settingsWindowVisible

    color: "transparent"

    function screenByName(name) {
        if (!name) return null;

        for (let i = 0; i < Quickshell.screens.length; i++) {
            if (Quickshell.screens[i].name === name) {
                return Quickshell.screens[i];
            }
        }

        return null;
    }

    function preparePlacement() {
        const targetScreen = screenByName(GlobalStates.settingsTargetScreenName || Compositor.focusedMonitor?.name || "");
        if (targetScreen) {
            settingsWindow.screen = targetScreen;
        }

        placementTimer.attempts = 0;
        placementTimer.restart();
    }

    function placeOnTargetWorkspace() {
        const targetWorkspace = GlobalStates.settingsTargetWorkspaceId || Compositor.focusedMonitor?.activeWorkspace?.id || Compositor.focusedWorkspace?.id || 0;
        if (!targetWorkspace) return false;

        const clients = Compositor.clients.values || [];
        for (let i = 0; i < clients.length; i++) {
            const client = clients[i];
            if (client.title === settingsWindow.title) {
                if (client.workspace?.id !== targetWorkspace) {
                    Compositor.dispatch(`movetoworkspacesilent ${targetWorkspace}, address:${client.address}`);
                }
                Compositor.dispatch(`focuswindow address:${client.address}`);
                return true;
            }
        }

        return false;
    }

    Timer {
        id: placementTimer
        interval: 100
        repeat: true
        property int attempts: 0
        onTriggered: {
            attempts++;
            if (!settingsWindow.visible || settingsWindow.placeOnTargetWorkspace() || attempts >= 20) {
                stop();
            }
        }
    }

    StyledRect {
        anchors.fill: parent
        variant: "bg"
        radius: 0

        SettingsTab {
            anchors.fill: parent
            anchors.margins: 16
        }
    }

    onVisibleChanged: {
        if (visible) {
            preparePlacement();
        }

        if (!visible && GlobalStates.settingsWindowVisible) {
            GlobalStates.settingsWindowVisible = false;
        }
    }

    Connections {
        target: GlobalStates
        function onSettingsWindowVisibleChanged() {
            if (GlobalStates.settingsWindowVisible) {
                settingsWindow.preparePlacement();
            }
            settingsWindow.visible = GlobalStates.settingsWindowVisible;
        }
    }
}
