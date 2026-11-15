# Catppuccin Mocha
# https://github.com/catppuccin/catppuccin
set -g default-terminal "screen-256color"

# tmux 3.8+: use terminal ANSI colours instead of the builtin light/dark theme
set -s theme terminal

set -g @my-color-rosewater "#f5e0dc"
set -g @my-color-flamingo "#f2cdcd"
set -g @my-color-pink "#f5c2e7"
set -g @my-color-mauve "#cba6f7"
set -g @my-color-red "#f38ba8"
set -g @my-color-maroon "#ee99a0"
set -g @my-color-peach "#fab387"
set -g @my-color-yellow "#f9e2af"
set -g @my-color-green "#a6e3a1"
set -g @my-color-teal "#94e2d5"
set -g @my-color-sky "#89dceb"
set -g @my-color-sapphire "#74c7ec"
set -g @my-color-blue "#89b4fa"
set -g @my-color-lavender "#b4befe"

set -g @my-color-text0 "#cdd6f4"
set -g @my-color-text1 "#a6adc8"
set -g @my-color-text2 "#bac2de"

set -g @my-color-surface0 "#313244"
set -g @my-color-surface1 "#45475a"
set -g @my-color-surface2 "#585b70"

set -g @my-color-overlay0 "#6c7086"
set -g @my-color-overlay1 "#7f849c"
set -g @my-color-overlay2 "#9399b2"

set -g @my-color-base "#1e1e2e"
set -g @my-color-mantle "#181825"
set -g @my-color-crust "#11111b"

set -g status-style "bg=#{@my-color-crust},fg=#{@my-color-text0}"
set -g status-left-style "bg=#{@my-color-mauve},fg=#{@my-color-base}"
set -g status-right-style "bg=#{@my-color-mauve},fg=#{@my-color-base}"

setw -g window-status-style "bg=#{@my-color-surface2},fg=#{@my-color-text2}"
setw -g window-status-current-style "bg=#{@my-color-peach},fg=#{@my-color-base}"
setw -g window-status-activity-style "bg=#{@my-color-red},fg=#{@my-color-base}"
setw -g window-status-bell-style "bg=#{@my-color-yellow},fg=#{@my-color-base}"

setw -g pane-border-style "bg=#{@my-color-surface0},fg=#{@my-color-overlay0}"
setw -g pane-active-border-style "bg=#{@my-color-lavender},fg=#{@my-color-base}"

set -g popup-style "bg=default"
set -g popup-border-style "fg=#{@my-color-red}"

set -g pane-border-lines single
set -g pane-border-indicators arrows
