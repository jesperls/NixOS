local SIZE = { x = 640, y = 360 }
local MARGIN = 20
local TILED_TAG = "popout_was_tiled"

local M = {
  scratchpad_size = { x = 900, y = 700 },
}

local function tag_list(window)
  local tags = window.tags
  if type(tags) == "table" then
    return tags
  end
  if type(tags) == "string" then
    return { tags }
  end
  return {}
end

local function has_tag(window, name)
  for _, tag in pairs(tag_list(window)) do
    if tostring(tag) == name then
      return true
    end
  end
  return false
end

local function origin(window)
  for _, tag in pairs(tag_list(window)) do
    local home = tostring(tag):match("^popout_from_(.+)$")
    if home then
      return home
    end
  end
end

local function pin(window)
  local workspace = window.workspace
  local monitor = workspace and workspace.monitor
  local home = workspace and workspace.id < 0 and workspace.name:match("^special:(.+)$") or nil
  if home then
    hl.dispatch(hl.dsp.window.tag({ tag = "+popout_from_" .. home, window = window }))
  end
  if not window.floating then
    hl.dispatch(hl.dsp.window.tag({ tag = "+" .. TILED_TAG, window = window }))
    hl.dispatch(hl.dsp.window.float({ action = "enable", window = window }))
  end
  hl.dispatch(hl.dsp.window.pin({ action = "enable", window = window }))
  hl.dispatch(hl.dsp.window.resize({ x = SIZE.x, y = SIZE.y, window = window }))
  if monitor then
    hl.dispatch(hl.dsp.window.move({
      x = monitor.x + math.floor(monitor.width / monitor.scale) - SIZE.x - MARGIN,
      y = monitor.y + math.floor(monitor.height / monitor.scale) - SIZE.y - MARGIN,
      window = window,
    }))
  end
end

local function unpin(window)
  local home = origin(window)
  -- pinning refuses fullscreen windows, so drop any fullscreen first
  hl.dispatch(hl.dsp.window.fullscreen_state({ internal = 0, client = 0, window = window }))
  hl.dispatch(hl.dsp.window.pin({ action = "disable", window = window }))
  if home then
    hl.dispatch(hl.dsp.window.tag({ tag = "-popout_from_" .. home, window = window }))
    hl.dispatch(hl.dsp.window.move({ workspace = "special:" .. home, follow = false, window = window }))
  end
  if has_tag(window, TILED_TAG) then
    hl.dispatch(hl.dsp.window.tag({ tag = "-" .. TILED_TAG, window = window }))
    hl.dispatch(hl.dsp.window.float({ action = "disable", window = window }))
  elseif home == "scratchpad" then
    hl.dispatch(hl.dsp.window.resize({ x = M.scratchpad_size.x, y = M.scratchpad_size.y, window = window }))
    hl.dispatch(hl.dsp.window.center({ window = window }))
  end
end

function M.toggle(window)
  window = window or hl.get_active_window()
  if not window then
    return
  end
  if window.pinned or window.pin_fullscreened then
    unpin(window)
  else
    pin(window)
  end
end

return M
