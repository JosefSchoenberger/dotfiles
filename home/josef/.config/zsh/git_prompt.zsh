function __git_prompt_git() {
  GIT_OPTIONAL_LOCKS=0 command git "$@"
}

function git_prompt_info() {
  if ! __git_prompt_git rev-parse --git-dir &> /dev/null \
     || [[ "$(__git_prompt_git config --get oh-my-zsh.hide-info 2>/dev/null)" == 1 ]]; then
    return 0
  fi

  local ref
  ref=$(__git_prompt_git symbolic-ref --short HEAD 2> /dev/null) \
  || ref=$(__git_prompt_git rev-parse --short HEAD 2> /dev/null) \
  || return 0

  local upstream
  if (( ${+ZSH_THEME_GIT_SHOW_UPSTREAM} )); then
    upstream=$(__git_prompt_git rev-parse --abbrev-ref --symbolic-full-name "@{upstream}" 2>/dev/null) \
    && upstream=" -> ${upstream}"
  fi

  echo "$(git_status_to_color)${ZSH_THEME_GIT_PROMPT_PREFIX}${ref}${upstream}${ZSH_THEME_GIT_PROMPT_SUFFIX}"
}

function git_status_to_color() {
	local git_out=$(command git status --porcelain | cut -c -2)
	if echo "$git_out" | grep -E 'M|\?|D' >/dev/null; then
		echo "$ZSH_THEME_GIT_PROMPT_MODIFIED_COLOR"
	elif echo "$git_out" | grep A >/dev/null; then
		echo "$ZSH_THEME_GIT_PROMPT_STAGED_COLOR"
	else
		echo "$ZSH_THEME_GIT_PROMPT_CLEAN_COLOR"
	fi
}
