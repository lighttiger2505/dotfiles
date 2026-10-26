# Send literal C-t to application (prefix + C-t)
bind-key C-t send-prefix

# Release all key bind
unbind-key Up
unbind-key Down
unbind-key Left
unbind-key Right
unbind-key S-Up
unbind-key S-Down
unbind-key S-Left
unbind-key S-Right
unbind-key C-Up
unbind-key C-Down
unbind-key C-Left
unbind-key C-Right

# Reload config
bind-key r source-file ~/.config/tmux/tmux.conf \; display "Reloaded!"

# Open new window
bind-key Enter new-window -c "#{pane_current_path}"
bind-key -n M-Enter new-window -c "#{pane_current_path}"

# Split Window
bind-key s split-window -v -c "#{pane_current_path}"

# Vertical Split Window
bind-key v split-window -h -c "#{pane_current_path}"

# Move(Select) pain
bind-key h select-pane -L
bind-key j select-pane -D
bind-key k select-pane -U
bind-key l select-pane -R
bind-key -n M-h select-pane -L
bind-key -n M-j select-pane -D
bind-key -n M-k select-pane -U
bind-key -n M-l select-pane -R

# Resize pain
bind-key H resize-pane -L 5
bind-key J resize-pane -D 5
bind-key K resize-pane -U 5
bind-key L resize-pane -R 5
bind-key -n M-H resize-pane -L 5
bind-key -n M-J resize-pane -D 5
bind-key -n M-K resize-pane -U 5
bind-key -n M-L resize-pane -R 5

# Move(Select) window
bind-key n next-window
bind-key p previous-window
bind-key -n M-n next-window
bind-key -n M-p previous-window

# Jump(Select) window
bind-key -n M-1 select-window -t 1
bind-key -n M-2 select-window -t 2
bind-key -n M-3 select-window -t 3
bind-key -n M-4 select-window -t 4
bind-key -n M-5 select-window -t 5
bind-key -n M-6 select-window -t 6
bind-key -n M-7 select-window -t 7
bind-key -n M-8 select-window -t 8
bind-key -n M-9 select-window -t 9

# Switch(Swap) window
bind-key 1 swap-window -t 1
bind-key 2 swap-window -t 2
bind-key 3 swap-window -t 3
bind-key 4 swap-window -t 4
bind-key 5 swap-window -t 5
bind-key 6 swap-window -t 6
bind-key 7 swap-window -t 7
bind-key 8 swap-window -t 8
bind-key 9 swap-window -t 9

# Toggle Window
bind-key Tab last-window
bind-key -n M-Tab last-window

# Change layout(Select layout) pane
bind-key -n C-Up select-layout even-horizontal
bind-key -n C-Down select-layout main-horizontal
bind-key -n C-Left select-layout even-vertical
bind-key -n C-Right select-layout main-vertical

# Switch(Swap) Window
bind-key -n S-Left swap-window -t -1 \; select-window -p
bind-key -n S-Right swap-window -t +1 \; select-window -n

# Move(Switch) session
bind-key N switch-client -n
bind-key P switch-client -p
bind-key -n M-N switch-client -n
bind-key -n M-P switch-client -p

# Reanme session
bind-key R command-prompt -I "#S" "rename-session '%%'"

# Key bind kill current pane
bind-key q kill-pane
bind-key -n M-q kill-pane

# Key bind kill current window
bind-key x confirm-before -p "kill-window #W? (y/n)" kill-window
bind-key X kill-window

# Key bind kill current session
bind-key d confirm-before -p "kill-session #S? (y/n)" kill-session
bind-key D kill-session

# Fullscreen
bind-key -n M-m resize-pane -Z
set -g pane-border-format '[ ZOOMED ] #{pane_current_command}'
set-hook -g after-resize-pane 'if -F "#{window_zoomed_flag}" "set pane-border-status top" "set pane-border-status off"'
