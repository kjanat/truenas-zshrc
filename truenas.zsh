#!/usr/bin/env zsh
# ██╗   ██╗██╗  ████████╗██╗███╗   ███╗ █████╗ ████████╗███████╗
# ██║   ██║██║  ╚══██╔══╝██║████╗ ████║██╔══██╗╚══██╔══╝██╔════╝
# ██║   ██║██║     ██║   ██║██╔████╔██║███████║   ██║   █████╗
# ██║   ██║██║     ██║   ██║██║╚██╔╝██║██╔══██║   ██║   ██╔══╝
# ╚██████╔╝███████╗██║   ██║██║ ╚═╝ ██║██║  ██║   ██║   ███████╗
#  ╚═════╝ ╚══════╝╚═╝   ╚═╝╚═╝     ╚═╝╚═╝  ╚═╝   ╚═╝   ╚══════╝
#
# ████████╗██████╗ ██╗   ██╗███████╗███╗   ██╗ █████╗ ███████╗
# ╚══██╔══╝██╔══██╗██║   ██║██╔════╝████╗  ██║██╔══██╗██╔════╝
#    ██║   ██████╔╝██║   ██║█████╗  ██╔██╗ ██║███████║███████╗
#    ██║   ██╔══██╗██║   ██║██╔══╝  ██║╚██╗██║██╔══██║╚════██║
#    ██║   ██║  ██║╚██████╔╝███████╗██║ ╚████║██║  ██║███████║
#    ╚═╝   ╚═╝  ╚═╝ ╚═════╝ ╚══════╝╚═╝  ╚═══╝╚═╝  ╚═╝╚══════╝
#
# ULTIMATE TrueNAS ZSH Configuration

# ============================================================================
# PERFORMANCE OPTIMIZATION
# ============================================================================

# Skip global compinit for faster startup
skip_global_compinit=1

# Additional completion paths
if [[ -d /usr/local/share/zsh/site-functions ]]; then
	fpath=(/usr/local/share/zsh/site-functions $fpath)
fi

# Optimize completion loading
autoload -Uz compinit
# Simple completion check - rebuild daily or if missing
zcompdump="${ZDOTDIR:-$HOME}/.zcompdump"
if [[ ! -f $zcompdump ]] || [[ $(find "$zcompdump" -mtime +1 2>/dev/null | wc -l) -gt 0 ]]; then
	compinit
else
	compinit -C
fi

# ============================================================================
# ENVIRONMENT & SYSTEM SETUP
# ============================================================================

# Core environment
umask 022                   # Set default permissions to 755 for directories and 644 for files
export LANG=en_US.UTF-8     # Set default locale to UTF-8
export LC_ALL=en_US.UTF-8   # Set all locale categories to UTF-8
export EDITOR=nano          # Set default text editor
export PAGER=less           # Set default pager
export BROWSER=lynx         # Set default web browser
export IGNORE_OSVERSION=yes # Ignore OS version checks

# Enhanced PATH
export PATH=/sbin:/bin:/usr/sbin:/usr/bin:/usr/local/sbin:/usr/local/bin:$HOME/bin:$HOME/.local/bin:/usr/games

# Less configuration
export LESS='-F -g -i -M -R -S -w -X -z-4'
export LESSHISTFILE=-

# ============================================================================
# SOURCE CONFIGURATION FILES
# ============================================================================

source "${0:A:h}/lib/options.zsh"
source "${0:A:h}/lib/aliases.zsh"
source "${0:A:h}/lib/history.zsh"
source "${0:A:h}/lib/keybindings.zsh"
source "${0:A:h}/lib/completion.zsh"
source "${0:A:h}/lib/prompt.zsh"
source "${0:A:h}/lib/functions.zsh"
source "${0:A:h}/lib/plugins.zsh"

# ============================================================================
# STARTUP BANNER & SYSTEM CHECK
# ============================================================================

# Only run in interactive shells and only once
if [[ $- == *i* && -z $ZSH_BANNER_SHOWN ]]; then
	export ZSH_BANNER_SHOWN=1

	############################################################################
	# Quick system status
	############################################################################
	# Hostname, RAM, uptime, and current time
	up="$(uptime | awk -F'up |, *[0-9]+ user' '{print $2}')"
	printf "📍 %s | 💾 %.1f GB RAM | 🔄 %s | ⏰ %s\n" \
		"$(hostname)" \
		"$(sysctl -n hw.physmem | awk '{printf "%.1f", $1/1024/1024/1024}')" \
		"$up" \
		"$(date +'%H:%M:%S')"

	############################################################################
	# ZFS quick status (works even inside a jail – silently skips if no pools)
	############################################################################
	get_zfs_status

	############################################################################
	# Check for freenas-update (non-blocking)
	############################################################################
	{
		if command -v freenas-update >/dev/null 2>&1; then
			update_output=$(freenas-update check 2>/dev/null)
			if [[ $? -eq 0 && -n "$update_output" ]]; then
				echo "📦 System update available: run 'freenas-update'"
			fi
		fi
	} &!

	# Enable new-mail notification for the session
	export MAIL="/var/mail/$USER"
fi

# ============================================================================
# FINAL OPTIMIZATIONS
# ============================================================================

# Rehash automatically
zstyle ':completion:*' rehash true

# Speed up completions
zstyle ':completion:*' accept-exact '*(N)'
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path ~/.zsh/cache

# Reduce escape sequence timeout
export KEYTIMEOUT=1

# Optimize for SSD
export ZSH_AUTOSUGGEST_MANUAL_REBIND=1

# Final message
echo "🎉 Ultimate TrueNAS ZSH loaded! Type 'help' for command overview."

# Help function
help() {
	echo "
TRUENAS ZSH COMMAND REFERENCE:

ZFS:
  pools           - List ZFS pools with health
  datasets        - List ZFS datasets
  snapshots       - List ZFS snapshots
  scrub <pool>    - Start pool scrub
  free            - FreeBSD memory info

NETWORK:
  myip / myipv4 / myipv6  - Show external IP
  localip         - Show local IPs
  netports        - Show listening ports

FILE OPERATIONS:
  ff [name]       - Find files by name
  ftext [text]    - Find files by content
  extract [file]  - Extract any archive
  backup [file]   - Quick backup with timestamp

UTILITIES:
  calc [expr]     - Calculator
  genpass [len]   - Password generator (default 20)
  serve [port]    - HTTP file server (default 8000)

QUICK NAVIGATION:
  ~freenas        - /mnt/PoolONE/FreeNAS
  ~pools          - /mnt
  ~logs           - /var/log
  ~etc            - /etc

PLUGIN MANAGEMENT:
  list_plugins              - Show installed plugins
  load_plugin <name>        - Load a plugin
  install_plugin <git_url>  - Install from git

Press TAB for auto-completion. Ctrl+R for history search."
}
