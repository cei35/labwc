#!/bin/sh
if pgrep -f "dock-config.jsonc" > /dev/null; then
    pkill -f "dock-config.jsonc"
else
    waybar -c "$HOME/.config/waybar/dock-config.jsonc" -s "$HOME/.config/waybar/dock-style.css" &
fi