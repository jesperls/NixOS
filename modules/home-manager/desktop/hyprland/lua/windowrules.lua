local state = require("jesperls.generated")

local function window_rule(rule)
  hl.window_rule(rule)
end

for _, class in ipairs({
  "pavucontrol",
  "blueman-manager",
  "nm-connection-editor",
  "org.gnome.Calculator",
  "org.gnome.NautilusPreviewer",
  "eog",
  "vlc",
  "imv",
  "feh",
  "file-roller",
  "qpwgraph",
  "org.pulseaudio.pavucontrol",
  "solaar",
  "overskride",
  "scrcpy",
}) do
  window_rule({ match = { class = class }, float = true })
end

for _, title in ipairs({
  "^(Open File)$",
  "^(Save File)$",
  "^(Confirm to replace files)$",
  "^(File Operation Progress)$",
  "^(JSST Subtitles)$",
}) do
  window_rule({ match = { title = title }, float = true })
end

window_rule({ match = { title = "^(JSST Subtitles)$" }, pin = true })
window_rule({ match = { title = "^(Quickshell Package Manager)$" }, float = true })
window_rule({ match = { title = "^(Quickshell Package Manager)$" }, center = true })

window_rule({ match = { title = "^(Picture-in-Picture)$" }, float = true })
window_rule({ match = { title = "^(Picture-in-Picture)$" }, pin = true })
window_rule({ match = { title = "^(Picture-in-Picture)$" }, size = { 480, 270 } })
window_rule({
  match = { title = "^(Picture-in-Picture)$" },
  move = { "monitor_w - 490", "monitor_h - 280" },
})

local translucent = string.format("%.2f %.2f", state.theme.translucent_opacity, state.theme.translucent_opacity)
for _, class in ipairs(state.theme.translucent_apps) do
  window_rule({ match = { class = class }, opacity = translucent })
end

if state.gaming.tearing then
  for _, pattern in ipairs(state.gaming.tearing_class_patterns) do
    window_rule({ match = { class = pattern }, immediate = true })
  end
end

window_rule({ match = { class = "xdg-desktop-portal-gtk" }, float = true })
window_rule({ match = { class = "hyprpolkitagent" }, float = true })

window_rule({ match = { title = "Sharing your screen" }, opacity = "1.0 override 1.0 override" })
window_rule({ match = { title = "sharing indicator" }, opacity = "1.0 override 1.0 override" })

window_rule({
  match = {
    class = "thunar",
    title = "^(File Operation Progress)$",
  },
  float = true,
})

window_rule({
  match = {
    class = "thunar",
    title = "^(Confirm to replace files)$",
  },
  float = true,
})

return true