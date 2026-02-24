#!/usr/bin/env zsh
# ============================================================================
# ULTIMATE TrueNAS ZSH Configuration
# ============================================================================

# ============================================================================
# PERFORMANCE OPTIMIZATION
# ============================================================================

# Skip global compinit for faster startup
skip_global_compinit=1

# Optimize completion loading
autoload -Uz compinit
# Simple completion check - rebuild daily or if missing
zcompdump="${ZDOTDIR:-$HOME}/.zcompdump"
if [[ ! -f $zcompdump ]] || [[ $(find "$zcompdump" -mtime +1 2> /dev/null | wc -l) -gt 0 ]]; then
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

# Less configuration for better viewing
export LESSOPEN="| /usr/bin/lesspipe %s"   # Use lesspipe for automatic file type detection
export LESSCLOSE="/usr/bin/lesspipe %s %s" # Close lesspipe after viewing
export LESS='-F -g -i -M -R -S -w -X -z-4' # Less options for better usability
export LESSHISTFILE=-                      # Disable less history file

# Grep colors
export GREP_COLOR='1;32'           # Set default grep color to bright green
export GREP_OPTIONS='--color=auto' # Enable color output for grep

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
	# Hostname, RAM, load‐average uptime, and current time in one neat line
	if uptime -p > /dev/null 2>&1; then
		up="$(uptime -p | sed 's/^up //')" # GNU coreutils
	else
		up="$(uptime | awk -F'up |, *[0-9]+ user' '{print $2}')" # BSD
	fi

	printf "📍 %s | 💾 %.1f GB RAM | ⏰ %s | 🔄 %s\n" \
		"$(hostname)" \
		"$(sysctl -n hw.physmem | awk '{printf "%.1f", $1/1024/1024/1024}')" \
		"$up" \
		"$(date +'%H:%M:%S')"

	############################################################################
	# ZFS quick status (works even inside a jail – silently skips if no pools)
	############################################################################
	get_zfs_status

	############################################################################
	# Check for pkg(8) updates (non-blocking) – only on SCALE, not CORE
	############################################################################
	if ! command -v freenas-update > /dev/null 2>&1; then
		# Run package check in background to avoid blocking shell startup
		{
			if command -v pkg > /dev/null 2>&1; then
				update_available=$(pkg version -v 2> /dev/null | grep -cF '<')
				if [[ -n $update_available && $update_available -gt 0 ]]; then
					echo "📦 ${update_available} Updates available: run 'sysupdate'"
				fi
			fi
		} &
	fi

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
🎯 ULTIMATE TRUENAS ZSH COMMAND REFERENCE:

📊 SYSTEM MONITORING:
  sysinfo         - Complete system dashboard
  perfmon         - Performance monitor
  temps           - Temperature sensors

🏊 ZFS MANAGEMENT:
  zhealth         - Complete ZFS health check
  zfsmaint        - ZFS maintenance helper
  pools           - List ZFS pools with health
  datasets        - List ZFS datasets
  snapshots       - List ZFS snapshots
  scrub           - Start pool scrub

🌐 NETWORK TOOLS:
  nettest         - Network connectivity test
  netinfo         - Complete network info
  myip            - Show external IP
  ports           - Show listening ports
  speedtest       - Internet speed test

🔧 SYSTEM ADMINISTRATION:
  servstat        - Service status overview
  jailmgr         - Jail/container manager
  seccheck        - Security check
  cleanup         - System cleanup
  sysupdate       - Update helper

📁 FILE OPERATIONS:
  ff [name]       - Find files by name
  ftext [text]    - Find files by content
  extract [file]  - Extract any archive
  backup [file]   - Quick backup
  findfile [name] - Find with preview

🎯 UTILITIES:
  calc [expr]     - Calculator
  genpass [len]   - Password generator
  serve [port]    - HTTP file server

📍 QUICK NAVIGATION:
  ~freenas        - /mnt/PoolONE/FreeNAS
  ~pools          - /mnt
  ~logs           - /var/log
  ~etc            - /etc

✨ Press TAB for auto-completion on everything!
🎨 Commands are color-coded as you type!
🔍 Use Ctrl+R for history search!"

	# End of configuration
}
