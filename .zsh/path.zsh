#!/usr/bin/zsh

# Path/Valiables
typeset -U path
path=(
# nvim
/opt/nvim/bin(N-/)
# nix
/etc/profiles/per-user/$USER/bin(N-/)
/run/current-system/sw/bin(N-/)
# mise
$HOME/.local/share/mise/shims
# brew
/opt/homebrew/opt/mysql@8.0/bin(N-/)
/opt/homebrew/opt/postgresql@16/bin(N-/)
/opt/homebrew/bin(N-/)
/opt/homebrew/sbin(N-/)
# bin
/usr/local/bin(N-/)
/usr/bin(N-/)
/bin(N-/)
# sbin
/usr/local/sbin(N-/)
/usr/sbin(N-/)
/sbin(N-/)
# Go lang
$HOME/go/bin(N-/)
# npm bin
$HOME/.npm-global/bin(N-/)
# mise
$HOME/.local/share/mise/shims(N-/)
# OpenCode
$HOME/.opencode/bin(N-/)

# GNU utils for mac
# coreutils
/usr/local/opt/coreutils/libexec/gnubin(N-/)
# ed
/usr/local/opt/ed/libexec/gnubin(N-/)
# findutils
/usr/local/opt/findutils/libexec/gnubin(N-/)
# sed
/usr/local/opt/gnu-sed/libexec/gnubin(N-/)
# tar
/usr/local/opt/gnu-tar/libexec/gnubin(N-/)
# grep
/usr/local/opt/grep/libexec/gnubin(N-/)
${path}
)

manpath=(
# coreutils
/usr/local/opt/coreutils/libexec/gnubin(N-/)
# ed
/usr/local/opt/ed/libexec/gnubin(N-/)
# findutils
/usr/local/opt/findutils/libexec/gnubin(N-/)
# sed
/usr/local/opt/gnu-sed/libexec/gnubin(N-/)
# tar
/usr/local/opt/gnu-tar/libexec/gnubin(N-/)
# grep
/usr/local/opt/grep/libexec/gnubin(N-/)
${manpath}
)
