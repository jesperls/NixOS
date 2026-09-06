pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs.modules.theme
import qs.modules.components
import qs.modules.services
import qs.modules.globals
import qs.config

Item {
    id: root

    property int maxContentWidth: 480
    readonly property int contentWidth: Math.min(width, maxContentWidth)
    readonly property real sideMargin: (width - contentWidth) / 2

    readonly property var colorNames: Colors.availableColorNames

    property bool colorPickerActive: false
    property var colorPickerColorNames: []
    property string colorPickerCurrentColor: ""
    property string colorPickerDialogTitle: ""
    property var colorPickerCallback: null

    function openColorPicker(colorNames, currentColor, dialogTitle, callback) {
        colorPickerColorNames = colorNames;
        colorPickerCurrentColor = currentColor;
        colorPickerDialogTitle = dialogTitle;
        colorPickerCallback = callback;
        colorPickerActive = true;
    }

    function closeColorPicker() {
        colorPickerActive = false;
        colorPickerCallback = null;
    }

    function handleColorSelected(color) {
        if (colorPickerCallback) {
            colorPickerCallback(color);
        }
        colorPickerCurrentColor = color;
    }

    Process {
        id: launcherIconPicker
        running: false
        command: ["zenity", "--file-selection", "--title=Select Launcher Icon", "--file-filter=Images | *.png *.jpg *.jpeg *.svg *.gif *.webp"]

        stdout: StdioCollector {
            onStreamFinished: {
                const path = text.trim();
                if (path) {
                    GlobalStates.markShellChanged();
                    Config.bar.launcherIcon = path;
                }
            }
        }
    }

    property string currentSection: ""

    component SectionButton: StyledRect {
        id: sectionBtn
        required property string text
        required property string sectionId

        property bool isHovered: false

        variant: isHovered ? "focus" : "pane"
        Layout.fillWidth: true
        Layout.preferredHeight: 56
        radius: Styling.radius(0)

        RowLayout {
            anchors.fill: parent
            anchors.margins: 16
            spacing: 16

            Text {
                text: sectionBtn.text
                font.family: Config.theme.font
                font.pixelSize: Styling.fontSize(0)
                font.bold: true
                color: Colors.overBackground
                Layout.fillWidth: true
            }

            Text {
                text: Icons.caretRight
                font.family: Icons.font
                font.pixelSize: 20
                color: Colors.overSurfaceVariant
            }
        }

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onEntered: sectionBtn.isHovered = true
            onExited: sectionBtn.isHovered = false
            onClicked: root.currentSection = sectionBtn.sectionId
        }
    }

    component ActionButton: StyledRect {
        id: actionBtn
        required property string text
        property string icon: ""
        signal clicked

        property bool isHovered: false

        variant: isHovered ? "focus" : "pane"
        Layout.fillWidth: true
        Layout.preferredHeight: 56
        radius: Styling.radius(0)

        RowLayout {
            anchors.fill: parent
            anchors.margins: 16
            spacing: 16

            Text {
                text: actionBtn.icon
                font.family: Icons.font
                font.pixelSize: 20
                color: Colors.overSurfaceVariant
                visible: actionBtn.icon !== ""
            }

            Text {
                text: actionBtn.text
                font.family: Config.theme.font
                font.pixelSize: Styling.fontSize(0)
                font.bold: true
                color: Colors.overBackground
                Layout.fillWidth: true
            }

            Text {
                text: Icons.arrowSquareOut
                font.family: Icons.font
                font.pixelSize: 18
                color: Colors.overSurfaceVariant
            }
        }

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onEntered: actionBtn.isHovered = true
            onExited: actionBtn.isHovered = false
            onClicked: actionBtn.clicked()
        }
    }

    component ToggleRow: RowLayout {
        id: toggleRowRoot
        property string label: ""
        property bool checked: false
        signal toggled(bool value)

        property bool _updating: false

        onCheckedChanged: {
            if (!_updating && toggleSwitch.checked !== checked) {
                _updating = true;
                toggleSwitch.checked = checked;
                _updating = false;
            }
        }

        Layout.fillWidth: true
        spacing: 8

        Text {
            text: toggleRowRoot.label
            font.family: Config.theme.font
            font.pixelSize: Styling.fontSize(0)
            color: Colors.overBackground
            Layout.fillWidth: true
        }

        Switch {
            id: toggleSwitch
            checked: toggleRowRoot.checked

            onCheckedChanged: {
                if (!toggleRowRoot._updating && checked !== toggleRowRoot.checked) {
                    toggleRowRoot.toggled(checked);
                }
            }

            indicator: Rectangle {
                implicitWidth: 40
                implicitHeight: 20
                x: toggleSwitch.leftPadding
                y: parent.height / 2 - height / 2
                radius: height / 2
                color: toggleSwitch.checked ? Styling.srItem("overprimary") : Colors.surfaceBright
                border.color: toggleSwitch.checked ? Styling.srItem("overprimary") : Colors.outline

                Behavior on color {
                    enabled: Config.animDuration > 0
                    ColorAnimation {
                        duration: Config.animDuration / 2
                    }
                }

                Rectangle {
                    x: toggleSwitch.checked ? parent.width - width - 2 : 2
                    y: 2
                    width: parent.height - 4
                    height: width
                    radius: width / 2
                    color: toggleSwitch.checked ? Colors.background : Colors.overSurfaceVariant

                    Behavior on x {
                        enabled: Config.animDuration > 0
                        NumberAnimation {
                            duration: Config.animDuration / 2
                            easing.type: Easing.OutCubic
                        }
                    }
                }
            }
            background: null
        }
    }

    component NumberInputRow: RowLayout {
        id: numberInputRowRoot
        property string label: ""
        property int value: 0
        property int minValue: 0
        property int maxValue: 100
        property string suffix: ""
        signal valueEdited(int newValue)

        Layout.fillWidth: true
        spacing: 8

        Text {
            text: numberInputRowRoot.label
            font.family: Config.theme.font
            font.pixelSize: Styling.fontSize(0)
            color: Colors.overBackground
            Layout.fillWidth: true
        }

        StyledRect {
            id: inputBackground
            variant: "common"
            Layout.preferredWidth: 60
            Layout.preferredHeight: 32
            radius: Styling.radius(-2)


            Rectangle {
                id: rejectOverlay
                anchors.fill: parent
                radius: inputBackground.radius
                color: Colors.error
                opacity: 0
            }

            SequentialAnimation {
                id: rejectFlash
                loops: 2
                NumberAnimation {
                    target: rejectOverlay
                    property: "opacity"
                    to: 0.4
                    duration: 90
                }
                NumberAnimation {
                    target: rejectOverlay
                    property: "opacity"
                    to: 0
                    duration: 140
                }
            }

            TextInput {
                id: numberTextInput
                anchors.fill: parent
                anchors.margins: 8
                font.family: Config.theme.font
                font.pixelSize: Styling.fontSize(0)
                color: Colors.overBackground
                selectByMouse: true
                clip: true
                verticalAlignment: TextInput.AlignVCenter
                horizontalAlignment: TextInput.AlignHCenter
                validator: IntValidator {
                    bottom: numberInputRowRoot.minValue
                    top: numberInputRowRoot.maxValue
                }

                readonly property int configValue: numberInputRowRoot.value
                onConfigValueChanged: {
                    if (!activeFocus && text !== configValue.toString()) {
                        text = configValue.toString();
                    }
                }
                Component.onCompleted: text = configValue.toString()

                Keys.onReturnPressed: event => {
                    if (acceptableInput) {
                        event.accepted = false;
                    } else {
                        rejectFlash.restart();
                    }
                }
                Keys.onEnterPressed: event => {
                    if (acceptableInput) {
                        event.accepted = false;
                    } else {
                        rejectFlash.restart();
                    }
                }
                onActiveFocusChanged: {
                    if (!activeFocus && !acceptableInput) {
                        rejectFlash.restart();
                        text = configValue.toString();
                    }
                }

                onEditingFinished: {
                    let newVal = parseInt(text);
                    if (!isNaN(newVal)) {
                        newVal = Math.max(numberInputRowRoot.minValue, Math.min(numberInputRowRoot.maxValue, newVal));
                        numberInputRowRoot.valueEdited(newVal);
                    }
                }
            }
        }

        Text {
            text: numberInputRowRoot.suffix
            font.family: Config.theme.font
            font.pixelSize: Styling.fontSize(0)
            color: Colors.overSurfaceVariant
            visible: suffix !== ""
        }
    }

    component TextInputRow: RowLayout {
        id: textInputRowRoot
        property string label: ""
        property string value: ""
        property string placeholder: ""
        property string actionText: ""
        signal valueEdited(string newValue)
        signal actionClicked()

        Layout.fillWidth: true
        spacing: 8

        Text {
            text: textInputRowRoot.label
            font.family: Config.theme.font
            font.pixelSize: Styling.fontSize(0)
            color: Colors.overBackground
            Layout.preferredWidth: 100
        }

        StyledRect {
            variant: "common"
            Layout.fillWidth: true
            Layout.preferredHeight: 32
            radius: Styling.radius(-2)

            TextInput {
                id: textInputField
                anchors.fill: parent
                anchors.margins: 8
                font.family: Config.theme.font
                font.pixelSize: Styling.fontSize(0)
                color: Colors.overBackground
                selectByMouse: true
                clip: true
                verticalAlignment: TextInput.AlignVCenter

                readonly property string configValue: textInputRowRoot.value
                onConfigValueChanged: {
                    if (!activeFocus && text !== configValue) {
                        text = configValue;
                    }
                }
                Component.onCompleted: text = configValue

                Text {
                    anchors.fill: parent
                    verticalAlignment: Text.AlignVCenter
                    text: textInputRowRoot.placeholder
                    font.family: Config.theme.font
                    font.pixelSize: Styling.fontSize(0)
                    color: Colors.overSurfaceVariant
                    visible: textInputField.text === ""
                }

                onEditingFinished: {
                    textInputRowRoot.valueEdited(text);
                }
            }
        }

        StyledRect {
            id: textActionButton
            variant: textInputRowRoot.actionText === "" ? "common" : "primary"
            Layout.preferredWidth: actionLabel.implicitWidth + 20
            Layout.preferredHeight: 32
            radius: Styling.radius(-2)
            visible: textInputRowRoot.actionText !== ""

            Text {
                id: actionLabel
                anchors.centerIn: parent
                text: textInputRowRoot.actionText
                font.family: Config.theme.font
                font.pixelSize: Styling.fontSize(0)
                font.bold: true
                color: textActionButton.item
            }

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: textInputRowRoot.actionClicked()
            }
        }
    }

    component SelectorRow: ColumnLayout {
        id: selectorRowRoot
        property string label: ""
        property var options: []  // Array of { label: "...", value: "...", icon: "..." (optional) }
        property string value: ""
        signal valueSelected(string newValue)

        function getIndexFromValue(val: string): int {
            for (let i = 0; i < options.length; i++) {
                if (options[i].value === val)
                    return i;
            }
            return 0;
        }

        Layout.fillWidth: true
        spacing: 4

        Text {
            text: selectorRowRoot.label
            font.family: Config.theme.font
            font.pixelSize: Styling.fontSize(-1)
            font.weight: Font.Medium
            color: Colors.overSurfaceVariant
            visible: selectorRowRoot.label !== ""
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 4

            Repeater {
                model: selectorRowRoot.options

                delegate: StyledRect {
                    id: optionButton
                    required property var modelData
                    required property int index

                    readonly property bool isSelected: selectorRowRoot.getIndexFromValue(selectorRowRoot.value) === index
                    property bool isHovered: false

                    variant: isSelected ? "primary" : (isHovered ? "focus" : "common")
                    enableShadow: true
                    Layout.fillWidth: true
                    height: 36
                    radius: isSelected ? Styling.radius(0) / 2 : Styling.radius(0)

                    Text {
                        id: optionIcon
                        anchors.left: parent.left
                        anchors.leftMargin: 12
                        anchors.verticalCenter: parent.verticalCenter
                        text: optionButton.modelData.icon ?? ""
                        font.family: Icons.font
                        font.pixelSize: 14
                        color: optionButton.item
                        visible: (optionButton.modelData.icon ?? "") !== ""
                    }

                    Text {
                        anchors.centerIn: parent
                        text: optionButton.modelData.label
                        font.family: Config.theme.font
                        font.pixelSize: Styling.fontSize(0)
                        font.bold: true
                        color: optionButton.item
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor

                        onEntered: optionButton.isHovered = true
                        onExited: optionButton.isHovered = false

                        onClicked: selectorRowRoot.valueSelected(optionButton.modelData.value)
                    }
                }
            }
        }
    }

    component ScreenListRow: ColumnLayout {
        id: screenListRowRoot
        property string label: "Screens"
        property var selectedScreens: []  // Array of screen names
        signal screensChanged(var newList)

        Layout.fillWidth: true
        spacing: 4

        Text {
            text: screenListRowRoot.label
            font.family: Config.theme.font
            font.pixelSize: Styling.fontSize(-1)
            font.weight: Font.Medium
            color: Colors.overSurfaceVariant
        }

        Text {
            text: "Empty = all screens"
            font.family: Config.theme.font
            font.pixelSize: Styling.fontSize(-2)
            color: Colors.outline
            Layout.bottomMargin: 4
        }

        Flow {
            Layout.fillWidth: true
            spacing: 4

            Repeater {
                model: Quickshell.screens

                delegate: StyledRect {
                    id: screenButton
                    required property var modelData
                    required property int index

                    readonly property string screenName: modelData.name
                    readonly property bool isSelected: {
                        const list = screenListRowRoot.selectedScreens;
                        return list && list.length > 0 && list.includes(screenName);
                    }
                    property bool isHovered: false

                    variant: isSelected ? "primary" : (isHovered ? "focus" : "common")
                    width: screenLabel.implicitWidth + 24
                    height: 32
                    radius: Styling.radius(-2)

                    Text {
                        id: screenLabel
                        anchors.centerIn: parent
                        text: screenButton.screenName
                        font.family: Config.theme.font
                        font.pixelSize: Styling.fontSize(-1)
                        font.bold: screenButton.isSelected
                        color: screenButton.item
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor

                        onEntered: screenButton.isHovered = true
                        onExited: screenButton.isHovered = false

                        onClicked: {
                            let currentList = screenListRowRoot.selectedScreens ? [...screenListRowRoot.selectedScreens] : [];
                            const idx = currentList.indexOf(screenButton.screenName);
                            if (idx >= 0) {
                                currentList.splice(idx, 1);
                            } else {
                                currentList.push(screenButton.screenName);
                            }
                            screenListRowRoot.screensChanged(currentList);
                        }
                    }
                }
            }
        }
    }

    Flickable {
        id: mainFlickable
        anchors.fill: parent
        contentHeight: mainColumn.implicitHeight
        clip: true
        boundsBehavior: Flickable.StopAtBounds
        interactive: !root.colorPickerActive

        opacity: root.colorPickerActive ? 0 : 1
        transform: Translate {
            x: root.colorPickerActive ? -30 : 0

            Behavior on x {
                enabled: Config.animDuration > 0
                NumberAnimation {
                    duration: Config.animDuration / 2
                    easing.type: Easing.OutQuart
                }
            }
        }

        Behavior on opacity {
            enabled: Config.animDuration > 0
            NumberAnimation {
                duration: Config.animDuration / 2
                easing.type: Easing.OutQuart
            }
        }

        ColumnLayout {
            id: mainColumn
            width: mainFlickable.width
            spacing: 8

            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: titlebar.height

                PanelTitlebar {
                    id: titlebar
                    width: root.contentWidth
                    anchors.horizontalCenter: parent.horizontalCenter
                    title: root.currentSection === "" ? "Shell" : (root.currentSection.charAt(0).toUpperCase() + root.currentSection.slice(1))
                    statusText: GlobalStates.shellHasChanges ? "Unsaved changes" : ""
                    statusColor: Colors.error

                    actions: {
                        let baseActions = [
                            {
                                icon: Icons.arrowCounterClockwise,
                                tooltip: "Discard changes",
                                enabled: GlobalStates.shellHasChanges,
                                onClicked: function () {
                                    GlobalStates.discardShellChanges();
                                }
                            },
                            {
                                icon: Icons.disk,
                                tooltip: "Apply changes",
                                enabled: GlobalStates.shellHasChanges,
                                onClicked: function () {
                                    GlobalStates.applyShellChanges();
                                }
                            }
                        ];

                        if (root.currentSection !== "") {
                            return [
                                {
                                    icon: Icons.arrowLeft,
                                    tooltip: "Back",
                                    onClicked: function () {
                                        root.currentSection = "";
                                    }
                                }
                            ].concat(baseActions);
                        }

                        return baseActions;
                    }
                }
            }

            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: contentColumn.implicitHeight

                ColumnLayout {
                    id: contentColumn
                    width: root.contentWidth
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: 16

                    ColumnLayout {
                        visible: root.currentSection === ""
                        Layout.fillWidth: true
                        spacing: 8

                        SectionButton {
                            text: "Layout Presets"
                            sectionId: "presets"
                        }
                        SectionButton {
                            text: "Bar"
                            sectionId: "bar"
                        }
                        SectionButton {
                            text: "Frame"
                            sectionId: "frame"
                        }
                        SectionButton {
                            text: "Notch"
                            sectionId: "notch"
                        }
                        SectionButton {
                            text: "Workspaces"
                            sectionId: "workspaces"
                        }
                        SectionButton {
                            text: "Overview"
                            sectionId: "overview"
                        }
                        SectionButton {
                            text: "Dashboard"
                            sectionId: "dashboard"
                        }
                        SectionButton {
                            text: "Launcher"
                            sectionId: "launcher"
                        }
                        SectionButton {
                            text: "Dock"
                            sectionId: "dock"
                        }
                        SectionButton {
                            text: "Lockscreen"
                            sectionId: "lockscreen"
                        }
                        SectionButton {
                            text: "OSD"
                            sectionId: "osd"
                        }
                        SectionButton {
                            text: "System"
                            sectionId: "system"
                        }
                        SectionButton {
                            text: "About"
                            sectionId: "about"
                        }
                    }

                    ColumnLayout {
                        id: presetsSection
                        visible: root.currentSection === "presets"
                        property string settingsSection: "presets"
                        Layout.fillWidth: true
                        spacing: 8

                        property bool saveVisible: false
                        property string presetName: ""
                        property string presetDescription: ""
                        property string saveMessage: ""

                        Text {
                            text: "Layout Presets"
                            font.family: Config.theme.font
                            font.pixelSize: Styling.fontSize(-1)
                            font.weight: Font.Medium
                            color: Colors.overSurfaceVariant
                            Layout.bottomMargin: -4
                        }

                        Text {
                            Layout.fillWidth: true
                            text: "Overhaul the shell in one click. Apply a preset to restyle everything, or save your current layout as a new preset."
                            font.family: Config.theme.font
                            font.pixelSize: Styling.fontSize(-1)
                            color: Colors.overSurfaceVariant
                            wrapMode: Text.WordWrap
                        }

                        StyledRect {
                            id: savePresetCard
                            Layout.fillWidth: true
                            Layout.preferredHeight: 44
                            radius: Styling.radius(0)
                            variant: savePresetCard.isHovered ? "focus" : "primary"

                            property bool isHovered: false

                            RowLayout {
                                anchors.fill: parent
                                anchors.margins: 16
                                spacing: 12

                                Text {
                                    text: presetsSection.saveVisible ? Icons.caretUp : Icons.plus
                                    font.family: Icons.font
                                    font.pixelSize: 18
                                    color: savePresetCard.item
                                }

                                Text {
                                    text: "Save current layout"
                                    font.family: Config.theme.font
                                    font.pixelSize: Styling.fontSize(0)
                                    font.bold: true
                                    color: savePresetCard.item
                                }
                            }

                            MouseArea {
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onEntered: savePresetCard.isHovered = true
                                onExited: savePresetCard.isHovered = false
                                onClicked: {
                                    presetsSection.saveVisible = !presetsSection.saveVisible;
                                    presetsSection.saveMessage = "";
                                }
                            }
                        }

                        StyledRect {
                            visible: presetsSection.saveVisible
                            variant: "pane"
                            Layout.fillWidth: true
                            Layout.preferredHeight: saveForm.implicitHeight + 24
                            radius: Styling.radius(0)

                            ColumnLayout {
                                id: saveForm
                                anchors.fill: parent
                                anchors.margins: 16
                                spacing: 8

                                Text {
                                    Layout.fillWidth: true
                                    text: "New preset"
                                    font.family: Config.theme.font
                                    font.pixelSize: Styling.fontSize(-1)
                                    font.weight: Font.Medium
                                    color: Colors.overSurfaceVariant
                                }

                                StyledRect {
                                    variant: "common"
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 32
                                    radius: Styling.radius(-2)

                                    TextInput {
                                        id: presetNameInput
                                        anchors.fill: parent
                                        anchors.margins: 8
                                        font.family: Config.theme.font
                                        font.pixelSize: Styling.fontSize(0)
                                        color: Colors.overBackground
                                        selectByMouse: true
                                        clip: true
                                        verticalAlignment: TextInput.AlignVCenter
                                        text: presetsSection.presetName
                                        onTextChanged: presetsSection.presetName = text

                                        Text {
                                            anchors.fill: parent
                                            verticalAlignment: Text.AlignVCenter
                                            text: "Name"
                                            font: parent.font
                                            color: Colors.overSurfaceVariant
                                            visible: !parent.text && !parent.activeFocus
                                        }
                                    }
                                }

                                StyledRect {
                                    variant: "common"
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 32
                                    radius: Styling.radius(-2)

                                    TextInput {
                                        id: presetDescriptionInput
                                        anchors.fill: parent
                                        anchors.margins: 8
                                        font.family: Config.theme.font
                                        font.pixelSize: Styling.fontSize(0)
                                        color: Colors.overBackground
                                        selectByMouse: true
                                        clip: true
                                        verticalAlignment: TextInput.AlignVCenter
                                        text: presetsSection.presetDescription
                                        onTextChanged: presetsSection.presetDescription = text

                                        Text {
                                            anchors.fill: parent
                                            verticalAlignment: Text.AlignVCenter
                                            text: "Description (optional)"
                                            font: parent.font
                                            color: Colors.overSurfaceVariant
                                            visible: !parent.text && !parent.activeFocus
                                        }
                                    }
                                }

                                RowLayout {
                                    Layout.fillWidth: true
                                    spacing: 8

                                    StyledRect {
                                        id: savePresetButton
                                        variant: isHovered ? "primaryfocus" : "primary"
                                        Layout.fillWidth: true
                                        Layout.preferredHeight: 36
                                        radius: Styling.radius(0)

                                        property bool isHovered: false

                                        Text {
                                            anchors.centerIn: parent
                                            text: "Save"
                                            font.family: Config.theme.font
                                            font.pixelSize: Styling.fontSize(0)
                                            font.bold: true
                                            color: savePresetButton.item
                                        }

                                        MouseArea {
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            cursorShape: Qt.PointingHandCursor
                                            onEntered: savePresetButton.isHovered = true
                                            onExited: savePresetButton.isHovered = false
                                            onClicked: {
                                                const id = LayoutPresets.saveCurrent(presetsSection.presetName, presetsSection.presetDescription);
                                                if (id) {
                                                    const savedName = presetsSection.presetName;
                                                    presetsSection.presetName = "";
                                                    presetsSection.presetDescription = "";
                                                    presetsSection.saveMessage = "Saved \"" + savedName + "\"";
                                                    presetsSection.saveVisible = false;
                                                }
                                            }
                                        }
                                    }

                                    StyledRect {
                                        id: cancelPresetButton
                                        variant: isHovered ? "focus" : "common"
                                        Layout.fillWidth: true
                                        Layout.preferredHeight: 36
                                        radius: Styling.radius(0)

                                        property bool isHovered: false

                                        Text {
                                            anchors.centerIn: parent
                                            text: "Cancel"
                                            font.family: Config.theme.font
                                            font.pixelSize: Styling.fontSize(0)
                                            color: cancelPresetButton.item
                                        }

                                        MouseArea {
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            cursorShape: Qt.PointingHandCursor
                                            onEntered: cancelPresetButton.isHovered = true
                                            onExited: cancelPresetButton.isHovered = false
                                            onClicked: presetsSection.saveVisible = false
                                        }
                                    }
                                }
                            }
                        }

                        Text {
                            Layout.fillWidth: true
                            text: presetsSection.saveMessage
                            font.family: Config.theme.font
                            font.pixelSize: Styling.fontSize(-1)
                            color: Colors.success
                            visible: presetsSection.saveMessage !== ""
                        }

                        Repeater {
                            model: LayoutPresets.presets

                            delegate: StyledRect {
                                id: presetCard
                                required property var modelData
                                required property int index

                                property bool isHovered: false
                                readonly property bool isUserPreset: !LayoutPresets.isBuiltin(presetCard.modelData.id)

                                variant: isHovered ? "focus" : "pane"
                                Layout.fillWidth: true
                                Layout.preferredHeight: presetContent.implicitHeight + 24
                                radius: Styling.radius(0)

                                MouseArea {
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onEntered: presetCard.isHovered = true
                                    onExited: presetCard.isHovered = false
                                    onClicked: LayoutPresets.apply(presetCard.modelData.id)
                                }

                                RowLayout {
                                    id: presetContent
                                    anchors.fill: parent
                                    anchors.margins: 16
                                    spacing: 16

                                    Text {
                                        text: presetCard.modelData.icon
                                        font.family: Icons.font
                                        font.pixelSize: 24
                                        color: Styling.srItem("overprimary")
                                        Layout.alignment: Qt.AlignVCenter
                                    }

                                    ColumnLayout {
                                        Layout.fillWidth: true
                                        spacing: 2

                                        RowLayout {
                                            Layout.fillWidth: true
                                            spacing: 8

                                            Text {
                                                text: presetCard.modelData.name
                                                font.family: Config.theme.font
                                                font.pixelSize: Styling.fontSize(0)
                                                font.bold: true
                                                color: Colors.overBackground
                                            }

                                            Text {
                                                text: "User"
                                                font.family: Config.theme.font
                                                font.pixelSize: Styling.fontSize(-3)
                                                color: Styling.srItem("overprimary")
                                                visible: presetCard.isUserPreset
                                            }
                                        }

                                        Text {
                                            Layout.fillWidth: true
                                            text: presetCard.modelData.description
                                            font.family: Config.theme.font
                                            font.pixelSize: Styling.fontSize(-1)
                                            color: Colors.overSurfaceVariant
                                            wrapMode: Text.WordWrap
                                        }
                                    }

                                    StyledRect {
                                        id: deleteButton
                                        visible: presetCard.isUserPreset
                                        Layout.alignment: Qt.AlignVCenter
                                        Layout.preferredWidth: 32
                                        Layout.preferredHeight: 32
                                        radius: Styling.radius(-4)
                                        variant: deleteButton.isHovered ? "errorfocus" : "common"

                                        property bool isHovered: false

                                        Text {
                                            anchors.centerIn: parent
                                            text: Icons.trash
                                            font.family: Icons.font
                                            font.pixelSize: 16
                                            color: deleteButton.item
                                        }

                                        MouseArea {
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            cursorShape: Qt.PointingHandCursor
                                            onEntered: deleteButton.isHovered = true
                                            onExited: deleteButton.isHovered = false
                                            onClicked: LayoutPresets.deletePreset(presetCard.modelData.id)
                                        }
                                    }
                                }
                            }
                        }
                    }

                    ColumnLayout {
                        visible: root.currentSection === "bar"
                        property string settingsSection: "bar"
                        Layout.fillWidth: true
                        spacing: 8

                        Text {
                            text: "Bar"
                            font.family: Config.theme.font
                            font.pixelSize: Styling.fontSize(-1)
                            font.weight: Font.Medium
                            color: Colors.overSurfaceVariant
                            Layout.bottomMargin: -4
                        }

                        SelectorRow {
                            label: ""
                            options: [
                                {
                                    label: "Top",
                                    value: "top",
                                    icon: Icons.arrowUp
                                },
                                {
                                    label: "Bottom",
                                    value: "bottom",
                                    icon: Icons.arrowDown
                                },
                                {
                                    label: "Left",
                                    value: "left",
                                    icon: Icons.arrowLeft
                                },
                                {
                                    label: "Right",
                                    value: "right",
                                    icon: Icons.arrowRight
                                }
                            ]
                            value: Config.bar.position ?? "top"
                            onValueSelected: newValue => {
                                if (newValue !== Config.bar.position) {
                                    GlobalStates.markShellChanged();
                                    Config.bar.position = newValue;
                                }
                            }
                        }

                        NumberInputRow {
                            label: "Bar Height (0 = auto)"
                            value: Config.bar.height ?? 0
                            minValue: 0
                            maxValue: 128
                            suffix: "px"
                            onValueEdited: newValue => {
                                if (newValue !== Config.bar.height) {
                                    GlobalStates.markShellChanged();
                                    Config.bar.height = newValue;
                                }
                            }
                        }

                        SelectorRow {
                            label: "Bar Style"
                            options: [
                                {
                                    label: "Floating",
                                    value: "floating"
                                },
                                {
                                    label: "Docked",
                                    value: "docked"
                                }
                            ]
                            value: Config.bar.style ?? "floating"
                            onValueSelected: newValue => {
                                if (newValue !== Config.bar.style) {
                                    GlobalStates.markShellChanged();
                                    Config.bar.style = newValue;
                                }
                            }
                        }

                        NumberInputRow {
                            label: "Bar Margin"
                            value: Config.bar.margin ?? 4
                            minValue: 0
                            maxValue: 64
                            suffix: "px"
                            onValueEdited: newValue => {
                                if (newValue !== Config.bar.margin) {
                                    GlobalStates.markShellChanged();
                                    Config.bar.margin = newValue;
                                }
                            }
                        }

                        NumberInputRow {
                            label: "Bar Spacing"
                            value: Config.bar.spacing ?? 4
                            minValue: 0
                            maxValue: 32
                            suffix: "px"
                            onValueEdited: newValue => {
                                if (newValue !== Config.bar.spacing) {
                                    GlobalStates.markShellChanged();
                                    Config.bar.spacing = newValue;
                                }
                            }
                        }

                        NumberInputRow {
                            label: "Bar Padding"
                            value: Config.bar.padding ?? 4
                            minValue: 0
                            maxValue: 32
                            suffix: "px"
                            onValueEdited: newValue => {
                                if (newValue !== Config.bar.padding) {
                                    GlobalStates.markShellChanged();
                                    Config.bar.padding = newValue;
                                }
                            }
                        }

                        TextInputRow {
                            label: "Launcher Icon"
                            value: Config.bar.launcherIcon ?? ""
                            placeholder: "Symbol, icon name, or path..."
                            actionText: "Browse"
                            onValueEdited: newValue => {
                                if (newValue !== Config.bar.launcherIcon) {
                                    GlobalStates.markShellChanged();
                                    Config.bar.launcherIcon = newValue;
                                }
                            }
                            onActionClicked: launcherIconPicker.running = true
                        }

                        ToggleRow {
                            label: "Launcher Icon Tint"
                            checked: Config.bar.launcherIconTint ?? true
                            onToggled: value => {
                                if (value !== Config.bar.launcherIconTint) {
                                    GlobalStates.markShellChanged();
                                    Config.bar.launcherIconTint = value;
                                }
                            }
                        }

                        ToggleRow {
                            label: "Launcher Icon Full Tint"
                            checked: Config.bar.launcherIconFullTint ?? true
                            onToggled: value => {
                                if (value !== Config.bar.launcherIconFullTint) {
                                    GlobalStates.markShellChanged();
                                    Config.bar.launcherIconFullTint = value;
                                }
                            }
                        }

                        NumberInputRow {
                            label: "Launcher Icon Size"
                            value: Config.bar.launcherIconSize ?? 24
                            minValue: 12
                            maxValue: 64
                            suffix: "px"
                            onValueEdited: newValue => {
                                if (newValue !== Config.bar.launcherIconSize) {
                                    GlobalStates.markShellChanged();
                                    Config.bar.launcherIconSize = newValue;
                                }
                            }
                        }

                        SelectorRow {
                            label: "Pill Style"
                            options: [
                                {
                                    label: "Default",
                                    value: "default"
                                },
                                {
                                    label: "Squished",
                                    value: "squished"
                                }
                            ]
                            value: Config.bar.pillStyle ?? "default"
                            onValueSelected: newValue => {
                                if (newValue !== Config.bar.pillStyle) {
                                    GlobalStates.markShellChanged();
                                    Config.bar.pillStyle = newValue;
                                }
                            }
                        }

                        SelectorRow {
                            label: "Clock Position"
                            options: [
                                {
                                    label: "Right",
                                    value: "right",
                                    icon: Icons.arrowRight
                                },
                                {
                                    label: "Center",
                                    value: "center",
                                    icon: Icons.alignCenter
                                }
                            ]
                            value: Config.bar.clockPosition ?? "right"
                            onValueSelected: newValue => {
                                if (newValue !== Config.bar.clockPosition) {
                                    GlobalStates.markShellChanged();
                                    Config.bar.clockPosition = newValue;
                                }
                            }
                        }

                        SelectorRow {
                            label: "Launcher Position"
                            options: [
                                {
                                    label: "Start",
                                    value: "start",
                                    icon: Icons.alignLeft
                                },
                                {
                                    label: "End",
                                    value: "end",
                                    icon: Icons.alignRight
                                }
                            ]
                            value: Config.bar.launcherPosition ?? "start"
                            onValueSelected: newValue => {
                                if (newValue !== Config.bar.launcherPosition) {
                                    GlobalStates.markShellChanged();
                                    Config.bar.launcherPosition = newValue;
                                }
                            }
                        }

                        ToggleRow {
                            label: "Flat Buttons"
                            checked: Config.bar.flatButtons ?? false
                            onToggled: value => {
                                if (value !== Config.bar.flatButtons) {
                                    GlobalStates.markShellChanged();
                                    Config.bar.flatButtons = value;
                                }
                            }
                        }

                        ToggleRow {
                            label: "Show Workspaces"
                            checked: Config.bar.showWorkspaces ?? true
                            onToggled: value => {
                                if (value !== Config.bar.showWorkspaces) {
                                    GlobalStates.markShellChanged();
                                    Config.bar.showWorkspaces = value;
                                }
                            }
                        }

                        ToggleRow {
                            label: "Use 12h Format"
                            checked: Config.bar.use12hFormat ?? false
                            onToggled: value => {
                                if (value !== Config.bar.use12hFormat) {
                                    GlobalStates.markShellChanged();
                                    Config.bar.use12hFormat = value;
                                }
                            }
                        }

                        ToggleRow {
                            label: "Show Seconds"
                            checked: Config.bar.showSeconds ?? false
                            onToggled: value => {
                                if (value !== Config.bar.showSeconds) {
                                    GlobalStates.markShellChanged();
                                    Config.bar.showSeconds = value;
                                }
                            }
                        }

                        ToggleRow {
                            label: "Show Date"
                            checked: Config.bar.showDate ?? false
                            onToggled: value => {
                                if (value !== Config.bar.showDate) {
                                    GlobalStates.markShellChanged();
                                    Config.bar.showDate = value;
                                }
                            }
                        }

                        ToggleRow {
                            label: "Enable Firefox Player"
                            checked: Config.bar.enableFirefoxPlayer ?? false
                            onToggled: value => {
                                if (value !== Config.bar.enableFirefoxPlayer) {
                                    GlobalStates.markShellChanged();
                                    Config.bar.enableFirefoxPlayer = value;
                                }
                            }
                        }

                        ToggleRow {
                            label: "Split on Centered Layout"
                            checked: Config.bar.splitOnCenteredLayout ?? true
                            onToggled: value => {
                                if (value !== Config.bar.splitOnCenteredLayout) {
                                    GlobalStates.markShellChanged();
                                    Config.bar.splitOnCenteredLayout = value;
                                }
                            }
                        }

                        NumberInputRow {
                            label: "Split Gap Padding"
                            value: Config.bar.splitGapPadding ?? 4
                            minValue: 0
                            maxValue: 64
                            suffix: "px"
                            onValueEdited: newValue => {
                                if (newValue !== Config.bar.splitGapPadding) {
                                    GlobalStates.markShellChanged();
                                    Config.bar.splitGapPadding = newValue;
                                }
                            }
                        }

                        Separator {
                            Layout.fillWidth: true
                        }

                        Text {
                            text: "Auto-hide"
                            font.family: Config.theme.font
                            font.pixelSize: Styling.fontSize(-1)
                            font.weight: Font.Medium
                            color: Colors.overSurfaceVariant
                            Layout.bottomMargin: -4
                        }

                        ToggleRow {
                            label: "Pinned on Startup"
                            checked: Config.bar.pinnedOnStartup ?? true
                            onToggled: value => {
                                if (value !== Config.bar.pinnedOnStartup) {
                                    GlobalStates.markShellChanged();
                                    Config.bar.pinnedOnStartup = value;
                                }
                            }
                        }

                        ToggleRow {
                            label: "Hover to Reveal"
                            checked: Config.bar.hoverToReveal ?? true
                            onToggled: value => {
                                if (value !== Config.bar.hoverToReveal) {
                                    GlobalStates.markShellChanged();
                                    Config.bar.hoverToReveal = value;
                                }
                            }
                        }

                        NumberInputRow {
                            label: "Hover Region Height"
                            value: Config.bar.hoverRegionHeight ?? 8
                            minValue: 0
                            maxValue: 32
                            suffix: "px"
                            onValueEdited: newValue => {
                                if (newValue !== Config.bar.hoverRegionHeight) {
                                    GlobalStates.markShellChanged();
                                    Config.bar.hoverRegionHeight = newValue;
                                }
                            }
                        }

                        NumberInputRow {
                            label: "Hide Delay"
                            value: Config.bar.hideDelay ?? 1000
                            minValue: 0
                            maxValue: 5000
                            suffix: "ms"
                            onValueEdited: newValue => {
                                if (newValue !== Config.bar.hideDelay) {
                                    GlobalStates.markShellChanged();
                                    Config.bar.hideDelay = newValue;
                                }
                            }
                        }

                        ToggleRow {
                            label: "Show Pin Button"
                            checked: Config.bar.showPinButton ?? true
                            onToggled: value => {
                                if (value !== Config.bar.showPinButton) {
                                    GlobalStates.markShellChanged();
                                    Config.bar.showPinButton = value;
                                }
                            }
                        }

                        ToggleRow {
                            label: "Available on Fullscreen"
                            checked: Config.bar.availableOnFullscreen ?? false
                            onToggled: value => {
                                if (value !== Config.bar.availableOnFullscreen) {
                                    GlobalStates.markShellChanged();
                                    Config.bar.availableOnFullscreen = value;
                                }
                            }
                        }

                        ScreenListRow {
                            label: "Screens"
                            selectedScreens: Config.bar.screenList ?? []
                            onScreensChanged: newList => {
                                GlobalStates.markShellChanged();
                                Config.bar.screenList = newList;
                            }
                        }
                    }

                    ColumnLayout {
                        visible: root.currentSection === "frame"
                        property string settingsSection: "frame"
                        Layout.fillWidth: true
                        spacing: 8

                        Text {
                            text: "Frame"
                            font.family: Config.theme.font
                            font.pixelSize: Styling.fontSize(-1)
                            font.weight: Font.Medium
                            color: Colors.overSurfaceVariant
                            Layout.bottomMargin: -4
                        }

                        ToggleRow {
                            label: "Enabled"
                            checked: Config.bar.frameEnabled ?? false
                            onToggled: value => {
                                if (value !== Config.bar.frameEnabled) {
                                    GlobalStates.markShellChanged();
                                    Config.bar.frameEnabled = value;
                                }
                            }
                        }

                        NumberInputRow {
                            label: "Thickness"
                            value: Config.bar.frameThickness ?? 6
                            minValue: 0
                            maxValue: 40
                            suffix: "px"
                            onValueEdited: newValue => {
                                if (newValue !== Config.bar.frameThickness) {
                                    GlobalStates.markShellChanged();
                                    Config.bar.frameThickness = newValue;
                                }
                            }
                        }

                        ToggleRow {
                            label: "Contain Bar"
                            checked: Config.bar.containBar ?? false
                            onToggled: value => {
                                if (value !== Config.bar.containBar) {
                                    GlobalStates.markShellChanged();
                                    Config.bar.containBar = value;
                                }
                            }
                        }

                        ToggleRow {
                            label: "Keep Bar Shadow"
                            checked: Config.bar.keepBarShadow ?? false
                            visible: Config.bar.containBar ?? false
                            onToggled: value => {
                                if (value !== Config.bar.keepBarShadow) {
                                    GlobalStates.markShellChanged();
                                    Config.bar.keepBarShadow = value;
                                }
                            }
                        }

                        ToggleRow {
                            label: "Keep Bar Border"
                            checked: Config.bar.keepBarBorder ?? false
                            visible: Config.bar.containBar ?? false
                            onToggled: value => {
                                if (value !== Config.bar.keepBarBorder) {
                                    GlobalStates.markShellChanged();
                                    Config.bar.keepBarBorder = value;
                                }
                            }
                        }
                    }

                    Separator {
                        Layout.fillWidth: true
                        visible: false
                    }

                    ColumnLayout {
                        visible: root.currentSection === "notch"
                        property string settingsSection: "notch"
                        Layout.fillWidth: true
                        spacing: 8

                        Text {
                            text: "Notch"
                            font.family: Config.theme.font
                            font.pixelSize: Styling.fontSize(-1)
                            font.weight: Font.Medium
                            color: Colors.overSurfaceVariant
                            Layout.bottomMargin: -4
                        }

                        SelectorRow {
                            label: ""
                            options: [
                                {
                                    label: "Top",
                                    value: "top",
                                    icon: Icons.arrowUp
                                },
                                {
                                    label: "Bottom",
                                    value: "bottom",
                                    icon: Icons.arrowDown
                                }
                            ]
                            value: Config.notch.position ?? "top"
                            onValueSelected: newValue => {
                                if (newValue !== Config.notch.position) {
                                    GlobalStates.markShellChanged();
                                    Config.notch.position = newValue;
                                }
                            }
                        }

                        SelectorRow {
                            label: ""
                            options: [
                                {
                                    label: "Default",
                                    value: "default"
                                },
                                {
                                    label: "Island",
                                    value: "island"
                                }
                            ]
                            value: Config.notch.theme ?? "default"
                            onValueSelected: newValue => {
                                if (newValue !== Config.notch.theme) {
                                    GlobalStates.markShellChanged();
                                    Config.notch.theme = newValue;
                                }
                            }
                        }

                        SelectorRow {
                            label: "Split Side"
                            options: [
                                {
                                    label: "Left",
                                    value: "left",
                                    icon: Icons.arrowLeft
                                },
                                {
                                    label: "Right",
                                    value: "right",
                                    icon: Icons.arrowRight
                                }
                            ]
                            value: Config.notch.splitSide ?? "left"
                            onValueSelected: newValue => {
                                if (newValue !== Config.notch.splitSide) {
                                    GlobalStates.markShellChanged();
                                    Config.notch.splitSide = newValue;
                                }
                            }
                        }

                        NumberInputRow {
                            label: "Hover Region Height"
                            value: Config.notch.hoverRegionHeight ?? 8
                            minValue: 0
                            maxValue: 32
                            suffix: "px"
                            onValueEdited: newValue => {
                                if (newValue !== Config.notch.hoverRegionHeight) {
                                    GlobalStates.markShellChanged();
                                    Config.notch.hoverRegionHeight = newValue;
                                }
                            }
                        }

                        NumberInputRow {
                            label: "Hide Delay"
                            value: Config.notch.hideDelay ?? 1000
                            minValue: 0
                            maxValue: 5000
                            suffix: "ms"
                            onValueEdited: newValue => {
                                if (newValue !== Config.notch.hideDelay) {
                                    GlobalStates.markShellChanged();
                                    Config.notch.hideDelay = newValue;
                                }
                            }
                        }

                        NumberInputRow {
                            label: "Hover Expansion Delay"
                            value: Config.notch.hoverExpansionDelay ?? 400
                            minValue: 0
                            maxValue: 5000
                            suffix: "ms"
                            onValueEdited: newValue => {
                                if (newValue !== Config.notch.hoverExpansionDelay) {
                                    GlobalStates.markShellChanged();
                                    Config.notch.hoverExpansionDelay = newValue;
                                }
                            }
                        }

                        ToggleRow {
                            label: "Keep Hidden"
                            checked: Config.notch.keepHidden ?? false
                            onToggled: value => {
                                if (value !== Config.notch.keepHidden) {
                                    GlobalStates.markShellChanged();
                                    Config.notch.keepHidden = value;
                                }
                            }
                        }

                        ToggleRow {
                            label: "Disable Hover Expansion"
                            checked: Config.notch.disableHoverExpansion ?? false
                            onToggled: value => {
                                if (value !== Config.notch.disableHoverExpansion) {
                                    GlobalStates.markShellChanged();
                                    Config.notch.disableHoverExpansion = value;
                                }
                            }
                        }

                        Separator {
                            Layout.fillWidth: true
                        }

                        Text {
                            text: "Collapsed Content"
                            font.family: Config.theme.font
                            font.pixelSize: Styling.fontSize(-1)
                            font.weight: Font.Medium
                            color: Colors.overSurfaceVariant
                            Layout.bottomMargin: -4
                        }

                        ToggleRow {
                            label: "Show User"
                            checked: Config.notch.showUser ?? true
                            onToggled: value => {
                                if (value !== Config.notch.showUser) {
                                    GlobalStates.markShellChanged();
                                    Config.notch.showUser = value;
                                }
                            }
                        }

                        ToggleRow {
                            label: "Show Media Player"
                            checked: Config.notch.showMedia ?? true
                            onToggled: value => {
                                if (value !== Config.notch.showMedia) {
                                    GlobalStates.markShellChanged();
                                    Config.notch.showMedia = value;
                                }
                            }
                        }

                        ToggleRow {
                            label: "Show Notification Indicator"
                            checked: Config.notch.showNotificationIndicator ?? true
                            onToggled: value => {
                                if (value !== Config.notch.showNotificationIndicator) {
                                    GlobalStates.markShellChanged();
                                    Config.notch.showNotificationIndicator = value;
                                }
                            }
                        }

                        Separator {
                            Layout.fillWidth: true
                        }

                        Text {
                            text: "No Media Display"
                            font.family: Config.theme.font
                            font.pixelSize: Styling.fontSize(-1)
                            font.weight: Font.Medium
                            color: Colors.overSurfaceVariant
                            Layout.bottomMargin: -4
                        }

                        SelectorRow {
                            label: ""
                            options: [
                                {
                                    label: "User@Host",
                                    value: "userHost",
                                    icon: Icons.user
                                },
                                {
                                    label: "Compositor",
                                    value: "compositor",
                                    icon: Icons.compositor
                                },
                                {
                                    label: "Custom",
                                    value: "custom",
                                    icon: Icons.textT
                                }
                            ]
                            value: Config.notch.noMediaDisplay ?? "userHost"
                            onValueSelected: newValue => {
                                if (newValue !== Config.notch.noMediaDisplay) {
                                    GlobalStates.markShellChanged();
                                    Config.notch.noMediaDisplay = newValue;
                                }
                            }
                        }

                        TextInputRow {
                            label: "Custom Text"
                            visible: Config.notch.noMediaDisplay === "custom"
                            value: Config.notch.customText ?? "Pangu"
                            placeholder: "Enter text..."
                            onValueEdited: newValue => {
                                if (newValue !== Config.notch.customText) {
                                    GlobalStates.markShellChanged();
                                    Config.notch.customText = newValue;
                                }
                            }
                        }
                    }

                    Separator {
                        Layout.fillWidth: true
                        visible: false
                    }

                    ColumnLayout {
                        visible: root.currentSection === "workspaces"
                        property string settingsSection: "workspaces"
                        Layout.fillWidth: true
                        spacing: 8

                        Text {
                            text: "Workspaces"
                            font.family: Config.theme.font
                            font.pixelSize: Styling.fontSize(-1)
                            font.weight: Font.Medium
                            color: Colors.overSurfaceVariant
                            Layout.bottomMargin: -4
                        }

                        NumberInputRow {
                            label: "Shown"
                            value: Config.workspaces.shown ?? 10
                            minValue: 1
                            maxValue: 20
                            onValueEdited: newValue => {
                                if (newValue !== Config.workspaces.shown) {
                                    GlobalStates.markShellChanged();
                                    Config.workspaces.shown = newValue;
                                }
                            }
                        }

                        ToggleRow {
                            label: "Show App Icons"
                            checked: Config.workspaces.showAppIcons ?? true
                            onToggled: value => {
                                if (value !== Config.workspaces.showAppIcons) {
                                    GlobalStates.markShellChanged();
                                    Config.workspaces.showAppIcons = value;
                                }
                            }
                        }

                        ToggleRow {
                            label: "Always Show Numbers"
                            checked: Config.workspaces.alwaysShowNumbers ?? false
                            onToggled: value => {
                                if (value !== Config.workspaces.alwaysShowNumbers) {
                                    GlobalStates.markShellChanged();
                                    Config.workspaces.alwaysShowNumbers = value;
                                }
                            }
                        }

                        ToggleRow {
                            label: "Show Numbers"
                            checked: Config.workspaces.showNumbers ?? false
                            onToggled: value => {
                                if (value !== Config.workspaces.showNumbers) {
                                    GlobalStates.markShellChanged();
                                    Config.workspaces.showNumbers = value;
                                }
                            }
                        }

                        ToggleRow {
                            label: "Dynamic"
                            checked: Config.workspaces.dynamic ?? false
                            onToggled: value => {
                                if (value !== Config.workspaces.dynamic) {
                                    GlobalStates.markShellChanged();
                                    Config.workspaces.dynamic = value;
                                }
                            }
                        }
                    }

                    Separator {
                        Layout.fillWidth: true
                        visible: false
                    }

                    ColumnLayout {
                        visible: root.currentSection === "overview"
                        property string settingsSection: "overview"
                        Layout.fillWidth: true
                        spacing: 8

                        Text {
                            text: "Overview"
                            font.family: Config.theme.font
                            font.pixelSize: Styling.fontSize(-1)
                            font.weight: Font.Medium
                            color: Colors.overSurfaceVariant
                            Layout.bottomMargin: -4
                        }

                        ToggleRow {
                            label: "Enabled"
                            checked: Config.overview.enabled ?? true
                            onToggled: value => {
                                if (value !== Config.overview.enabled) {
                                    GlobalStates.markShellChanged();
                                    Config.overview.enabled = value;
                                }
                            }
                        }

                        SelectorRow {
                            label: "Layout"
                            options: [
                                {
                                    label: "Standard",
                                    value: "standard"
                                },
                                {
                                    label: "Scrolling",
                                    value: "scrolling"
                                }
                            ]
                            value: Config.overview.layout ?? "standard"
                            onValueSelected: newValue => {
                                if (newValue !== Config.overview.layout) {
                                    GlobalStates.markShellChanged();
                                    Config.overview.layout = newValue;
                                }
                            }
                        }

                        NumberInputRow {
                            label: "Rows"
                            value: Config.overview.rows ?? 2
                            minValue: 1
                            maxValue: 5
                            onValueEdited: newValue => {
                                if (newValue !== Config.overview.rows) {
                                    GlobalStates.markShellChanged();
                                    Config.overview.rows = newValue;
                                }
                            }
                        }

                        NumberInputRow {
                            label: "Columns"
                            value: Config.overview.columns ?? 5
                            minValue: 1
                            maxValue: 10
                            onValueEdited: newValue => {
                                if (newValue !== Config.overview.columns) {
                                    GlobalStates.markShellChanged();
                                    Config.overview.columns = newValue;
                                }
                            }
                        }

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 8

                            Text {
                                text: "Scale"
                                font.family: Config.theme.font
                                font.pixelSize: Styling.fontSize(0)
                                color: Colors.overBackground
                                Layout.preferredWidth: 100
                            }

                            StyledSlider {
                                id: overviewScaleSlider
                                Layout.fillWidth: true
                                Layout.preferredHeight: 20
                                progressColor: Styling.srItem("overprimary")
                                tooltipText: `${(value * 0.2).toFixed(2)}`
                                scroll: true
                                stepSize: 0.05
                                snapMode: "always"

                                readonly property real configValue: (Config.overview.scale ?? 0.1) / 0.2

                                onConfigValueChanged: {
                                    if (Math.abs(value - configValue) > 0.001) {
                                        value = configValue;
                                    }
                                }

                                Component.onCompleted: value = configValue

                                onValueChanged: {
                                    let newScale = Math.round(value * 0.2 * 100) / 100;  // Round to 2 decimals
                                    if (Math.abs(newScale - (Config.overview.scale ?? 0.1)) > 0.001) {
                                        GlobalStates.markShellChanged();
                                        Config.overview.scale = newScale;
                                    }
                                }
                            }

                            Text {
                                text: ((Config.overview.scale ?? 0.1)).toFixed(2)
                                font.family: Config.theme.font
                                font.pixelSize: Styling.fontSize(0)
                                color: Colors.overBackground
                                horizontalAlignment: Text.AlignRight
                                Layout.preferredWidth: 40
                            }
                        }

                        NumberInputRow {
                            label: "Workspace Spacing"
                            value: Config.overview.workspaceSpacing ?? 4
                            minValue: 0
                            maxValue: 20
                            suffix: "px"
                            onValueEdited: newValue => {
                                if (newValue !== Config.overview.workspaceSpacing) {
                                    GlobalStates.markShellChanged();
                                    Config.overview.workspaceSpacing = newValue;
                                }
                            }
                        }
                    }

                    ColumnLayout {
                        visible: root.currentSection === "dashboard"
                        property string settingsSection: "dashboard"
                        Layout.fillWidth: true
                        spacing: 8

                        Text {
                            text: "Dashboard"
                            font.family: Config.theme.font
                            font.pixelSize: Styling.fontSize(-1)
                            font.weight: Font.Medium
                            color: Colors.overSurfaceVariant
                            Layout.bottomMargin: -4
                        }

                        NumberInputRow {
                            label: "Dashboard Width (0 = auto)"
                            value: Config.dashboard.width ?? 0
                            minValue: 0
                            maxValue: 2000
                            suffix: "px"
                            onValueEdited: newValue => {
                                if (newValue !== Config.dashboard.width) {
                                    GlobalStates.markShellChanged();
                                    Config.dashboard.width = newValue;
                                }
                            }
                        }

                        NumberInputRow {
                            label: "Dashboard Height (0 = auto)"
                            value: Config.dashboard.height ?? 0
                            minValue: 0
                            maxValue: 2000
                            suffix: "px"
                            onValueEdited: newValue => {
                                if (newValue !== Config.dashboard.height) {
                                    GlobalStates.markShellChanged();
                                    Config.dashboard.height = newValue;
                                }
                            }
                        }

                        ToggleRow {
                            label: "Show Tab Rail"
                            checked: Config.dashboard.showTabRail ?? true
                            onToggled: value => {
                                if (value !== Config.dashboard.showTabRail) {
                                    GlobalStates.markShellChanged();
                                    Config.dashboard.showTabRail = value;
                                }
                            }
                        }

                        SelectorRow {
                            label: "Tab Rail Position"
                            options: [
                                {
                                    label: "Left",
                                    value: "left",
                                    icon: Icons.arrowLeft
                                },
                                {
                                    label: "Right",
                                    value: "right",
                                    icon: Icons.arrowRight
                                },
                                {
                                    label: "Top",
                                    value: "top",
                                    icon: Icons.arrowUp
                                },
                                {
                                    label: "Bottom",
                                    value: "bottom",
                                    icon: Icons.arrowDown
                                }
                            ]
                            value: Config.dashboard.tabPosition ?? "left"
                            onValueSelected: newValue => {
                                if (newValue !== Config.dashboard.tabPosition) {
                                    GlobalStates.markShellChanged();
                                    Config.dashboard.tabPosition = newValue;
                                }
                            }
                        }

                        Separator {
                            Layout.fillWidth: true
                        }

                        Text {
                            text: "Tabs"
                            font.family: Config.theme.font
                            font.pixelSize: Styling.fontSize(-1)
                            font.weight: Font.Medium
                            color: Colors.overSurfaceVariant
                            Layout.bottomMargin: -4
                        }

                        ToggleRow {
                            label: "Show Widgets Tab"
                            checked: Config.dashboard.showWidgets ?? true
                            onToggled: value => {
                                if (value !== Config.dashboard.showWidgets) {
                                    GlobalStates.markShellChanged();
                                    Config.dashboard.showWidgets = value;
                                }
                            }
                        }

                        ToggleRow {
                            label: "Show Wallpapers Tab"
                            checked: Config.dashboard.showWallpapers ?? true
                            onToggled: value => {
                                if (value !== Config.dashboard.showWallpapers) {
                                    GlobalStates.markShellChanged();
                                    Config.dashboard.showWallpapers = value;
                                }
                            }
                        }

                        ToggleRow {
                            label: "Show Metrics Tab"
                            checked: Config.dashboard.showMetrics ?? true
                            onToggled: value => {
                                if (value !== Config.dashboard.showMetrics) {
                                    GlobalStates.markShellChanged();
                                    Config.dashboard.showMetrics = value;
                                }
                            }
                        }

                        Separator {
                            Layout.fillWidth: true
                        }

                        Text {
                            text: "Background"
                            font.family: Config.theme.font
                            font.pixelSize: Styling.fontSize(-1)
                            font.weight: Font.Medium
                            color: Colors.overSurfaceVariant
                            Layout.bottomMargin: -4
                        }

                        NumberInputRow {
                            label: "Background Opacity"
                            value: Math.round((Config.dashboard.backgroundOpacity ?? 1.0) * 100)
                            minValue: 0
                            maxValue: 100
                            suffix: "%"
                            onValueEdited: newValue => {
                                const v = newValue / 100;
                                if (v !== Config.dashboard.backgroundOpacity) {
                                    GlobalStates.markShellChanged();
                                    Config.dashboard.backgroundOpacity = v;
                                }
                            }
                        }
                    }

                    ColumnLayout {
                        visible: root.currentSection === "launcher"
                        property string settingsSection: "launcher"
                        Layout.fillWidth: true
                        spacing: 8

                        Text {
                            text: "Launcher"
                            font.family: Config.theme.font
                            font.pixelSize: Styling.fontSize(-1)
                            font.weight: Font.Medium
                            color: Colors.overSurfaceVariant
                            Layout.bottomMargin: -4
                        }

                        NumberInputRow {
                            label: "Launcher Width (0 = auto)"
                            value: Config.launcher.width ?? 0
                            minValue: 0
                            maxValue: 2000
                            suffix: "px"
                            onValueEdited: newValue => {
                                if (newValue !== Config.launcher.width) {
                                    GlobalStates.markShellChanged();
                                    Config.launcher.width = newValue;
                                }
                            }
                        }

                        NumberInputRow {
                            label: "Launcher Height (0 = auto)"
                            value: Config.launcher.height ?? 0
                            minValue: 0
                            maxValue: 2000
                            suffix: "px"
                            onValueEdited: newValue => {
                                if (newValue !== Config.launcher.height) {
                                    GlobalStates.markShellChanged();
                                    Config.launcher.height = newValue;
                                }
                            }
                        }

                        ToggleRow {
                            label: "Show App Comments"
                            checked: Config.launcher.showAppComments ?? true
                            onToggled: value => {
                                if (value !== Config.launcher.showAppComments) {
                                    GlobalStates.markShellChanged();
                                    Config.launcher.showAppComments = value;
                                }
                            }
                        }

                        ToggleRow {
                            label: "Sort by Usage"
                            checked: Config.launcher.sortByUsage ?? true
                            onToggled: value => {
                                if (value !== Config.launcher.sortByUsage) {
                                    GlobalStates.markShellChanged();
                                    Config.launcher.sortByUsage = value;
                                }
                            }
                        }
                    }

                    Separator {
                        Layout.fillWidth: true
                        visible: false
                    }

                    ColumnLayout {
                        visible: root.currentSection === "dock"
                        property string settingsSection: "dock"
                        Layout.fillWidth: true
                        spacing: 8

                        Text {
                            text: "Dock"
                            font.family: Config.theme.font
                            font.pixelSize: Styling.fontSize(-1)
                            font.weight: Font.Medium
                            color: Colors.overSurfaceVariant
                            Layout.bottomMargin: -4
                        }

                        ToggleRow {
                            label: "Enabled"
                            checked: Config.dock.enabled ?? false
                            onToggled: value => {
                                if (value !== Config.dock.enabled) {
                                    GlobalStates.markShellChanged();
                                    Config.dock.enabled = value;
                                }
                            }
                        }

                        SelectorRow {
                            label: "Position"
                            options: [
                                {
                                    label: "Top",
                                    value: "top",
                                    icon: Icons.arrowUp
                                },
                                {
                                    label: "Bottom",
                                    value: "bottom",
                                    icon: Icons.arrowDown
                                },
                                {
                                    label: "Left",
                                    value: "left",
                                    icon: Icons.arrowLeft
                                },
                                {
                                    label: "Right",
                                    value: "right",
                                    icon: Icons.arrowRight
                                }
                            ]
                            value: Config.dock.position ?? "bottom"
                            onValueSelected: newValue => {
                                if (newValue !== Config.dock.position) {
                                    GlobalStates.markShellChanged();
                                    Config.dock.position = newValue;
                                }
                            }
                        }

                        SelectorRow {
                            label: "Theme"
                            options: [
                                {
                                    label: "Default",
                                    value: "default"
                                },
                                {
                                    label: "Floating",
                                    value: "floating"
                                },
                                {
                                    label: "Integrated",
                                    value: "integrated"
                                }
                            ]
                            value: Config.dock.theme ?? "default"
                            onValueSelected: newValue => {
                                if (newValue !== Config.dock.theme) {
                                    GlobalStates.markShellChanged();
                                    Config.dock.theme = newValue;
                                }
                            }
                        }

                        NumberInputRow {
                            label: "Height"
                            visible: (Config.dock.theme ?? "default") !== "integrated"
                            value: Config.dock.height ?? 56
                            minValue: 32
                            maxValue: 128
                            suffix: "px"
                            onValueEdited: newValue => {
                                if (newValue !== Config.dock.height) {
                                    GlobalStates.markShellChanged();
                                    Config.dock.height = newValue;
                                }
                            }
                        }

                        NumberInputRow {
                            label: "Icon Size"
                            visible: (Config.dock.theme ?? "default") !== "integrated"
                            value: Config.dock.iconSize ?? 40
                            minValue: 24
                            maxValue: 96
                            suffix: "px"
                            onValueEdited: newValue => {
                                if (newValue !== Config.dock.iconSize) {
                                    GlobalStates.markShellChanged();
                                    Config.dock.iconSize = newValue;
                                }
                            }
                        }

                        NumberInputRow {
                            label: "Spacing"
                            visible: (Config.dock.theme ?? "default") !== "integrated"
                            value: Config.dock.spacing ?? 4
                            minValue: 0
                            maxValue: 32
                            suffix: "px"
                            onValueEdited: newValue => {
                                if (newValue !== Config.dock.spacing) {
                                    GlobalStates.markShellChanged();
                                    Config.dock.spacing = newValue;
                                }
                            }
                        }

                        NumberInputRow {
                            label: "Margin"
                            visible: (Config.dock.theme ?? "default") !== "integrated"
                            value: Config.dock.margin ?? 8
                            minValue: 0
                            maxValue: 32
                            suffix: "px"
                            onValueEdited: newValue => {
                                if (newValue !== Config.dock.margin) {
                                    GlobalStates.markShellChanged();
                                    Config.dock.margin = newValue;
                                }
                            }
                        }

                        ToggleRow {
                            label: "Hover to Reveal"
                            visible: (Config.dock.theme ?? "default") !== "integrated"
                            checked: Config.dock.hoverToReveal ?? true
                            onToggled: value => {
                                if (value !== Config.dock.hoverToReveal) {
                                    GlobalStates.markShellChanged();
                                    Config.dock.hoverToReveal = value;
                                }
                            }
                        }

                        NumberInputRow {
                            label: "Hover Region"
                            visible: (Config.dock.theme ?? "default") !== "integrated"
                            value: Config.dock.hoverRegionHeight ?? 8
                            minValue: 0
                            maxValue: 32
                            suffix: "px"
                            onValueEdited: newValue => {
                                if (newValue !== Config.dock.hoverRegionHeight) {
                                    GlobalStates.markShellChanged();
                                    Config.dock.hoverRegionHeight = newValue;
                                }
                            }
                        }

                        NumberInputRow {
                            label: "Hide Delay"
                            visible: (Config.dock.theme ?? "default") !== "integrated"
                            value: Config.dock.hideDelay ?? 1000
                            minValue: 0
                            maxValue: 5000
                            suffix: "ms"
                            onValueEdited: newValue => {
                                if (newValue !== Config.dock.hideDelay) {
                                    GlobalStates.markShellChanged();
                                    Config.dock.hideDelay = newValue;
                                }
                            }
                        }

                        ToggleRow {
                            label: "Pinned on Startup"
                            visible: (Config.dock.theme ?? "default") !== "integrated"
                            checked: Config.dock.pinnedOnStartup ?? true
                            onToggled: value => {
                                if (value !== Config.dock.pinnedOnStartup) {
                                    GlobalStates.markShellChanged();
                                    Config.dock.pinnedOnStartup = value;
                                }
                            }
                        }

                        ToggleRow {
                            label: "Show Pin Button"
                            visible: (Config.dock.theme ?? "default") !== "integrated"
                            checked: Config.dock.showPinButton ?? true
                            onToggled: value => {
                                if (value !== Config.dock.showPinButton) {
                                    GlobalStates.markShellChanged();
                                    Config.dock.showPinButton = value;
                                }
                            }
                        }

                        ToggleRow {
                            label: "Available on Fullscreen"
                            visible: (Config.dock.theme ?? "default") !== "integrated"
                            checked: Config.dock.availableOnFullscreen ?? false
                            onToggled: value => {
                                if (value !== Config.dock.availableOnFullscreen) {
                                    GlobalStates.markShellChanged();
                                    Config.dock.availableOnFullscreen = value;
                                }
                            }
                        }

                        ToggleRow {
                            label: "Keep Hidden"
                            visible: (Config.dock.theme ?? "default") !== "integrated"
                            checked: Config.dock.keepHidden ?? false
                            onToggled: value => {
                                if (value !== Config.dock.keepHidden) {
                                    GlobalStates.markShellChanged();
                                    Config.dock.keepHidden = value;
                                }
                            }
                        }

                        ToggleRow {
                            label: "Show Running Indicators"
                            visible: (Config.dock.theme ?? "default") !== "integrated"
                            checked: Config.dock.showRunningIndicators ?? true
                            onToggled: value => {
                                if (value !== Config.dock.showRunningIndicators) {
                                    GlobalStates.markShellChanged();
                                    Config.dock.showRunningIndicators = value;
                                }
                            }
                        }

                        ToggleRow {
                            label: "Show Overview Button"
                            visible: (Config.dock.theme ?? "default") !== "integrated"
                            checked: Config.dock.showOverviewButton ?? true
                            onToggled: value => {
                                if (value !== Config.dock.showOverviewButton) {
                                    GlobalStates.markShellChanged();
                                    Config.dock.showOverviewButton = value;
                                }
                            }
                        }

                        ScreenListRow {
                            label: "Screens"
                            visible: (Config.dock.theme ?? "default") !== "integrated"
                            selectedScreens: Config.dock.screenList ?? []
                            onScreensChanged: newList => {
                                GlobalStates.markShellChanged();
                                Config.dock.screenList = newList;
                            }
                        }
                    }

                    Separator {
                        Layout.fillWidth: true
                        visible: false
                    }

                    ColumnLayout {
                        visible: root.currentSection === "lockscreen"
                        property string settingsSection: "lockscreen"
                        Layout.fillWidth: true
                        spacing: 8

                        Text {
                            text: "Lockscreen"
                            font.family: Config.theme.font
                            font.pixelSize: Styling.fontSize(-1)
                            font.weight: Font.Medium
                            color: Colors.overSurfaceVariant
                            Layout.bottomMargin: -4
                        }

                        SelectorRow {
                            label: "Position"
                            options: [
                                {
                                    label: "Top",
                                    value: "top",
                                    icon: Icons.arrowUp
                                },
                                {
                                    label: "Bottom",
                                    value: "bottom",
                                    icon: Icons.arrowDown
                                }
                            ]
                            value: Config.lockscreen.position ?? "bottom"
                            onValueSelected: newValue => {
                                if (newValue !== Config.lockscreen.position) {
                                    GlobalStates.markShellChanged();
                                    Config.lockscreen.position = newValue;
                                }
                            }
                        }

                        ToggleRow {
                            label: "Lock on Boot"
                            checked: Config.lockscreen.lockOnBoot ?? false
                            onToggled: value => {
                                if (value !== Config.lockscreen.lockOnBoot) {
                                    GlobalStates.markShellChanged();
                                    Config.lockscreen.lockOnBoot = value;
                                }
                            }
                        }

                        ToggleRow {
                            label: "Show Clock"
                            checked: Config.lockscreen.showClock ?? true
                            onToggled: value => {
                                if (value !== Config.lockscreen.showClock) {
                                    GlobalStates.markShellChanged();
                                    Config.lockscreen.showClock = value;
                                }
                            }
                        }

                        ToggleRow {
                            label: "Show Date"
                            checked: Config.lockscreen.showDate ?? true
                            onToggled: value => {
                                if (value !== Config.lockscreen.showDate) {
                                    GlobalStates.markShellChanged();
                                    Config.lockscreen.showDate = value;
                                }
                            }
                        }

                        ToggleRow {
                            label: "Show Media Player"
                            checked: Config.lockscreen.showMediaPlayer ?? true
                            onToggled: value => {
                                if (value !== Config.lockscreen.showMediaPlayer) {
                                    GlobalStates.markShellChanged();
                                    Config.lockscreen.showMediaPlayer = value;
                                }
                            }
                        }

                        ToggleRow {
                            label: "Show Avatar"
                            checked: Config.lockscreen.showAvatar ?? true
                            onToggled: value => {
                                if (value !== Config.lockscreen.showAvatar) {
                                    GlobalStates.markShellChanged();
                                    Config.lockscreen.showAvatar = value;
                                }
                            }
                        }

                        ToggleRow {
                            label: "Show Username"
                            checked: Config.lockscreen.showUsername ?? true
                            onToggled: value => {
                                if (value !== Config.lockscreen.showUsername) {
                                    GlobalStates.markShellChanged();
                                    Config.lockscreen.showUsername = value;
                                }
                            }
                        }

                        ToggleRow {
                            label: "Blur Wallpaper"
                            checked: Config.lockscreen.blurWallpaper ?? true
                            onToggled: value => {
                                if (value !== Config.lockscreen.blurWallpaper) {
                                    GlobalStates.markShellChanged();
                                    Config.lockscreen.blurWallpaper = value;
                                }
                            }
                        }

                        NumberInputRow {
                            label: "Dim Strength"
                            value: Config.lockscreen.dimOpacity ?? 25
                            minValue: 0
                            maxValue: 100
                            suffix: "%"
                            onValueEdited: newValue => {
                                if (newValue !== Config.lockscreen.dimOpacity) {
                                    GlobalStates.markShellChanged();
                                    Config.lockscreen.dimOpacity = newValue;
                                }
                            }
                        }
                    }

                    Separator {
                        Layout.fillWidth: true
                        visible: false
                    }

                    ColumnLayout {
                        visible: root.currentSection === "osd"
                        property string settingsSection: "osd"
                        Layout.fillWidth: true
                        spacing: 8

                        Text {
                            text: "OSD"
                            font.family: Config.theme.font
                            font.pixelSize: Styling.fontSize(-1)
                            font.weight: Font.Medium
                            color: Colors.overSurfaceVariant
                            Layout.bottomMargin: -4
                        }

                        SelectorRow {
                            label: "Position"
                            options: [
                                {
                                    label: "Bottom",
                                    value: "bottom",
                                    icon: Icons.arrowDown
                                },
                                {
                                    label: "Top",
                                    value: "top",
                                    icon: Icons.arrowUp
                                }
                            ]
                            value: Config.osd.position ?? "bottom"
                            onValueSelected: newValue => {
                                if (newValue !== Config.osd.position) {
                                    GlobalStates.markShellChanged();
                                    Config.osd.position = newValue;
                                }
                            }
                        }

                        NumberInputRow {
                            label: "Width"
                            value: Config.osd.width ?? 260
                            minValue: 180
                            maxValue: 480
                            suffix: "px"
                            onValueEdited: newValue => {
                                if (newValue !== Config.osd.width) {
                                    GlobalStates.markShellChanged();
                                    Config.osd.width = newValue;
                                }
                            }
                        }

                        SelectorRow {
                            label: "Icon Style"
                            options: [
                                {
                                    label: "Chip",
                                    value: "chip"
                                },
                                {
                                    label: "Plain",
                                    value: "plain"
                                }
                            ]
                            value: Config.osd.iconStyle ?? "chip"
                            onValueSelected: newValue => {
                                if (newValue !== Config.osd.iconStyle) {
                                    GlobalStates.markShellChanged();
                                    Config.osd.iconStyle = newValue;
                                }
                            }
                        }

                        ToggleRow {
                            label: "Show Percentage"
                            checked: Config.osd.showPercentage ?? true
                            onToggled: value => {
                                if (value !== Config.osd.showPercentage) {
                                    GlobalStates.markShellChanged();
                                    Config.osd.showPercentage = value;
                                }
                            }
                        }

                        ToggleRow {
                            label: "Show Slider"
                            checked: Config.osd.showSlider ?? true
                            onToggled: value => {
                                if (value !== Config.osd.showSlider) {
                                    GlobalStates.markShellChanged();
                                    Config.osd.showSlider = value;
                                }
                            }
                        }
                    }

                    Separator {
                        Layout.fillWidth: true
                        visible: false
                    }

                    ColumnLayout {
                        visible: root.currentSection === "system"
                        property string settingsSection: "system"
                        Layout.fillWidth: true
                        spacing: 8

                        Text {
                            text: "System"
                            font.family: Config.theme.font
                            font.pixelSize: Styling.fontSize(-1)
                            font.weight: Font.Medium
                            color: Colors.overSurfaceVariant
                            Layout.bottomMargin: -4
                        }

                        Text {
                            text: "OCR Languages"
                            font.family: Config.theme.font
                            font.pixelSize: Styling.fontSize(-2)
                            color: Styling.srItem("overprimary")
                            font.bold: true
                            Layout.topMargin: 8
                        }

                        ToggleRow {
                            label: "English"
                            checked: Config.system.ocr.eng ?? true
                            onToggled: value => {
                                if (value !== Config.system.ocr.eng) {
                                    GlobalStates.markShellChanged();
                                    Config.system.ocr.eng = value;
                                }
                            }
                        }

                        ToggleRow {
                            label: "Spanish"
                            checked: Config.system.ocr.spa ?? true
                            onToggled: value => {
                                if (value !== Config.system.ocr.spa) {
                                    GlobalStates.markShellChanged();
                                    Config.system.ocr.spa = value;
                                }
                            }
                        }

                        ToggleRow {
                            label: "Latin"
                            checked: Config.system.ocr.lat ?? false
                            onToggled: value => {
                                if (value !== Config.system.ocr.lat) {
                                    GlobalStates.markShellChanged();
                                    Config.system.ocr.lat = value;
                                }
                            }
                        }

                        ToggleRow {
                            label: "Japanese"
                            checked: Config.system.ocr.jpn ?? false
                            onToggled: value => {
                                if (value !== Config.system.ocr.jpn) {
                                    GlobalStates.markShellChanged();
                                    Config.system.ocr.jpn = value;
                                }
                            }
                        }

                        ToggleRow {
                            label: "Chinese (Simplified)"
                            checked: Config.system.ocr.chi_sim ?? false
                            onToggled: value => {
                                if (value !== Config.system.ocr.chi_sim) {
                                    GlobalStates.markShellChanged();
                                    Config.system.ocr.chi_sim = value;
                                }
                            }
                        }

                        ToggleRow {
                            label: "Chinese (Traditional)"
                            checked: Config.system.ocr.chi_tra ?? false
                            onToggled: value => {
                                if (value !== Config.system.ocr.chi_tra) {
                                    GlobalStates.markShellChanged();
                                    Config.system.ocr.chi_tra = value;
                                }
                            }
                        }

                        ToggleRow {
                            label: "Korean"
                            checked: Config.system.ocr.kor ?? false
                            onToggled: value => {
                                if (value !== Config.system.ocr.kor) {
                                    GlobalStates.markShellChanged();
                                    Config.system.ocr.kor = value;
                                }
                            }
                        }
                    }

                    ColumnLayout {
                        visible: root.currentSection === "about"
                        property string settingsSection: "about"
                        Layout.fillWidth: true
                        spacing: 8

                        Text {
                            text: "About"
                            font.family: Config.theme.font
                            font.pixelSize: Styling.fontSize(-1)
                            font.weight: Font.Medium
                            color: Colors.overSurfaceVariant
                            Layout.bottomMargin: -4
                        }

                        StyledRect {
                            variant: "pane"
                            Layout.fillWidth: true
                            Layout.preferredHeight: aboutColumn.implicitHeight + 32
                            radius: Styling.radius(0)

                            ColumnLayout {
                                id: aboutColumn
                                anchors.fill: parent
                                anchors.margins: 16
                                spacing: 8

                                Text {
                                    text: "Pangu"
                                    font.family: Config.theme.font
                                    font.pixelSize: Styling.fontSize(4)
                                    font.bold: true
                                    color: Colors.overBackground
                                }

                                Text {
                                    text: "The desktop shell for this configuration"
                                    font.family: Config.theme.font
                                    font.pixelSize: Styling.fontSize(-1)
                                    color: Colors.overSurfaceVariant
                                }

                                RowLayout {
                                    Layout.topMargin: 8
                                    spacing: 8

                                    Text {
                                        text: "Version"
                                        font.family: Config.theme.font
                                        font.pixelSize: Styling.fontSize(-1)
                                        color: Colors.overBackground
                                        Layout.fillWidth: true
                                    }

                                    Text {
                                        text: Config.version !== "" ? Config.version : "dev"
                                        font.family: Config.theme.monoFont
                                        font.pixelSize: Styling.fontSize(-1)
                                        color: Styling.srItem("overprimary")
                                    }
                                }

                                RowLayout {
                                    spacing: 8

                                    Text {
                                        text: "License"
                                        font.family: Config.theme.font
                                        font.pixelSize: Styling.fontSize(-1)
                                        color: Colors.overBackground
                                        Layout.fillWidth: true
                                    }

                                    Text {
                                        text: "AGPL-3.0"
                                        font.family: Config.theme.monoFont
                                        font.pixelSize: Styling.fontSize(-1)
                                        color: Styling.srItem("overprimary")
                                    }
                                }
                            }
                        }
                    }

                }
            }
        }
    }

    Item {
        id: colorPickerContainer
        anchors.fill: parent
        clip: true

        opacity: root.colorPickerActive ? 1 : 0
        transform: Translate {
            x: root.colorPickerActive ? 0 : 30

            Behavior on x {
                enabled: Config.animDuration > 0
                NumberAnimation {
                    duration: Config.animDuration / 2
                    easing.type: Easing.OutQuart
                }
            }
        }

        Behavior on opacity {
            enabled: Config.animDuration > 0
            NumberAnimation {
                duration: Config.animDuration / 2
                easing.type: Easing.OutQuart
            }
        }

        enabled: root.colorPickerActive

        MouseArea {
            anchors.fill: parent
            enabled: root.colorPickerActive
            hoverEnabled: true
            acceptedButtons: Qt.AllButtons
            onPressed: event => event.accepted = true
            onReleased: event => event.accepted = true
            onWheel: event => event.accepted = true
        }

        ColorPickerView {
            id: colorPickerContent
            anchors.fill: parent
            anchors.leftMargin: root.sideMargin
            anchors.rightMargin: root.sideMargin
            colorNames: root.colorPickerColorNames
            currentColor: root.colorPickerCurrentColor
            dialogTitle: root.colorPickerDialogTitle

            onColorSelected: color => root.handleColorSelected(color)
            onClosed: root.closeColorPicker()
        }
    }
}
