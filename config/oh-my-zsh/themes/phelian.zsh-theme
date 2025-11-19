if [ $UID -eq 0 ]; then CARETCOLOR="red"; else CARETCOLOR="blue"; fi

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
    echo "$(basename "$repo_path")"
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
  # Build the left side
  local left_prompt="$(build_custom_prompt)%{${fg[green]}%}$(git_repo_name) $(git_prompt_info)%{${reset_color}%}"

  # Build the right side (gcloud info)
  local right_prompt="$(custom_gcloud_prompt)"

  # Strip color codes to get visible lengths
  local left_visible="${(S%%)left_prompt//\%\{*\%\}}"
  local right_visible="${(S%%)right_prompt//\%\{*\%\}}"
  local left_length=${#left_visible}
  local right_length=${#right_visible}

  # Calculate padding (leave at least 1 space)
  local total_length=$((left_length + right_length))
  local padding=$((COLUMNS - total_length))

  if [[ $padding -lt 1 ]]; then
    padding=1
  fi

  # Build the first line with padding
  local spaces=$(printf ' %.0s' {1..$padding})
  echo "${left_prompt}${spaces}${right_prompt}"
}

function set_prompt_style() {
  if [[ $PROMPT_MULTILINE -eq 1 ]]; then
    # Multi-line prompt: prompt on one line, cursor on the next
    PROMPT='$(build_multiline_prompt)
%{${fg_bold[$CARETCOLOR]}%}»%{${reset_color}%} '
    RPROMPT='${return_code}'
  else
    # Single-line prompt: everything on one line
    PROMPT='$(build_custom_prompt)%{${fg[green]}%}$(git_repo_name) $(git_prompt_info)%{${fg_bold[$CARETCOLOR]}%}»%{${reset_color}%} '
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

ZSH_THEME_GIT_PROMPT_PREFIX="%{$fg[yellow]%}‹"
ZSH_THEME_GIT_PROMPT_SUFFIX="› %{$reset_color%}"