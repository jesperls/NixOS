local state = require("jesperls.generated")

local layouts = state.layouts.cycle
local default = state.layouts.default

local rules = {}

local function next_layout(current)
  for i, layout in ipairs(layouts) do
    if layout == current then
      return layouts[i % #layouts + 1]
    end
  end
  return layouts[1]
end

local function announce(layout)
  require("jesperls.layouts").schedule_scan()
  hl.dispatch(hl.dsp.event("layout," .. layout .. "," .. (layout == default and "1" or "0")))
end

hl.on("workspace.active", function(workspace)
  if workspace and not workspace.special then
    announce(workspace.tiled_layout)
  end
end)

local M = {}

function M.set(target)
  local workspace = hl.get_active_workspace()
  if not workspace or workspace.special or workspace.tiled_layout == target then
    return
  end

  if target == "lua:centered" then
    require("jesperls.layouts").center_active()
  end

  local previous = rules[workspace.id]
  if previous and previous.set_enabled then
    previous:set_enabled(false)
  end
  rules[workspace.id] = hl.workspace_rule({
    workspace = "r[" .. workspace.id .. "-" .. workspace.id .. "]",
    layout = target,
  })

  announce(target)
end

function M.toggle()
  local workspace = hl.get_active_workspace()
  if not workspace or workspace.special then
    return
  end
  M.set(next_layout(workspace.tiled_layout))
end

return M
