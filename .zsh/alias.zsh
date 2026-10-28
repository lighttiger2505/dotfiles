#####################################################################
# Change directory
#####################################################################

alias ..='cd ..'
alias ....='cd ../..'
alias ......='cd ../../..'
alias dot="$HOME/src/github.com/lighttiger2505/.dotfiles"
alias dl="~/Downloads"

# Move to the selected directory from the results of find
cd-fzf-find() {
    local dir
    DIR=$(fd --hidden --type d 2> /dev/null | fzf +m --ansi --preview 'eza --long --all --icons --color=always {}')
    if [ -n "$DIR" ]; then
        cd $DIR
    fi
}
alias cdd=cd-fzf-find

# Open the selected file from the result of find in Vim
vim-fzf-find() {
    local FILE=$(fd --hidden --type f 2> /dev/null | fzf +m --ansi --preview 'bat -n --color=always {}')
    if [ -n "$FILE" ]; then
        ${EDITOR:-vim} $FILE
    fi
}
alias vimf=vim-fzf-find

#####################################################################
# Replace rust commands
#####################################################################

# cat to bat
if executable bat; then
    alias cat=bat
fi

# ls to eza
if executable eza; then
    alias ls=eza
    # show list all files
    alias ll="ls --long --all --icons"
    # show list order by newer files
    alias lr="ls --long --all --sort=modified --icons"
    # show tree all files
    alias lt="ls --long --all --tree --color=always | less --icons"
else
    # show list all files
    alias ll="ls -al"
    # show list order by newer files
    alias lr="ls -ltr"
fi

# diff to delta
if executable delta; then
    alias diff=delta
fi

# diff to delta
if executable zoxide; then
    alias z=cdi
fi

#####################################################################
# Git
#####################################################################
alias g="git"

remove-merged-branch() {
  git branch --merged | grep -vE '^[*+]' | xargs -r git branch -d
}
alias rm-branch=remove-merged-branch

remove-safe-worktree() {
  local branches=$(wt list --format=json | jq -r '.items[] | select(.display.state == "integrated") | .branch')
  if [[ -z "$branches" ]]; then
    return 0
  fi
  echo "$branches" | xargs -I{} wt remove {}
}
alias rm-wt=remove-safe-worktree

remove-force-worktree() {
  local branches=$(wt list --format=json | jq -r '.items[] | select(.display.state == "integrated" or .display.state == "empty" or .display.state == "behind") | .branch')
  if [[ -z "$branches" ]]; then
    return 0
  fi
  echo "$branches" | xargs -I{} wt remove -f {}
}
alias rm-wtf=remove-force-worktree

git-clean() {
  git pull --prune --tags --force --all
  remove-merged-branch
  remove-safe-worktree
  git worktree prune
}
alias gc=git-clean

git-pull() {
  git pull --prune --tags --force --all
}
alias gp=git-pull

git-rebase-develop() {
  git checkout develop 
  git pull origin develop --prune --tags --force
  git rebase origin/develop
}
alias rdev=git-rebase-develop

# global alias for git branch
alias -g B='`git branch --all | grep -v HEAD | fzf -m | sed "s/.* //" | sed "s#remotes/[^/]*/##"`'

# git status
alias gs='git status'
alias ts='tig status'

function cd-git-worktree-fzf() {
  local dir
  dir=$(git worktree list | fzf | awk '$1=="*" {print $2; next} {print $1}')
  [ -n "$dir" ] && cd "$dir"
}
alias cdw=cd-git-worktree-fzf

function clean-submodule() {
  git submodule sync --recursive
  git submodule update --init --recursive --force
  git submodule foreach --recursive git reset --hard
  git submodule foreach --recursive git clean -xfd
}
alias gscl=clean-submodule

#####################################################################
# Zsh
#####################################################################
# zshrc source
alias zs="source ~/.zshrc"

# zshrc load benchmark
alias zb="time ( zsh -i -c exit; )"

# zshrc remove cache
alias zc="rm -f ~/.zsh/*.zwc"

#####################################################################
# Vim
#####################################################################
# when not exist vim then start up vi
if executable vim; then
    alias vi=vim
else
    alias vim=vi
fi

# when not exist nvim then start up vim
if executable nvim; then
    alias vim=nvim
else
    alias nvim=vim
fi

alias vimdiff='vim -d'
function GitDiffVim() {
    nvim -c 'lua require("diffview")' -c 'DiffviewOpen'
}
alias vimdiffdd=GitDiffVim

# Open vim with tmux capture-pane
alias tm='tmux capture-pane -pS - > /tmp/tmux_output && vim /tmp/tmux_output'

# open vim with vimmemo
alias td='vim $VIM_MEMO_DIR/todo.md'
alias tl='vim $VIM_MEMO_DIR/link.md'
alias tf='vim $VIM_MEMO_DIR/feedback.md'

#####################################################################
# GitHub cli
#####################################################################
alias hb='gh repo view --web'
alias hp='gh pr view --web'
alias ha='gh pr checks'
alias hl='gh pr view --json title,url --jq "\"[\(.title)](\(.url))\""'

alias vimdiffgd='nvim -c ":DiffviewOpen"'
alias vimdiffpr='nvim -c ":OpenDiffviewPR"'

alias prcreate='gh pr create --template "pull_request_template.md"'

# Create PR diff and review by AI
function ai-review-github-pr() {
    local tmpfile="/tmp/pr-diff-$(date +%s)"
    gh pr view --json url | jq .url | gh pr diff > ${tmpfile}
    nvim -c 'lua require("codecompanion")' -c 'lua vim.cmd("CodeCompanion /custom_review_pull_request")' ${tmpfile}
}
alias airev=ai-review-github-pr

function github-pr-review-fzf() {
    local selected=$(
        gh pr list \
            --search "org:MobilityTechnologies review-requested:@me -label:dependencies sort:updated-desc" \
            --json number,headRepositoryOwner,headRepository,title,updatedAt,reviewRequests \
            --jq '
                .[] 
                | select(any(.reviewRequests[]; .login == "go-toshikazu-ohashi")) 
                | "\(.number)\t\(.headRepositoryOwner.login)/\(.headRepository.name)\t\(.title)\t\(.updatedAt)"
            ' \
            | fzf --reverse --prompt='Select PR> '
    )
    [[ -z $selected ]] && return 0
    local prNum=$(awk -F'\t' '{print $1}' <<<"$selected")

    wt switch "pr:${prNum}"
    git pull --rebase
    local baseBranch=$(gh pr status --json baseRefName -q '.currentBranch.baseRefName')
    git fetch origin "$baseBranch":"$baseBranch"
    nvim -c ":OpenDiffviewPR"
}
alias prrevf=github-pr-review-fzf

function github-pr-review-all-fzf() {
    # Cross-repo version of prrevf: select from review-requested PRs in the org, then cd to the local repo.
    # Only PRs where I am requested directly (team requests are excluded).
    local selected=$(
        gh api graphql \
            -f q="org:MobilityTechnologies is:pr is:open review-requested:@me -label:dependencies sort:updated-desc" \
            -f query='query($q: String!) {
              search(query: $q, type: ISSUE, first: 100) {
                nodes {
                  ... on PullRequest {
                    number title updatedAt
                    repository { nameWithOwner }
                    reviewRequests(first: 30) { nodes { requestedReviewer { ... on User { login } } } }
                  }
                }
              }
            }' \
            --jq '.data.search.nodes[]
                | select(any(.reviewRequests.nodes[]; .requestedReviewer.login == "go-toshikazu-ohashi"))
                | "\(.number)\t\(.repository.nameWithOwner)\t\(.title)\t\(.updatedAt)"' \
            | fzf --reverse --prompt='Select PR> '
    )
    [[ -z $selected ]] && return 0

    local prNum=$(awk -F'\t' '{print $1}' <<<"$selected")
    local repo=$(awk -F'\t' '{print $2}' <<<"$selected")
    local localDir=$(get_repo_local_dir "$repo")
    if [[ $? -ne 0 ]]; then
        return 1
    fi

    cd "$localDir" || return 1
    wt switch "pr:${prNum}"
    git pull --rebase
    local baseBranch=$(gh pr status --json baseRefName -q '.currentBranch.baseRefName')
    git fetch origin "$baseBranch":"$baseBranch"
    nvim -c ":OpenDiffviewPR"
}
alias prrevfa=github-pr-review-all-fzf

function get_repo_local_dir() {
    local repo="$1"

    local localDir
    case "$repo" in
        "MobilityTechnologies/kingston")
            localDir=~/src/github.com/MobilityTechnologies/kingston
            ;;
        "MobilityTechnologies/kingston-static")
            localDir=~/src/github.com/MobilityTechnologies/kingston-static
            ;;
        *)
            localDir=~/src/github.com/$repo
            ;;
    esac

    if [[ ! -d $localDir ]]; then
        echo "Error: Directory '$localDir' does not exist." >&2
        return 1
    fi

    echo "$localDir"
    return 0
}

function github-pr-switch-fzf() {
    local selected=$(
        gh pr list \
            --search "org:MobilityTechnologies is:open author:@me -label:dependencies sort:updated-desc" \
            --json number,headRepositoryOwner,headRepository,headRefName,title,updatedAt \
            --jq '.[] | "\(.number)\t\(.headRepositoryOwner.login)/\(.headRepository.name)\t\(.headRefName)\t\(.title)\t\(.updatedAt)"' \
            | fzf --reverse --prompt='Select PR> '
    )
    [[ -z $selected ]] && return 0

    local prNum=$(awk -F'\t' '{print $1}' <<<"$selected")
    local repo=$(awk -F'\t' '{print $2}' <<<"$selected")
    local branch=$(awk -F'\t' '{print $3}' <<<"$selected")
    local localDir=$(get_repo_local_dir "$repo")
    if [[ $? -ne 0 ]]; then
        return 1
    fi

    cd "$localDir" || return 1
    wt switch $branch
}
alias prsif=github-pr-switch-fzf

github-pr-list-markdown() {
  # Usage: prmd [owner/repo ...]  (no args: all repos in MobilityTechnologies)
  local scope=(--owner MobilityTechnologies)
  if (( $# > 0 )); then
    scope=()
    local repo
    for repo in "$@"; do
      scope+=(--repo "$repo")
    done
  fi

  gh search prs "${scope[@]}" \
    --state open --author @me \
    --limit 100 \
    --json title,url,repository,isDraft,updatedAt \
    --jq 'sort_by(.updatedAt) | reverse | sort_by([.repository.name, .isDraft])
      | .[] | "- [\(if .isDraft then "(Draft) " else "" end)\(.repository.name) \(.title)](\(.url))"' \
    -- -label:dependencies
}
alias prmd=github-pr-list-markdown

github-pr-review-markdown() {
  # Usage: prrevmd [owner/repo ...]  (no args: all repos in MobilityTechnologies)
  # Only PRs where I am requested directly (team requests are excluded).
  # gh search prs has no reviewRequests field, so use GraphQL search.
  local scope="org:MobilityTechnologies"
  if (( $# > 0 )); then
    scope=""
    local repo
    for repo in "$@"; do
      scope+="repo:${repo} "
    done
  fi

  gh api graphql \
    -f q="${scope} is:pr is:open review-requested:@me -label:dependencies" \
    -f query='query($q: String!) {
      search(query: $q, type: ISSUE, first: 100) {
        nodes {
          ... on PullRequest {
            title url isDraft updatedAt
            repository { name }
            reviewRequests(first: 30) { nodes { requestedReviewer { ... on User { login } } } }
          }
        }
      }
    }' \
    --jq '.data.search.nodes
      | map(select(any(.reviewRequests.nodes[]; .requestedReviewer.login == "go-toshikazu-ohashi")))
      | sort_by(.updatedAt) | reverse | sort_by([.repository.name, .isDraft])
      | .[] | "- [\(if .isDraft then "(Draft) " else "" end)\(.repository.name) \(.title)](\(.url))"'
}
alias prrevmd=github-pr-review-markdown

function list-copilot-models() {
    curl -s \
        -H "Authorization: Bearer $(gh auth token)" \
        https://api.githubcopilot.com/models \
        | jq '.data[] | "\(.id): \(.name)"'
}
alias copilotmodels=list-copilot-models
#####################################################################
# liary
#####################################################################
alias li='liary'

#####################################################################
# Draw.io
#####################################################################
function open-tmp-drawfile() {
  local tmpfile="${HOME}/vscode/drawmemo/$(date +'%Y%m%d').drawio"
  touch ${tmpfile}
  code ${tmpfile}
}
alias drawio=open-tmp-drawfile

#####################################################################
# fibonacci
#####################################################################
function draw-fibonacci() {
    m=0
    n=1
    num=8

    (( num +=2 ))

    for i in $(seq 1 $num)
    do
        (( o = $m + $n ))
        echo $o
        m=$n
        n=$o
    done
}
alias fib=draw-fibonacci

#####################################################################
# Obsidian
#####################################################################
function obsidian-new() {
    nvim -c 'lua require("obsidian")' -c 'ObsidianNew'
}
alias on=obsidian-new
function obsidian-list-preview() {
    nvim -c 'lua require("obsidian")' -c 'ObsidianQuickSwitch'
}
alias ov=obsidian-list-preview

fzf_alias_exec() {
  local selected=$(alias | fzf)
  [[ -z $selected ]] && return
  selected=${selected#alias }
  local name=${selected%%=*}
  eval "$name"
}
alias al='fzf_alias_exec'

#####################################################################
# Claude Code
#####################################################################
alias cc='claude'
alias ccao='claude --model opus --effort high --permission-mode auto'
claude-ultracode() {
  claude --model opus --settings '{"ultracode": true}' --permission-mode auto
}
alias ult=claude-ultracode

claude-code-with-tmux-session() {
  # gitリポジトリ確認
  local repo_root
  repo_root=$(git rev-parse --show-toplevel 2>/dev/null)
  if [[ -z "$repo_root" ]]; then
    echo "Error: git repository not found" >&2
    return 1
  fi

  # tmux起動確認
  if [[ -z "$TMUX" ]] && ! tmux info &>/dev/null; then
    echo "Error: tmux is not running" >&2
    return 1
  fi

  local repo_name
  repo_name=$(basename "$repo_root")

  # 暫定セッション名: cc-{repo}-{HHMMSS}（並列起動しても衝突しない）
  local session="cc-${repo_name}-$(date +%H%M%S)"

  if [[ -n "$TMUX" ]]; then
    # tmux内から呼んだ場合: 新しいセッションを作って切り替え
    tmux new-session -d -s "$session" -c "$repo_root"
    tmux send-keys -t "$session" "claude" Enter
    tmux switch-client -t "$session"
  else
    # tmux外から呼んだ場合: 新しいセッションを作ってアタッチ
    tmux new-session -d -s "$session" -c "$repo_root"
    tmux send-keys -t "$session" "claude" Enter
    tmux attach -t "$session"
  fi
}
alias ccss='claude-code-with-tmux-session'

open-prompts() {
  local dir="${HOME}/.config/prompts"
  local file
  file=$(fd --type f . "$dir" 2>/dev/null || find "$dir" -type f) || return
  file=$(printf '%s\n' "$file" | fzf \
    --preview 'bat --color=always --style=numbers {} 2>/dev/null || cat {}'
  ) || return
  [[ -n "$file" ]] && ${EDITOR:-nvim} "$file"
}
alias pt=open-prompts

function edit-claude-settings() {
    local files=(
        "~/.claude/settings.json"
        ".claude/settings.json"
        ".claude/settings.local.json"
    )
    selected=$(printf "%s\n" "${files[@]}" | xargs -I{} sh -c "[ -f {} ] && echo {}" \
        | fzf --preview "sed -n \"1,200p\" {}")
    [ -n "$selected" ] && ${EDITOR:-nvim} "$selected"
}
alias cccon=edit-claude-settings

#####################################################################
# llmbox
#####################################################################
alias lbcc='lbox exec sandbox claude'
lbox-review-worktree() {
  local common root here rel
  common=$(git rev-parse --path-format=absolute --git-common-dir) || return 1
  root=${common%/.git}
  here=$(pwd -P)
  if [ "$here" = "$root" ]; then rel=.; else rel=${here#"$root"/}; fi
  (cd "$root" && lbox exec sandbox sh -c 'cd "$1" && shift && exec claude "$@"' _ "$rel" "$@")
}
alias lbrev=lbox-review-worktree
alias lbccao='lbox exec sandbox claude --model opus --effort high --permission-mode auto'
lbox-claude-ultracode() {
  lbox exec sandbox claude --model opus --settings '{"ultracode": true}' --permission-mode auto
}
alias lbccult=lbox-claude-ultracode
alias lbcw='lbox exec sandbox claude -w'
alias lbcwao='lbox exec sandbox claude --model opus --effort high --permission-mode auto -w'
lbox-claude-ultracode-worktree() {
  lbox exec sandbox claude --model opus --settings '{"ultracode": true}' --permission-mode auto
}
alias lbcwult='lbox exec sandbox claude --model opus --effort high --permission-mode auto -w'
alias lbsh='lbox exec sandbox bash'
alias lbre='lbox down && lbox build && lbox up -d'

#####################################################################
# Docker Sandboxes
#####################################################################
alias sbcc='sbx run claude'
alias sbcw='sbx run claude -- --worktree'
alias sbcl='sbx run --clone claude'
alias sbclw='sbx run --clone claude -- --worktree'

#####################################################################
# Process management
#####################################################################
function kill-process-fzf() {
    local PROCESS=$(ps aux | sed 1d | fzf --multi --header --reverse)
    if [[ -n "$PROCESS" ]]; then
        echo "$PROCESS" | awk '{print $2}' | xargs -r kill
    fi
}
alias pkf=kill-process-fzf

#####################################################################
# Mac Utilities
#####################################################################
alias stopsleep='caffeinate -i -d'

#####################################################################
# Exit
#####################################################################
alias ei=exit

#####################################################################
# OpenCode
#####################################################################
alias oc=opencode

#####################################################################
# clitto
#####################################################################
alias clf='clto pick'
alias cle='clto open'

#####################################################################
# chrosuke
#####################################################################
alias hi='chsu history'
alias bk='chsu bookmark'

#####################################################################
# Microsoft Defender
#####################################################################
mdatp-rank() {
  local n="${1:-20}"
  printf "%-7s %10s %9s  %s\n" "PID" "FILES" "SCAN(s)" "COMMAND"
  mdatp diagnostic real-time-protection-statistics --output json \
  | jq -r '.counters
      | sort_by(.totalScanTime | tonumber) | reverse
      | .[]
      | "\(.id)\t\(.totalFilesScanned)\t\(.totalScanTime)"' \
  | head -n "$n" \
  | while IFS=$'\t' read -r pid files ns; do
      local sec
      sec=$(awk "BEGIN{printf \"%.1f\", $ns/1e9}")
      local cmd
      cmd=$(ps -p "$pid" -o command= 2>/dev/null | cut -c1-70)
      [[ -z "$cmd" ]] && cmd="(exited)"
      printf "%-7s %10s %9s  %s\n" "$pid" "$files" "$sec" "$cmd"
    done
}
alias mdatprank=mdatp-rank
alias mdatpton="mdatp config real-time-protection-statistics --value disabled"
alias mdatptoff="mdatp config real-time-protection-statistics --value enabled"

#####################################################################
# work
#####################################################################
open-sale() {
  if [[ -z "$1" ]]; then
    echo "Usage: osl <carRequestId>" >&2
    return 1
  fi
  open "https://management.go.mo-t.com/sales?carRequestId=$1"
}
alias osl=open-sale

open-car-request() {
  if [[ -z "$1" ]]; then
    echo "Usage: ocr <carRequestId>" >&2
    return 1
  fi
  open "https://management.go.mo-t.com/orders?carRequestId=$1"
}
alias ocr=open-car-request
