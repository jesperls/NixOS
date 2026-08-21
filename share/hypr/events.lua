local state = require("pangu.generated")
local fullscreen = require("pangu.fullscreen")

local classes = {}
for _, class in ipairs(state.auto_fake_fullscreen.classes) do
  classes[class] = true
end

local demoting = false

hl.on("window.fullscreen", function(window)
  if
    demoting
    or fullscreen.suppress
    or not window
    or (window.fullscreen ~= 2 and window.fullscreen_client ~= 2)
  then
    return
  end

  local pinned = window.pinned or window.pin_fullscreened

  if not pinned then
    if not state.auto_fake_fullscreen.enable or not classes[window.class] then
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
  end

  demoting = true
  pcall(hl.dispatch, hl.dsp.window.fullscreen_state({
    internal = 0,
    client = 2,
    window = "address:" .. window.address,
  }))
  demoting = false

  if pinned then
    -- fullscreen_state leaves sync_fullscreen off, which would make the next
    -- request native-fake and let allow_pin_fullscreen unpin the window
    pcall(hl.dispatch, hl.dsp.window.set_prop({
      prop = "sync_fullscreen",
      value = "1",
      window = "address:" .. window.address,
    }))
  end
end)

return true
