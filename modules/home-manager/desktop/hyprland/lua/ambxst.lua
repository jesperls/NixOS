local state = require("jesperls.generated")

if not state.ambxst then
  return true
end

local chunk = loadfile(os.getenv("HOME") .. "/.local/share/ambxst/hyprland.lua")
if chunk then
  chunk()
end

return true
