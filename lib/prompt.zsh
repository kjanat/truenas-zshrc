# ============================================================================
# ULTRA ADVANCED PROMPT WITH STATUS INDICATORS
# ============================================================================

autoload -U colors && colors
autoload -Uz vcs_info

# Git status with detailed info
zstyle ':vcs_info:git:*' formats ' %F{yellow}⎇ %b%f%c%u'
zstyle ':vcs_info:git:*' actionformats ' %F{yellow}⎇ %b%f %F{red}(%a)%f%c%u'
zstyle ':vcs_info:git:*' stagedstr ' %F{green}●%f'
zstyle ':vcs_info:git:*' unstagedstr ' %F{red}●%f'
zstyle ':vcs_info:*' check-for-changes true
zstyle ':vcs_info:*' enable git

# System load indicator
get_load() {
	local load load_int
	load=$(uptime | awk -F 'load averages: ' '{print $2}' | awk '{print $1}' | sed 's/,//')
	load_int=${load%.*}
	if [[ $load_int -gt 2 ]]; then
		printf "\033[31m⚠ %s\033[0m\n" "$load" # Red
	elif [[ $load_int -gt 1 ]]; then
		printf "\033[33m⚡ %s\033[0m\n" "$load" # Yellow
	else
		printf "\033[32m✓ %s\033[0m\n" "$load" # Green
	fi
}

# ZFS pool health indicator
get_zfs_quick_status() {
	local zfs_status_count
	zfs_status_count=$(zpool status -x 2> /dev/null | grep -v "errors: No known data errors\|all pools are healthy" | grep -icE "(errors|degraded|offline|repaired|unrecoverable)")
	if [[ $zfs_status_count -gt 0 ]]; then
		echo "%F{red}⚠  ZFS%f"
	else
		echo "%F{green}✓ ZFS%f"
	fi
}

# Battery status (ACPI on FreeBSD)
get_battery() {
	if command -v acpiconf > /dev/null 2>&1; then
		local battery
		battery=$(acpiconf -i 0 2> /dev/null | awk '/Remaining capacity:/ {gsub(/%/, "", $3); print $3}')
		if [[ -n $battery ]]; then
			if [[ $battery -lt 20 ]]; then
				echo "%F{red}🔋 ${battery}%%%f"
			elif [[ $battery -lt 50 ]]; then
				echo "%F{yellow}🔋 ${battery}%%%f"
			else
				echo "%F{green}🔋 ${battery}%%%f"
			fi
		fi
	fi
}

# Network connectivity indicator
get_network() {
	if ping -c 1 8.8.8.8 &> /dev/null; then
		echo '%F{green}🌐%f'
	else
		echo '%F{red}⚠ NET%f'
	fi
}

# Async functions for prompt
autoload -Uz add-zsh-hook

precmd() {
	vcs_info
	# Cache system info for performance
	typeset -g _load_info="$(get_load)"
	typeset -g _zfs_info="$(get_zfs_quick_status)"
	typeset -g _net_info="$(get_network)"
	typeset -g _battery_info="$(get_battery)"
}

# Ultimate multi-line prompt
PROMPT='%F{cyan}╭─[%f%F{green}%n@%m%f%F{cyan}]─[%f%F{blue}%~%f%F{cyan}]${vcs_info_msg_0_}─[%f${_load_info}%F{cyan}]─[%f${_zfs_info}%F{cyan}]─[%f${_net_info}%F{cyan}]${_battery_info:+─[}${_battery_info}${_battery_info:+%F{cyan}%f 
%F{cyan}╰─%f%(?.%F{green}➤%f.%F{red}➤%f) '

# Right prompt with time, exit code, and job count
RPROMPT='%(1j.%F{magenta}⚙ %j%f .)%(?..%F{red}✗ %?%f )%F{cyan}⌚ %D{%H:%M:%S}%f'
