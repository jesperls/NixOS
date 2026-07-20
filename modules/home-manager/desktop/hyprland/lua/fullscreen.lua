-- Shared between binds.lua and events.lua: fullscreen events fired while
-- `suppress` is set come from a keybind, not the client, so the auto fake
-- fullscreen handler must leave them alone.
local M = { suppress = false }

function M.dispatch_real(dispatcher)
  M.suppress = true
  local ok, err = pcall(hl.dispatch, dispatcher)
  M.suppress = false
  if not ok then
    error(err)
  end
end

return M
