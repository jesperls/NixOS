local state = require("jesperls.generated")

if state.lockscreen.enable and state.lockscreen.lock_on_boot then
  hl.on("hyprland.start", function()
    hl.exec_cmd("sleep 1 && caelestia-shell ipc --any-display call lock lock")
  end)
end

return true