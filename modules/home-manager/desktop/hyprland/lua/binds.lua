local state = require("jesperls.generated")

local terminal = "kitty"
local browser = "firefox"
local mainMod = "SUPER"

local function combo(mods, key)
  if mods == "" then
    return key
  end

  local parts = {}

  for part in mods:gmatch("%S+") do
    parts[#parts + 1] = part
  end

  parts[#parts + 1] = key

  return table.concat(parts, " + ")
end

local function bind_exec(mods, key, command, flags)
  hl.bind(combo(mods, key), hl.dsp.exec_cmd(command), flags)
end

local function bind_dispatch(mods, key, dispatcher, flags)
  hl.bind(combo(mods, key), dispatcher, flags)
end

if state.lockscreen.enable then
  bind_exec(mainMod, "L", "caelestia-shell ipc --any-display call lock lock")
end

bind_exec(mainMod, "T", terminal)
bind_exec(mainMod, "R", "ratty")
bind_exec(mainMod, "E", "thunar")
bind_exec(mainMod, "D", "discord")
bind_exec(mainMod, "B", browser)
bind_exec(mainMod, "C", "code")
bind_exec(mainMod, "G", "myna")
bind_exec(mainMod, "P", "qs-pkg-manager")
bind_exec(mainMod .. " SHIFT", "W", "wallpaper-manager pick")

bind_dispatch(mainMod, "Q", hl.dsp.window.close())
bind_dispatch(mainMod, "W", hl.dsp.window.float({ action = "toggle" }))
bind_dispatch(mainMod, "F", hl.dsp.window.fullscreen({ mode = "fullscreen" }))
bind_dispatch(mainMod .. " SHIFT", "F", hl.dsp.window.fullscreen({ mode = "maximized" }))
bind_dispatch(mainMod, "J", hl.dsp.layout("togglesplit"))
bind_exec(mainMod, "M", "easyeffects")
bind_dispatch("ALT", "Tab", hl.dsp.focus({ last = true }))
bind_dispatch("ALT", "Tab", hl.dsp.window.alter_zorder({ mode = "top" }))

bind_dispatch(mainMod, "left", hl.dsp.focus({ direction = "l" }))
bind_dispatch(mainMod, "right", hl.dsp.focus({ direction = "r" }))
bind_dispatch(mainMod, "up", hl.dsp.focus({ direction = "u" }))
bind_dispatch(mainMod, "down", hl.dsp.focus({ direction = "d" }))

bind_dispatch(mainMod .. " SHIFT", "left", hl.dsp.window.move({ direction = "l" }))
bind_dispatch(mainMod .. " SHIFT", "right", hl.dsp.window.move({ direction = "r" }))
bind_dispatch(mainMod .. " SHIFT", "up", hl.dsp.window.move({ direction = "u" }))
bind_dispatch(mainMod .. " SHIFT", "down", hl.dsp.window.move({ direction = "d" }))

for workspace = 1, 10 do
  local key = tostring(workspace % 10)
  local workspaceId = tostring(workspace)

  bind_dispatch(mainMod, key, hl.dsp.focus({ workspace = workspaceId }))
  bind_dispatch(mainMod .. " SHIFT", key, hl.dsp.window.move({ workspace = workspaceId }))
end

bind_dispatch(mainMod, "mouse_down", hl.dsp.focus({ workspace = "r-1" }))
bind_dispatch(mainMod, "mouse_up", hl.dsp.focus({ workspace = "r+1" }))

bind_dispatch(mainMod, "grave", hl.dsp.workspace.toggle_special("magic"))
bind_dispatch(mainMod .. " SHIFT", "grave", hl.dsp.window.move({ workspace = "special:magic" }))

bind_dispatch(mainMod, "S", hl.dsp.workspace.toggle_special("scratchpad"))
bind_dispatch(mainMod .. " SHIFT", "S", hl.dsp.window.move({ workspace = "special:scratchpad" }))
bind_dispatch(mainMod .. " CTRL", "S", hl.dsp.exec_cmd("kitty", { workspace = "special:scratchpad silent" }))

bind_exec(mainMod, "V", "cliphist list | wofi --dmenu | cliphist decode | wl-copy")

bind_exec(mainMod .. " SHIFT", "Print", "grim - | wl-copy && notify-send 'Screenshot Taken' 'Full screen copied to clipboard' -i video-display")
bind_exec("", "Print", "grim -g \"$(slurp)\" - | wl-copy && notify-send 'Screenshot Taken' 'Area copied to clipboard' -i video-display")

bind_exec(mainMod .. " SHIFT", "C", "hyprpicker -a")

bind_dispatch(mainMod, "period", hl.dsp.focus({ workspace = "r+1" }))
bind_dispatch(mainMod, "comma", hl.dsp.focus({ workspace = "r-1" }))
bind_dispatch(mainMod .. " CTRL", "period", hl.dsp.focus({ monitor = "-1" }))
bind_dispatch(mainMod .. " CTRL", "comma", hl.dsp.focus({ monitor = "+1" }))
bind_dispatch(mainMod .. " SHIFT", "period", hl.dsp.window.move({ monitor = "-1" }))
bind_dispatch(mainMod .. " SHIFT", "comma", hl.dsp.window.move({ monitor = "+1" }))

bind_dispatch(mainMod, "mouse:272", hl.dsp.window.drag(), { mouse = true })
bind_dispatch(mainMod, "mouse:273", hl.dsp.window.resize(), { mouse = true })
bind_dispatch(mainMod, "Z", hl.dsp.window.drag(), { mouse = true })
bind_dispatch(mainMod, "X", hl.dsp.window.resize(), { mouse = true })

bind_exec("", "XF86AudioRaiseVolume", "pamixer -i 5", { repeating = true })
bind_exec("", "XF86AudioLowerVolume", "pamixer -d 5", { repeating = true })
bind_exec("", "XF86AudioMute", "pamixer -t", { repeating = true })
bind_exec("", "XF86AudioMicMute", "pamixer --default-source -t", { repeating = true })

bind_exec("", "XF86MonBrightnessUp", "brightnessctl set 5%+", { repeating = true })
bind_exec("", "XF86MonBrightnessDown", "brightnessctl set 5%-", { repeating = true })

bind_dispatch(mainMod .. " CTRL", "right", hl.dsp.window.resize({ x = 30, y = 0, relative = true }), { repeating = true })
bind_dispatch(mainMod .. " CTRL", "left", hl.dsp.window.resize({ x = -30, y = 0, relative = true }), { repeating = true })
bind_dispatch(mainMod .. " CTRL", "up", hl.dsp.window.resize({ x = 0, y = -30, relative = true }), { repeating = true })
bind_dispatch(mainMod .. " CTRL", "down", hl.dsp.window.resize({ x = 0, y = 30, relative = true }), { repeating = true })
bind_dispatch(mainMod .. " CTRL", "l", hl.dsp.window.resize({ x = 30, y = 0, relative = true }), { repeating = true })
bind_dispatch(mainMod .. " CTRL", "h", hl.dsp.window.resize({ x = -30, y = 0, relative = true }), { repeating = true })
bind_dispatch(mainMod .. " CTRL", "k", hl.dsp.window.resize({ x = 0, y = -30, relative = true }), { repeating = true })
bind_dispatch(mainMod .. " CTRL", "j", hl.dsp.window.resize({ x = 0, y = 30, relative = true }), { repeating = true })

bind_exec("", "XF86AudioPlay", "playerctl play-pause", { locked = true })
bind_exec("", "XF86AudioPause", "playerctl play-pause", { locked = true })
bind_exec("", "XF86AudioNext", "playerctl next", { locked = true })
bind_exec("", "XF86AudioPrev", "playerctl previous", { locked = true })
bind_exec("", "XF86AudioStop", "playerctl stop", { locked = true })

bind_exec(mainMod, "Super_L", "caelestia-shell ipc --any-display call drawers toggle launcher", { release = true })

return true