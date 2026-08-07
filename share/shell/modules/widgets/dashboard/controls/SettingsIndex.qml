
import QtQuick
import qs.modules.theme
import qs.config

QtObject {

    
    property var dynamicItems: []

    readonly property var staticItems: [
        { label: "Network", keywords: "internet wifi connection ethernet ip", section: "network", subSection: "", subLabel: "", icon: Icons.wifiHigh, isIcon: true },
        
        { label: "Bluetooth", keywords: "devices pairing connect", section: "bluetooth", subSection: "", subLabel: "", icon: Icons.bluetooth, isIcon: true },
        
        { label: "Audio Mixer", keywords: "sound volume output input mic speaker", section: "mixer", subSection: "", subLabel: "", icon: Icons.faders, isIcon: true },
        
        { label: "Audio Effects", keywords: "equalizer bass treble easyeffects", section: "effects", subSection: "", subLabel: "", icon: Icons.waveform, isIcon: true },
        
        { label: "Theme", keywords: "appearance look style customize", section: "theme", subSection: "", subLabel: "Theme", icon: Icons.paintBrush, isIcon: true },
        
        { label: "Wallpapers", keywords: "background image picture desktop", section: "theme", subSection: "general", subLabel: "Theme > General", icon: Icons.image, isIcon: true },
        { label: "Tint Icons", keywords: "color icons tint monochrome", section: "theme", subSection: "general", subLabel: "Theme > General", icon: Icons.palette, isIcon: true },
        { label: "Enable Corners", keywords: "rounded corners radius screen", section: "theme", subSection: "general", subLabel: "Theme > General", icon: Icons.cornersOut, isIcon: true },
        { label: "Animation Duration", keywords: "speed fast slow transition", section: "theme", subSection: "general", subLabel: "Theme > General", icon: Icons.clock, isIcon: true },
        { label: "UI Font", keywords: "typography text family size", section: "theme", subSection: "general", subLabel: "Theme > General", icon: Icons.textT, isIcon: true },
        { label: "Roundness", keywords: "radius border curve", section: "theme", subSection: "general", subLabel: "Theme > General", icon: Icons.circle, isIcon: true },
        
        { label: "Shadow Opacity", keywords: "darkness alpha transparency", section: "theme", subSection: "shadow", subLabel: "Theme > Shadow", icon: Icons.drop, isIcon: true },
        { label: "Shadow Blur", keywords: "softness diffusion", section: "theme", subSection: "shadow", subLabel: "Theme > Shadow", icon: Icons.drop, isIcon: true },
        { label: "Shadow Offset", keywords: "position x y direction", section: "theme", subSection: "shadow", subLabel: "Theme > Shadow", icon: Icons.arrowsOutSimple, isIcon: true },

        { label: "Color Scheme", keywords: "palette variant light dark", section: "theme", subSection: "colors", subLabel: "Theme > Colors", icon: Icons.palette, isIcon: true },
        { label: "Color Variant", keywords: "background popup internal bar pane", section: "theme", subSection: "colors", subLabel: "Theme > Colors", icon: Icons.palette, isIcon: true },
        { label: "Background Variant", keywords: "wallpaper desktop color", section: "theme", subSection: "colors", subLabel: "Theme > Colors", icon: Icons.palette, isIcon: true },
        { label: "Popup Variant", keywords: "dialog modal color", section: "theme", subSection: "colors", subLabel: "Theme > Colors", icon: Icons.palette, isIcon: true },
        { label: "Internal BG Variant", keywords: "inside background color", section: "theme", subSection: "colors", subLabel: "Theme > Colors", icon: Icons.palette, isIcon: true },
        { label: "Bar BG Variant", keywords: "taskbar panel color", section: "theme", subSection: "colors", subLabel: "Theme > Colors", icon: Icons.palette, isIcon: true },
        { label: "Pane Variant", keywords: "sidebar panel color", section: "theme", subSection: "colors", subLabel: "Theme > Colors", icon: Icons.palette, isIcon: true },
        { label: "Gradient Mode", keywords: "linear radial halftone", section: "theme", subSection: "colors", subLabel: "Theme > Colors", icon: Icons.palette, isIcon: true },
        { label: "Item Color", keywords: "overbackground surface", section: "theme", subSection: "colors", subLabel: "Theme > Colors", icon: Icons.palette, isIcon: true },
        { label: "Color Opacity", keywords: "alpha transparency", section: "theme", subSection: "colors", subLabel: "Theme > Colors", icon: Icons.palette, isIcon: true },
        { label: "Color Border", keywords: "stroke outline", section: "theme", subSection: "colors", subLabel: "Theme > Colors", icon: Icons.palette, isIcon: true },
        { label: "Gradient Stops", keywords: "color position stops", section: "theme", subSection: "colors", subLabel: "Theme > Colors", icon: Icons.palette, isIcon: true },
        { label: "Gradient Angle", keywords: "direction rotation degrees", section: "theme", subSection: "colors", subLabel: "Theme > Colors", icon: Icons.palette, isIcon: true },

        { label: "System", keywords: "hardware info resources cpu ram", section: "system", subSection: "", subLabel: "System", icon: Icons.circuitry, isIcon: true },
        
        { label: "Prefixes", keywords: "shortcuts launcher quick actions", section: "system", subSection: "prefixes", subLabel: "System > Prefixes", icon: Icons.keyboard, isIcon: true },
        { label: "Clipboard Prefix", keywords: "cc copy paste launcher", section: "system", subSection: "prefixes", subLabel: "System > Prefixes", icon: Icons.keyboard, isIcon: true },
        { label: "Emoji Prefix", keywords: "ee picker launcher", section: "system", subSection: "prefixes", subLabel: "System > Prefixes", icon: Icons.keyboard, isIcon: true },
        { label: "Tmux Prefix", keywords: "tt terminal launcher", section: "system", subSection: "prefixes", subLabel: "System > Prefixes", icon: Icons.keyboard, isIcon: true },
        { label: "Wallpapers Prefix", keywords: "ww background launcher", section: "system", subSection: "prefixes", subLabel: "System > Prefixes", icon: Icons.keyboard, isIcon: true },
        { label: "Notes Prefix", keywords: "nn note launcher", section: "system", subSection: "prefixes", subLabel: "System > Prefixes", icon: Icons.keyboard, isIcon: true },
        
        { label: "Weather Location", keywords: "city country place gps", section: "system", subSection: "weather", subLabel: "System > Weather", icon: Icons.mapPin, isIcon: true },
        { label: "Temperature Unit", keywords: "celsius fahrenheit scale", section: "system", subSection: "weather", subLabel: "System > Weather", icon: Icons.thermometer, isIcon: true },

        { label: "Blur Transition", keywords: "animation speed performance effect", section: "system", subSection: "performance", subLabel: "System > Performance", icon: Icons.lightning, isIcon: true },
        { label: "Window Preview", keywords: "thumbnail overview alt-tab", section: "system", subSection: "performance", subLabel: "System > Performance", icon: Icons.windowsLogo, isIcon: true },
        { label: "Wavy Line", keywords: "animated wave effect performance", section: "system", subSection: "performance", subLabel: "System > Performance", icon: Icons.lightning, isIcon: true },
        
        { label: "System Resources", keywords: "cpu ram memory usage monitor", section: "system", subSection: "system", subLabel: "System > Resources", icon: Icons.circuitry, isIcon: true },

        { label: "Audio Visualizer", keywords: "cava bars media player performance", section: "system", subSection: "performance", subLabel: "System > Performance", icon: Icons.waveform, isIcon: true },

        { label: "Replay Buffer Length", keywords: "recording clip instant replay seconds", section: "system", subSection: "recording", subLabel: "System > Recording", icon: Icons.recordScreen, isIcon: true },

        { label: "Slideshow", keywords: "wallpaper cycle rotate shuffle background", section: "system", subSection: "wallpaper", subLabel: "System > Wallpaper", icon: Icons.image, isIcon: true },
        { label: "Wallpaper Interval", keywords: "slideshow minutes timer background", section: "system", subSection: "wallpaper", subLabel: "System > Wallpaper", icon: Icons.clock, isIcon: true },

        { label: "Auto Theme", keywords: "day night light dark schedule", section: "system", subSection: "daynight", subLabel: "System > Day & Night", icon: Icons.sun, isIcon: true },
        { label: "Night Light Temperature", keywords: "blue light filter warm kelvin", section: "system", subSection: "daynight", subLabel: "System > Day & Night", icon: Icons.nightLight, isIcon: true },

        { label: "Do Not Disturb", keywords: "dnd silent notifications popups mute", section: "system", subSection: "notifications", subLabel: "System > Notifications", icon: Icons.bellSlash, isIcon: true },

        { label: "Pomodoro", keywords: "timer work rest session focus spotify", section: "system", subSection: "pomodoro", subLabel: "System > Pomodoro", icon: Icons.timer, isIcon: true },

        { label: "Idle Settings", keywords: "screen lock timeout sleep suspend", section: "system", subSection: "idle", subLabel: "System > Idle", icon: Icons.moon, isIcon: true },
        { label: "Idle Actions", keywords: "master enable dim lock suspend timers", section: "system", subSection: "idle", subLabel: "System > Idle", icon: Icons.moon, isIcon: true },
        { label: "Lock on Boot", keywords: "lockscreen session start login", section: "system", subSection: "idle", subLabel: "System > Idle", icon: Icons.lock, isIcon: true },
        { label: "Lock on Sleep", keywords: "lockscreen suspend before sleep", section: "system", subSection: "idle", subLabel: "System > Idle", icon: Icons.lock, isIcon: true },
        { label: "Lock After", keywords: "idle timeout lockscreen minutes", section: "system", subSection: "idle", subLabel: "System > Idle", icon: Icons.lock, isIcon: true },
        { label: "Suspend After", keywords: "idle timeout sleep minutes", section: "system", subSection: "idle", subLabel: "System > Idle", icon: Icons.moon, isIcon: true },
        { label: "Lock Command", keywords: "pangu lock screen idle", section: "system", subSection: "idle", subLabel: "System > Idle", icon: Icons.moon, isIcon: true },
        { label: "After Sleep", keywords: "screen on resume idle", section: "system", subSection: "idle", subLabel: "System > Idle", icon: Icons.moon, isIcon: true },
        { label: "Idle Listener", keywords: "timeout brightness screen off suspend", section: "system", subSection: "idle", subLabel: "System > Idle", icon: Icons.moon, isIcon: true },
        
        { label: "Compositor", keywords: "compositor window manager wm", section: "compositor", subSection: "", subLabel: "Compositor", icon: Icons.compositor, isIcon: true },
        
        { label: "Border Size", keywords: "width thickness stroke", section: "compositor", subSection: "general", subLabel: "Compositor > Hyprland", icon: Icons.frameCorners, isIcon: true },
        { label: "Window Gaps", keywords: "spacing margin padding", section: "compositor", subSection: "general", subLabel: "Compositor > Hyprland", icon: Icons.squaresFour, isIcon: true },
        
        { label: "Border Colors", keywords: "active inactive focus", section: "compositor", subSection: "colors", subLabel: "Compositor > Hyprland", icon: Icons.palette, isIcon: true },

        { label: "Shadows Enabled", keywords: "toggle on off", section: "compositor", subSection: "shadows", subLabel: "Compositor > Hyprland", icon: Icons.drop, isIcon: true },
        { label: "Sync Shadow Color", keywords: "match border", section: "compositor", subSection: "shadows", subLabel: "Compositor > Hyprland", icon: Icons.palette, isIcon: true },
        { label: "Sync Shadow Opacity", keywords: "match border alpha", section: "compositor", subSection: "shadows", subLabel: "Compositor > Hyprland", icon: Icons.drop, isIcon: true },
        { label: "Shadow Range", keywords: "blur radius size", section: "compositor", subSection: "shadows", subLabel: "Compositor > Hyprland", icon: Icons.circle, isIcon: true },
        { label: "Shadow Offset", keywords: "position x y move", section: "compositor", subSection: "shadows", subLabel: "Compositor > Hyprland", icon: Icons.arrowsOutSimple, isIcon: true },
        { label: "Shadow Power", keywords: "strength render intensity", section: "compositor", subSection: "shadows", subLabel: "Compositor > Hyprland", icon: Icons.lightning, isIcon: true },
        { label: "Shadow Scale", keywords: "zoom resize", section: "compositor", subSection: "shadows", subLabel: "Compositor > Hyprland", icon: Icons.cornersOut, isIcon: true },

        { label: "Blur Enabled", keywords: "toggle on off transparency", section: "compositor", subSection: "blur", subLabel: "Compositor > Hyprland", icon: Icons.drop, isIcon: true },
        { label: "Blur Size", keywords: "radius amount", section: "compositor", subSection: "blur", subLabel: "Compositor > Hyprland", icon: Icons.circle, isIcon: true },
        { label: "Blur Passes", keywords: "quality iterations", section: "compositor", subSection: "blur", subLabel: "Compositor > Hyprland", icon: Icons.circle, isIcon: true },
        { label: "Blur Xray", keywords: "transparency see through", section: "compositor", subSection: "blur", subLabel: "Compositor > Hyprland", icon: Icons.drop, isIcon: true },
        { label: "Blur New Optimizations", keywords: "performance speed", section: "compositor", subSection: "blur", subLabel: "Compositor > Hyprland", icon: Icons.lightning, isIcon: true },
        { label: "Blur Ignore Opacity", keywords: "transparency alpha", section: "compositor", subSection: "blur", subLabel: "Compositor > Hyprland", icon: Icons.drop, isIcon: true },
        { label: "Blur Ignorealpha", keywords: "explicit transparency", section: "compositor", subSection: "blur", subLabel: "Compositor > Hyprland", icon: Icons.drop, isIcon: true },
        { label: "Blur Ignorealpha Value", keywords: "threshold amount", section: "compositor", subSection: "blur", subLabel: "Compositor > Hyprland", icon: Icons.drop, isIcon: true },
        { label: "Blur Noise", keywords: "grain texture static", section: "compositor", subSection: "blur", subLabel: "Compositor > Hyprland", icon: Icons.drop, isIcon: true },
        { label: "Blur Contrast", keywords: "intensity difference", section: "compositor", subSection: "blur", subLabel: "Compositor > Hyprland", icon: Icons.drop, isIcon: true },
        { label: "Blur Brightness", keywords: "light dark level", section: "compositor", subSection: "blur", subLabel: "Compositor > Hyprland", icon: Icons.drop, isIcon: true },
        { label: "Blur Vibrancy", keywords: "saturation color", section: "compositor", subSection: "blur", subLabel: "Compositor > Hyprland", icon: Icons.drop, isIcon: true },

        { label: "Shell", keywords: "shell panels modules", section: "shell", subSection: "", subLabel: "", icon: Icons.cube, isIcon: true },
        { label: "About", keywords: "about info credits version license pangu", section: "shell", subSection: "about", subLabel: "Shell > About", icon: Icons.cube, isIcon: true },
        
        { label: "Bar", keywords: "panel taskbar top bottom", section: "shell", subSection: "bar", subLabel: "Shell > Bar", icon: Icons.layout, isIcon: true },
        { label: "Bar Position", keywords: "top bottom left right edge", section: "shell", subSection: "bar", subLabel: "Shell > Bar", icon: Icons.layout, isIcon: true },
        { label: "Launcher Icon", keywords: "logo symbol path", section: "shell", subSection: "bar", subLabel: "Shell > Bar", icon: Icons.layout, isIcon: true },
        { label: "Launcher Icon Tint", keywords: "color theme", section: "shell", subSection: "bar", subLabel: "Shell > Bar", icon: Icons.palette, isIcon: true },
        { label: "Launcher Icon Full Tint", keywords: "monochrome color", section: "shell", subSection: "bar", subLabel: "Shell > Bar", icon: Icons.palette, isIcon: true },
        { label: "Launcher Icon Size", keywords: "width height pixels", section: "shell", subSection: "bar", subLabel: "Shell > Bar", icon: Icons.layout, isIcon: true },
        { label: "Pill Style", keywords: "squished roundness radius bar", section: "shell", subSection: "bar", subLabel: "Shell > Bar", icon: Icons.layout, isIcon: true },
        { label: "Firefox Player", keywords: "browser media music", section: "shell", subSection: "bar", subLabel: "Shell > Bar", icon: Icons.layout, isIcon: true },
        { label: "Bar Auto-hide", keywords: "autohide hide show reveal", section: "shell", subSection: "bar", subLabel: "Shell > Bar", icon: Icons.layout, isIcon: true },
        { label: "Pinned on Startup", keywords: "show visible default", section: "shell", subSection: "bar", subLabel: "Shell > Bar", icon: Icons.layout, isIcon: true },
        { label: "Hover to Reveal", keywords: "mouse show hide edge", section: "shell", subSection: "bar", subLabel: "Shell > Bar", icon: Icons.layout, isIcon: true },
        { label: "Hover Region Height", keywords: "pixels trigger area", section: "shell", subSection: "bar", subLabel: "Shell > Bar", icon: Icons.layout, isIcon: true },
        { label: "Show Pin Button", keywords: "toggle pin unpin", section: "shell", subSection: "bar", subLabel: "Shell > Bar", icon: Icons.layout, isIcon: true },
        { label: "Available on Fullscreen", keywords: "overlay game video", section: "shell", subSection: "bar", subLabel: "Shell > Bar", icon: Icons.layout, isIcon: true },
        { label: "Show Running Indicators", keywords: "dots active apps", section: "shell", subSection: "bar", subLabel: "Shell > Bar", icon: Icons.layout, isIcon: true },
        { label: "Show Overview Button", keywords: "workspace switcher", section: "shell", subSection: "bar", subLabel: "Shell > Bar", icon: Icons.layout, isIcon: true },
        { label: "Bar Screens", keywords: "monitor display eDP", section: "shell", subSection: "bar", subLabel: "Shell > Bar", icon: Icons.layout, isIcon: true },
        
        { label: "Frame", keywords: "border screen edge thickness contain bar", section: "shell", subSection: "frame", subLabel: "Shell > Frame", icon: Icons.frameCorners, isIcon: true },

        { label: "Notch", keywords: "island dynamic island center", section: "shell", subSection: "notch", subLabel: "Shell > Notch", icon: Icons.layout, isIcon: true },
        
        { label: "Workspaces", keywords: "virtual desktop spaces", section: "shell", subSection: "workspaces", subLabel: "Shell > Workspaces", icon: Icons.squaresFour, isIcon: true },
        { label: "Workspaces Shown", keywords: "number count visible", section: "shell", subSection: "workspaces", subLabel: "Shell > Workspaces", icon: Icons.squaresFour, isIcon: true },
        { label: "Show App Icons", keywords: "application thumbnail workspace", section: "shell", subSection: "workspaces", subLabel: "Shell > Workspaces", icon: Icons.squaresFour, isIcon: true },
        { label: "Always Show Numbers", keywords: "workspace label index", section: "shell", subSection: "workspaces", subLabel: "Shell > Workspaces", icon: Icons.squaresFour, isIcon: true },
        { label: "Show Numbers", keywords: "workspace label index", section: "shell", subSection: "workspaces", subLabel: "Shell > Workspaces", icon: Icons.squaresFour, isIcon: true },
        { label: "Dynamic Workspaces", keywords: "auto add remove flexible", section: "shell", subSection: "workspaces", subLabel: "Shell > Workspaces", icon: Icons.squaresFour, isIcon: true },
        
        { label: "Overview", keywords: "expose mission control windows", section: "shell", subSection: "overview", subLabel: "Shell > Overview", icon: Icons.squaresFour, isIcon: true },
        { label: "Overview Rows", keywords: "grid layout vertical", section: "shell", subSection: "overview", subLabel: "Shell > Overview", icon: Icons.squaresFour, isIcon: true },
        { label: "Overview Columns", keywords: "grid layout horizontal", section: "shell", subSection: "overview", subLabel: "Shell > Overview", icon: Icons.squaresFour, isIcon: true },
        { label: "Overview Scale", keywords: "zoom size preview", section: "shell", subSection: "overview", subLabel: "Shell > Overview", icon: Icons.squaresFour, isIcon: true },
        { label: "Overview Workspace Spacing", keywords: "gap margin distance", section: "shell", subSection: "overview", subLabel: "Shell > Overview", icon: Icons.squaresFour, isIcon: true },
        
        { label: "Dock", keywords: "taskbar launcher apps favorites", section: "shell", subSection: "dock", subLabel: "Shell > Dock", icon: Icons.layout, isIcon: true },
        { label: "Dock Enabled", keywords: "show hide toggle", section: "shell", subSection: "dock", subLabel: "Shell > Dock", icon: Icons.layout, isIcon: true },
        { label: "Dock Mode", keywords: "default floating integrated style", section: "shell", subSection: "dock", subLabel: "Shell > Dock", icon: Icons.layout, isIcon: true },
        { label: "Dock Position", keywords: "left bottom right edge", section: "shell", subSection: "dock", subLabel: "Shell > Dock", icon: Icons.layout, isIcon: true },
        { label: "Dock Height", keywords: "size thickness pixels", section: "shell", subSection: "dock", subLabel: "Shell > Dock", icon: Icons.layout, isIcon: true },
        { label: "Dock Icon Size", keywords: "width height pixels apps", section: "shell", subSection: "dock", subLabel: "Shell > Dock", icon: Icons.layout, isIcon: true },
        { label: "Dock Spacing", keywords: "gap between icons", section: "shell", subSection: "dock", subLabel: "Shell > Dock", icon: Icons.layout, isIcon: true },
        { label: "Dock Margin", keywords: "edge distance offset", section: "shell", subSection: "dock", subLabel: "Shell > Dock", icon: Icons.layout, isIcon: true },
        { label: "Dock Hover Region Height", keywords: "trigger area pixels", section: "shell", subSection: "dock", subLabel: "Shell > Dock", icon: Icons.layout, isIcon: true },
        { label: "Dock Pinned on Startup", keywords: "show visible default", section: "shell", subSection: "dock", subLabel: "Shell > Dock", icon: Icons.layout, isIcon: true },
        
        { label: "Lockscreen", keywords: "lock screen password login", section: "shell", subSection: "lockscreen", subLabel: "Shell > Lockscreen", icon: Icons.lock, isIcon: true },
        
        { label: "Desktop", keywords: "icons wallpaper home", section: "shell", subSection: "desktop", subLabel: "Shell > Desktop", icon: Icons.layout, isIcon: true },
        { label: "Desktop Enabled", keywords: "show hide icons toggle", section: "shell", subSection: "desktop", subLabel: "Shell > Desktop", icon: Icons.layout, isIcon: true },
        { label: "Desktop Icon Size", keywords: "width height pixels", section: "shell", subSection: "desktop", subLabel: "Shell > Desktop", icon: Icons.layout, isIcon: true },
        { label: "Desktop Vertical Spacing", keywords: "gap margin", section: "shell", subSection: "desktop", subLabel: "Shell > Desktop", icon: Icons.layout, isIcon: true },
        { label: "Desktop Text Color", keywords: "label font", section: "shell", subSection: "desktop", subLabel: "Shell > Desktop", icon: Icons.palette, isIcon: true },
        
        { label: "Shell System", keywords: "config settings pangu", section: "shell", subSection: "system", subLabel: "Shell > System", icon: Icons.circuitry, isIcon: true }
    ]

    property var items: staticItems.concat(dynamicItems)

    function addDynamicItems(newItems) {
        let currentLabels = new Set(items.map(i => i.section + ":" + i.label));
        let uniqueNew = [];
        
        for (let i = 0; i < newItems.length; i++) {
            let item = newItems[i];
            let key = item.section + ":" + item.label;
            if (!currentLabels.has(key)) {
                uniqueNew.push(item);
                currentLabels.add(key);
            }
        }
        
        if (uniqueNew.length > 0) {
            dynamicItems = dynamicItems.concat(uniqueNew);
        }
    }
}
