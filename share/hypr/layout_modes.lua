local state = require("pangu.generated")
local layouts_module = require("pangu.layouts")
local session = require("pangu.session")

local cycle = state.layouts.cycle

local modes = session.table("layout_modes")

local rules = {}

local function apply(id, target)
  local previous = rules[id]
  if previous and previous.target == target then
    previous.rule:set_enabled(true)
    return
  end
  if previous then
    previous.rule:set_enabled(false)
  end
  rules[id] = {
    target = target,
    rule = hl.workspace_rule({
      workspace = "r[" .. id .. "-" .. id .. "]",
      layout = target,
    }),
  }
end

for id, target in pairs(modes) do
  apply(id, target)
end

local function next_layout(current)
  for i, layout in ipairs(cycle) do
    if layout == current then
      return cycle[i % #cycle + 1]
    end
  end
  return cycle[1]
end

local M = {}

function M.set(target)
  local workspace = hl.get_active_workspace()
  if not workspace or workspace.special or workspace.tiled_layout == target then
    return
  end

  if target == "lua:centered" then
    layouts_module.center_active()
  end

  apply(workspace.id, target)
  modes[workspace.id] = target
  session.save()

  layouts_module.schedule_scan()
end

function M.toggle()
  local workspace = hl.get_active_workspace()
  if not workspace or workspace.special then
    return
  end
  M.set(next_layout(workspace.tiled_layout))
end

return M
