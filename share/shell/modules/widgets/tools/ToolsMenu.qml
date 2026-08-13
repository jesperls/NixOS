import QtQuick
import qs.modules.components
import qs.modules.theme
import qs.modules.globals
import Quickshell.Io

import qs.modules.services
import qs.config

ActionGrid {
    id: root

    signal itemSelected

    QtObject {
        id: recordAction
        property string icon: ScreenRecorder.isRecording ? Icons.stop : Icons.recordScreen
        property string text: ScreenRecorder.isRecording ? ScreenRecorder.duration : ""
        property string tooltip: ScreenRecorder.isRecording ? "Stop Recording" : "Screen Recorder"
        property string command: ""
        property string variant: ScreenRecorder.isRecording ? "error" : "primary"
        property string type: "button"
    }

    QtObject {
        id: replayAction
        property string icon: Icons.rewind
        property string tooltip: ReplayService.active ? "Stop Replay Buffer" : "Replay Buffer"
        property string command: ""
        property string variant: ReplayService.active ? "tertiary" : "primary"
        property string type: "button"
    }

    QtObject {
        id: saveReplayAction
        property string icon: Icons.clip
        property string tooltip: "Save Replay"
        property string command: ""
        property string variant: "tertiary"
        property string type: "button"
    }

    layout: "row"
    buttonSize: 48
    iconSize: 20
    spacing: 8

    property var allActions: [
        {
            icon: Icons.camera,
            tooltip: "Screenshot",
            command: ""
        },
        {
            icon: Icons.screenshots,
            tooltip: "Open Screenshots",
            command: ""
        },
        {
            type: "separator"
        },
        recordAction,
        replayAction,
        saveReplayAction,
        {
            icon: Icons.recordings,
            tooltip: "Open Recordings",
            command: ""
        },
        {
            type: "separator"
        },
        {
            icon: Icons.picker,
            tooltip: "Color Picker",
            command: ""
        },
        {
            icon: Icons.textT,
            tooltip: "OCR",
            command: ""
        },
        {
            icon: Icons.qrCode,
            tooltip: "QR Code",
            command: ""
        },
        {
            icon: Icons.google,
            tooltip: "Google Lens",
            command: ""
        },
        {
            icon: GlobalStates.mirrorWindowVisible ? Icons.webcamSlash : Icons.webcam,
            tooltip: "Mirror",
            command: ""
        }
    ]

    actions: allActions.filter(action => action !== saveReplayAction || ReplayService.active)

    Process {
        id: colorPickerProc
    }

    Process {
        id: ocrProc
    }

    Process {
        id: qrProc
    }

    Process {
        id: openFolderProc
        command: ["bash", "-c", "nohup xdg-open \"$0\" > /dev/null 2>&1 &"]
    }

    onActionTriggered: action => {
        if (action.tooltip === "Screenshot") {
            Screenshot.initialize();
            GlobalStates.screenshotToolVisible = true;
            root.itemSelected();
        } else if (action.tooltip === "Screen Recorder") {
            ScreenRecorder.initialize();
            GlobalStates.screenRecordReplayMode = false;
            GlobalStates.screenRecordToolVisible = true;
            root.itemSelected();
        } else if (action.tooltip === "Stop Recording") {
            ScreenRecorder.toggleRecording();
            root.itemSelected();
        } else if (action.tooltip === "Replay Buffer" || action.tooltip === "Stop Replay Buffer") {
            if (ReplayService.active) {
                ReplayService.stop();
            } else {
                ScreenRecorder.initialize();
                GlobalStates.screenRecordReplayMode = true;
                GlobalStates.screenRecordToolVisible = true;
            }
            root.itemSelected();
        } else if (action.tooltip === "Save Replay") {
            ReplayService.saveClip();
            root.itemSelected();
        } else if (action.tooltip === "Open Screenshots") {
            var cmd = "dir=\"$(xdg-user-dir PICTURES)/Screenshots\"; mkdir -p \"$dir\"; nohup xdg-open \"$dir\" > /dev/null 2>&1 &";
            
            openFolderProc.command = ["bash", "-c", cmd];
            openFolderProc.running = true;
            
            root.itemSelected();
        } else if (action.tooltip === "Open Recordings") {
            var cmd = "dir=\"$(xdg-user-dir VIDEOS)/Recordings\"; mkdir -p \"$dir\"; nohup xdg-open \"$dir\" > /dev/null 2>&1 &";
            
            openFolderProc.command = ["bash", "-c", cmd];
            openFolderProc.running = true;
            
             root.itemSelected();
        } else if (action.tooltip === "Color Picker") {
            var scriptPath = Paths.script("colorpicker.py");
            colorPickerProc.command = ["bash", "-c", "nohup python3 \"" + scriptPath + "\" > /dev/null 2>&1 &"];
            colorPickerProc.running = true;
            root.itemSelected();
        } else if (action.tooltip === "OCR") {
            var scriptPath = Paths.script("ocr.sh");
            
            var ocrConfig = Config.system.ocr;
            var langs = [];
            
            if (ocrConfig) {
                if (ocrConfig.eng !== false) langs.push("eng"); // Default true
                if (ocrConfig.spa !== false) langs.push("spa"); // Default true
                if (ocrConfig.lat === true) langs.push("lat");
                if (ocrConfig.jpn === true) langs.push("jpn");
                if (ocrConfig.chi_sim === true) langs.push("chi_sim");
                if (ocrConfig.chi_tra === true) langs.push("chi_tra");
                if (ocrConfig.kor === true) langs.push("kor");
            } else {
                langs = ["eng", "spa"];
            }
            
            if (langs.length === 0) langs.push("eng");
            var langString = langs.join("+");

            ocrProc.command = ["bash", "-c", "nohup \"" + scriptPath + "\" \"" + langString + "\" > /dev/null 2>&1 &"];
            ocrProc.running = true;
            root.itemSelected();
        } else if (action.tooltip === "QR Code") {
            var scriptPath = Paths.script("qr_scan.sh");
            qrProc.command = ["bash", "-c", "nohup \"" + scriptPath + "\" > /dev/null 2>&1 &"];
            qrProc.running = true;
            root.itemSelected();
        } else if (action.tooltip === "Google Lens") {
            Screenshot.captureMode = "lens";
            GlobalStates.screenshotToolVisible = true;
            root.itemSelected();
        } else if (action.tooltip === "Mirror") {
            GlobalStates.mirrorWindowVisible = !GlobalStates.mirrorWindowVisible;
            root.itemSelected();
        }
    }
}
