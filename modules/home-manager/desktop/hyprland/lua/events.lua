local state = require("jesperls.generated")

if not state.auto_fake_fullscreen.enable then
  return true
end

local classes = {}
for _, class in ipairs(state.auto_fake_fullscreen.classes) do
  classes[class] = true
end

-- Demote fullscreen to client-only when the window shares the workspace
-- with tiled windows: the video fills the tile, real fullscreen when alone.
local demoting = false

hl.on("window.fullscreen", function(window)
  if demoting or not window or not classes[window.class] or window.fullscreen ~= 2 then
    return
  end

  local workspace = window.workspace
  if not workspace then
    return
  end

  local tiled = 0
  for _, other in ipairs(workspace:get_windows()) do
    if not other.floating then
      tiled = tiled + 1
    end
  end
  if tiled < 2 then
    return
  end

  demoting = true
  pcall(hl.dispatch, hl.dsp.window.fullscreen_state({
    internal = 0,
    client = 2,
    window = "address:" .. window.address,
  }))
  demoting = false
end)

return true
