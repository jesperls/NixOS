{ config, pkgs, ... }:

{
  services.swaync = {
    enable = true;
    settings = {
      positionX = "right";
      positionY = "top";
      layer = "overlay";
      control-center-layer = "top";
      layer-shell = true;
      cssPriority = "application";
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
      * {
        font-family: "JetBrainsMono Nerd Font";
        font-weight: bold;
      }
      .control-center .notification-row:focus,
      .control-center .notification-row:hover {
        opacity: 1;
        background: #1e1e2e;
      }
      .notification-row {
        outline: none;
        margin: 10px;
        padding: 0;
      }
      .notification {
        background: transparent;
        padding: 0;
        margin: 0px;
      }
      .notification-content {
        background: #1e1e2e;
        padding: 10px;
        border-radius: 5px;
        border: 1px solid #89b4fa;
        margin: 0;
      }
      .notification-default-action {
        margin: 0;
        padding: 0;
        border-radius: 5px;
      }
      .close-button {
        background: #f38ba8;
        color: #1e1e2e;
        text-shadow: none;
        padding: 0;
        border-radius: 5px;
        margin-top: 5px;
        margin-right: 5px;
      }
      .close-button:hover {
        box-shadow: none;
        background: #f38ba8;
        transition: all 0.15s ease-in-out;
        border: none;
      }
      .notification-action {
        border: 2px solid #89b4fa;
        border-top: none;
        border-radius: 5px;
      }
      .notification-default-action:hover,
      .notification-action:hover {
        color: #89b4fa;
        background: #89b4fa;
      }
      .notification-default-action {
        border-radius: 5px;
        margin: 0px;
      }
      .notification-default-action:not(:only-child) {
        border-bottom-left-radius: 0px;
        border-bottom-right-radius: 0px;
      }
      .notification-action:first-child {
        border-bottom-left-radius: 10px;
        background: #1e1e2e;
      }
      .notification-action:last-child {
        border-bottom-right-radius: 10px;
        background: #1e1e2e;
      }
      .inline-reply {
        margin-top: 8px;
      }
      .inline-reply-entry {
        background: #1e1e2e;
        color: #cdd6f4;
        border: 1px solid #89b4fa;
        border-radius: 5px;
      }
      .inline-reply-button {
        margin-left: 4px;
        background: #1e1e2e;
        border: 1px solid #89b4fa;
        border-radius: 5px;
        color: #cdd6f4;
      }
      .inline-reply-button:disabled {
        background: initial;
        color: #585b70;
        border: 1px solid #585b70;
      }
      .inline-reply-button:hover {
        background: #1e1e2e;
      }
      .body-image {
        margin-top: 6px;
        background-color: #cdd6f4;
        border-radius: 5px;
      }
      .summary {
        font-size: 16px;
        font-weight: 700;
        background: transparent;
        color: #cdd6f4;
        text-shadow: none;
      }
      .time {
        font-size: 16px;
        font-weight: 700;
        background: transparent;
        color: #cdd6f4;
        text-shadow: none;
        margin-right: 18px;
      }
      .body {
        font-size: 15px;
        font-weight: 400;
        background: transparent;
        color: #cdd6f4;
        text-shadow: none;
      }
      .control-center {
        background: #1e1e2e;
        border: 2px solid #89b4fa;
        border-radius: 10px;
      }
      .control-center-list {
        background: transparent;
      }
      .control-center-list-placeholder {
        opacity: 0.5;
      }
      .floating-notifications {
        background: transparent;
      }
      .blank-window {
        background: alpha(black, 0);
      }
      .widget-title {
        color: #89b4fa;
        background: #1e1e2e;
        padding: 5px 10px;
        margin: 10px 10px 5px 10px;
        font-size: 1.5rem;
        border-radius: 5px;
      }
      .widget-title > button {
        font-size: 1rem;
        color: #cdd6f4;
        text-shadow: none;
        background: #1e1e2e;
        box-shadow: none;
        border-radius: 5px;
      }
      .widget-title > button:hover {
        background: #f38ba8;
        color: #1e1e2e;
      }
      .widget-dnd {
        background: #1e1e2e;
        padding: 5px 10px;
        margin: 10px 10px 5px 10px;
        border-radius: 5px;
        font-size: large;
        color: #89b4fa;
      }
      .widget-dnd > switch {
        border-radius: 5px;
        background: #1e1e2e;
      }
      .widget-dnd > switch:checked {
        background: #89b4fa;
        border: 1px solid #89b4fa;
      }
      .widget-dnd > switch slider {
        background: #1e1e2e;
        border-radius: 5px;
      }
      .widget-dnd > switch:checked slider {
        background: #1e1e2e;
        border-radius: 5px;
      }
      .widget-label {
        margin: 10px 10px 5px 10px;
      }
      .widget-label > label {
        font-size: 1rem;
        color: #cdd6f4;
      }
      .widget-mpris {
        color: #cdd6f4;
        background: #1e1e2e;
        padding: 5px 10px;
        margin: 10px 10px 5px 10px;
        border-radius: 5px;
      }
      .widget-mpris > box > button {
        border-radius: 5px;
      }
      .widget-mpris-player {
        padding: 5px 10px;
        margin: 10px;
      }
      .widget-mpris-title {
        font-weight: 700;
        font-size: 1.25rem;
      }
      .widget-mpris-subtitle {
        font-size: 1.1rem;
      }
      .widget-buttons-grid {
        padding: 5px;
        margin: 10px 10px 5px 10px;
        border-radius: 5px;
        background: #1e1e2e;
      }
      .widget-buttons-grid > flowbox > flowboxchild > button {
        background: #1e1e2e;
        border-radius: 5px;
      }
      .widget-buttons-grid > flowbox > flowboxchild > button:hover {
        background: #89b4fa;
        color: #1e1e2e;
      }
      .widget-menubar > box > box > button {
        border-radius: 5px;
        background: #1e1e2e;
      }
      .widget-menubar > box > box > button:hover {
        background: #89b4fa;
        color: #1e1e2e;
      }
      .topbar-buttons > button {
        border: none;
        background: transparent;
      }
    '';
  };
}
