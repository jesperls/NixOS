local state = require("pangu.generated")

if state.lockscreen.enable and state.lockscreen.lock_on_boot then
  hl.on("hyprland.start", function()
    hl.exec_cmd("sleep 1 && pangu run lockscreen")
  end)
end

return true