if [ $UID -eq 0 ]; then CARETCOLOR="red"; else CARETCOLOR="blue"; fi

# Enable command substitution in prompts
setopt prompt_subst

# Git prompt styling - MUST be defined before any function calls
ZSH_THEME_GIT_PROMPT_PREFIX="%{$fg[yellow]%}‹"
ZSH_THEME_GIT_PROMPT_SUFFIX="› %{$reset_color%}"

# Simple git branch display - doesn't rely on oh-my-zsh
function git_branch_info() {
  local branch
  branch=$(git symbolic-ref --short HEAD 2>/dev/null) || return 0

  # Check for dirty status
  local dirty=""
  if [[ -n $(git status --porcelain 2>/dev/null) ]]; then
    dirty="*"
  fi

  echo "%{$fg[yellow]%}‹${branch}${dirty}›%{$reset_color%}"
}

# Source private gcloud account configurations if they exist
# This file is git-ignored and allows you to add work/private account displays
[[ -f "$HOME/.gcloud-prompt-accounts.zsh" ]] && source "$HOME/.gcloud-prompt-accounts.zsh"

function custom_gcloud_prompt() {
  # Displays gcloud account info in the right prompt
  # - Only shows if gcloud is installed
  # - Shows account name and current project
  # - Reads config file directly (fast, no CLI calls)
  #
  # For private account configurations (work emails, etc.), create:
  #   ~/.gcloud-prompt-accounts.zsh
  # See README.md for details on custom account display

  # Only show if gcloud is installed
  if ! command -v gcloud &> /dev/null; then
    echo ""
    return
  fi

  # Fast gcloud info by reading config file directly
  local gcloud_config="$HOME/.config/gcloud/configurations/config_default"

  if [[ ! -f "$gcloud_config" ]]; then
    echo ""
    return
  fi

  local account=$(grep "^account = " "$gcloud_config" 2>/dev/null | cut -d' ' -f3)
  local project=$(grep "^project = " "$gcloud_config" 2>/dev/null | cut -d' ' -f3)

  if [[ -z "$account" ]]; then
    echo ""
    return
  fi

  # Check if custom account display function exists (from private config)
  if typeset -f custom_gcloud_account_display > /dev/null; then
    local custom_output=$(custom_gcloud_account_display "$account" "$project")
    if [[ -n "$custom_output" ]]; then
      echo "$custom_output"
      return
    fi
  fi

  # Default public accounts
  if [[ "$account" == "alexander@fogpipe.com" ]]; then
    if [[ -n "$project" ]]; then
      echo "%{$fg[green]%}[fogpipe%{$reset_color%}|%{$fg[cyan]%}$project%{$reset_color%}] "
    else
      echo "%{$fg[green]%}[fogpipe]%{$reset_color%} "
    fi
  else
    echo ""
  fi
}

function smart_kube_ps1() {
  # Only show if kubectl is installed
  if ! command -v kubectl &> /dev/null; then
    echo ""
    return
  fi

  local context=$(kubectl config current-context 2>/dev/null)
  if [[ -n "$context" ]]; then
    kube_ps1
  else
    echo ""
  fi
}

function build_custom_prompt() {
  local kube_info=$(smart_kube_ps1)

  if [[ -n "$kube_info" ]]; then
    echo "$kube_info "
  fi
}

function git_repo_name() {
  local repo_path=$(git rev-parse --show-toplevel 2>/dev/null)
  if [[ -n "$repo_path" ]]; then
    local repo_name="$(basename "$repo_path")"
    local current_path="$PWD"

    # Get relative path from repo root
    local rel_path="${current_path#$repo_path}"
    rel_path="${rel_path#/}"  # Remove leading slash

    if [[ -z "$rel_path" ]]; then
      # At repo root
      echo "$repo_name"
    else
      # Split path into components
      local -a path_parts=("${(@s:/:)rel_path}")
      local num_parts=${#path_parts}

      if [[ $num_parts -le 3 ]]; then
        # Show repo name + full subpath (up to 3 levels)
        echo "$repo_name/$rel_path"
      else
        # More than 3 levels deep - show last 3 with ../
        local last_three="${path_parts[-3]}/${path_parts[-2]}/${path_parts[-1]}"
        echo "../$last_three"
      fi
    fi
  else
    echo "%3~"
  fi
}

local return_code="%(?..%{$fg[red]%}%? ↵%{$reset_color%})"

# Prompt style toggle - load preference from file if it exists
if [[ -f "$HOME/.prompt-multiline" ]]; then
  PROMPT_MULTILINE=1
else
  PROMPT_MULTILINE=0
fi

function build_multiline_prompt() {
  # Build components
  local kube_part="$(build_custom_prompt)"
  local repo_part="$(git_repo_name)"
  local gcloud_part="$(custom_gcloud_prompt)"

  # Build left prompt - we need to call git_prompt_info inline for proper evaluation
  # First build a version for length calculation (without git_prompt_info)
  local left_base="${kube_part}%{${fg[green]}%}${repo_part}%{${reset_color}%}"

  # Get git branch info for length calculation
  local git_info="$(git_branch_info)"
  local left_for_calc="${left_base} ${git_info}"

  # Calculate visible length using zsh's prompt expansion
  local left_length=${#${(S%%)left_for_calc//(\%([KF1]|)\{*\}|\%[Bbkf])}}
  local right_length=${#${(S%%)gcloud_part//(\%([KF1]|)\{*\}|\%[Bbkf])}}

  # Calculate padding (leave at least 1 space)
  local total_length=$((left_length + right_length))
  local padding=$((COLUMNS - total_length))

  if [[ $padding -lt 1 ]]; then
    padding=1
  fi

  # Build the first line with padding - include git_info
  local spaces="${(l:$padding:: :)}"
  echo "${left_base} ${git_info}${spaces}${gcloud_part}"
}

function set_prompt_style() {
  if [[ $PROMPT_MULTILINE -eq 1 ]]; then
    # Multi-line prompt: prompt on one line, cursor on the next
    PROMPT='$(build_multiline_prompt)
%{${fg_bold[$CARETCOLOR]}%}»%{${reset_color}%} '
    RPROMPT='${return_code}'
  else
    # Single-line prompt: everything on one line
    PROMPT='$(build_custom_prompt)%{${fg[green]}%}$(git_repo_name) $(git_branch_info)%{${fg_bold[$CARETCOLOR]}%}»%{${reset_color}%} '
    RPROMPT='$(custom_gcloud_prompt)${return_code}'
  fi
}

function toggle_prompt() {
  if [[ $PROMPT_MULTILINE -eq 1 ]]; then
    PROMPT_MULTILINE=0
    rm -f "$HOME/.prompt-multiline"
    echo "Switched to single-line prompt"
  else
    PROMPT_MULTILINE=1
    touch "$HOME/.prompt-multiline"
    echo "Switched to multi-line prompt"
  fi
  set_prompt_style
}

# Set initial prompt style
set_prompt_style