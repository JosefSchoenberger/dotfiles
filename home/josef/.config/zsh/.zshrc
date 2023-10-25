PATH_TO_THIS_FILE="$ZDOTDIR"

# Lines configured by zsh-newuser-install
HISTFILE=~/.config/zsh/.histfile
HISTSIZE=200000
SAVEHIST=200000
unsetopt beep
# End of lines configured by zsh-newuser-install
# The following lines were added by compinstall
zstyle :compinstall filename '/home/josef/.config/zsh/.zshrc'

autoload -Uz compinit
compinit
zmodload zsh/complist
# End of lines added by compinstall
_comp_options+=(globdots)

if [ -e "$HOME/.cargo/env" ]; then
	. "$HOME/.cargo/env" # Load Rust even if non-interactive
fi

# do nothing if not interactive
case $- in
	*i*) ;;
	  *) return ;;
esac

setopt HIST_IGNORE_SPACE
setopt HIST_NO_STORE
setopt histignorealldups

bindkey '[1;5C' forward-word # Ctrl+Right
bindkey '[1;5D' backward-word # Ctrl+Left
bindkey '' backward-kill-word # Ctrl+Backspace
bindkey -M menuselect '[Z' reverse-menu-complete # Shift+Tab

[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

case "$TERM" in
	xterm-color|*-256color|xterm-kitty) color_prompt=yes;;
esac

force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
	if [ -x /usr/bin/tput ] && tput setaf 1>&/dev/null; then
		color_prompt=yes
	else
		color_prompt=
	fi
fi

setopt PROMPT_SUBST
if [ -r $PATH_TO_THIS_FILE/git_prompt.zsh ]; then
	source $PATH_TO_THIS_FILE/git_prompt.zsh && git='$(git_prompt_info)' || git=''
else
	git=''
fi
ZSH_THEME_GIT_PROMPT_PREFIX=' ['
ZSH_THEME_GIT_PROMPT_SUFFIX="]"

if [ "$color_prompt" = yes ]; then
	if [ $EUID = 0 ]; then
		color_user="%B%F{9}"
	else
		color_user="%F{2}"
	fi
	[ -n "$SSH_TTY" ] && color_host="%B%F{3}" || color_host="%F{2}"
	
	ZSH_THEME_GIT_PROMPT_MODIFIED_COLOR="%F{1}"
	ZSH_THEME_GIT_PROMPT_STAGED_COLOR="%F{3}"
	ZSH_THEME_GIT_PROMPT_CLEAN_COLOR="%F{2}"

	# default: PROMPT='%m%#'
	# PROMPT="$color_user%n%f%b@$color_host%m%f%b:%B%F{4}%~%b$git%(?..%B%F{1} (%?%))%b%f%# "
	PROMPT="$color_user%n%f%b@$color_host%m%f%b:%B%F{4}%~%b$git%b%f%(?..%B%F{1}%b)%#%f "
	RPROMPT='%F{236}%(?..($?%) )$(OUT=$(git branch --show-current 2>/dev/null) && echo "[$OUT] ")%1(j.(%j jobs%) .)%D{%a %d.%m, %H:%M:%S Uhr}'
else
	PROMPT="%n@%m:%~$git (%?.. (%?%))%#"
fi

unset color_user color_host color_prompt force_color_prompt

if [ -x /usr/bin/dircolors ]; then
	test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
	alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
    alias rgrep='rgrep -n --color=auto'
	alias ip='ip -c'
fi

# colored GCC warnings and errors
#export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# some more ls aliases
alias ll='ls -lhF'
alias la='ls -A'
alias lla='ls -lhFA'
#alias l='ls -CF'
export LESS="--mouse --wheel-lines=3 -R"
alias minemount="sudo mount -o exec,gid=$(id -u),uid=$(id -u),umask=027" # mount for me
command -v vim >/dev/null && alias vi='vim --cmd "let g:no_ycm=1"'

command -v gdb >/dev/null && alias gdb='gdb -q' # I've seen the copyright statement.
command -v rust-gdb >/dev/null && alias rust-gdb='rust-gdb -q'
alias ffmpeg='ffmpeg -hide_banner'
alias ffplay='ffplay -hide_banner'
alias ffprobe='ffprobe -hide_banner'

alias make='make -j$(nproc)'

alias docker-image-dependencies="docker inspect --format='{{.Size}} {{truncate .Id 16}} {{if .Parent}}-> {{truncate .Parent 16}}{{else}}   ---------{{end}} {{.RepoTags}}' \$(docker images --all -q) | sed 's/sha256://g' | sort -k2 | numfmt --field=1 --to=iec-i --pad=6 --suffix=B"

alias sudopriv="sudo -E setpriv --reuid $(id -u) --regid $(id -g) --groups $(id -g),$(groups | tr ' ' ',') --inh-caps=+all --ambient-caps=+all $SHELL"

cdtmp() {
	cd $(mktemp -d)
}

rmcwd() {
	echo -n "Do you really want to remove this folder (y/n): "
	pwd
	read && if [ "$REPLY" = y ]; then 
		local o="$OLDPWD"
		rm "$(pwd)" -r
		cd ..
		OLDPWD=$o
	fi
}

mkcdir() {
	mkdir -p -- "$1" && cd -P -- "$1"
}

mvcd() {
	mv -- "$1" "$2" && cd -- "$2"
}

DISABLE_AUTO_TITLE="true"
if [ -n "$SSH_TTY" ]; then
	function set_terminal_title_precmd() {
		echo -En $'\e]2;SSH' "$HOST: ${PWD/\/home\/$USER/~}"$'\a'
	}
	function set_terminal_title_preexec() {
		echo -En $'\e]2;SSH' "$HOST ❯ ${1//$'\x1b'/\\e}"$'\a'
	}
else
	function set_terminal_title_precmd() {
		echo -En $'\e]2;ZSH:' "${PWD/\/home\/$USER/~}"$'\a'
	}
	function set_terminal_title_preexec() {
		echo -En $'\e]2;❯' "${1//$'\x1b'/\\e}"$'\a'
	}
fi
autoload -Uz add-zsh-hook
add-zsh-hook precmd set_terminal_title_precmd
add-zsh-hook preexec set_terminal_title_preexec

stty quit 
export WORDCHARS=$(tr -d '/' <<<"$WORDCHARS")

function man() {
	env LESS_TERMCAP_md=$(tput bold; tput setaf 6) LESS_TERMCAP_us=$(tput setaf 219; tput smul) LESS_TERMCAP_ue=$(tput sgr0; tput rmul) GROFF_NO_SGR=1 man "$@"
}

zstyle ':completion:*' menu select
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:::::' completer _complete _approximate
zstyle ':completion:*' format '%B%F{12}━━━━ %d ━━━━%b%f'
zstyle ':completion:*' group-name ''

zstyle ':completion:*:cd:*' ignored-patterns '(*/)#CVS'
zstyle ':completion:*:*:vim:*' file-patterns '^*.(aux|pdf|exe|out|ps|zip|tar|pyc|xdvi|jpg):source-files' '*:all-files'
zstyle ':completion:*:*:log:*' file-sort time

autoload -U + X bashcompinit && bashcompinit
# source /usr/share/bash-completion/bash_completion

[ -r "$PATH_TO_THIS_FILE/zsh-autosuggestions/zsh-autosuggestions.zsh" ] && source "$PATH_TO_THIS_FILE/zsh-autosuggestions/zsh-autosuggestions.zsh"
ZSH_AUTOSUGGEST_STRATEGY=(history completion)

[ -r "$PATH_TO_THIS_FILE/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ] && source "$PATH_TO_THIS_FILE/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
unset PATH_TO_THIS_FILE

if [ -n "$SSH_TTY" ]; then
	. ~/.profile
fi

redstderr() {
	set -o pipefail;
	"$@" 2> >(sed $'s/.*/\e[31m&\e[m/' >&2)
}

export DEBUGFS_PAGER=cat
