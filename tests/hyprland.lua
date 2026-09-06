local source = assert(arg[1])
for file in io.popen("find '" .. source .. "' -name '*.lua'"):lines() do
  assert(loadfile(file))
end

local state = {
  apps = {},
  layouts = { centered = { master_width = 0.5, full_height = false, aspect = {16, 9}, height_resize_step = 0.15 } },
}
local slots = { [1] = {master = 10, left = {11}, right = {12}} }
local weights = { [10] = 2, [11] = 3, [12] = 4, [20] = 2 }
local layout
package.preload['pangu.generated'] = function() return state end
package.preload['pangu.gamemode'] = function() return {on_change = function() end} end
package.preload['pangu.session'] = function() return {table = function(key) return key == 'slots' and slots or weights end} end
hl = {
  on = function() end,
  timer = function() return {set_enabled = function() end} end,
  layout = {register = function(_, implementation) layout = implementation end},
}
dofile(source .. '/layouts.lua')
layout.layout_msg({targets = {{window = {workspace = {id = 1}}}}}, 'equalize')
assert(weights[10] == nil and weights[11] == nil and weights[12] == nil)
assert(weights[20] == 2, 'Equalize changed another workspace')

local appliedSettings
hl.config = function(config) appliedSettings = config end
state.theme = {animations = {enabled = true}}
state.tearing = {enable = false}
state.input, state.render = {}, {}
hl.curve, hl.animation = function() end, function() end
dofile(source .. '/settings.lua')
assert(appliedSettings.layout.single_window_aspect_ratio[2] == 0,
  'Global single-window padding must not shrink an already centered layout')
local placed
local target = {
  window = {stable_id = 99, active = true, workspace = {id = 99}},
  place = function(_, box) placed = box end,
}
layout.recalculate({area = {x = 0, y = 44, w = 5120, h = 1396}, targets = {target}})
assert(placed.w == 2560 and placed.x == 1280, 'Single centered window lost its width')

local binds, dispatched = {}, 0
local floating = true
local function dispatcher() return {} end
hl = {
  bind = function(_, callback, flags) binds[flags.description] = callback end,
  dsp = setmetatable({
    window = setmetatable({}, {__index = function() return dispatcher end}),
    workspace = setmetatable({}, {__index = function() return dispatcher end}),
  }, {__index = function() return dispatcher end}),
  dispatch = function() dispatched = dispatched + 1 end,
  get_active_workspace = function() return {tiled_layout = 'lua:centered'} end,
  get_active_window = function() return {floating = floating} end,
}
package.preload['pangu.layouts'] = function() return {start_drag = function() end, end_drag = function() end} end
package.preload['pangu.layout_modes'] = function() return {toggle = function() end} end
package.preload['pangu.fullscreen'] = function() return {} end
package.preload['pangu.popout'] = function() return {} end
dofile(source .. '/binds.lua')
binds['Mouse: resize window']()
binds['Mouse: resize window (side button)']()
assert(dispatched == 2, 'Floating windows cannot be resized in centered workspaces')
floating = false
binds['Mouse: resize window']()
assert(dispatched == 2, 'Tiled centered window used the floating resize dispatcher')
print('Hyprland syntax, workspace isolation and floating resize tests passed')
