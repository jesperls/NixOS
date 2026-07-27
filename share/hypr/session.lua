local dir = os.getenv("XDG_RUNTIME_DIR") or "/tmp"
local instance = os.getenv("HYPRLAND_INSTANCE_SIGNATURE")
if instance then
  dir = dir .. "/hypr/" .. instance
end
local path = dir .. "/pangu-layout-state.lua"

local M = { data = {} }

local chunk = loadfile(path)
if chunk then
  local ok, result = pcall(chunk)
  if ok and type(result) == "table" then
    M.data = result
  end
end

function M.table(key)
  local value = M.data[key]
  if type(value) ~= "table" then
    value = {}
    M.data[key] = value
  end
  return value
end

local function encode(value, out)
  local t = type(value)
  if t == "number" then
    if value % 1 == 0 and value < 2 ^ 53 and value > -2 ^ 53 then
      out[#out + 1] = string.format("%.0f", value)
    else
      out[#out + 1] = string.format("%.14g", value)
    end
  elseif t == "string" then
    out[#out + 1] = string.format("%q", value)
  elseif t == "boolean" then
    out[#out + 1] = tostring(value)
  elseif t == "table" then
    out[#out + 1] = "{"
    for k, v in pairs(value) do
      local kt = type(k)
      if kt == "number" or kt == "string" then
        out[#out + 1] = "["
        encode(k, out)
        out[#out + 1] = "]="
        encode(v, out)
        out[#out + 1] = ","
      end
    end
    out[#out + 1] = "}"
  else
    out[#out + 1] = "nil"
  end
end

local written

function M.save()
  local out = {}
  encode(M.data, out)
  local text = "return " .. table.concat(out) .. "\n"
  if text == written then
    return
  end

  local tmp = path .. ".tmp"
  local file = io.open(tmp, "w")
  if not file then
    return
  end
  file:write(text)
  file:close()
  os.rename(tmp, path)
  written = text
end

return M
