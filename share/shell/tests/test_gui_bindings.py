import os
from pathlib import Path
import re
import shutil
import subprocess
import tempfile
import unittest


SHELL = Path(__file__).resolve().parents[1]


@unittest.skipUnless(shutil.which("qs"), "Quickshell is required")
class GuiBindingsTest(unittest.TestCase):
    def run_scene(self, root, scene):
        (root / "runtime").mkdir(mode=0o700)
        (root / "shell.qml").write_text(scene)
        env = dict(os.environ, XDG_RUNTIME_DIR=str(root / "runtime"), XDG_CACHE_HOME=str(root / "cache"),
                   QT_QPA_PLATFORM="offscreen", QML_DISABLE_DISK_CACHE="1")
        env.pop("WAYLAND_DISPLAY", None)
        result = subprocess.run(["qs", "-p", str(root / "shell.qml")], env=env,
                                capture_output=True, text=True, timeout=10)
        log = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, log)
        for error in ("TypeError", "ReferenceError", "Binding loop", "CHECK_FAILED", "Cannot assign"):
            self.assertNotIn(error, log)
        self.assertIn("CHECK_PASSED", log)

    def test_overview_delegate_owner_and_geometry(self):
        with tempfile.TemporaryDirectory(prefix="pangu-overview-") as directory:
            root = Path(directory)
            source = (SHELL / "modules/widgets/overview/Overview.qml").read_text()
            start = source.index("            Repeater {\n                model: windowSpace.filteredWindowData")
            end = source.index("            Rectangle {\n                id: focusedWorkspaceIndicator", start)
            delegate = source[start:end].replace("Repeater {", "Repeater {\n                id: testedWindows", 1)
            window = (SHELL / "modules/widgets/overview/OverviewWindow.qml").read_text()
            declarations = [line for line in window.splitlines()
                            if re.match(r"    (required )?property (var|Item|real|int|bool|string) ", line)
                            and "atInitPosition" not in line]
            signals = [line for line in window.splitlines() if line.startswith("    signal ")]
            (root / "OverviewWindow.qml").write_text("import QtQuick\nItem {\n" + "\n".join(declarations + signals) + "\n}\n")
            self.run_scene(root, '''import QtQuick
import Quickshell
Item {
    id: overviewRoot
    width: 1000; height: 500
    property real workspaceImplicitWidth: 300
    property real workspaceImplicitHeight: 200
    property int workspacePadding: 8
    property int workspaceSpacing: 12
    property int columns: 3
    property int workspacesShown: 6
    property var monitorData: ({x: 0, y: 0})
    property string barPosition: "top"
    property int barReserved: 40
    function isWindowMatched(address) { return true; }
    function isWindowSelected(address) { return false; }
    Item {
        id: windowSpace
        property var filteredWindowData: [
            {windowData: {workspace: {id: 1}, address: "first"}, toplevel: null},
            {windowData: {workspace: {id: 2}, address: "second"}, toplevel: null}
        ]
    }
''' + delegate + '''
    Timer {
        interval: 200; running: true
        onTriggered: {
            const first = testedWindows.itemAt(0);
            const second = testedWindows.itemAt(1);
            console.log(first && second && first.overviewItem === overviewRoot &&
                first.availableWorkspaceWidth === 300 && second.xOffset === 324
                ? "CHECK_PASSED" : "CHECK_FAILED");
            Qt.quit();
        }
    }
}
''')

    def test_visibility_lookup_has_no_registration_side_effect(self):
        with tempfile.TemporaryDirectory(prefix="pangu-visibility-") as directory:
            root = Path(directory)
            services = root / "modules/services"
            services.mkdir(parents=True)
            shutil.copy(SHELL / "modules/services/Visibilities.qml", services / "Visibilities.qml")
            (services / "qmldir").write_text("singleton Visibilities 1.0 Visibilities.qml\nsingleton Compositor 1.0 Compositor.qml\n")
            (services / "Compositor.qml").write_text('''pragma Singleton
import QtQuick
QtObject { property var focusedMonitor: ({name: "absent"}) }
''')
            self.run_scene(root, '''import QtQuick
import Quickshell
import "modules/services"
ShellRoot {
    readonly property var absent: Visibilities.getForScreen("absent")
    Timer {
        interval: 200; running: true
        onTriggered: {
            const registered = Object.keys(Visibilities.screens).length;
            console.log(absent === null && registered === Quickshell.screens.length
                ? "CHECK_PASSED" : "CHECK_FAILED");
            Qt.quit();
        }
    }
}
''')
