local state = require("jesperls.generated")
local theme = state.theme

hl.config({
  general = {
    gaps_in = theme.gaps_in,
    gaps_out = theme.gaps_out,
    border_size = theme.border_size,
    col = {
      active_border = theme.active_border,
      inactive_border = theme.inactive_border,
    },
    layout = "dwindle",
    resize_on_border = true,
    allow_tearing = state.gaming.tearing,
    snap = {
      enabled = true,
    },
  },
  layout = {
    single_window_aspect_ratio = { 16, 9 },
  },
  decoration = {
    rounding = theme.rounding,
    blur = {
      enabled = theme.blur.enabled,
      size = theme.blur.size,
      passes = theme.blur.passes,
      new_optimizations = true,
      ignore_opacity = true,
      xray = theme.blur.xray,
    },
    shadow = {
      enabled = theme.shadow_enabled,
    },
  },
  animations = {
    enabled = theme.animations.enabled,
  },
  input = {
    kb_layout = state.keyboard_layout,
    follow_mouse = 1,
    touchpad = {
      natural_scroll = true,
    },
    sensitivity = 0,
  },
  dwindle = {
    preserve_split = true,
  },
  scrolling = {
    column_width = 0.5,
    explicit_column_widths = "0.25, 0.333, 0.5, 0.667, 1.0",
  },
  binds = {
    -- Must stay 0: throttled scroll events leak through to the window.
    scroll_event_delay = 0,
  },
  misc = {
    disable_hyprland_logo = true,
    disable_splash_rendering = true,
    mouse_move_enables_dpms = true,
    key_press_enables_dpms = true,
  },
})

for _, curve in ipairs({
  { "easeOutQuint", { type = "bezier", points = { { 0.23, 1.0 }, { 0.32, 1.0 } } } },
  { "easeInOutQuint", { type = "bezier", points = { { 0.83, 0.0 }, { 0.17, 1.0 } } } },
  { "sharpBounce", { type = "bezier", points = { { 0.76, 0.0 }, { 0.24, 1.1 } } } },
  { "easeInOutElastic", { type = "bezier", points = { { 0.68, -0.55 }, { 0.265, 1.55 } } } },
  { "easeInBounce", { type = "bezier", points = { { 0.42, 0.0 }, { 0.58, 1.0 } } } },
  { "easeOutCubic", { type = "bezier", points = { { 0.215, 0.61 }, { 0.355, 1.0 } } } },
  { "easeInOutCubic", { type = "bezier", points = { { 0.65, 0.05 }, { 0.36, 1.0 } } } },
}) do
  hl.curve(curve[1], curve[2])
end

local animEnabled = theme.animations.enabled
local animSpeed = theme.animations.speed

for _, animation in ipairs({
  { leaf = "windows", enabled = animEnabled, speed = animSpeed, bezier = "easeInOutQuint", style = "slide" },
  { leaf = "windowsOut", enabled = animEnabled, speed = animSpeed, bezier = "easeInOutQuint", style = "slide" },
  { leaf = "fade", enabled = animEnabled, speed = animSpeed, bezier = "easeInOutQuint" },
  { leaf = "workspaces", enabled = animEnabled, speed = animSpeed, bezier = "easeInOutQuint", style = "slidevert" },
}) do
  hl.animation(animation)
end

return true