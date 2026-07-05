local state = require("jesperls.generated")

local layouts = state.layouts.cycle
local default = state.layouts.default
local per_workspace = {}

local function next_layout(current)
  for i, layout in ipairs(layouts) do
    if layout == current then
      return layouts[i % #layouts + 1]
    end
  end
  return layouts[1]
end

local function apply(workspace)
  if not workspace or workspace.special then
    return
  end

  local layout = per_workspace[workspace.id] or default
  if hl.get_config("general.layout") ~= layout then
    hl.config({ general = { layout = layout } })
  end
  hl.dispatch(hl.dsp.event("layout," .. layout .. "," .. (layout == default and "1" or "0")))
end

hl.on("workspace.active", apply)

local M = {}

function M.toggle()
  local workspace = hl.get_active_workspace()
  if not workspace or workspace.special then
    return
  end

  per_workspace[workspace.id] = next_layout(per_workspace[workspace.id] or default)
  apply(workspace)
end

return M
