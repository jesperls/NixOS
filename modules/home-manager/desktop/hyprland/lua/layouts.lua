local state = require("jesperls.generated")

local centered = state.layouts.centered
local mwfact = centered.master_width

-- Per-workspace slot memory: windows keep their side across closes, and
-- dragged windows are classified by drop position when they re-enter.
local slots = {}
local fresh = {}

-- open_early fires before the layout sees the window; plain window.open is
-- too late to mark it as newly opened rather than dropped in by a drag.
hl.on("window.open_early", function(window)
  if window then
    fresh[window.stable_id] = true
  end
end)

hl.on("window.close", function(window)
  if window then
    fresh[window.stable_id] = nil
  end
end)

-- Boxes must stay edge-to-edge: gaps are applied by the layout target, and
-- directional focus only sees windows whose ungapped boxes touch.
local function stack(targets, box)
  for i, target in ipairs(targets) do
    target:place({
      x = box.x,
      y = box.y + box.h * (i - 1) / #targets,
      w = box.w,
      h = box.h / #targets,
    })
  end
end

local function workspace_id(ctx)
  for _, target in ipairs(ctx.targets) do
    local window = target.window
    if window and window.workspace then
      return window.workspace.id
    end
  end
  return 0
end

local function lighter(s)
  return #s.right <= #s.left and s.right or s.left
end

local function index_of(list, id)
  for i, v in ipairs(list) do
    if v == id then
      return i
    end
  end
end

local function insert_by_y(list, id, cy, area)
  local n = #list + 1
  local index = math.floor((cy - area.y) / (area.h / n)) + 1
  table.insert(list, math.min(math.max(index, 1), n), id)
end

local function classify(s, id, target, area, master_w)
  local box = target.box
  local cx = box.x + box.w / 2
  local cy = box.y + box.h / 2
  local master_x = area.x + (area.w - master_w) / 2

  if cx < master_x then
    insert_by_y(s.left, id, cy, area)
  elseif cx > master_x + master_w then
    insert_by_y(s.right, id, cy, area)
  else
    if s.master then
      table.insert(lighter(s), 1, s.master)
    end
    s.master = id
  end
end

local function sync(ctx, area, master_w)
  local ws = workspace_id(ctx)
  local s = slots[ws]
  if not s then
    s = { master = nil, left = {}, right = {} }
    slots[ws] = s
  end

  local present = {}
  for _, target in ipairs(ctx.targets) do
    if target.window then
      present[target.window.stable_id] = target
    end
  end

  local alive = {}
  for _, window in ipairs(hl.get_workspace_windows(ws)) do
    if not window.floating then
      alive[window.stable_id] = true
    end
  end

  for _, list in ipairs({ s.left, s.right }) do
    for i = #list, 1, -1 do
      if not alive[list[i]] then
        table.remove(list, i)
      end
    end
  end
  if s.master and not alive[s.master] then
    s.master = table.remove(s.right, 1) or table.remove(s.left, 1)
  end

  local known = {}
  if s.master then
    known[s.master] = true
  end
  for _, list in ipairs({ s.left, s.right }) do
    for _, id in ipairs(list) do
      known[id] = true
    end
  end

  for _, target in ipairs(ctx.targets) do
    local id = target.window and target.window.stable_id
    if id and not known[id] then
      if not s.master then
        s.master = id
      elseif fresh[id] then
        table.insert(lighter(s), id)
      else
        classify(s, id, target, area, master_w)
      end
      fresh[id] = nil
    end
  end

  return s, present
end

local ratio_w, ratio_h
local function publish_single_ratio(master_w, area)
  local w = math.floor(master_w + 0.5)
  local h = math.floor(area.h + 0.5)
  if w ~= ratio_w or h ~= ratio_h then
    ratio_w, ratio_h = w, h
    hl.config({ layout = { single_window_aspect_ratio = { w, h } } })
  end
end

local function active_id(ctx)
  for _, target in ipairs(ctx.targets) do
    if target.window and target.window.active then
      return target.window.stable_id
    end
  end
end

hl.layout.register("centered", {
  recalculate = function(ctx)
    local n = #ctx.targets
    if n == 0 then
      return
    end

    local area = ctx.area
    local master_w = area.w * mwfact
    publish_single_ratio(master_w, area)
    local s, present = sync(ctx, area, master_w)

    if n == 1 then
      ctx.targets[1]:place({ x = area.x, y = area.y, w = area.w, h = area.h })
      return
    end

    local left, right = {}, {}
    for _, id in ipairs(s.left) do
      table.insert(left, present[id])
    end
    for _, id in ipairs(s.right) do
      table.insert(right, present[id])
    end
    for _, target in ipairs(ctx.targets) do
      if not target.window then
        table.insert(#right <= #left and right or left, target)
      end
    end

    local master_x = area.x + (area.w - master_w) / 2
    local master = s.master and present[s.master] or ctx.targets[1]
    master:place({ x = master_x, y = area.y, w = master_w, h = area.h })

    local side_w = (area.w - master_w) / 2
    if #right > 0 then
      stack(right, { x = master_x + master_w, y = area.y, w = side_w, h = area.h })
    end
    if #left > 0 then
      stack(left, { x = area.x, y = area.y, w = side_w, h = area.h })
    end
  end,

  layout_msg = function(ctx, msg)
    local s = slots[workspace_id(ctx)]
    if not s then
      return
    end

    if msg == "promote" then
      local id = active_id(ctx)
      if not id or id == s.master then
        return true
      end
      for _, list in ipairs({ s.left, s.right }) do
        local i = index_of(list, id)
        if i then
          list[i] = s.master
          s.master = id
          return true
        end
      end
      return true
    end

    local dir = msg:match("^move%s+([lrud])$")
    if dir then
      local id = active_id(ctx)
      if not id then
        return true
      end

      if dir == "u" or dir == "d" then
        for _, list in ipairs({ s.left, s.right }) do
          local i = index_of(list, id)
          if i then
            local j = dir == "u" and i - 1 or i + 1
            if list[j] then
              list[i], list[j] = list[j], list[i]
            end
            return true
          end
        end
        return true
      end

      if id == s.master then
        local list = dir == "l" and s.left or s.right
        if list[1] then
          s.master = list[1]
          list[1] = id
        end
        return true
      end

      local toward_center = (dir == "r" and index_of(s.left, id)) or (dir == "l" and index_of(s.right, id))
      if toward_center then
        local list = dir == "r" and s.left or s.right
        list[toward_center] = s.master
        s.master = id
      end
      return true
    end

    local delta = msg:match("^mfact%s+([+-]?%d*%.?%d+)$")
    if delta then
      mwfact = math.min(centered.master_width_max, math.max(centered.master_width_min, mwfact + tonumber(delta)))
      return true
    end
  end,
})

return true
