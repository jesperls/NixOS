local state = require("jesperls.generated")

local apps = state.apps
local mainMod = "SUPER"

local function combo(mods, key)
  if mods == "" then
    return key
  end
  return (mods:gsub("%s+", " + ")) .. " + " .. key
end

local function bind(mods, key, dispatcher, flags)
  hl.bind(combo(mods, key), dispatcher, flags)
end

local function bind_exec(mods, key, command, flags)
  bind(mods, key, hl.dsp.exec_cmd(command), flags)
end

local function in_centered()
  local workspace = hl.get_active_workspace()
  return workspace ~= nil and workspace.tiled_layout == "lua:centered"
end

-- Launchers ------------------------------------------------------------

bind_exec(mainMod, "T", apps.terminal)
bind_exec(mainMod, "B", apps.browser)
bind_exec(mainMod, "E", apps.file_manager)
bind_exec(mainMod, "C", apps.editor)
bind_exec(mainMod, "R", "ratty")
bind_exec(mainMod, "D", "discord")
bind(mainMod, "G", require("jesperls.gamemode").toggle)
bind_exec(mainMod, "M", "easyeffects")
bind_exec(mainMod, "P", "qs-pkg-manager")
bind(mainMod .. " SHIFT", "W", function()
  local win = hl.get_windows({ class = "Linux Wallpaper Engine" })[1]
  if win then
    hl.dispatch(hl.dsp.focus({ window = win }))
  else
    hl.exec_cmd("linux-wallpaper-engine")
  end
end)
bind_exec(mainMod, "Super_L", "ambxst run launcher", { release = true })

-- Ambxst modules ---------------------------------------------------------

bind_exec(mainMod, "A", "ambxst run dashboard")
bind_exec(mainMod, "N", "ambxst run notes")
bind_exec(mainMod, "Tab", "ambxst run overview")
bind_exec(mainMod, "Escape", "ambxst run powermenu")

if state.lockscreen.enable then
  -- Ambxst's lockscreen listens for the logind lock signal.
  bind_exec(mainMod, "L", "loginctl lock-session")
end

-- Windows --------------------------------------------------------------

bind(mainMod, "Q", hl.dsp.window.close())
bind(mainMod, "W", hl.dsp.window.float({ action = "toggle" }))
-- Dispatch through the suppress flag so the auto fake fullscreen handler
-- in events.lua never demotes keybind-initiated fullscreen.
local fullscreen = require("jesperls.fullscreen")
local real_fullscreen = hl.dsp.window.fullscreen({ mode = "fullscreen" })
local real_maximize = hl.dsp.window.fullscreen({ mode = "maximized" })
bind(mainMod, "F", function()
  fullscreen.dispatch_real(real_fullscreen)
end)
bind(mainMod .. " SHIFT", "F", function()
  fullscreen.dispatch_real(real_maximize)
end)
-- Fake fullscreen: the client renders fullscreen but the window stays tiled.
bind(mainMod .. " CTRL", "F", hl.dsp.window.fullscreen_state({ internal = 0, client = 2, action = "toggle" }))
bind(mainMod, "J", hl.dsp.layout("togglesplit"))
bind("ALT", "Tab", hl.dsp.focus({ last = true }))
bind("ALT", "Tab", hl.dsp.window.alter_zorder({ mode = "top" }))

for key, direction in pairs({ left = "l", right = "r", up = "u", down = "d" }) do
  bind(mainMod, key, hl.dsp.focus({ direction = direction }))

  local move = hl.dsp.window.move({ direction = direction })
  bind(mainMod .. " SHIFT", key, function()
    if in_centered() then
      hl.dispatch(hl.dsp.layout("move " .. direction))
    else
      hl.dispatch(move)
    end
  end)
end

local function sign_step(value, step)
  return (value > 0 and "+" or "-") .. step
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
  local resize = hl.dsp.window.resize({ x = delta[1], y = delta[2], relative = true })
  bind(mainMod .. " CTRL", key, function()
    local window = hl.get_active_window()
    if not in_centered() or not window or window.floating then
      hl.dispatch(resize)
    elseif delta[2] ~= 0 then
      -- The master column width is fixed, so only heights are adjustable.
      hl.dispatch(hl.dsp.layout("vresize " .. sign_step(delta[2], state.layouts.centered.height_resize_step)))
    end
  end, { repeating = true })
end

local layouts = require("jesperls.layouts")

bind(mainMod, "mouse:272", hl.dsp.window.drag(), { mouse = true })
bind(mainMod, "mouse:273", hl.dsp.window.resize(), { mouse = true })
bind(mainMod, "mouse:273", layouts.start_drag)
bind(mainMod, "mouse:273", layouts.end_drag, { release = true })
bind(mainMod, "Z", hl.dsp.window.drag(), { mouse = true })
bind(mainMod, "X", hl.dsp.window.resize(), { mouse = true })

bind("", "mouse:275", hl.dsp.window.drag(), { mouse = true })
bind("", "mouse:276", hl.dsp.window.resize(), { mouse = true })
bind("", "mouse:276", layouts.start_drag)
bind("", "mouse:276", layouts.end_drag, { release = true })
bind("", "mouse:277", hl.dsp.window.close())

-- Layouts ----------------------------------------------------------------

local layout_modes = require("jesperls.layout_modes")

bind(mainMod, "O", layout_modes.toggle)

local function centered_only(msg)
  return function()
    if in_centered() then
      hl.dispatch(hl.dsp.layout(msg))
    end
  end
end

bind(mainMod, "Return", centered_only("promote"))
bind(mainMod, "mouse:274", function()
  if not in_centered() then
    layout_modes.set("lua:centered")
  elseif layouts.master_focused() then
    layout_modes.toggle()
  else
    hl.dispatch(hl.dsp.layout("promote"))
  end
end)
bind(mainMod .. " CTRL", "Return", centered_only("equalize"))

-- Workspaces -----------------------------------------------------------

for workspace = 1, 10 do
  local key = tostring(workspace % 10)
  local workspace_id = tostring(workspace)

  bind(mainMod, key, hl.dsp.focus({ workspace = workspace_id }))
  bind(mainMod .. " SHIFT", key, hl.dsp.window.move({ workspace = workspace_id }))
end

bind(mainMod, "mouse_up", hl.dsp.focus({ workspace = "r-1" }))
bind(mainMod, "mouse_down", hl.dsp.focus({ workspace = "r+1" }))
bind(mainMod, "period", hl.dsp.focus({ workspace = "r+1" }))
bind(mainMod, "comma", hl.dsp.focus({ workspace = "r-1" }))

bind(mainMod, "grave", hl.dsp.workspace.toggle_special("magic"))
bind(mainMod .. " SHIFT", "grave", hl.dsp.window.move({ workspace = "special:magic" }))
bind(mainMod, "S", hl.dsp.workspace.toggle_special("scratchpad"))
bind(mainMod .. " SHIFT", "S", hl.dsp.window.move({ workspace = "special:scratchpad" }))
bind(mainMod .. " CTRL", "S", hl.dsp.exec_cmd(apps.terminal, { workspace = "special:scratchpad silent" }))

-- Monitors -------------------------------------------------------------

bind(mainMod .. " CTRL", "period", hl.dsp.focus({ monitor = "-1" }))
bind(mainMod .. " CTRL", "comma", hl.dsp.focus({ monitor = "+1" }))
bind(mainMod .. " SHIFT", "period", hl.dsp.window.move({ monitor = "-1" }))
bind(mainMod .. " SHIFT", "comma", hl.dsp.window.move({ monitor = "+1" }))

-- Utilities ------------------------------------------------------------

bind_exec(mainMod, "V", "ambxst run clipboard")
bind_exec(mainMod .. " SHIFT", "C", "hyprpicker -a")

bind_exec("", "Print", "ambxst run screenshot")
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
