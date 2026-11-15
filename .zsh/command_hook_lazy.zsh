#!/usr/bin/zsh

if executable zoxide; then
    eval "$(zoxide init zsh --cmd cd)"
    export _ZO_FZF_OPTS='--height 70% --reverse'
fi

if executable atuin; then
    eval "$(atuin init zsh)"
    # atuin has no "down" widget, so both keys open the same search.
    bindkey -M viins '^P' atuin-up-search-viins
    bindkey -M viins '^N' atuin-up-search-viins
fi

if executable $HOME/.local/bin/mise; then
    eval "$($HOME/.local/bin/mise activate zsh)"
fi

# Google Cloud SDK.
# The next line updates PATH for the Google Cloud SDK.
if [ -f $HOME/google-cloud-sdk/path.zsh.inc ]; then . $HOME/google-cloud-sdk/path.zsh.inc; fi
if [ -f $HOME/google-cloud-sdk/completion.zsh.inc ]; then . $HOME/google-cloud-sdk/completion.zsh.inc; fi
