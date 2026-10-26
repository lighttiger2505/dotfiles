# Prefix key is [Ctrl+t]
set -g prefix C-t

# kill tmux when the last session is killed
set -g detach-on-destroy off

# Escape time dilay
set -sg escape-time 20

# Start number of window index is [1]
set -g base-index 1

# Start number of pain index is [1]
setw -g pane-base-index 1

# Mouse control on
setw -g mouse on

# renumber windows when one is closed. I don't want to have 1, 2, 4, 5 windows when I close window 3.
set -g renumber-windows on

# status msg disappears in the blink of an eye
set -g display-time 2000
set -g display-panes-time 2000

# maximum number of lines held in window history
set -g history-limit 20000

set -g focus-events on

# Enable neitive scrollbar
set -g pane-scrollbars off
