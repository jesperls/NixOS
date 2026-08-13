import QtQuick
import QtQuick.Effects
import Quickshell
import Quickshell.Wayland
import qs.modules.bar
import qs.modules.bar.workspaces
import qs.modules.notch
import qs.modules.dock
import qs.modules.frame
import qs.modules.services
import qs.modules.globals
import qs.modules.components
import qs.config

PanelWindow {
    id: unifiedPanel

    required property ShellScreen targetScreen
    screen: targetScreen

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }

    color: "transparent"

    WlrLayershell.keyboardFocus: {
        if (notchContent.screenNotchOpen) {
            return WlrKeyboardFocus.Exclusive;
        }
        return WlrKeyboardFocus.None;
    }
    WlrLayershell.namespace: "pangu"
    WlrLayershell.layer: WlrLayer.Overlay
    exclusionMode: ExclusionMode.Ignore

    readonly property bool needsFullScreenInput: notchContent.screenNotchOpen || FocusGrabManager.hasActiveGrab

    readonly property bool barEnabled: {
        if (!Config.barReady) return false;
        return Config.enabledForScreen(Config.bar.screenList, targetScreen.name);
    }

    readonly property bool dockEnabled: {
        if (!Config.dockReady || !Config.dockPanelEnabled) return false;
        return Config.enabledForScreen(Config.dock.screenList, targetScreen.name);
    }

    readonly property alias barPosition: barContent.barPosition
    readonly property alias barPinned: barContent.pinned
    readonly property alias barHoverActive: barContent.hoverActive
    readonly property bool barReveal: barEnabled && barContent.reveal
    readonly property alias barTargetWidth: barContent.barTargetWidth
    readonly property alias barTargetHeight: barContent.barTargetHeight
    readonly property alias barOuterMargin: barContent.baseOuterMargin

    readonly property alias dockPosition: dockContent.position
    readonly property alias dockPinned: dockContent.pinned
    readonly property bool dockReveal: dockEnabled && dockContent.reveal
    readonly property int dockHeight: dockContent.dockSize + dockContent.totalMargin

    readonly property alias notchHoverActive: notchContent.hoverActive
    readonly property alias notchOpen: notchContent.screenNotchOpen
    readonly property alias notchReveal: notchContent.reveal

    readonly property alias pinned: barContent.pinned
    readonly property bool reveal: barEnabled ? barContent.reveal : false
    readonly property alias hoverActive: barContent.hoverActive

    readonly property var compositorMonitor: Compositor.monitorFor(targetScreen)
    readonly property bool hasFullscreenWindow: {
        if (!compositorMonitor || !compositorMonitor.activeWorkspace)
            return false;

        const activeWorkspaceId = compositorMonitor.activeWorkspace.id;
        const monId = compositorMonitor.id;

        const toplevel = ToplevelManager.activeToplevel;
        if (toplevel && toplevel.fullscreen && Compositor.focusedMonitor && Compositor.focusedMonitor.id === monId) {
            return true;
        }

        const wins = CompositorData.windowList;
        for (let i = 0; i < wins.length; i++) {
            if (wins[i].monitor === monId && wins[i].fullscreen && wins[i].workspace.id === activeWorkspaceId) {
                return true;
            }
        }
        return false;
    }

    readonly property bool keepBarShadow: Config.bar.keepBarShadow ?? false
    readonly property bool keepBarBorder: Config.bar.keepBarBorder ?? false
    readonly property bool containBar: Config.bar.containBar && (Config.bar.frameEnabled ?? false)

    Component.onCompleted: {
        Visibilities.registerBarPanel(screen.name, unifiedPanel);
        Visibilities.registerNotchPanel(screen.name, unifiedPanel);
        Visibilities.registerDockPanel(screen.name, dockContent);
        Visibilities.registerNotch(screen.name, notchContent.notchContainerRef);
    }

    Component.onDestruction: {
        Visibilities.unregisterBarPanel(screen.name);
        Visibilities.unregisterNotchPanel(screen.name);
        Visibilities.unregisterDockPanel(screen.name);
        Visibilities.unregisterNotch(screen.name);
    }

    Item {
        id: fullScreenMask
        anchors.fill: parent
    }

    mask: Region {
        item: unifiedPanel.needsFullScreenInput ? fullScreenMask : null
        regions: [
            Region {
                item: barContent.visible ? barContent.barHitbox : null
            },
            Region {
                item: (barContent.visible && barContent.splitActive) ? barContent.barHitboxRight : null
            },
            Region {
                item: notchContent.notchHitbox
            },
            Region {
                item: dockContent.visible ? dockContent.dockHitbox : null
            }
        ]
    }

    FocusGrab {
        id: focusGrab
        windows: [unifiedPanel]
        active: notchContent.screenNotchOpen

        onCleared: {
            Visibilities.setActiveModule("");
        }
    }

    MouseArea {
        id: backdropArea
        anchors.fill: parent
        visible: unifiedPanel.needsFullScreenInput
        z: -1

        onClicked: {
            FocusGrabManager.clearTopGrab();
        }
    }

    Item {
        id: visualContent
        anchors.fill: parent

        layer.enabled: true
        layer.effect: Shadow {}

        ScreenFrameContent {
            id: frameContent
            anchors.fill: parent
            targetScreen: unifiedPanel.targetScreen
            hasFullscreenWindow: unifiedPanel.hasFullscreenWindow
            z: 1
        }

        BarContent {
            id: barContent
            anchors.fill: parent
            screen: unifiedPanel.targetScreen
            z: 2
            visible: unifiedPanel.barEnabled
        }

        DockContent {
            id: dockContent
            anchors.fill: parent
            screen: unifiedPanel.targetScreen
            z: 3
            visible: unifiedPanel.dockEnabled
        }

        NotchContent {
            id: notchContent
            anchors.fill: parent
            screen: unifiedPanel.targetScreen
            z: 4
        }

    }
}
