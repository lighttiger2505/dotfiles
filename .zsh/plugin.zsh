#!/usr/bin/zsh

local ZSH_PLUGIN_HOME=$HOME/.zsh_plugins

# Function to install plugin if not exists
install_plugin() {
    local repo=$1
    local repo_tmp=${repo%/}
    repo_tmp=${repo_tmp##*/}
    repo_tmp=${repo_tmp%.git}
    local dir_name=${ZSH_PLUGIN_HOME}/${repo_tmp}

    if [ ! -e ${dir_name} ]; then
        git clone --depth 1 --recursive ${repo} ${dir_name}
    fi
}

# Function to load plugin with optional defer
# Usage: load_plugin <plugin> [entry] [no_defer]
#   no_defer: pass any non-empty string to force synchronous loading
load_plugin() {
    local plugin=$1
    local entry=$2
    local no_defer=$3
    local dir_name=${ZSH_PLUGIN_HOME}/${plugin}
    local plugin_file=""

    if [[ -n ${entry} ]]; then
        if [[ -f ${dir_name}/${entry} ]]; then
            plugin_file=${dir_name}/${entry}
        fi
    else
        for initscript in ${plugin#*/}.zsh ${plugin#*/}.plugin.zsh ${plugin#*/}.sh; do
            if [[ -f ${dir_name}/${initscript} ]]; then
                plugin_file=${dir_name}/${initscript}
                break
            fi
        done
    fi

    [[ -z ${plugin_file} ]] && return

    if [[ -z ${no_defer} ]] && executable zsh-defer; then
        zsh-defer source ${plugin_file}
    else
        source ${plugin_file}
    fi
}

# Install and load zsh-defer
install_plugin "https://github.com/romkatv/zsh-defer"
load_plugin "zsh-defer"

install_plugin "https://github.com/zsh-users/zsh-completions"
load_plugin "zsh-completions"

install_plugin "https://github.com/Aloxaf/fzf-tab"
load_plugin "fzf-tab" "fzf-tab.plugin.zsh" "no_defer"
zstyle ':fzf-tab:*' fzf-command ftb-tmux-popup

install_plugin "https://github.com/zsh-users/zsh-autosuggestions"
load_plugin "zsh-autosuggestions"
