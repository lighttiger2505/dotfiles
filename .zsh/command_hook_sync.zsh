#!/usr/bin/zsh

# Source the output of `<cmd> ...`, regenerating the cache only when the binary is newer.
cached_eval() {
    local name=$1; shift
    local cache=${XDG_CACHE_HOME:-$HOME/.cache}/zsh/$name.zsh
    if [[ ! -s $cache || ${commands[$1]} -nt $cache ]]; then
        mkdir -p ${cache:h}
        "$@" >| $cache
    fi
    source $cache
}

if executable direnv; then
    cached_eval direnv direnv hook zsh
fi

if executable wt; then
    cached_eval wt wt config shell init zsh
fi

export DEJA_CYCLE_KEY=
if [[ -r "$HOME/.local/share/deja/init.zsh" ]];
    then source "$HOME/.local/share/deja/init.zsh";
else
    eval "$(deja init zsh)";
fi

if executable zsh-patina; then
    eval "$(zsh-patina activate)"
fi
