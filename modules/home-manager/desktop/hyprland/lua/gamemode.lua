-- Per-workspace "game mode": strips gaps, borders, rounding and animations so
-- a fullscreen game gets a pixel-exact, effect-free surface.
local active = {}

local M = {}

function M.is_active(workspace_id)
  return active[workspace_id] ~= nil
end

function M.toggle()
  local workspace = hl.get_active_workspace()
  if not workspace or workspace.special then
    return
  end
  local id = workspace.id

  local rules = active[id]
  if rules then
    active[id] = nil
    for _, rule in ipairs(rules) do
      rule:set_enabled(false)
    end
  else
    active[id] = {
      hl.workspace_rule({
        workspace = "r[" .. id .. "-" .. id .. "]s[0]",
        gaps_in = 0,
        gaps_out = 0,
        border_size = 0,
        no_rounding = true,
        no_shadow = true,
      }),
      hl.window_rule({
        match = { workspace = tostring(id) },
        no_anim = true,
        no_blur = true,
      }),
    }
  end

  -- The centergap event carries a "square" flag derived from this state, so
  -- the bar's split strip has to be told even when nothing else changed.
  require("jesperls.layouts").schedule_scan()
end

return M
