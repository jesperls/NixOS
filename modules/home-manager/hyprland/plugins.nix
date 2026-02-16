{
  osConfig,
  lib,
  ...
}:
{
  "plugin:hyprexpo" = {
    columns = 3;
    gap_size = 6;
    bg_col = "rgb(111111)";
    workspace_method = "first m+1";
    skip_empty = false;
  };
  "plugin:hyprtrails" = {
    color = "rgb(A869A8)";
  };
  "plugin:dynamic-cursors" = {
    mode = "tilt";
    tilt = {
      limit = 5000;
      full_tilt = 180;
    };
    shake = {
      enabled = false;
    };
  };
}
