pragma Singleton

import QtQuick
import Quickshell
import qs.config

Singleton {
    id: root

    property bool enabled: false

    function toggle() {
        root.enabled = !root.enabled;
    }

    function minutesOf(timeStr, fallback) {
        var parts = String(timeStr).split(":");
        var value = parseInt(parts[0]) * 60 + parseInt(parts[1]);
        return isNaN(value) ? fallback : value;
    }

    function boundaries() {
        var dayStr = WeatherService.sunrise.length > 0 ? WeatherService.sunrise : (Config.system.autoTheme?.dayStart ?? "08:00");
        var nightStr = WeatherService.sunset.length > 0 ? WeatherService.sunset : (Config.system.autoTheme?.nightStart ?? "20:00");
        return {
            day: minutesOf(dayStr, 480),
            night: minutesOf(nightStr, 1200)
        };
    }

    function apply() {
        if (!root.enabled || SuspendManager.isSuspending)
            return;
        var b = boundaries();
        var now = new Date();
        var minute = now.getHours() * 60 + now.getMinutes();
        var wantLight = minute >= b.day && minute < b.night;
        if (Config.initialLoadComplete && Config.theme.lightMode !== wantLight) {
            Config.theme.lightMode = wantLight;
            Config.save("theme");
        }
        var nextMinute = minute < b.day ? b.day : (minute < b.night ? b.night : b.day + 1440);
        boundaryTimer.interval = new Date(now.getFullYear(), now.getMonth(), now.getDate(), 0, nextMinute).getTime() - now.getTime() + 1000;
        boundaryTimer.restart();
    }

    onEnabledChanged: {
        if (StateService.initialized)
            StateService.set("autoTheme", root.enabled);
        if (root.enabled)
            apply();
        else
            boundaryTimer.stop();
    }

    Timer {
        id: boundaryTimer
        repeat: false
        onTriggered: root.apply()
    }

    Connections {
        target: SuspendManager
        function onPreparingForSleep() {
            boundaryTimer.stop();
        }
        function onWakingUp() {
            if (root.enabled)
                root.apply();
        }
    }

    Connections {
        target: WeatherService
        function onSunriseChanged() {
            if (root.enabled)
                root.apply();
        }
        function onSunsetChanged() {
            if (root.enabled)
                root.apply();
        }
    }

    Connections {
        target: Config
        function onInitialLoadCompleteChanged() {
            if (Config.initialLoadComplete && root.enabled)
                root.apply();
        }
    }

    Component.onCompleted: if (StateService.initialized) restore()

    function restore() {
        root.enabled = StateService.get("autoTheme", false);
        if (root.enabled)
            apply();
    }

    Connections {
        target: StateService
        function onStateLoaded() {
            root.restore();
        }
    }
}
