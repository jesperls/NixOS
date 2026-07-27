import QtQuick
import qs.modules.components
import qs.modules.services
import qs.config

Item {
    implicitWidth: powerMenu.implicitWidth
    implicitHeight: powerMenu.implicitHeight

    Behavior on implicitWidth {
        enabled: Config.animDuration > 0
        NumberAnimation {
            duration: Config.animDuration
            easing.type: Easing.OutQuart
        }
    }

    Behavior on implicitHeight {
        enabled: Config.animDuration > 0
        NumberAnimation {
            duration: Config.animDuration
            easing.type: Easing.OutQuart
        }
    }

    PowerMenu {
        id: powerMenu
        anchors.fill: parent
        
        onItemSelected: {
            Visibilities.setActiveModule("")
        }
    }
    
    onVisibleChanged: {
        if (visible) {
            Qt.callLater(() => {
                powerMenu.forceActiveFocus();
            });
        }
    }
    
    Component.onCompleted: {
        if (visible) {
            Qt.callLater(() => {
                powerMenu.forceActiveFocus();
            });
        }
    }
}
