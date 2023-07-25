# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

if [ -e "$HOME/.cargo/env" ]; then
	. "$HOME/.cargo/env" # Load Rust even if non-interactive
fi

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color|*-256color|xterm-kitty) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
force_color_prompt=yes

if [ -z "$force_color_prompt" ]; then
	if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
		# We have color support; assume it's compliant with Ecma-48
		# (ISO/IEC-6429). (Lack of such support is extremely rare, and such
		# a case would tend to support setf rather than setaf.)
		color_prompt=yes
	else
		color_prompt=
	fi
fi

if [ "$color_prompt" = yes ]; then
	if [ $EUID = 0 ]; then
		USER_COLOR="\033[01;31m"
	else
		USER_COLOR="\033[01;32m"
	fi
	if [ -n "$SSH_TTY" ]; then
		HOST_COLOR="\033[01;33m"
	else
		HOST_COLOR="\033[01;32m"
	fi
	PS1='${debian_chroot:+($debian_chroot)}\['$USER_COLOR'\]\u\[\033[m\]@\['$HOST_COLOR'\]\h\[\033[m\]:\[\033[01;34m\]\w\[\033[m\]\[$(retval=$?; [ $retval -ne 0 ] && printf "\033[31m" $retval)\]\$\[\033[m\] '

	# \000 to avoid the repitition of the first letter
	export PS4='\000$(printf \e[32m"%s\e[m:\e[32m%3d\e[m | %s" $BASH_SOURCE $LINENO ${FUNCNAME[0]:+\e[33m${FUNCNAME[0]}()\e[m:" "})'
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
# PS1='$(retval=$?; printf "%$((COLUMNS))s\r" ; exit $retval)'$PS1
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
    alias rgrep='rgrep -n --color=auto'
	alias ip='ip -color=always'
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

if [ ! -n "$(command -v mpv)" ] && [ -n ${WSLENV+"non_zero_string if and only if WSLENV set"} ]; then
	alias mpv='mpv.com'
fi

command -v gdb >/dev/null && alias gdb='gdb -q' # I've seen the copyright statement.
command -v rust-gdb >/dev/null && alias rust-gdb='rust-gdb -q'

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

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

command -v gtk-launch >/dev/null && alias start='gtk-launch' # in case I forget the standard application...

# to replace Ctrl+[ for german keyboards. See `man stty' for more information
stty quit 
#set -o vi

# use color in manpages
if [ -x /usr/bin/tput ]; then
	function man() {
		env LESS_TERMCAP_md=$(tput bold; tput setaf 6) LESS_TERMCAP_us=$(tput setaf 219; tput smul) LESS_TERMCAP_ue=$(tput sgr0; tput rmul) GROFF_NO_SGR=1 man "$@"
	}
else
	function man() {
		env LESS_TERMCAP_md=$'\e[1;36m' LESS_TERMCAP_us=$'\e[4;38;5;219m' LESS_TERMCAP_ue=$'\e[0;24m' GROFF_NO_SGR=1 man "$@"
	}
fi
