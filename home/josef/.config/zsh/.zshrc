PATH_TO_THIS_FILE="$ZDOTDIR"

# Lines configured by zsh-newuser-install
HISTFILE=~/.config/zsh/.histfile
HISTSIZE=200000
SAVEHIST=200000
unsetopt beep
# End of lines configured by zsh-newuser-install
# The following lines were added by compinstall
zstyle :compinstall filename '/home/josef/.config/zsh/.zshrc'

if command -v rustup 2>&1 >/dev/null; then
	# Must be before compinit
	P=~/.local/share/zsh/functions/Completions/
	mkdir -p "$P"
	if ! [ -s "$P/_rustup" ]; then
		rustup completions zsh rustup >"$P/_rustup"
	fi
	if ! [ -s "$P/_cargo" ]; then
		rustup completions zsh cargo >"$P/_cargo"
	fi
	fpath+="$P"
	unset P
fi

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

setopt interactivecomments

bindkey '[1;5C' forward-word # Ctrl+Right
bindkey '[1;5D' backward-word # Ctrl+Left
bindkey '' backward-kill-word # Ctrl+Backspace
bindkey '[3;5~' kill-word # Ctrl+Delete
bindkey -M menuselect '[Z' reverse-menu-complete # Shift+Tab

[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

case "$TERM" in
	xterm-color|*-256color|xterm-kitty) color_prompt=yes;;
esac

#force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
	if [ -x /usr/bin/tput ] && tput setaf 1>&/dev/null; then
		color_prompt=yes
	else
		color_prompt=
	fi
fi

if [ "$color_prompt" = yes ]; then
	setopt PROMPT_SUBST

	if [ $EUID = 0 ]; then
		color_user="%B%F{9}"
	else
		color_user="%(!.%F{3}.%F{2})"
	fi
	[ -n "$SSH_TTY" ] && color_host="%B%F{3}" || color_host="%F{2}"
	
	#ZSH_THEME_GIT_PROMPT_MODIFIED_COLOR="%F{1}"
	#ZSH_THEME_GIT_PROMPT_STAGED_COLOR="%F{3}"
	#ZSH_THEME_GIT_PROMPT_CLEAN_COLOR="%F{2}"

	RPROMPT_COLOR='%F{238}'

	# default: PROMPT='%m%#'
	# PROMPT="$color_user%n%f%b@$color_host%m%f%b:%B%F{4}%~%b$git%(?..%B%F{1} (%?%))%b%f%# "
	PROMPT="$color_user%n%f%b@$color_host%m%f%b:%B%F{4}%~%b%f%(?..%B%F{1}%b)%#%f "
	RPROMPT=$RPROMPT_COLOR'%(?..($?%) )'
	#RPROMPT+='$(OUT=$(timeout 0.3s git branch --show-current 2>/dev/null) && echo "[$OUT] ")'
	if [ -r $PATH_TO_THIS_FILE/git-prompt.zsh ]; then
		RPROMPT+='$(gitprompt)$(gitprompt_secondary)'"$RPROMPT_COLOR"
		ZSH_GIT_PROMPT_ENABLE_SECONDARY=y
		ZSH_THEME_GIT_PROMPT_PREFIX="["
		ZSH_THEME_GIT_PROMPT_SUFFIX="$RPROMPT_COLOR] "
		ZSH_THEME_GIT_PROMPT_SEPARATOR="$RPROMPT_COLOR|"
		ZSH_THEME_GIT_PROMPT_DETACHED="%B%F{52}"
		ZSH_THEME_GIT_PROMPT_BRANCH="%B"
		ZSH_THEME_GIT_PROMPT_UPSTREAM_PREFIX="%{$fg[red]%}(%{$fg[yellow]%}"
		ZSH_THEME_GIT_PROMPT_UPSTREAM_SUFFIX="%{$fg[red]%})"
		ZSH_THEME_GIT_PROMPT_UPSTREAM_NO_TRACKING="%F{52}$"
		ZSH_THEME_GIT_PROMPT_BEHIND="%K{52}%F{244}↓"
		ZSH_THEME_GIT_PROMPT_AHEAD="%F{28}↑"
		ZSH_THEME_GIT_PROMPT_UNMERGED="%K{52}✖"
		ZSH_THEME_GIT_PROMPT_STAGED="%F{28}●"
		ZSH_THEME_GIT_PROMPT_UNSTAGED="%F{58}✚"
		ZSH_THEME_GIT_PROMPT_UNTRACKED=$RPROMPT_COLOR"…"
		ZSH_THEME_GIT_PROMPT_STASHED="%F{21}⚑"
		ZSH_THEME_GIT_PROMPT_CLEAN="%F{22}✔"
		ZSH_THEME_GIT_PROMPT_SECONDARY_PREFIX=""
		ZSH_THEME_GIT_PROMPT_SECONDARY_SUFFIX=" "
		ZSH_THEME_GIT_PROMPT_TAGS_SEPARATOR=$RPROMPT_COLOR","
		ZSH_THEME_GIT_PROMPT_TAGS_PREFIX="-"
		ZSH_THEME_GIT_PROMPT_TAGS_SUFFIX=""
		ZSH_THEME_GIT_PROMPT_TAG="%F{95}"
		source $PATH_TO_THIS_FILE/git-prompt.zsh
	else
		RPROMPT+='$(OUT=$(timeout 0.3s git branch --show-current 2>/dev/null) && echo "[$OUT] ")'
	fi

	#RPROMPT+='$(DIFF=$(timeout 0.1s git diff --shortstat 2>/dev/null | sed -e '\''s!, ! !g'\'' -e '\''s!\s*[0-9]\+ files\? changed!!'\'' -e '\''s!\s*\([0-9]\+\) insertions\?(+)!\1+!'\'' -e '\''s!\([0-9]\+\) deletions\?(-)!\1-!'\'' -e '\''s!\s\s\+! !g'\'') && { [ -n "$DIFF" ] && echo "%F{52}$DIFF%F{238} " })'
	RPROMPT+='%1(j.(%j job%2(j.s.)%) .)'
	RPROMPT+='%D{%d.%m, %H:%M:%S}'
else
	PROMPT="%n@%m:%~$git%(?.. (%?%))%# "
fi

#if [ -r $PATH_TO_THIS_FILE/git_prompt.zsh ]; then
#	source $PATH_TO_THIS_FILE/git_prompt.zsh && git='$(git_prompt_info)' || git=''
#else
#	git=''
#fi
#ZSH_THEME_GIT_PROMPT_PREFIX=' ['
#ZSH_THEME_GIT_PROMPT_SUFFIX="]"


setopt nomultios # this is stupid. >&1 >&1 duplicates the output...

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
[ -e /etc/wsl.conf ] && export BROWSER="$PATH_TO_THIS_FILE/wsl-open-with-firefox.bash" || : # for rustup doc
alias minemount="sudo mount -o exec,gid=$(id -u),uid=$(id -u),umask=027" # mount for me
command -v vim >/dev/null && alias vi='vim --cmd "let g:no_ycm=1"'

command -v gdb >/dev/null && alias gdb='gdb -q' # I've seen the copyright statement.
command -v rust-gdb >/dev/null && alias rust-gdb='rust-gdb -q'
alias ffmpeg='ffmpeg -hide_banner'
alias ffplay='ffplay -hide_banner'
alias ffprobe='ffprobe -hide_banner'
alias kitty-mpv="mpv --vo=kitty --vo-kitty-use-shm=yes"

alias make='make -j$(nproc)'

#alias docker-image-dependencies="docker inspect --format='{{.Size}} {{truncate .Id 16}} {{if .Parent}}-> {{truncate .Parent 16}}{{else}}   ---------{{end}} {{.RepoTags}}' \$(docker images --all -q) | sed 's/sha256://g' | sort -k2 | numfmt --field=1 --to=iec-i --pad=6 --suffix=B"
alias docker-image-dependencies='docker inspect --format='\''{{.Size}} {{truncate .Id 16}} {{if .Parent}} {{truncate .Parent 16}}{{else}} ---------{{end}} {{.RepoTags}}'\'' $(docker images --all -q) | sort -h | numfmt --field=1 --to=iec-i --pad=6 --suffix=B | sed "s/sha256://g" | column --tree-id=2 --tree-parent=3 --tree 4 -H 3 -o " "'

alias help='run-help'

analyze_latex_log() {
	( [ -r "$1" ] && cat "$1" || cat "build/exam.tex/$1/$1.log" ) \
		| python3 -c "import regex, sys; [print(regex.sub(r'\\(jcc\\)|\\(/usr/share[^()]*(""(?R) *)*[^()]*\) *', '', line), end='') for line in sys.stdin]" \
		| sed -e 's/\/usr\/share\/tex[A-Za-z0-9/._\-]*\//'$'\e[38;5;239m\\0\e[39m/g' \
		      -e 's/chapter \([0-9]\+.\|without number\)/'$'\e[38;5;239m\\0\e[39m/g' \
			  -e 's/\[[0-9]\+\]/'$'\e[38;5;239m\\0\e[39m/g' \
			  -e 's/^.*\(Warning\|warning\|Error\|Underfull\|Overfull\|\!\|Reference\|Label\|Citation\).*$/'$'\e[31m\\0\e[39m/' \
			  -e 's!/endterm/[A-Za-z0-9./_-]*tex!'$'\e[33m\\0\e[39m!g'
}

alias sudopriv="sudo -E setpriv --reuid $(id -u) --regid $(id -g) --groups $(id -g),$(groups | tr ' ' ',') --inh-caps=+all --ambient-caps=+all $SHELL"
alias gh='git hist --color=always --all | head -n20'
alias ghl='git hist --color=always --all | less'
#gs = ghostscript
#alias gs='git status'
alias gst='git status'
alias gd='git diff'
alias gds='git diff --staged'
alias gdw='git diff --color-words'
alias gdws='git diff --color-words --staged'
alias gsh='git show'
alias gshw='git show --color-words'
alias ga='git add'
alias gsw='git switch'

cdtmp() {
	cd $(mktemp -d)
}
# same, but persistent (i.e. persist accross reboots)
cdptmp() {
	cd $(mktemp -d -p /var/tmp)
}

rmcwd() {
	echo -n "Do you really want to remove this folder (y/N): "
	pwd
	read && if [ "$REPLY" != y ]; then
		return
	fi
	if [[ ! "$(pwd)" =~ '^/tmp' && ! "$(pwd)" =~ '^/var/tmp' ]]; then
		echo "REALLY?! You're not within /tmp or /var/tmp (y/N)!"
		read && if [ "$REPLY" != y ]; then
			return
		fi
	fi


	local o="$OLDPWD"
	rm "$(pwd)" -r
	cd ..
	OLDPWD=$o
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

if [ -n "$KITTY_INSTALLATION_DIR" ]; then
	KITTY_SHELL_INTEGRATION="${KITTY_SHELL_INTEGRATION//no-rc( |)}"
	autoload -Uz -- "$KITTY_INSTALLATION_DIR"/shell-integration/zsh/kitty-integration
    kitty-integration
    unfunction kitty-integration

	alias kssh='kitten ssh'
fi

zstyle ':completion:*' menu select
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:::::' completer _complete _approximate
zstyle ':completion:*' format '%B%F{12}━━━━ %d ━━━━%b%f'
zstyle ':completion:*' group-name ''

zstyle ':completion:*:cd:*' ignored-patterns '(*/)#CVS'
zstyle ':completion:*:*:vim:*' file-patterns '^*.(aux|pdf|exe|out|ps|zip|tar|pyc|xdvi|jpg):source-files' '*:all-files'
zstyle ':completion:*:*:okular:*' file-patterns '^*.(aux|out|tex):source-files' '*:all-files'
zstyle ':completion:*:*:log:*' file-sort time

autoload -U + X bashcompinit && bashcompinit
# source /usr/share/bash-completion/bash_completion

if [ -r /usr/share/doc/fzf/examples/key-bindings.zsh ]; then
	source /usr/share/doc/fzf/examples/key-bindings.zsh
	source /usr/share/doc/fzf/examples/completion.zsh
	#export FZF_ALT_C_OPTS="--walker-skip .git,node_modules,target --preview 'tree -C {}'"
	#	export FZF_CTRL_T_OPTS="--walker-skip .git,node_modules,target --preview 'bat -n --color=always {}' --bind 'ctrl-/:change-preview-window(down|hidden|)'"
	ansi=
	if command -V fdfind >/dev/null 2>&1; then
		export FZF_DEFAULT_COMMAND='fdfind -c always --strip-cwd-prefix --hidden --follow --exclude .git,/proc'
		export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
		ansi=--ansi
	fi
	if [ -e "$PATH_TO_THIS_FILE/fzf-preview.sh" ]; then
		export FZF_DEFAULT_OPTS="--preview '$PATH_TO_THIS_FILE/fzf-preview.sh {}' --bind 'ctrl-/:change-preview-window(down|hidden|)' $ansi"
		export FZF_CTRL_T_OPTS="$FZF_DEFAULT_OPTS"
	elif command -V bat >/dev/null 2>&1; then
		export FZF_DEFAULT_OPTS="--preview 'bat -n --color=always {}' --bind 'ctrl-/:change-preview-window(down|hidden|)' $ansi"
		export FZF_CTRL_T_OPTS="$FZF_DEFAULT_OPTS"
	else
		export FZF_DEFAULT_OPTS="--preview 'cat {}' --bind 'ctrl-/:change-preview-window(down|hidden|)' $ansi"
		export FZF_CTRL_T_OPTS="$FZF_DEFAULT_OPTS"
	fi
	export FZF_ALT_C_OPTS="--preview 'tree -C {}'"
	export FZF_CTRL_R_OPTS="--preview 'echo {}' --preview-window=top,30%,wrap"
	unset ansi
fi

[ -r "$PATH_TO_THIS_FILE/zsh-autosuggestions/zsh-autosuggestions.zsh" ] && source "$PATH_TO_THIS_FILE/zsh-autosuggestions/zsh-autosuggestions.zsh"
ZSH_AUTOSUGGEST_STRATEGY=(history completion)

if [ -r "$PATH_TO_THIS_FILE/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]; then
	source "$PATH_TO_THIS_FILE/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
	ZSH_HIGHLIGHT_STYLES[comment]=fg=blue
fi

if [ -n "$SSH_TTY" ]; then
	. ~/.profile
fi

redstderr() {
	set -o pipefail;
	"$@" 2> >(sed $'s/.*/\e[31m&\e[m/' >&2)
}

export DEBUGFS_PAGER=cat
export GPG_TTY="$(tty)"
export ANSIBLE_NOCOWS=1

if [ -z "$SSH_TTY" ]; then
	function presentationmode() {
		if ! pgrep mako >/dev/null 2>&1; then
			echo "Error: Mako is not currently running."
			return
		fi
		if [ "$1" = "" ]; then
			echo "Usage: presentationmode <time>" >&2
			return
		fi
		if makoctl mode | grep -q silent; then
			echo "Already in presentation mode." >&2
			return
		fi
		makoctl mode -a silent >/dev/null || return
		pkill gammastep
		systemd-inhibit --what=idle sleep "$1"
		makoctl mode -r silent >/dev/null
		(
		gammastep >/dev/null 2>&1 &
		)
	}
fi

unset PATH_TO_THIS_FILE
