#!/bin/bash
# https://qiita.com/dai_chi/items/d72ec42444d66e88a044

input=$(cat)

IFS=$'\x1f' read -r model context_pct workspace cost rate_5h rate_7d resets_at_5h resets_at_7d total_in total_out session_name \
  <<< "$(echo "$input" | jq -r '[
    (.model.display_name // "Unknown"),
    (.context_window.used_percentage // 0),
    (.workspace.current_dir // ""),
    (.cost.total_cost_usd // 0),
    (.rate_limits.five_hour.used_percentage // ""),
    (.rate_limits.seven_day.used_percentage // ""),
    (.rate_limits.five_hour.resets_at // ""),
    (.rate_limits.seven_day.resets_at // ""),
    (.context_window.total_input_tokens // ""),
    (.context_window.total_output_tokens // ""),
    (.session_name // "" | if length > 60 then .[0:59] + "…" else . end)
  ] | join("\u001f")' 2>/dev/null)"

_result=""
format_rate() {
  local pct="$1" resets_at="$2" div1="$3" unit1="$4" div2="$5" unit2="$6"
  if [[ -z "$pct" || "$pct" == "null" ]]; then
    _result="--"
    return
  fi
  local pct_int="${pct%.*}"
  local reset_display=""
  if [[ -n "$resets_at" && "$resets_at" != "null" ]]; then
    local remaining=$(( resets_at - now ))
    if (( remaining > 0 )); then
      local u1=$(( remaining / div1 )) u2=$(( (remaining % div1) / div2 ))
      reset_display=" (${u1}${unit1}${u2}${unit2})"
    fi
  fi
  _result="${pct_int}%${reset_display}"
}

ws_name="--"
branch_label="Branch"
branch_icon="🌿"
if [[ -n "$workspace" ]]; then
  origin_url=$(git -C "$workspace" remote get-url origin 2>/dev/null)
  { read -r git_dir; read -r common_dir; } < <(git -C "$workspace" rev-parse --git-dir --git-common-dir 2>/dev/null)
  # --git-common-dir may be relative depending on the cwd, so normalize with cd && pwd -P
  # (--path-format=absolute requires git 2.31+).
  [[ -n "$git_dir" ]] && git_dir=$(cd "$workspace" 2>/dev/null && cd "$git_dir" 2>/dev/null && pwd -P)
  [[ -n "$common_dir" ]] && common_dir=$(cd "$workspace" 2>/dev/null && cd "$common_dir" 2>/dev/null && pwd -P)

  if [[ -n "$origin_url" ]]; then
    ws_name=$(basename "$origin_url" .git)
  elif [[ -n "$common_dir" ]]; then
    ws_name=$(basename "$(dirname "$common_dir")")
  else
    ws_name=$(basename "$workspace")
  fi

  if [[ -n "$git_dir" && -n "$common_dir" && "$git_dir" != "$common_dir" ]]; then
    branch_label="Worktree"
    branch_icon="🌳"
  fi
fi

branch=$(git -C "$workspace" branch --show-current 2>/dev/null || echo "--")
branch="${branch:-"--"}"

context_int="${context_pct%.*}"

filled=$(( context_int / 10 )); empty_count=$(( 10 - filled ))
bar=""
for (( i=0; i<filled; i++ )); do bar+="█"; done
for (( i=0; i<empty_count; i++ )); do bar+="░"; done

[[ -n "$rate_5h$rate_7d" ]] && now=$(date +%s)

format_rate "$rate_5h" "$resets_at_5h" 3600 h 60 m
rate_5h_display="$_result"
format_rate "$rate_7d" "$resets_at_7d" 86400 d 3600 h
rate_7d_display="$_result"

fmt_k() {
  local n="$1"
  if (( n >= 1000 )); then
    printf '%d.%dk' "$(( n / 1000 ))" "$(( (n % 1000) / 100 ))"
  else
    printf '%d' "$n"
  fi
}

ctx_tokens_display=""
if [[ -n "$total_in" && "$total_in" != "null" && -n "$total_out" && "$total_out" != "null" ]]; then
  ctx_tokens_display=" (⬇️$(fmt_k "$total_in") in / ⬆️$(fmt_k "$total_out") out)"
fi

cost_display=$(printf '$%.2f' "$cost")

session_name="${session_name:-"--"}"

echo "📝Session:${session_name}"
echo "🤖Model:${model} ▸ 📦Repository:${ws_name} ▸ ${branch_icon}${branch_label}:${branch}"
echo "🪣Context: ${bar} ${context_int}%${ctx_tokens_display} ▸ 🔶5h: ${rate_5h_display} ▸ 🔴7d: ${rate_7d_display} ▸ 💰Cost:${cost_display}"
