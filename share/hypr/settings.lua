local state = require("pangu.generated")
local theme = state.theme

hl.config({
  general = {
    layout = state.layouts.default,
    resize_on_border = true,
    allow_tearing = state.gaming.tearing,
    snap = {
      enabled = true,
    },
  },
  layout = {
    single_window_aspect_ratio = state.layouts.single_window_ratio,
    single_window_aspect_ratio_tolerance = 0,
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
    accel_profile = state.input.accel_profile,
    repeat_rate = state.input.repeat_rate,
    repeat_delay = state.input.repeat_delay,
    numlock_by_default = state.input.numlock,
  },
  render = {
    direct_scanout = state.render.direct_scanout,
  },
  dwindle = {
    preserve_split = true,
  },
  binds = {
    scroll_event_delay = 0, -- must stay 0: throttled scroll events leak through to the window
  },
  misc = {
    disable_hyprland_logo = true,
    disable_splash_rendering = true,
    mouse_move_enables_dpms = true,
    key_press_enables_dpms = true,
    font_family = theme.font_family,
    focus_on_activate = true,
    render_unfocused_fps = 30,
  },
  plugin = {
    dynamic_cursors = {
      enabled = true,
      mode = "tilt",
      threshold = 2,
      rotate = {
        length = 20,
        offset = 0.0,
      },
      tilt = {
        limit = 10000,
        activation = "negative_quadratic",
        window = 200,
        full = 90,
      },
      stretch = {
        limit = 3000,
        activation = "quadratic",
        window = 100,
      },
      shake = {
        enabled = true,
        threshold = 6.0,
        base = 4.0,
        speed = 4.0,
        influence = 0.0,
        limit = 0.0,
        timeout = 2000,
        effects = false,
        ipc = false,
      },
      hyprcursor = {
        nearest = true,
        enabled = true,
        resolution = -1,
        fallback = "clientside",
      },
    },
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

for _, animation in ipairs({
  { leaf = "windows", style = "slide" },
  { leaf = "windowsOut", style = "slide" },
  { leaf = "fade" },
  { leaf = "workspaces", style = "slidevert" },
}) do
  animation.enabled = theme.animations.enabled
  animation.speed = theme.animations.speed
  animation.bezier = "easeInOutQuint"
  hl.animation(animation)
end

return true
