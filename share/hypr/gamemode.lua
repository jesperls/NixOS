local path = os.getenv("HOME") .. "/.local/share/pangu/gamemode.lua"
local interval = 200

local active = {}
local listeners = {}
local last_text

local M = {}

function M.is_active(workspace_id)
  return active[workspace_id] ~= nil
end

function M.on_change(callback)
  listeners[#listeners + 1] = callback
end

local function enable(id)
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

local function disable(id)
  for _, rule in ipairs(active[id]) do
    rule:set_enabled(false)
  end
  active[id] = nil
end

local function apply(desired)
  local changed = false

  for id in pairs(desired) do
    if not active[id] then
      enable(id)
      changed = true
    end
  end
  for id in pairs(active) do
    if not desired[id] then
      disable(id)
      changed = true
    end
  end

  if changed then
    for _, callback in ipairs(listeners) do
      callback()
    end
  end
end

local function poll()
  local file = io.open(path, "r")
  if not file then
    if last_text ~= nil then
      last_text = nil
      apply({})
    end
    return
  end

  local text = file:read("*a")
  file:close()
  if text == last_text then
    return
  end
  last_text = text

  local desired = {}
  local chunk = loadfile(path)
  if chunk then
    local ok, result = pcall(chunk)
    if ok and type(result) == "table" then
      for _, id in ipairs(result) do
        desired[id] = true
      end
    end
  end
  apply(desired)
end

poll()

hl.timer(poll, { timeout = interval, type = "repeat" })

return M
