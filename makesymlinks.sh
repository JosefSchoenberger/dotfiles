#!/usr/bin/env bash

should_print_verbose=0
[ "$1" = "-v" ] && should_print_verbose=1

is_root=0
[ "$UID" = 0 ] && [ "$EUID" = 0 ] && is_root=1

fail() {
	echo $'\e[31mError:\e[39m' "$1. Exiting." >&2
	exit 1
}

warn() {
	echo $'\e[33mWarning:\e[39m' "$1" >&2
}

ensure_installed() {
	command -v "$1" >/dev/null 2>&1 || fail "Command $1 is not installed"
}

ensure_installed git
[ "$is_root" = 1 ] || ensure_installed sudo

DOTFILES_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd ) || fail "Could not determine the path of this script: $SCRIPT_DIR."

cd "$DOTFILES_DIR" || fail "Could not cd into $SCRIPT_DIR"

git submodule update --init --recursive || fail "Could not update git subdir"

cd home/josef || fail "Could not cd into $DOTFILES_DIR/home/josef"

link_home() {
	[ -L ~/"$1" ] && return
	if [ -f ~/"$1" ]; then
		warn "File ~/$1 already exists as regular file. Skipping..."
		return
	fi
	if [ -d ~/"$1" ]; then
		warn "File ~/$1 already exists as regular directory. Skipping..."
		return
	fi
	mkdir -p "$(dirname -- ~/"$1")"
	ln -s "$DOTFILES_DIR/home/josef/$1" ~/"$1" || fail "Could not create symlink to ~/$1"
}

warned_about_sudo=0
mysudo() {
	if [ "$is_root" = 1 ]; then
		"$@"
		return
	fi
	if [ "$warned_about_sudo" != 1 ]; then
		warn "Using sudo to install system-wide files."
		warned_about_sudo=1
	fi
	echo "Running: sudo $@"
	sudo "$@"
}

link_root() {
	[ -L /"$1" ] && return
	if [ -f /"$1" ]; then
		SHA_IS=$(sha256sum /"$1") || fail "Could not compute sha256sum of /${1#/}"
		SHA_SHOULD=$(sha256sum "$DOTFILES_DIR/$1") || fail "Could not compute sha256sum of $DOTFILES_DIR/${1#/}"

		if [ "$(cut -f1 -d' ' <<<"$SHA_IS")" == "$(cut -f1 -d' ' <<<"$SHA_SHOULD")" ]; then
			mysudo rm /"$1"
			if [ "$?" != 0 ]; then
				warn "Could not replace /${1#/} with symlink, even though file matches. Skipping..."
				return
			fi
		else
			warn "File /${1#/} already exists as regular file and does not match. Skipping..."
			return
		fi
	fi
	if [ -d /"$1" ]; then
		warn "File /${1#/} already exists as regular directory. Skipping..."
		return
	fi

	mysudo mkdir -p "$(dirname -- /"$1")"
	mysudo ln -s "$DOTFILES_DIR/$1" /"$1" || fail "Could not create symlink to /$1"
}

link_home .vimrc
link_home .vim/after
link_home .vim/clang-format-style.vim
link_home .vim/colors
link_home .vim/colors.vim
link_home .vim/indent
link_home .vim/pull-jdtls.bash
link_home .vim/syntax
link_home .vim/tagstack.vim
link_home .vim/UltiSnips

link_home .bashrc
link_home .gitignore
link_home .gitconfig
link_home .profile
link_home .tmux.conf
link_home .zprofile

link_home keep_new_screens_empty.sh
link_home Pictures/Wallpapers

link_home .config/waybar
link_home .config/mako
link_home .config/i3blocks
link_home .config/zsh/fzf-preview.sh
link_home .config/zsh/git-prompt.zsh
link_home .config/zsh/wsl-open-with-firefox.bash
link_home .config/zsh/zsh-autosuggestions
link_home .config/zsh/zsh-syntax-highlighting
link_home .config/wofi/config
link_home .config/wofi/style.css
link_home .config/xdg-desktop-portal/portals.conf
link_home .config/systemd/user/coinbase_expiry_warningd.sh
link_home .config/systemd/user/coinbase_expiry_warningd.service
link_home .config/systemd/user/coinbase_expiry_warningd.timer
link_home .config/swayimg/init.lua
link_home .config/mpv/mpv.conf
link_home .config/mpv/input.conf
link_home .config/kitty/kitty.conf

link_home .config/sway/brightness
link_home .config/sway/brightness_wofi
link_home .config/sway/config
link_home .config/sway/disable_all_displays.sh
link_home .config/sway/enable_all_displays.sh
link_home .config/sway/i3-input
link_home .config/sway/notification_status.sh
link_home .config/sway/output-configs
link_home .config/sway/refresh_mako
link_home .config/sway/secrets
link_home .config/sway/toggle_paprofile
link_home .config/sway/toggle_power.sh
link_home .config/sway/toggle_refreshrate
link_home .config/sway/toggle_rotate
link_home .config/sway/toggle_wifirf

link_home .config/gdb/dashboard.gdb
link_home .config/gdb/dashboard_additions.gdb
link_home .config/gdb/gdb-dashboard
link_home .config/gdb/gdbinit
link_home .config/gdb/skip_interrupt.gdb
link_home .config/gdb/stack_layout.gdb

link_root /opt/save_power.sh
link_root /opt/set_power_profile.sh
link_root /opt/unleash_the_power.sh
link_root /opt/dpkg-zfs-depend-compatible-version.bash
link_root /etc/apt/apt.conf.d/60zfs-depend-kernel
link_root /etc/zsh/zshenv
link_root /etc/systemd/user/sway-session.target

[ -d ~/".vim/bundle/Vundle.vim/" ] || git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
