{ config, pkgs, osConfig, ... }:

let
  colors = osConfig.mySystem.theme.colors;
  fonts = osConfig.mySystem.theme.fonts;
in {
  services.swaync = {
    enable = true;
    settings = {
      positionX = "right";
      positionY = "top";
      layer = "overlay";
      control-center-layer = "top";
      layer-shell = true;
      layer-shell-cover-screen = false;
      ignore-gtk-theme = true;
      cssPriority = "user";
      control-center-margin-top = 0;
      control-center-margin-bottom = 0;
      control-center-margin-right = 0;
      control-center-margin-left = 0;
      notification-2fa-action = true;
      notification-inline-replies = false;
      notification-icon-size = 64;
      notification-body-image-height = 100;
      notification-body-image-width = 200;
    };
    style = ''
      /* Global Reset & Font */
      * {
        font-family: "${fonts.monospace}";
        font-weight: bold;
      }

      /* Structure & Transparency Overrides */
      .control-center, .notification, .notification-list, .floating-notifications, .blank-window,
      .widget-title, .widget-dnd, .widget-label, .widget-mpris, .widget-buttons-grid, .widget-menubar {
        background: transparent !important;
      }

      /* Notification Rows */
      .notification-row {
        outline: none;
        margin: 10px;
        padding: 0;
      }

      /* Notification Content */
      .notification-content {
        background: ${colors.base} !important;
        padding: 15px;
        border-radius: 12px;
        border: 1px solid ${colors.surface};
        margin: 0;
        box-shadow: 0 4px 12px 0 rgba(0, 0, 0, 0.5);
      }

      /* Hover & Focus Effects */
      .control-center .notification-row:focus,
      .control-center .notification-row:hover {
        opacity: 1;
        background: transparent;
      }

      /* Control Center Main Container */
      .control-center {
        background: ${colors.base} !important;
        border: 1px solid ${colors.surface};
        border-radius: 16px;
        box-shadow: 0 4px 20px rgba(0,0,0,0.5);
        margin: 15px;
        padding: 0;
      }

      /* Buttons & Actions Shared Styling */
      .close-button, .notification-action, .notification-default-action,
      .widget-title > button, .widget-dnd > switch, .widget-buttons-grid > flowbox > flowboxchild > button,
      .widget-menubar > box > box > button, .widget-mpris > box > button {
        background: ${colors.surface};
        color: ${colors.text};
        border: none;
        border-radius: 12px;
        box-shadow: none;
        text-shadow: none;
      }

      /* Button Hover Effects */
      .close-button:hover, .notification-action:hover, .notification-default-action:hover,
      .widget-title > button:hover, .widget-buttons-grid > flowbox > flowboxchild > button:hover,
      .widget-menubar > box > box > button:hover {
        background: ${colors.accent};
        color: ${colors.base};
        transition: all 0.15s ease-in-out;
      }

      /* Close Button Specifics */
      .close-button {
        background: ${colors.urgent};
        color: ${colors.base};
        border-radius: 100%;
        margin: 5px 5px 0 0;
        min-width: 24px;
        min-height: 24px;
      }
      .close-button:hover { background: ${colors.urgent}; }

      /* Text Styling */
      .summary { font-size: 16px; font-weight: 800; color: ${colors.text}; background: transparent; }
      .time { font-size: 14px; font-weight: 700; color: ${colors.subtext}; background: transparent; margin-right: 18px; }
      .body { font-size: 15px; font-weight: 500; color: ${colors.text}; background: transparent; }
      .widget-label > label { font-size: 1rem; color: ${colors.text}; }
      .widget-title { color: ${colors.accent}; padding: 10px; margin: 10px; font-size: 1.5rem; }

      /* Widget Containers */
      .widget-dnd, .widget-mpris, .widget-buttons-grid {
        background: ${colors.base} !important;
        padding: 10px;
        margin: 10px;
        border-radius: 12px;
      }

      /* Inputs & Toggles */
      .widget-dnd > switch:checked { background: ${colors.accent}; border: 1px solid ${colors.accent}; }
      .widget-dnd > switch slider { background: ${colors.text}; border-radius: 12px; }
      .inline-reply-entry { background: ${colors.base}; color: ${colors.text}; border: 1px solid ${colors.surface}; border-radius: 12px; }
      .body-image { background-color: ${colors.text}; border-radius: 12px; margin-top: 6px; }
    '';
  };
}
