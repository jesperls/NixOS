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
    -- hl.exec_cmd("notify-send -e 'Game mode' 'Disabled on workspace " .. id .. "' -i input-gaming")
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
    -- hl.exec_cmd("notify-send -e 'Game mode' 'Enabled on workspace " .. id .. "' -i input-gaming")
  end
end

return M
