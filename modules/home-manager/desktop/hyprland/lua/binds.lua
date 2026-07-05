local state = require("jesperls.generated")

local apps = state.apps
local mainMod = "SUPER"

local function combo(mods, key)
  if mods == "" then
    return key
  end
  return (mods:gsub("%s+", " + ")) .. " + " .. key
end

local function bind_exec(mods, key, command, flags)
  hl.bind(combo(mods, key), hl.dsp.exec_cmd(command), flags)
end

local function bind_dispatch(mods, key, dispatcher, flags)
  hl.bind(combo(mods, key), dispatcher, flags)
end

-- Launchers ------------------------------------------------------------

bind_exec(mainMod, "T", apps.terminal)
bind_exec(mainMod, "B", apps.browser)
bind_exec(mainMod, "E", apps.file_manager)
bind_exec(mainMod, "C", apps.editor)
bind_exec(mainMod, "R", "ratty")
bind_exec(mainMod, "D", "discord")
bind_exec(mainMod, "G", "caelestia-shell ipc call gameMode toggle")
bind_exec(mainMod, "M", "easyeffects")
bind_exec(mainMod, "P", "qs-pkg-manager")
bind_exec(mainMod .. " SHIFT", "W", "wallpaper-manager pick")
bind_exec(mainMod, "Super_L", "caelestia-shell ipc --any-display call drawers toggle launcher", { release = true })

if state.lockscreen.enable then
  bind_exec(mainMod, "L", "caelestia-shell ipc --any-display call lock lock")
end

-- Windows --------------------------------------------------------------

bind_dispatch(mainMod, "Q", hl.dsp.window.close())
bind_dispatch(mainMod, "W", hl.dsp.window.float({ action = "toggle" }))
bind_dispatch(mainMod, "F", hl.dsp.window.fullscreen({ mode = "fullscreen" }))
bind_dispatch(mainMod .. " SHIFT", "F", hl.dsp.window.fullscreen({ mode = "maximized" }))
-- Fake fullscreen: the client renders fullscreen but the window stays tiled.
bind_dispatch(mainMod .. " CTRL", "F", hl.dsp.window.fullscreen_state({ internal = 0, client = 2, action = "toggle" }))
bind_dispatch(mainMod, "J", hl.dsp.layout("togglesplit"))
bind_dispatch("ALT", "Tab", hl.dsp.focus({ last = true }))
bind_dispatch("ALT", "Tab", hl.dsp.window.alter_zorder({ mode = "top" }))

for key, direction in pairs({ left = "l", right = "r", up = "u", down = "d" }) do
  bind_dispatch(mainMod, key, hl.dsp.focus({ direction = direction }))

  local move = hl.dsp.window.move({ direction = direction })
  bind_dispatch(mainMod .. " SHIFT", key, function()
    if hl.get_config("general.layout") == "lua:centered" then
      hl.dispatch(hl.dsp.layout("move " .. direction))
    else
      hl.dispatch(move)
    end
  end)
end

for key, delta in pairs({
  right = { 30, 0 },
  left = { -30, 0 },
  up = { 0, -30 },
  down = { 0, 30 },
  l = { 30, 0 },
  h = { -30, 0 },
  k = { 0, -30 },
  j = { 0, 30 },
}) do
  bind_dispatch(
    mainMod .. " CTRL",
    key,
    hl.dsp.window.resize({ x = delta[1], y = delta[2], relative = true }),
    { repeating = true }
  )
end

bind_dispatch(mainMod, "mouse:272", hl.dsp.window.drag(), { mouse = true })
bind_dispatch(mainMod, "mouse:273", hl.dsp.window.resize(), { mouse = true })
bind_dispatch(mainMod, "Z", hl.dsp.window.drag(), { mouse = true })
bind_dispatch(mainMod, "X", hl.dsp.window.resize(), { mouse = true })

-- Layouts ----------------------------------------------------------------

bind_dispatch(mainMod, "O", require("jesperls.layout_modes").toggle)

local function centered_only(msg)
  return function()
    if hl.get_config("general.layout") == "lua:centered" then
      hl.dispatch(hl.dsp.layout(msg))
    end
  end
end

bind_dispatch(mainMod, "minus", centered_only("mfact -" .. state.layouts.centered.resize_step))
bind_dispatch(mainMod, "equal", centered_only("mfact +" .. state.layouts.centered.resize_step))
bind_dispatch(mainMod, "Return", centered_only("promote"))
bind_dispatch(mainMod, "mouse:274", centered_only("promote"))

-- Workspaces -----------------------------------------------------------

for workspace = 1, 10 do
  local key = tostring(workspace % 10)
  local workspaceId = tostring(workspace)

  bind_dispatch(mainMod, key, hl.dsp.focus({ workspace = workspaceId }))
  bind_dispatch(mainMod .. " SHIFT", key, hl.dsp.window.move({ workspace = workspaceId }))
end

bind_dispatch(mainMod, "mouse_down", hl.dsp.focus({ workspace = "r-1" }))
bind_dispatch(mainMod, "mouse_up", hl.dsp.focus({ workspace = "r+1" }))
bind_dispatch(mainMod, "period", hl.dsp.focus({ workspace = "r+1" }))
bind_dispatch(mainMod, "comma", hl.dsp.focus({ workspace = "r-1" }))

bind_dispatch(mainMod, "grave", hl.dsp.workspace.toggle_special("magic"))
bind_dispatch(mainMod .. " SHIFT", "grave", hl.dsp.window.move({ workspace = "special:magic" }))
bind_dispatch(mainMod, "S", hl.dsp.workspace.toggle_special("scratchpad"))
bind_dispatch(mainMod .. " SHIFT", "S", hl.dsp.window.move({ workspace = "special:scratchpad" }))
bind_dispatch(mainMod .. " CTRL", "S", hl.dsp.exec_cmd(apps.terminal, { workspace = "special:scratchpad silent" }))

-- Monitors -------------------------------------------------------------

bind_dispatch(mainMod .. " CTRL", "period", hl.dsp.focus({ monitor = "-1" }))
bind_dispatch(mainMod .. " CTRL", "comma", hl.dsp.focus({ monitor = "+1" }))
bind_dispatch(mainMod .. " SHIFT", "period", hl.dsp.window.move({ monitor = "-1" }))
bind_dispatch(mainMod .. " SHIFT", "comma", hl.dsp.window.move({ monitor = "+1" }))

-- Utilities ------------------------------------------------------------

bind_exec(mainMod, "V", "cliphist list | wofi --dmenu | cliphist decode | wl-copy")
bind_exec(mainMod .. " SHIFT", "C", "hyprpicker -a")

bind_exec("", "Print", "grim -g \"$(slurp)\" - | wl-copy && notify-send 'Screenshot Taken' 'Area copied to clipboard' -i video-display")
bind_exec(mainMod, "Print", "grim -g \"$(slurp)\" - | swappy -f -")
bind_exec(mainMod .. " SHIFT", "Print", "grim - | wl-copy && notify-send 'Screenshot Taken' 'Full screen copied to clipboard' -i video-display")

-- Media / hardware keys ------------------------------------------------

for key, command in pairs({
  XF86AudioRaiseVolume = "pamixer -i 5",
  XF86AudioLowerVolume = "pamixer -d 5",
  XF86AudioMute = "pamixer -t",
  XF86AudioMicMute = "pamixer --default-source -t",
}) do
  bind_exec("", key, command, { repeating = true })
end

for key, command in pairs({
  XF86AudioPlay = "playerctl play-pause",
  XF86AudioPause = "playerctl play-pause",
  XF86AudioNext = "playerctl next",
  XF86AudioPrev = "playerctl previous",
  XF86AudioStop = "playerctl stop",
}) do
  bind_exec("", key, command, { locked = true })
end

bind_exec("", "XF86MonBrightnessUp", "brightnessctl set 5%+", { repeating = true })
bind_exec("", "XF86MonBrightnessDown", "brightnessctl set 5%-", { repeating = true })

return true
