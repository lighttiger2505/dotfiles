#!/bin/bash
# Move to the left/right pane. At the edge, wrap to the previous/next window's opposite edge pane.
# Usage: smart_pane_move.sh left|right

case "$1" in
left)  edge=pane_at_left;  opposite=pane_at_right; step=-L; opposite_step=-R; window=previous-window ;;
right) edge=pane_at_right; opposite=pane_at_left;  step=-R; opposite_step=-L; window=next-window ;;
*) echo "usage: $0 left|right" >&2; exit 1 ;;
esac

if [ "$(tmux display-message -p "#{$edge}")" != "1" ]; then
    tmux select-pane "$step"
    exit 0
fi

tmux "$window"
while [ "$(tmux display-message -p "#{$opposite}")" != "1" ]; do
    tmux select-pane "$opposite_step" || break
done
