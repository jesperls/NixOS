local state = require("pangu.generated")

if not state.shell then
  return true
end

local chunk = loadfile(os.getenv("HOME") .. "/.local/share/pangu/hyprland.lua")
if chunk then
  pcall(chunk)
end

return true
