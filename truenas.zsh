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

# Optimize completion loading
autoload -Uz compinit
# Simple completion check - rebuild daily or if missing
zcompdump="${ZDOTDIR:-$HOME}/.zcompdump"
if [[ ! -f "$zcompdump" ]] || [[ $(find "$zcompdump" -mtime +1 2>/dev/null | wc -l) -gt 0 ]]; then
    compinit
else
    compinit -C
fi

# ============================================================================
# TERMINAL PASTE MODE FIXES
# ============================================================================

# Fix bracketed paste mode issues (prevents ~, 201~ etc. when pasting)
# This comprehensive fix addresses terminal paste mode issues that can cause
# unwanted characters like ~ or 201~ to appear when pasting via right-click

# 1. Disable ZSH bracketed paste variables
unset zle_bracketed_paste 2>/dev/null
unset BRACKETED_PASTE 2>/dev/null

# 2. Disable terminal bracketed paste mode entirely
printf '\e[?2004l' 2>/dev/null

# 3. Set ZSH options to handle paste properly
setopt NO_BEEP                    # Disable beep on paste errors
setopt IGNORE_EOF                 # Don't exit on Ctrl+D during paste
setopt INTERACTIVE_COMMENTS       # Allow comments in interactive shell

# 4. Configure ZSH line editor to handle paste better
if [[ -n "$ZLE_VERSION" ]]; then
    # Disable bracketed paste in ZLE
    zstyle ':bracketed-paste-magic' active-widgets '.false.'
    # Handle paste as regular input
    zstyle ':completion:*' menu select=0
fi

# 5. Additional terminal compatibility settings
stty -ixon 2>/dev/null           # Disable XON/XOFF flow control
# DO NOT DISABLE CTRL+Z (susp) or CTRL+C (intr) for proper keyboard functionality

# 6. Function to force disable bracketed paste
disable_bracketed_paste() {
    printf '\e[?2004l' 2>/dev/null
    # Restore default terminal control behavior
    stty intr '^C' 2>/dev/null   # Restore Ctrl+C functionality
    stty susp '^Z' 2>/dev/null   # Restore Ctrl+Z functionality
    stty eof '^D' 2>/dev/null    # Restore Ctrl+D functionality
}

# 7. Ensure paste mode stays disabled but preserve keyboard functionality
trap disable_bracketed_paste EXIT
# Don't trap INT (Ctrl+C) or it will break keyboard functionality
trap disable_bracketed_paste TERM

# 8. Re-disable on prompt display (for persistent terminals)
precmd_disable_paste() {
    printf '\e[?2004l' 2>/dev/null
    # Make sure terminal keyboard controls are properly restored
    stty intr '^C' 2>/dev/null   # Ensure Ctrl+C works
}
autoload -Uz add-zsh-hook
add-zsh-hook precmd precmd_disable_paste

# ============================================================================

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
export LESSOPEN="| /usr/bin/lesspipe %s"    # Use lesspipe for automatic file type detection
export LESSCLOSE="/usr/bin/lesspipe %s %s"  # Close lesspipe after viewing
export LESS='-F -g -i -M -R -S -w -X -z-4'  # Less options for better usability
export LESSHISTFILE=-                       # Disable less history file

# Grep colors
export GREP_COLOR='1;32'            # Set default grep color to bright green
export GREP_OPTIONS='--color=auto'  # Enable color output for grep

# Terminal initialization function - Ensures keyboard shortcuts work properly
init_terminal() {
    # Reset terminal control settings
    stty sane 2>/dev/null

    # Ensure critical keyboard shortcuts work
    stty intr '^C' 2>/dev/null      # Ctrl+C for interrupt
    stty susp '^Z' 2>/dev/null      # Ctrl+Z for suspend
    stty eof '^D' 2>/dev/null       # Ctrl+D for EOF
    stty start '^Q' 2>/dev/null     # Ctrl+Q for XON
    stty stop '^S' 2>/dev/null      # Ctrl+S for XOFF

    # Disable bracketed paste mode
    printf '\e[?2004l' 2>/dev/null

    # Ensure proper text display
    printf '\e[0m' 2>/dev/null      # Reset text attributes

    # Set UTF-8 support (if terminal supports it)
    printf '\e%%G' 2>/dev/null
}

# Run terminal initialization
init_terminal

# ============================================================================
# ALIASES - THE ULTIMATE COLLECTION
# ============================================================================

# Your original aliases
alias h='history 25'
alias j='jobs -l'
alias c='clear'
alias la='ls -aF'
alias lf='ls -FA'
alias ll='ls -lAF'
alias freenas_dir='cd /mnt/PoolONE/FreeNAS'

# Enhanced ls aliases with colors (FreeBSD compatible)
alias l='ls -CF'
alias lr='ls -R'                         # recursive
alias lt='ls -ltrh'                      # sort by date
alias lk='ls -lSrh'                      # sort by size
alias lx='ls -lXBh'                      # sort by extension (if supported)
alias lc='ls -ltcrh'                     # sort by change time
alias lu='ls -lturh'                     # sort by access time
alias lm='ls -al | more'                 # pipe through more
alias tree='tree -C 2>/dev/null || find . -type d | sed -e "s/[^-][^\/]*\//  |/g" -e "s/|\([^ ]\)/|-\1/"'

# Navigation power aliases
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'
alias ......='cd ../../../../..'
alias -- -='cd -'
alias ~='cd ~'
alias back='cd $OLDPWD'

# File operations with confirmations (FreeBSD compatible)
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'
alias ln='ln -i'
alias chown='chown'
alias chmod='chmod'
alias chgrp='chgrp'

# System monitoring aliases
alias df='df -h'
alias du='du -h'
alias free='freebsd_meminfo'
alias ps='ps -aux'
alias psg='ps -aux | grep -v grep | grep -i -e VSZ -e'
# alias top='htop 2>/dev/null || top'
alias iotop='iotop 2>/dev/null || iostat'
alias nethogs='nethogs 2>/dev/null || echo "nethogs not installed"'

# Network aliases
alias myip="curl -s ifconfig.me"
alias myipv4="curl -s ipv4.icanhazip.com"
alias myipv6="curl -s ipv6.icanhazip.com"
alias localip="ifconfig | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1'"
alias speedtest='curl -s https://raw.githubusercontent.com/sivel/speedtest-cli/master/speedtest.py | python'
alias netports="sockstat -46lsc | sed -n '1p'; sockstat -46Llsc | sed '1d' | sort -uk6 -k2 -k5 -k7 | column -t"
# shellcheck disable=SC2142
alias listening='sockstat -46lsc | awk "NR==1{print; next} /[tu][cd]p/ && \$8>0 {print \$1, \$2, \$3, \$4, \$5, \$6, \$7, \$8}" | sort -k8 -k6 -k1 -k5 | column -t | grep "LISTEN\|FOREIGN"'
alias tcpdump='tcpdump -nn'

# TrueNAS power aliases
alias pools='zpool list -o name,size,allocated,free,capacity,health'
alias datasets='zfs list -o name,used,avail,refer,mountpoint'
alias snapshots='zfs list -t snapshot -o name,used,refer,creation'
alias scrub='zpool scrub'
alias scrubstatus='zpool status | grep scrub' # -x or not?
alias iostat='zpool iostat 1'
alias services='service -e'
alias servicestatus='service -l'
alias jails='jls -v'
alias plugins='iocage list'
alias logs='tail -f /var/log/messages'
alias syslog='less /var/log/messages'
alias dmesg='dmesg --color=always | less -R'
alias mountinfo='mount | column -t'

# Quick editing
alias zshrc='$EDITOR ~/.zshrc && source ~/.zshrc'
alias vimrc='$EDITOR ~/.vimrc'
alias nanorc='$EDITOR ~/.nanorc'
alias hosts='$EDITOR /etc/hosts'
alias fstab='$EDITOR /etc/fstab'

# Archive operations
alias tarxz='tar -Jxf'
alias targz='tar -zxf'
alias tarbz='tar -jxf'
alias mktar='tar -cvf'
alias mktargz='tar -czvf'
alias mktarbz='tar -cjvf'
alias mktarxz='tar -cJvf'

# Search aliases
alias grep='grep --color=auto'
alias egrep='egrep --color=auto'
alias fgrep='fgrep --color=auto'
alias histg='history | grep'
alias psg='ps -aux | grep'

# Quick shortcuts
alias q='exit'
alias x='exit'
alias :q='exit'
alias bashrc='$EDITOR ~/.bashrc'
alias path='echo -e ${PATH//:/\\n}'
alias now='date +"%T"'
alias nowtime=now
alias nowdate='date +"%d-%m-%Y"'

# Safety aliases for destructive commands (FreeBSD compatible)
alias rm='rm -i'
alias del='rm -i'
alias mv='mv -i'
alias cp='cp -i'
alias ln='ln -i'

# Funny aliases for typos
alias sl='ls'
alias cd..='cd ..'
alias l='ls'
alias ll='ls -la'
alias lsl='ls -la'
alias claer='clear'
alias cealr='clear'
alias clera='clear'
alias celar='clear'

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
        echo "%F{red}⚠ ${load}%f"
    elif [[ $load_int -gt 1 ]]; then
        echo "%F{yellow}⚡ ${load}%f"
    else
        echo "%F{green}✓ ${load}%f"
    fi
}

# ZFS pool health indicator
get_zfs_quick_status() {
    local zfs_status_count
    zfs_status_count=$(zpool status -x 2>/dev/null | grep -v "errors: No known data errors\|all pools are healthy" | grep -icE "(errors|degraded|offline|repaired|unrecoverable)")
    if [[ $zfs_status_count -gt 0 ]]; then
        echo "%F{red}⚠  ZFS%f"
    else
        echo "%F{green}✓ ZFS%f"
    fi
}

# Battery status (if applicable)
get_battery() {
    # Check for Linux battery info
    if [[ -f /sys/class/power_supply/BAT0/capacity ]]; then
        local battery
        battery=$(cat /sys/class/power_supply/BAT0/capacity)
        if [[ $battery -lt 20 ]]; then
            echo "%F{red}🔋 ${battery}%%%f"
        elif [[ $battery -lt 50 ]]; then
            echo "%F{yellow}🔋 ${battery}%%%f"
        else
            echo "%F{green}🔋 ${battery}%%%f"
        fi
    # Check for FreeBSD battery info (ACPI)
    elif command -v acpiconf >/dev/null 2>&1; then
        local battery
        battery=$(acpiconf -i 0 2>/dev/null | awk '/Remaining capacity:/ {gsub(/%/, "", $3); print $3}')
        if [[ -n "$battery" ]]; then
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
    if ping -c 1 8.8.8.8 &>/dev/null; then
        echo "%F{green}🌐%f"
    else
        echo "%F{red}⚠ NET%f"
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

# ============================================================================
# HISTORY CONFIGURATION - MAXIMUM POWER
# ============================================================================

HISTSIZE=100000
SAVEHIST=100000
HISTFILE=~/.zsh_history

# All the history options
setopt EXTENDED_HISTORY          # Write timestamps to history
setopt HIST_EXPIRE_DUPS_FIRST    # Expire duplicates first
setopt HIST_FIND_NO_DUPS         # Don't display duplicates during search
setopt HIST_IGNORE_DUPS          # Don't record duplicates
setopt HIST_IGNORE_ALL_DUPS      # Delete old duplicates
setopt HIST_IGNORE_SPACE         # Don't record commands starting with space
setopt HIST_SAVE_NO_DUPS         # Don't save duplicates
setopt HIST_VERIFY               # Show expanded history before executing
setopt SHARE_HISTORY             # Share history between sessions
setopt APPEND_HISTORY            # Append to history
setopt INC_APPEND_HISTORY        # Write immediately
setopt HIST_REDUCE_BLANKS        # Remove extra blanks
setopt HIST_NO_STORE             # Don't store history commands

# ============================================================================
# KEY BINDINGS - ULTIMATE POWER USER SETUP
# ============================================================================

# Emacs-style bindings
bindkey -e

# Standard bindings
bindkey '^W' backward-kill-word
bindkey '^[[A' history-search-backward
bindkey '^[[B' history-search-forward
bindkey '^[[1;5C' forward-word
bindkey '^[[1;5D' backward-word
bindkey '^[[3~' delete-char
bindkey '^[[H' beginning-of-line
bindkey '^[[F' end-of-line
bindkey '^R' history-incremental-search-backward
bindkey '^S' history-incremental-search-forward

# Advanced bindings
bindkey '^P' up-history
bindkey '^N' down-history
bindkey '^?' backward-delete-char
bindkey '^h' backward-delete-char
bindkey '^w' backward-kill-word
bindkey '^u' kill-whole-line
bindkey '^k' kill-line
bindkey '^a' beginning-of-line
bindkey '^e' end-of-line
bindkey '^f' forward-char
bindkey '^b' backward-char
bindkey '^d' delete-char

# Alt bindings
bindkey '^[f' forward-word
bindkey '^[b' backward-word
bindkey '^[d' kill-word
bindkey '^[^?' backward-kill-word

# Function key bindings
bindkey '^[[1~' beginning-of-line
bindkey '^[[4~' end-of-line
bindkey '^[[5~' up-line-or-history
bindkey '^[[6~' down-line-or-history

# ============================================================================
# COMPLETION SYSTEM - ULTRA ADVANCED
# ============================================================================

# Load completion system
autoload -Uz compinit
compinit

# Completion caching
zstyle ':completion::complete:*' use-cache on
zstyle ':completion::complete:*' cache-path ~/.zsh/cache

# Enhanced completion settings
zstyle ':completion:*' auto-description 'specify: %d'
zstyle ':completion:*' completer _expand _complete _correct _approximate
zstyle ':completion:*' format 'Completing %d'
zstyle ':completion:*' group-name ''
zstyle ':completion:*' menu select=2
# zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' list-colors ''
zstyle ':completion:*' list-prompt %SAt %p: Hit TAB for more, or the character to insert%s
zstyle ':completion:*' matcher-list '' 'm:{a-z}={A-Z}' 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=* l:|=*'
zstyle ':completion:*' menu select=long
zstyle ':completion:*' select-prompt %SScrolling active: current selection at %p%s
zstyle ':completion:*' use-compctl false
zstyle ':completion:*' verbose true

# Case-insensitive completion
zstyle ':completion:*' matcher-list 'm:{a-zA-Z-_}={A-Za-z_-}' 'r:|=*' 'l:|=* r:|=*'

# Fuzzy completion
zstyle ':completion:*' completer _complete _match _approximate
zstyle ':completion:*:match:*' original only
zstyle ':completion:*:approximate:*' max-errors 1 numeric

# Group matches and describe
zstyle ':completion:*:*:*:*:*' menu select
zstyle ':completion:*:matches' group 'yes'
zstyle ':completion:*:options' description 'yes'
zstyle ':completion:*:options' auto-description '%d'
zstyle ':completion:*:corrections' format ' %F{green}-- %d (errors: %e) --%f'
zstyle ':completion:*:descriptions' format ' %F{yellow}-- %d --%f'
zstyle ':completion:*:messages' format ' %F{purple} -- %d --%f'
zstyle ':completion:*:warnings' format ' %F{red}-- no matches found --%f'
zstyle ':completion:*:default' list-prompt '%S%M matches%s'

# Advanced command completion
zstyle ':completion:*:sudo:*' command-path /usr/local/sbin /usr/local/bin /usr/sbin /usr/bin /sbin /bin
zstyle ':completion:*:(rm|kill|diff):*' ignore-line other
zstyle ':completion:*:rm:*' file-patterns '*:all-files'

# Process completion
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#) ([0-9a-z-]#)*=01;34=0=01'
zstyle ':completion:*:*:*:*:processes' command "ps -u $USER -o pid,user,comm -w -w"
zstyle ':completion:*:*:killall:*' menu yes select
zstyle ':completion:*:killall:*' force-list always

# SSH/SCP hostname completion - Shellcheck-clean version
# This version works in ZSH and passes shellcheck

# Function to set up SSH completion (keeps 'local' usage valid)
_setup_ssh_completion() {
    # Initialize hosts array
    typeset -a h
    h=()

    # Parse SSH config file
    if [[ -r ~/.ssh/config ]]; then
        # Read SSH config and extract Host entries
        while IFS= read -r line; do
            # Match lines starting with "Host " (case insensitive)
            if [[ "$line" =~ ^[[:space:]]*[Hh]ost[[:space:]]+(.+)$ ]]; then
                local host_entry="${match[1]}"
                # Skip wildcard entries (* and ?)
                if [[ "$host_entry" != *"*"* ]] && [[ "$host_entry" != *"?"* ]]; then
                    # Split multiple hosts on the same line
                    local -a hosts_on_line
                    # ZSH word splitting - disable shellcheck for ZSH-specific syntax
                    # shellcheck disable=SC2206
                    hosts_on_line=(${=host_entry})
                    local host
                    for host in "${hosts_on_line[@]}"; do
                        # Skip empty entries and wildcards
                        if [[ -n "$host" ]] && [[ "$host" != *"*"* ]] && [[ "$host" != *"?"* ]]; then
                            h+=("$host")
                        fi
                    done
                fi
            fi
        done < ~/.ssh/config
    fi

    # Parse known_hosts files
    if [[ -r ~/.ssh/known_hosts ]]; then
        # Process known_hosts file
        while IFS= read -r line; do
            # Skip empty lines and comments
            [[ -z "$line" || "$line" == "#"* ]] && continue

            # Extract hostname (first field, before space)
            local host_field="${line%% *}"

            # Handle comma-separated hosts and ports
            if [[ "$host_field" == *","* ]]; then
                # Split on comma and take first entry
                host_field="${host_field%%,*}"
            fi

            # Remove port numbers [host]:port format
            if [[ "$host_field" == "["*"]:"* ]]; then
                host_field="${host_field#[}"
                host_field="${host_field%]:*}"
            fi

            # Remove standard port suffix :22
            host_field="${host_field%:22}"

            # Skip if contains wildcards or special characters
            if [[ "$host_field" != *"*"* ]] && [[ "$host_field" != *"?"* ]] && [[ -n "$host_field" ]]; then
                h+=("$host_field")
            fi
        done < ~/.ssh/known_hosts
    fi

    # Also check known_hosts2 if it exists
    if [[ -r ~/.ssh/known_hosts2 ]]; then
        while IFS= read -r line; do
            [[ -z "$line" || "$line" == "#"* ]] && continue
            local host_field="${line%% *}"
            if [[ "$host_field" == *","* ]]; then
                host_field="${host_field%%,*}"
            fi
            if [[ "$host_field" == "["*"]:"* ]]; then
                host_field="${host_field#[}"
                host_field="${host_field%]:*}"
            fi
            host_field="${host_field%:22}"
            if [[ "$host_field" != *"*"* ]] && [[ "$host_field" != *"?"* ]] && [[ -n "$host_field" ]]; then
                h+=("$host_field")
            fi
        done < ~/.ssh/known_hosts2
    fi

    # Remove duplicates and sort (ZSH-specific but we'll disable shellcheck)
    if [[ ${#h[@]} -gt 0 ]]; then
        # Remove duplicates using associative array
        typeset -A seen
        typeset -a unique_hosts
        local host
        for host in "${h[@]}"; do
            if [[ -z "${seen[$host]}" ]]; then
                seen[$host]=1
                unique_hosts+=("$host")
            fi
        done

        # Sort the hosts (ZSH-specific parameter expansion)
        # shellcheck disable=SC2296
        h=("${(@o)unique_hosts}")

        # Set up completion styles
        zstyle ':completion:*:ssh:*' hosts "${h[@]}"
        zstyle ':completion:*:slogin:*' hosts "${h[@]}"
        zstyle ':completion:*:scp:*' hosts "${h[@]}"
        zstyle ':completion:*:rsync:*' hosts "${h[@]}"
        zstyle ':completion:*:sftp:*' hosts "${h[@]}"

        # Optional: Set up additional SSH-related completions
        zstyle ':completion:*:(ssh|scp|rsync|slogin|sftp):*' tag-order 'hosts:-host:host hosts:-domain:domain hosts:-ipaddr:ip\ address *'
        zstyle ':completion:*:(ssh|scp|rsync|slogin|sftp):*:hosts-host' ignored-patterns '*(.|:)*' loopback ip6-loopback localhost ip6-localhost broadcasthost
        zstyle ':completion:*:(ssh|scp|rsync|slogin|sftp):*:hosts-domain' ignored-patterns '<->.<->.<->.<->' '^[-[:alnum:]]##(.[-[:alnum:]]##)##' '*@*'
        zstyle ':completion:*:(ssh|scp|rsync|slogin|sftp):*:hosts-ipaddr' ignored-patterns '^(<->.<->.<->.<->|(|::)([[:xdigit:].]##:(#c,2))##(|%*))' '127.0.0.<->' '255.255.255.255' '::1' 'fe80::*'

        echo "✅ SSH completion loaded ${#h[@]} hosts"
    fi
}

# Alternative shellcheck-friendly version without ZSH-specific features
_setup_ssh_completion_portable() {
    # This version avoids ZSH-specific syntax entirely
    local -a h
    h=()

    # Parse SSH config file
    if [[ -r ~/.ssh/config ]]; then
        while IFS= read -r line; do
            if [[ "$line" =~ ^[[:space:]]*[Hh]ost[[:space:]]+(.+)$ ]]; then
                local host_entry="${match[1]}"
                if [[ "$host_entry" != *"*"* ]] && [[ "$host_entry" != *"?"* ]]; then
                    # Use standard word splitting instead of ZSH-specific
                    local word
                    for word in $host_entry; do
                        if [[ -n "$word" ]] && [[ "$word" != *"*"* ]] && [[ "$word" != *"?"* ]]; then
                            h+=("$word")
                        fi
                    done
                fi
            fi
        done < ~/.ssh/config
    fi

    # Parse known_hosts files (same logic as before)
    local known_hosts_file
    for known_hosts_file in ~/.ssh/known_hosts ~/.ssh/known_hosts2; do
        if [[ -r "$known_hosts_file" ]]; then
            while IFS= read -r line; do
                [[ -z "$line" || "$line" == "#"* ]] && continue
                local host_field="${line%% *}"
                host_field="${host_field%%,*}"
                if [[ "$host_field" == "["*"]:"* ]]; then
                    host_field="${host_field#[}"
                    host_field="${host_field%]:*}"
                fi
                host_field="${host_field%:22}"
                if [[ "$host_field" != *"*"* ]] && [[ "$host_field" != *"?"* ]] && [[ -n "$host_field" ]]; then
                    h+=("$host_field")
                fi
            done < "$known_hosts_file"
        fi
    done

    # Simple deduplication without ZSH-specific features
    if [[ ${#h[@]} -gt 0 ]]; then
        # Convert array to newline-separated, sort and deduplicate
        local sorted_hosts
        # shellcheck disable=SC2207
        sorted_hosts=($(printf '%s\n' "${h[@]}" | sort -u))

        # Set up completion
        zstyle ':completion:*:ssh:*' hosts "${sorted_hosts[@]}"
        zstyle ':completion:*:slogin:*' hosts "${sorted_hosts[@]}"
        zstyle ':completion:*:scp:*' hosts "${sorted_hosts[@]}"
        zstyle ':completion:*:rsync:*' hosts "${sorted_hosts[@]}"
        zstyle ':completion:*:sftp:*' hosts "${sorted_hosts[@]}"

        echo "✅ SSH completion loaded ${#sorted_hosts[@]} hosts (portable mode)"
    fi
}

# Debug function to show loaded hosts
ssh_completion_debug() {
    local hosts
    # Get hosts from zstyle
    zstyle -a ':completion:*:ssh:*' hosts hosts
    if [[ ${#hosts[@]} -gt 0 ]]; then
        echo "SSH completion has ${#hosts[@]} hosts:"
        printf '%s\n' "${hosts[@]}" | sort | column -c 80 2>/dev/null || printf '%s\n' "${hosts[@]}" | sort
    else
        echo "No SSH hosts configured for completion"
    fi
}

# Function to reload SSH completion
ssh_completion_reload() {
    echo "Reloading SSH completion..."
    if command -v _setup_ssh_completion >/dev/null 2>&1; then
        _setup_ssh_completion
    else
        _setup_ssh_completion_portable
    fi
}

# Actually set up the completion
# Use the ZSH-optimized version if in ZSH, otherwise use portable version
if [[ -n "$ZSH_VERSION" ]]; then
    _setup_ssh_completion
else
    _setup_ssh_completion_portable
fi

# ============================================================================
# ZSH OPTIONS - ALL THE POWER
# ============================================================================

# Directory navigation
setopt AUTO_CD              # cd by typing directory name
setopt AUTO_PUSHD           # Push old directory onto stack
setopt PUSHD_IGNORE_DUPS    # Don't push duplicates
setopt PUSHD_MINUS          # Exchange + and - for pushd
setopt CD_ABLE_VARS         # Try expanding as variable
setopt PUSHD_SILENT         # Don't print stack after pushd/popd

# Globbing and expansion
setopt EXTENDED_GLOB        # Extended globbing
setopt NO_CASE_GLOB         # Case insensitive globbing
setopt NUMERIC_GLOB_SORT    # Sort numerically
setopt GLOB_DOTS            # Include dotfiles
setopt MARK_DIRS            # Mark directories with /
setopt GLOB_COMPLETE        # Complete globs
setopt BAD_PATTERN          # Error on bad pattern

# Completion
setopt AUTO_LIST            # List choices on ambiguous completion
setopt AUTO_MENU            # Show menu on successive tab
setopt AUTO_PARAM_SLASH     # Add slash after directory completion
setopt COMPLETE_IN_WORD     # Complete from both ends
setopt ALWAYS_TO_END        # Move cursor to end
setopt PATH_DIRS            # Perform path search on commands with slashes
setopt AUTO_REMOVE_SLASH    # Remove trailing slash

# Job control
setopt LONG_LIST_JOBS       # List jobs in long format
setopt AUTO_RESUME          # Resume jobs with their name
setopt NOTIFY               # Report status immediately
setopt CHECK_JOBS           # Check jobs on exit
setopt HUP                  # Send HUP to jobs on shell exit
setopt BG_NICE              # Background jobs at lower priority

# Input/Output
setopt CORRECT              # Try to correct spelling
setopt CORRECT_ALL          # Try to correct all arguments
setopt DVORAK               # Use Dvorak keyboard
setopt FLOW_CONTROL         # Enable flow control
setopt IGNORE_EOF           # Don't exit on EOF
setopt INTERACTIVE_COMMENTS # Allow comments in interactive mode
setopt HASH_CMDS            # Hash commands for faster lookup
setopt HASH_DIRS            # Hash directories

# Prompting
setopt PROMPT_SUBST         # Parameter expansion in prompts
setopt TRANSIENT_RPROMPT    # Remove right prompt from previous lines

# Scripts and functions
setopt MULTIOS              # Multiple redirections
setopt SHORT_LOOPS          # Allow short loop syntax

# Don't beep!
unsetopt BEEP
unsetopt HIST_BEEP
unsetopt LIST_BEEP

# ============================================================================
# FREEBSD COMPATIBILITY FUNCTIONS
# ============================================================================

# FreeBSD-compatible memory info function
freebsd_meminfo() {
    local total_bytes page_size free_pages inactive_pages cache_pages

    total_bytes=$(sysctl -n hw.physmem)
    page_size=$(sysctl -n vm.stats.vm.v_page_size)
    free_pages=$(sysctl -n vm.stats.vm.v_free_count)
    inactive_pages=$(sysctl -n vm.stats.vm.v_inactive_count)
    cache_pages=$(sysctl -n vm.stats.vm.v_cache_count 2>/dev/null || echo 0)

    # Use awk for calculations to avoid dependency on bc
    local total_gb free_bytes free_gb inactive_bytes inactive_gb cache_bytes cache_gb available_gb used_gb

    total_gb=$(echo "$total_bytes" | awk '{printf "%.1f", $1/1024/1024/1024}')
    free_bytes=$(echo "$free_pages $page_size" | awk '{print $1*$2}')
    free_gb=$(echo "$free_bytes" | awk '{printf "%.1f", $1/1024/1024/1024}')
    inactive_bytes=$(echo "$inactive_pages $page_size" | awk '{print $1*$2}')
    inactive_gb=$(echo "$inactive_bytes" | awk '{printf "%.1f", $1/1024/1024/1024}')
    cache_bytes=$(echo "$cache_pages $page_size" | awk '{print $1*$2}')
    cache_gb=$(echo "$cache_bytes" | awk '{printf "%.1f", $1/1024/1024/1024}')
    available_gb=$(echo "$free_gb $inactive_gb $cache_gb" | awk '{printf "%.1f", $1+$2+$3}')
    used_gb=$(echo "$total_gb $available_gb" | awk '{printf "%.1f", $1-$2}')

    printf "%-15s %8s %8s %8s %8s\n" "" "total" "used" "free" "available"
    printf "%-15s %7.1fG %7.1fG %7.1fG %7.1fG\n" "Mem:" "$total_gb" "$used_gb" "$free_gb" "$available_gb"
}

# ============================================================================
# MEGA FUNCTION LIBRARY
# ============================================================================

# Create directory and cd into it
mkcd() {
    mkdir -p "$1" && cd "$1" || return
}

# Universal archive extractor
extract() {
    if [ -f $1 ] ; then
        case $1 in
            *.tar.bz2)   tar xjf $1     ;;
            *.tar.gz)    tar xzf $1     ;;
            *.tar.xz)    tar xJf $1     ;;
            *.bz2)       bunzip2 $1     ;;
            *.rar)       unrar x $1     ;;
            *.gz)        gunzip $1      ;;
            *.tar)       tar xf $1      ;;
            *.tbz2)      tar xjf $1     ;;
            *.tgz)       tar xzf $1     ;;
            *.zip)       unzip $1       ;;
            *.Z)         uncompress $1  ;;
            *.7z)        7z x $1        ;;
            *.deb)       ar x $1        ;;
            *.tar.zst)   tar xf $1      ;;
            *)           echo "'$1' cannot be extracted via extract()" ;;
        esac
    else
        echo "'$1' is not a valid file"
    fi
}

# Create archive - Fixed with proper quoting and error handling
mkarchive() {
    # Check if at least archive name and one file/directory is provided
    if [[ $# -lt 2 ]]; then
        echo "Usage: mkarchive <archive_name> <file1> [file2] [...]"
        echo "Supported formats: .tar.gz, .tar.bz2, .tar.xz, .zip, .7z"
        echo "Examples:"
        echo "  mkarchive backup.tar.gz ~/Documents ~/Pictures"
        echo "  mkarchive project.zip src/ docs/ README.md"
        return 1
    fi

    local archive_name="$1"
    shift  # Remove archive name from arguments, leaving only files/directories

    # Check if any source files/directories exist
    local source_exists=false
    for source in "$@"; do
        if [[ -e "$source" ]]; then
            source_exists=true
            break
        fi
    done

    if [[ "$source_exists" == false ]]; then
        echo "Error: None of the specified files or directories exist"
        return 1
    fi

    # Check if archive already exists
    if [[ -e "$archive_name" ]]; then
        echo "Warning: Archive '$archive_name' already exists"
        read -p "Overwrite? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            echo "Archive creation cancelled"
            return 1
        fi
    fi

    echo "Creating archive: $archive_name"
    echo "Including: $*"

    case "$archive_name" in
        *.tar.gz|*.tgz)
            if command -v tar >/dev/null 2>&1; then
                tar -czf "$archive_name" "$@"
            else
                echo "Error: tar command not found"
                return 1
            fi
            ;;
        *.tar.bz2|*.tbz2)
            if command -v tar >/dev/null 2>&1; then
                tar -cjf "$archive_name" "$@"
            else
                echo "Error: tar command not found"
                return 1
            fi
            ;;
        *.tar.xz|*.txz)
            if command -v tar >/dev/null 2>&1; then
                tar -cJf "$archive_name" "$@"
            else
                echo "Error: tar command not found"
                return 1
            fi
            ;;
        *.tar)
            if command -v tar >/dev/null 2>&1; then
                tar -cf "$archive_name" "$@"
            else
                echo "Error: tar command not found"
                return 1
            fi
            ;;
        *.zip)
            if command -v zip >/dev/null 2>&1; then
                zip -r "$archive_name" "$@"
            else
                echo "Error: zip command not found"
                echo "Install with: pkg install zip (FreeBSD) or apt install zip (Debian/Ubuntu)"
                return 1
            fi
            ;;
        *.7z)
            if command -v 7z >/dev/null 2>&1; then
                7z a "$archive_name" "$@"
            elif command -v 7za >/dev/null 2>&1; then
                7za a "$archive_name" "$@"
            else
                echo "Error: 7z/7za command not found"
                echo "Install with: pkg install p7zip (FreeBSD) or apt install p7zip-full (Debian/Ubuntu)"
                return 1
            fi
            ;;
        *.rar)
            if command -v rar >/dev/null 2>&1; then
                rar a "$archive_name" "$@"
            else
                echo "Error: rar command not found"
                echo "Note: RAR is proprietary software, consider using .7z or .zip instead"
                return 1
            fi
            ;;
        *.tar.zst|*.tzst)
            if command -v tar >/dev/null 2>&1 && tar --help 2>&1 | grep -q zstd; then
                tar --zstd -cf "$archive_name" "$@"
            else
                echo "Error: tar with zstd support not found"
                return 1
            fi
            ;;
        *.tar.lz4)
            if command -v tar >/dev/null 2>&1 && command -v lz4 >/dev/null 2>&1; then
                tar -cf - "$@" | lz4 > "$archive_name"
            else
                echo "Error: tar or lz4 command not found"
                return 1
            fi
            ;;
        *)
            echo "Error: Unsupported archive format: $archive_name"
            echo "Supported formats:"
            echo "  • .tar.gz, .tgz     - Gzip compressed tar"
            echo "  • .tar.bz2, .tbz2   - Bzip2 compressed tar"
            echo "  • .tar.xz, .txz     - XZ compressed tar"
            echo "  • .tar.zst, .tzst   - Zstandard compressed tar"
            echo "  • .tar.lz4          - LZ4 compressed tar"
            echo "  • .tar              - Uncompressed tar"
            echo "  • .zip              - ZIP archive"
            echo "  • .7z               - 7-Zip archive"
            echo "  • .rar              - RAR archive (if available)"
            return 1
            ;;
    esac

    local exit_code=$?
    if [[ $exit_code -eq 0 ]]; then
        echo "✅ Archive created successfully: $archive_name"

        # Show archive info if possible
        if [[ -f "$archive_name" ]]; then
            local size
            if command -v du >/dev/null 2>&1; then
                size=$(du -h "$archive_name" | cut -f1)
                echo "📦 Archive size: $size"
            fi

            # Show file count for supported formats
            case "$archive_name" in
                *.tar*|*.tgz|*.tbz2|*.txz|*.tzst)
                    if command -v tar >/dev/null 2>&1; then
                        local file_count
                        file_count=$(tar -tf "$archive_name" 2>/dev/null | wc -l)
                        echo "📁 Files archived: $file_count"
                    fi
                    ;;
                *.zip)
                    if command -v unzip >/dev/null 2>&1; then
                        local file_count
                        file_count=$(unzip -l "$archive_name" 2>/dev/null | tail -1 | awk '{print $2}')
                        echo "📁 Files archived: $file_count"
                    fi
                    ;;
                *.7z)
                    if command -v 7z >/dev/null 2>&1; then
                        echo "📁 Archive contents:"
                        7z l "$archive_name" | tail -3 | head -1
                    fi
                    ;;
            esac
        fi
    else
        echo "❌ Archive creation failed with exit code: $exit_code"
        return $exit_code
    fi
}

# Companion function to list archive contents
lsarchive() {
    if [[ $# -ne 1 ]]; then
        echo "Usage: lsarchive <archive_name>"
        return 1
    fi

    local archive_name="$1"

    if [[ ! -f "$archive_name" ]]; then
        echo "Error: Archive '$archive_name' not found"
        return 1
    fi

    echo "📦 Contents of: $archive_name"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

    case "$archive_name" in
        *.tar.gz|*.tgz|*.tar.bz2|*.tbz2|*.tar.xz|*.txz|*.tar.zst|*.tzst|*.tar)
            if command -v tar >/dev/null 2>&1; then
                tar -tvf "$archive_name"
            else
                echo "Error: tar command not found"
                return 1
            fi
            ;;
        *.zip)
            if command -v unzip >/dev/null 2>&1; then
                unzip -l "$archive_name"
            else
                echo "Error: unzip command not found"
                return 1
            fi
            ;;
        *.7z)
            if command -v 7z >/dev/null 2>&1; then
                7z l "$archive_name"
            elif command -v 7za >/dev/null 2>&1; then
                7za l "$archive_name"
            else
                echo "Error: 7z/7za command not found"
                return 1
            fi
            ;;
        *.rar)
            if command -v unrar >/dev/null 2>&1; then
                unrar l "$archive_name"
            else
                echo "Error: unrar command not found"
                return 1
            fi
            ;;
        *)
            echo "Error: Unsupported archive format for listing"
            return 1
            ;;
    esac
}

# Function to test archive integrity
testarchive() {
    if [[ $# -ne 1 ]]; then
        echo "Usage: testarchive <archive_name>"
        return 1
    fi

    local archive_name="$1"

    if [[ ! -f "$archive_name" ]]; then
        echo "Error: Archive '$archive_name' not found"
        return 1
    fi

    echo "🔍 Testing archive integrity: $archive_name"

    case "$archive_name" in
        *.tar.gz|*.tgz|*.tar.bz2|*.tbz2|*.tar.xz|*.txz|*.tar.zst|*.tzst|*.tar)
            if command -v tar >/dev/null 2>&1; then
                if tar -tf "$archive_name" >/dev/null 2>&1; then
                    echo "✅ Archive is valid"
                else
                    echo "❌ Archive is corrupted or invalid"
                    return 1
                fi
            else
                echo "Error: tar command not found"
                return 1
            fi
            ;;
        *.zip)
            if command -v unzip >/dev/null 2>&1; then
                if unzip -t "$archive_name" >/dev/null 2>&1; then
                    echo "✅ Archive is valid"
                else
                    echo "❌ Archive is corrupted or invalid"
                    return 1
                fi
            else
                echo "Error: unzip command not found"
                return 1
            fi
            ;;
        *.7z)
            if command -v 7z >/dev/null 2>&1; then
                if 7z t "$archive_name" >/dev/null 2>&1; then
                    echo "✅ Archive is valid"
                else
                    echo "❌ Archive is corrupted or invalid"
                    return 1
                fi
            else
                echo "Error: 7z command not found"
                return 1
            fi
            ;;
        *)
            echo "Error: Unsupported archive format for testing"
            return 1
            ;;
    esac
}

# Find files by name
ff() {
    find . -type f -iname '*'"$*"'*' -ls
}

# Find files by content
ftext() {
    grep -r --include="$2" "$1" .
}

# Find and replace in files
findreplace() {
    find . -type f -name "$1" -exec sed -i "s/$2/$3/g" {} +
}

# Quick backup function
backup() {
    cp "$1" "$1.bak-$(date +%Y%m%d-%H%M%S)"
}

# Show directory size
dirsize() {
    du -sh "${1:-.}" | cut -f1
}

# Quick network test
nettest() {
    echo "🌐 Testing network connectivity..."
    if ping -c 3 8.8.8.8 >/dev/null 2>&1; then
        echo "✅ Internet: OK"
    else
        echo "❌ Internet: Failed"
    fi

    local gateway

    gateway=$(route -n get default 2>/dev/null | awk '/gateway:/ {print $2}' || netstat -rn | awk '/^default/ {print $2}' | head -1)

    if [[ -n $gateway ]]; then
        if ping -c 3 "$gateway" >/dev/null 2>&1; then
            echo "✅ Gateway ($gateway): OK"
        else
            echo "❌ Gateway ($gateway): Failed"
        fi
    fi

    echo "📡 DNS Test:"
    nslookup google.com >/dev/null 2>&1 && echo "✅ DNS: OK" || echo "❌ DNS: Failed"
}

# Enhanced ports function
ports() {
    echo "🔌 Open (non-local) ports:"
    sockstat -4 -6 -L -l -s -U -c \
      | awk '/[tu][cd]p/ {print $1, $2, $3, $4, $5, $6, $7, $8}' \
      | sort -k8 -k6 -k1 -k5 \
      | column -t \
      | sed -E "s/(:[0-9]+)/$(printf '\033[1;31m')\1$(printf '\033[0m')/g"
    echo "🌐 Established connections:"
    sockstat -4 -6 -s -L | grep ESTABLISHED | wc -l | xargs echo "Active connections:"
}

# Ultimate ZFS health check
zhealth() {
    echo "🏊 === ZFS Pool Status ==="
    zpool status -x

    echo -e "\n📊 === Pool Space Usage ==="
    zpool list -o name,size,allocated,free,capacity,health
 
    echo -e "\n💾 === ZFS Datasets ==="
    zfs list -o name,used,available,refer,mountpoint,usedbychildren,usedbysnapshots,encryption,devices,usedbyrefreservation \
      -d 2 \
      -s name \
      | grep -v '^freenas-boot/\|PoolONE/iocage/\|PoolONE/Volumes/\|FlashONE/iocage/\|FlashONE/Volumes/\|PoolONE/FreeNAS/AnonymousFTP'

    echo -e "\n📸 === Recent Snapshots ==="
    zfs list -t snapshot -s creation | tail -5

    echo -e "\n⚡ === I/O Statistics ==="
    zpool iostat -v 1 1
}

truenas_version() {
    if [[ -f /etc/version ]]; then
        cat /etc/version
    else
        echo "Unknown"
    fi
}

# System info dashboard
sysinfo() {
    echo "🖥️  === TrueNAS System Dashboard ==="
    echo "📍 Hostname: $(hostname)"
    echo "⏰ Uptime: $(uptime | awk -F, '{sub(".*up ",x,$1);print $1}' | sed 's/^ *//')"
    echo "📈 Load: $(uptime | awk -F'load averages: ' '{print $2}')"
    echo "💾 Memory: $(sysctl -n hw.physmem | awk '{printf "%.1f GB total", $1/1024/1024/1024}') | $(sysctl -n vm.stats.vm.v_free_count vm.stats.vm.v_page_size | awk 'NR==1{free=$1} NR==2{pagesize=$1} END{printf "%.1f GB free", (free*pagesize)/1024/1024/1024}')"
    echo "💿 Root Disk: $(df -h / | awk 'NR==2 {print $3 "/" $2 " (" $5 ")"}')"
    echo "🌡️ CPU Temp: $(sysctl -n hw.acpi.thermal.tz0.temperature 2>/dev/null | sed 's/C/°C/' || echo "N/A")"
    echo "🔧 TrueNAS: $(truenas_version)"
    echo "🐧 Kernel: $(uname -r)"
    echo "🏃 Processes: $(ps -aux | wc -l)"
    echo "👥 User sessions: $(who | wc -l)"
    echo "🌐 IP: $(ifconfig | grep 'inet ' | grep -v '127.0.0.1' | head -1 | awk '{print $2}')"
}

# Process management
topcpu() {
    echo "🔥 Top ${1:-10} CPU processes:"
    ps -r | awk 'NR==1{print; next} $3>0{print}' | head -$((${1:-10}+1))
}

topmem() {
    echo "💾 Top ${1:-10} Memory processes:"
    ps -m | awk 'NR==1{print; next} $4>0{print}' | head -$((${1:-10}+1))
}

# ZFS pool health indicator
get_zfs_status() {
  if command -v zpool >/dev/null 2>&1; then
    local zfs_output
    zfs_output=$(zpool status -x 2>/dev/null)
    if echo "$zfs_output" | grep -q "all pools are healthy"; then
      echo "✅ ZFS: All pools are healthy"
    elif echo "$zfs_output" | grep -q "no pools available" || [[ -z "$zfs_output" ]]; then
      # Silent skip - we're in a jail without pool access or no output
      :
    else
      echo "⚠️  ZFS: Check pool status with 'zhealth'"
    fi
  fi
}

# Service management helper
# Replace the existing servstat function (around line 786) with this enhanced version

# Enhanced Service Status Function for TrueNAS
servstat() {
    local filter=""
    local show_disabled=false
    local show_details=false
    local sort_output=false
    local output_format="table"

    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -a|--all)
                show_disabled=true
                shift
                ;;
            -d|--details)
                show_details=true
                shift
                ;;
            -s|--sort)
                sort_output=true
                shift
                ;;
            -j|--json)
                output_format="json"
                shift
                ;;
            -r|--running)
                filter="running"
                shift
                ;;
            -x|--stopped)
                filter="stopped"
                shift
                ;;
            -h|--help)
                echo "Usage: servstat [OPTIONS] [SERVICE_NAME]"
                echo ""
                echo "Options:"
                echo "  -a, --all        Show all services (including disabled)"
                echo "  -d, --details    Show detailed service information"
                echo "  -s, --sort       Sort services alphabetically"
                echo "  -j, --json       Output in JSON format"
                echo "  -r, --running    Show only running services"
                echo "  -x, --stopped    Show only stopped services"
                echo "  -h, --help       Show this help message"
                echo ""
                echo "Examples:"
                echo "  servstat                    # Show all enabled services"
                echo "  servstat ssh                # Show specific service status"
                echo "  servstat -a -s              # Show all services, sorted"
                echo "  servstat -r                 # Show only running services"
                echo "  servstat -d ssh             # Show detailed info for ssh"
                return 0
                ;;
            -*)
                echo "Unknown option: $1"
                echo "Use 'servstat --help' for usage information"
                return 1
                ;;
            *)
                # Single service query
                _servstat_single_service "$1" "$show_details"
                return $?
                ;;
        esac
    done

    # Main service overview
    _servstat_overview "$filter" "$show_disabled" "$show_details" "$sort_output" "$output_format"
}

# Function to check single service
_servstat_single_service() {
    local service_name="$1"
    local show_details="$2"

    if [[ -z "$service_name" ]]; then
        echo "❌ No service name provided"
        return 1
    fi

    # Check if service exists
    if ! service -l 2>/dev/null | grep -q "^${service_name}$"; then
        echo "❌ Service '$service_name' not found"
        echo "💡 Available services: $(service -l 2>/dev/null | tr '\n' ' ')"
        return 1
    fi

    echo "🔍 Service: $service_name"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

    # Get service status
    local status_output status_code

    status_output=$(service "$service_name" onestatus 2>/dev/null)
    status_code=$?

    # Determine status
    local status_icon="❓"
    local status_text="Unknown"
    local status_color=""

    if [[ $status_code -eq 0 ]]; then
        if echo "$status_output" | grep -q "is running"; then
            status_icon="✅"
            status_text="Running"
            status_color="\033[32m"  # Green
        else
            status_icon="❌"
            status_text="Stopped"
            status_color="\033[31m"  # Red
        fi
    else
        status_icon="⚠️"
        status_text="Error"
        status_color="\033[33m"  # Yellow
    fi

    echo -e "${status_color}Status: ${status_icon} ${status_text}\033[0m"

    if [[ "$show_details" == true ]]; then
        echo ""
        echo "📋 Detailed Information:"

        # Service description
        local desc

        desc=$(service "$service_name" describe 2>/dev/null || echo "No description available")
        echo "Description: $desc"

        # RC script location
        local rc_script="/etc/rc.d/$service_name"
        if [[ -f "$rc_script" ]] || [[ -f "/usr/local/etc/rc.d/$service_name" ]]; then
            [[ -f "$rc_script" ]] || rc_script="/usr/local/etc/rc.d/$service_name"
            echo "RC Script: $rc_script"
            echo "Permissions: $(ls -la "$rc_script" | awk '{print $1, $3, $4}')"
        fi

        # Check if enabled at boot
        local enabled_status="❌ Disabled"
        if sysrc -n "${service_name}_enable" 2>/dev/null | grep -q "YES"; then
            enabled_status="✅ Enabled"
        fi
        echo "Boot Enable: $enabled_status"

        # Process information if running
        if [[ "$status_text" == "Running" ]]; then
            echo ""
            echo "🏃 Process Information:"
            local pids=$(pgrep -f "$service_name" 2>/dev/null || pgrep "$service_name" 2>/dev/null)
            if [[ -n "$pids" ]]; then
                echo "PIDs: $pids"
                echo "Memory Usage:"
                ps -o pid,pcpu,pmem,vsz,rss,comm -p $pids 2>/dev/null | head -10
            else
                echo "No processes found (service may use different process names)"
            fi
        fi

        # Configuration files
        echo ""
        echo "📁 Configuration:"
        local config_dirs=("/etc" "/usr/local/etc" "/etc/rc.conf.d")
        for dir in "${config_dirs[@]}"; do
            if [[ -f "$dir/$service_name" ]] || [[ -f "$dir/${service_name}.conf" ]]; then
                [[ -f "$dir/$service_name" ]] && echo "Config: $dir/$service_name"
                [[ -f "$dir/${service_name}.conf" ]] && echo "Config: $dir/${service_name}.conf"
            fi
        done

        # Log files
        echo ""
        echo "📝 Recent Logs:"
        local log_patterns=("/var/log/${service_name}.log" "/var/log/${service_name}/*.log" "/var/log/messages")
        for pattern in "${log_patterns[@]}"; do
            if ls "$pattern" 2>/dev/null | head -1 >/dev/null; then
                echo "Recent entries from system logs:"
                grep -i "$service_name" /var/log/messages 2>/dev/null | tail -5 | while read line; do
                    echo "  $line"
                done
                break
            fi
        done
    fi

    echo ""
    echo "🔧 Quick Actions:"
    echo "  service $service_name start     # Start service"
    echo "  service $service_name stop      # Stop service"
    echo "  service $service_name restart   # Restart service"
    echo "  service $service_name reload    # Reload configuration"
    echo "  sysrc ${service_name}_enable=YES   # Enable at boot"
    echo "  sysrc ${service_name}_enable=NO    # Disable at boot"
}

# Function for service overview
_servstat_overview() {
    local filter="$1"
    local show_disabled="$2"
    local show_details="$3"
    local sort_output="$4"
    local output_format="$5"

    if ! command -v service >/dev/null 2>&1; then
        echo "❌ Service management not available on this system"
        return 1
    fi

    echo "🖥️ TrueNAS Service Status Overview"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

    # Collect service information
    local services=()
    local running_count=0
    local stopped_count=0
    local error_count=0

    # Get list of services
    local service_list
    if [[ "$show_disabled" == true ]]; then
        service_list=$(service -l 2>/dev/null)
    else
        service_list=$(service -e 2>/dev/null)
    fi

    if [[ -z "$service_list" ]]; then
        echo "❌ No services found"
        return 1
    fi

    # Process each service
    while IFS= read -r svc; do
        [[ -z "$svc" ]] && continue

        local status_output
        local status_code

        status_output=$(service "$svc" onestatus 2>/dev/null)
        status_code=$?

        local status_icon="❓"
        local status_text="Unknown"
        local boot_enabled="❌"

        # Determine status
        if [[ $status_code -eq 0 ]]; then
            if echo "$status_output" | grep -q "is running"; then
                status_icon="✅"
                status_text="Running"
                ((running_count++))
            else
                status_icon="❌"
                status_text="Stopped"
                ((stopped_count++))
            fi
        else
            status_icon="⚠️"
            status_text="Error"
            ((error_count++))
        fi

        # Check boot status
        if sysrc -n "${svc}_enable" 2>/dev/null | grep -q "YES"; then
            boot_enabled="✅"
        fi

        # Apply filters
        if [[ -n "$filter" ]]; then
            case "$filter" in
                "running")
                    [[ "$status_text" != "Running" ]] && continue
                    ;;
                "stopped")
                    [[ "$status_text" != "Stopped" ]] && continue
                    ;;
            esac
        fi

        # Store service info
        if [[ "$output_format" == "json" ]]; then
            services+=("{\"name\":\"$svc\",\"status\":\"$status_text\",\"boot_enabled\":\"$boot_enabled\",\"icon\":\"$status_icon\"}")
        else
            services+=("$svc|$status_icon|$status_text|$boot_enabled")
        fi

    done <<< "$service_list"

    # Output results
    if [[ "$output_format" == "json" ]]; then
        echo "{"
        echo "  \"summary\": {"
        echo "    \"total\": $((running_count + stopped_count + error_count)),"
        echo "    \"running\": $running_count,"
        echo "    \"stopped\": $stopped_count,"
        echo "    \"errors\": $error_count"
        echo "  },"
        echo "  \"services\": ["
        printf '    %s' "${services[@]}"
        echo ""
        echo "  ]"
        echo "}"
    else
        # Summary
        echo ""
        echo "📊 Summary: 🟢 $running_count running | 🔴 $stopped_count stopped | ⚠️ $error_count errors"
        echo ""

        # Table header
        printf "%-20s %-8s %-10s %-12s\n" "SERVICE" "STATUS" "STATE" "BOOT ENABLE"
        printf "%-20s %-8s %-10s %-12s\n" "-------" "------" "-----" "-----------"

        # Sort if requested
        if [[ "$sort_output" == true ]]; then
            printf '%s\n' "${services[@]}" | sort | while IFS='|' read -r name icon state boot; do
                printf "%-20s %-8s %-10s %-12s\n" "$name" "$icon" "$state" "$boot"
            done
        else
            for service_info in "${services[@]}"; do
                IFS='|' read -r name icon state boot <<< "$service_info"
                printf "%-20s %-8s %-10s %-12s\n" "$name" "$icon" "$state" "$boot"
            done
        fi

        echo ""
        echo "💡 Tips:"
        echo "  • Use 'servstat <service>' for detailed info"
        echo "  • Use 'servstat -r' to show only running services"
        echo "  • Use 'servstat -d <service>' for detailed analysis"
        echo "  • Use 'servstat --help' for all options"
    fi
}

# Log analysis
logwatch() {
    echo "📝 Recent system events:"
    echo "=== Errors ==="
    tail -100 /var/log/messages | grep -i error | tail -5
    echo "=== Warnings ==="
    tail -100 /var/log/messages | grep -i warn | tail -5
    echo "=== Last 10 entries ==="
    tail -10 /var/log/messages
}

# Temperature monitoring
temps() {
    echo "🌡️  System Temperatures:"
    for sensor in $(sysctl -a | grep temperature | cut -d: -f1); do
        temp=$(sysctl -n $sensor 2>/dev/null)
        if [[ -n $temp ]]; then
            echo "$sensor: $temp"
        fi
    done
}

# Disk usage analyzer
diskusage() {
    echo "💾 Disk Usage Analysis:"
    echo "=== Top 10 largest directories ==="
    du -h --max-depth=1 ${1:-.} 2>/dev/null | sort -hr | head -10
    echo "=== Disk space by filesystem ==="
    df -h | grep -v tmpfs | grep -v udev
}

# Network analyzer
netinfo() {
    echo "🌐 Network Information:"
    echo "=== Interfaces ==="
    ifconfig | grep -E "(inet |UP,|flags=)"

    echo "=== Routing Table ==="
    netstat -rn

    echo "=== DNS Servers ==="
    # shellcheck disable=SC2002
    cat /etc/resolv.conf | grep nameserver

    echo "=== Open Connections ==="
    netstat -uln -p tcp | head -20
}

# Security scanner
seccheck() {
    echo "🔒 Security Check:"

    echo "=== Failed Login Attempts ==="
    grep "Failed password" /var/log/auth.log 2>/dev/null | tail -5 || echo "No auth.log found"

    echo "=== Open Ports ==="
    netstat -4lCna --libxo json \
      | jq -r '["PROTOCOL", "ADDRESS", "PORT", "STATE"], (.statistics.socket[] | select(.["tcp-state"] != null and (if .["tcp-state"] | type == "string" then .["tcp-state"] | contains("LISTEN") else false end)) | [.protocol, .local.address, .local.port, .["tcp-state"]]) | @tsv' \
      | sort -nk3 -k2 -k1 \
      | column -t

    echo "=== Root Login Sessions ==="
    last root | head -5

    echo "=== File Permissions Check ==="
    find /etc -name "passwd" -o -name "shadow" -o -name "group" -print | xargs ls -la
}

# Performance monitor
perfmon() {
    echo "⚡ Performance Monitor:"
    echo "=== CPU Usage ==="
    top -bn | grep "CPU:" || iostat -c 1 1 | tail -1

    echo "=== Memory Usage ==="
    echo "Total: $(sysctl -n hw.physmem | awk '{printf "%.1f GB", $1/1024/1024/1024}')"
    echo "Free: $(sysctl -n vm.stats.vm.v_free_count vm.stats.vm.v_page_size | awk 'NR==1{free=$1} NR==2{pagesize=$1} END{printf "%.1f GB", (free*pagesize)/1024/1024/1024}')"

    echo "=== Disk I/O ==="
    iostat 1 2>/dev/null || iostat -d 1 1 2>/dev/null || echo "iostat not available"

    echo "=== Network I/O ==="
    # FreeBSD doesn't have /proc/net/dev, use netstat instead

    netstat -ibn 2>/dev/null | grep -v "lo0" | awk 'NR>1 && $1!~/Name/ {print $1 ": " $7 " bytes in, " $10 " bytes out"}' | head -5 || ifconfig | grep -E "(RX|TX) bytes"
    echo "=== Load Average ==="
    uptime
}

# ZFS maintenance helper
zfsmaint() {
    echo "🛠️  ZFS Maintenance Helper:"

    echo "=== Pool Status ==="
    zpool status | grep -E "pool:|state:|errors:"

    echo "=== Scrub Status ==="
    zpool status | grep scrub

    echo "=== Recent Snapshots ==="
    zfs list -t snapshot -s creation | tail -10

    echo "=== Space Usage ==="
    zfs list | head -20

    echo -e "\n🔧 Maintenance Commands:"
    echo "  zpool scrub [pool]     - Start scrub"
    echo "  zfs snapshot [dataset]@$(date +%Y%m%d) - Create snapshot"
    echo "  zfs destroy [snapshot] - Remove snapshot"
}

# Container/Jail manager
jailmgr() {
    echo "🏢 Jail/Container Manager:"

    echo "=== Running Jails ==="
    jls -v 2>/dev/null || echo "No jails running"

    echo "=== iocage Jails ==="
    iocage list --header \
    | sort -rk3 -k2 \
    | column -t 2>/dev/null || echo "iocage not available"

    echo "=== Resource Usage ==="
    for jail in $(jls -h jid 2>/dev/null); do
        [[ $jail == "jid" ]] && continue
        echo "Jail $jail: $(ps -J "$jail" | wc -l) processes"
    done 2>/dev/null
}

# File finder with preview
findfile() {
    find "${2:-.}" -iname "*$1*" -type f 2>/dev/null | head -20 | while read -r file; do
        echo "📄 $file"
        if [[ $(file "$file" | grep text) ]]; then
            echo "   Preview: $(head -1 "$file" 2>/dev/null | cut -c1-80)..."
        fi
    done
}

# Quick file server
serve() {
    local port=${1:-8000}
    echo "🌐 Starting HTTP server on port $port"
    echo "📁 Serving: $(pwd)"
    echo "🔗 URL: http://$(ifconfig | grep 'inet ' | grep -v '127.0.0.1' | head -1 | awk '{print $2}'):$port"
    python3 -m http.server "$port" 2>/dev/null || python -m SimpleHTTPServer "$port"
}

# System cleanup
cleanup() {
    echo "🧹 System Cleanup:"

    echo "=== Cleaning temporary files ==="
    sudo rm -rf /tmp/* /var/tmp/* 2>/dev/null && echo "✅ Temp files cleaned"

    echo "=== Cleaning old logs ==="
    sudo find /var/log -name "*.log.*" -mtime +30 -delete 2>/dev/null && echo "✅ Old logs cleaned"

    echo "=== Package cache cleanup ==="
    sudo pkg clean -y 2>/dev/null && echo "✅ Package cache cleaned"

    echo "=== ZFS snapshot cleanup (older than 30 days) ==="
    # FreeBSD-compatible date calculation (30 days ago)
    cutoff_date=$(date -v-30d '+%Y-%m-%d' 2>/dev/null || date -d '30 days ago' '+%Y-%m-%d' 2>/dev/null || echo "1970-01-01")
    zfs list -t snapshot -o name,creation | awk '$2 < "'"$cutoff_date"'" {print $1}' | head -5
}

# Weather function
weather() {
    local city=${1:-Amsterdam}
    curl -s "wttr.in/$city?format=3" 2>/dev/null || echo "🌤️  Weather service unavailable"
}

# Color test
colortest() {
    echo "🎨 Color Test:"
    for i in {0..255}; do
        printf "\x1b[38;5;${i}m%3d " "${i}"
        if (( i == 15 )) || (( i > 15 )) && (( (i-15) % 6 == 0 )); then
            printf "\x1b[0m\n";
        fi
    done
}

# System benchmark
benchmark() {
    echo "🏃 Quick System Benchmark:"
    echo "=== CPU Test ==="
    time echo "scale=5000; 4*a(1)" | bc -l >/dev/null

    echo "=== Memory Test ==="
    dd if=/dev/zero of=/tmp/benchmark bs=1M count=100 2>&1 | grep copied
    rm -f /tmp/benchmark

    echo "=== Disk Test ==="
    dd if=/dev/zero of=/tmp/disktest bs=1M count=100 oflag=sync 2>&1 | grep copied
    rm -f /tmp/disktest
}

# Git shortcuts (if git is available)
gits() {
    if command -v git >/dev/null; then
        echo "📋 Git Status:"
        git status --short 2>/dev/null || echo "Not a git repository"
    fi
}

gitl() {
    if command -v git >/dev/null; then
        git log --oneline -10 2>/dev/null || echo "Not a git repository"
    fi
}

# Quick calculator
calc() {
    echo "scale=3; $*" | bc -l
}

# Password generator
genpass() {
    local length=${1:-16}
    openssl rand -base64 "$length" | cut -c1-"$length" 2>/dev/null || \
    tr -dc 'A-Za-z0-9!"#$%&'\''()*+,-./:;<=>?@[\]^_`{|}~' </dev/urandom | head -c "$length"; echo
}

# System update helper
sysupdate() {
    echo "🔄 System Update Helper:"

    # Detect if on TrueNAS Core (freenas-update present, pkg repo likely broken)
    if command -v freenas-update >/dev/null 2>&1; then
        echo "=== TrueNAS Core detected ==="
        echo "The package manager (pkg) is not supported on the host system."
        echo "Use the TrueNAS web interface for major updates and patches."
        echo ""
        echo "For CLI/system update:"
        echo "  sudo freenas-update check         # Check for updates"
        echo "  sudo freenas-update download      # Download updates"
        echo "  sudo freenas-update install       # Install updates (will reboot)"
        echo ""
        echo "=== Jail/Plugin updates ==="
        echo "For jails/plugins, use 'pkg' **inside** each jail, not on the host!"
    else
        echo "=== FreeBSD system detected ==="
        echo "=== Updating package index ==="
        if sudo pkg update 2>/dev/null; then
            echo "✅ Package index updated"
            echo "=== Available updates ==="
            pkg version -v 2>/dev/null | grep '<' || echo "No updates available or pkg repository not configured"
        else
            echo "⚠️ Package repository not available or configured"
            echo "This may be expected on TrueNAS systems where pkg is managed separately"
        fi
        echo "=== Update commands ==="
        echo "  sudo pkg upgrade    - Upgrade all packages"
    fi
}

# ============================================================================
# DIRECTORY SHORTCUTS & HASHES
# ============================================================================

# Directory hashes for quick navigation
hash -d freenas=/mnt/PoolONE/FreeNAS
hash -d pools=/mnt
hash -d jails=/mnt/FlashONE/iocage/jails
hash -d media=/mnt/PoolONE/FreeNAS/Media
hash -d nextcloud=/mnt/PoolONE/Nextcloud/kjanat/files
hash -d logs=/var/log
hash -d etc=/etc
hash -d usr=/usr/local
hash -d home=/home
hash -d tmp=/tmp
hash -d var=/var
hash -d root=/root
hash -d boot=/boot

# ============================================================================
# INTELLIGENT AUTO-SUGGESTIONS & SYNTAX HIGHLIGHTING
# ============================================================================

# Load syntax highlighting (if available)
if [[ -f /usr/local/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]]; then
    source /usr/local/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

    # Custom highlighting styles
    ZSH_HIGHLIGHT_STYLES[default]=none
    ZSH_HIGHLIGHT_STYLES[unknown-token]=fg=red,bold
    ZSH_HIGHLIGHT_STYLES[reserved-word]=fg=cyan,bold
    ZSH_HIGHLIGHT_STYLES[suffix-alias]=fg=green,underline
    ZSH_HIGHLIGHT_STYLES[global-alias]=fg=cyan
    ZSH_HIGHLIGHT_STYLES[precommand]=fg=green,underline
    ZSH_HIGHLIGHT_STYLES[commandseparator]=fg=blue,bold
    ZSH_HIGHLIGHT_STYLES[autodirectory]=fg=green,underline
    ZSH_HIGHLIGHT_STYLES[path]=underline
    ZSH_HIGHLIGHT_STYLES[path_pathseparator]=
    ZSH_HIGHLIGHT_STYLES[path_prefix_pathseparator]=
    ZSH_HIGHLIGHT_STYLES[globbing]=fg=blue,bold
    ZSH_HIGHLIGHT_STYLES[history-expansion]=fg=blue,bold
    ZSH_HIGHLIGHT_STYLES[command-substitution]=none
    ZSH_HIGHLIGHT_STYLES[command-substitution-delimiter]=fg=magenta
    ZSH_HIGHLIGHT_STYLES[process-substitution]=none
    ZSH_HIGHLIGHT_STYLES[process-substitution-delimiter]=fg=magenta
    ZSH_HIGHLIGHT_STYLES[single-hyphen-option]=fg=cyan
    ZSH_HIGHLIGHT_STYLES[double-hyphen-option]=fg=cyan
    ZSH_HIGHLIGHT_STYLES[back-quoted-argument]=none
    ZSH_HIGHLIGHT_STYLES[back-quoted-argument-delimiter]=fg=blue,bold
    ZSH_HIGHLIGHT_STYLES[single-quoted-argument]=fg=yellow
    ZSH_HIGHLIGHT_STYLES[double-quoted-argument]=fg=yellow
    ZSH_HIGHLIGHT_STYLES[dollar-quoted-argument]=fg=yellow
    ZSH_HIGHLIGHT_STYLES[rc-quote]=fg=magenta
    ZSH_HIGHLIGHT_STYLES[dollar-double-quoted-argument]=fg=magenta
    ZSH_HIGHLIGHT_STYLES[back-double-quoted-argument]=fg=magenta
    ZSH_HIGHLIGHT_STYLES[back-dollar-quoted-argument]=fg=magenta
    ZSH_HIGHLIGHT_STYLES[assign]=none
    ZSH_HIGHLIGHT_STYLES[redirection]=fg=blue,bold
    ZSH_HIGHLIGHT_STYLES[comment]=fg=black,bold
    ZSH_HIGHLIGHT_STYLES[named-fd]=none
    ZSH_HIGHLIGHT_STYLES[numeric-fd]=none
    ZSH_HIGHLIGHT_STYLES[arg0]=fg=green
fi

# Load autosuggestions (if available)
if [[ -f /usr/local/share/zsh-autosuggestions/zsh-autosuggestions.zsh ]]; then
    source /usr/local/share/zsh-autosuggestions/zsh-autosuggestions.zsh
    ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=240'
    ZSH_AUTOSUGGEST_STRATEGY=(history completion)
    ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20
fi

# ============================================================================
# INTELLIGENT COMMAND CORRECTION
# ============================================================================

# Advanced spell correction
setopt CORRECT
setopt CORRECT_ALL

# Custom corrections
alias sl='ls'
alias cd..='cd ..'
alias pdw='pwd'
alias claer='clear'
alias whihc='which'

# ============================================================================
# AUTO-COMPLETION ENHANCEMENTS
# ============================================================================

# Load additional completions
if [[ -d /usr/local/share/zsh/site-functions ]]; then
    fpath=(/usr/local/share/zsh/site-functions $fpath)
fi

# Load bash completion compatibility
autoload -U +X bashcompinit && bashcompinit

# Custom completion functions
_zfs_completion() {
    local -a datasets
    mapfile -t datasets < <(zfs list -H -o name 2>/dev/null)
    compadd "${datasets[@]}"
}
compdef _zfs_completion zfs

_zpool_completion() {
    local -a pools
    mapfile -t pools < <(zpool list -H -o name 2>/dev/null)
    compadd "${pools[@]}"
}
compdef _zpool_completion zpool

# ============================================================================
# STARTUP BANNER & SYSTEM CHECK
# ============================================================================

# Only run in interactive shells and only once
if [[ $- == *i* && -z $ZSH_BANNER_SHOWN ]]; then
  export ZSH_BANNER_SHOWN=1

  ############################################################################
  # Fancy banner (aligns only in a mono-emoji font – JetBrains Mono NF, etc.)
  ############################################################################
  cat <<'EOF'
╔══════════════════════════════════════════════════════════════════════════╗
║  🚀 WELCOME TO ULTIMATE TRUENAS ZSH – BEAST MODE ACTIVATED! 🚀           ║
╠══════════════════════════════════════════════════════════════════════════╣
║  📊 Quick Commands: sysinfo | zhealth | nettest | perfmon | servstat     ║
║  🔧 ZFS Tools: pools | datasets | snapshots | scrub | zfsmaint           ║
║  🌐 Network: myip | ports | netinfo | speedtest                          ║
║  📁 Files: ff [name] | ftext [content] | extract [file] | backup [file]  ║
║  🎯 Utils: weather | calc | genpass | cleanup | temps                    ║
╚══════════════════════════════════════════════════════════════════════════╝
EOF

  ############################################################################
  # Quick system status
  ############################################################################
  # Hostname, RAM, load‐average uptime, and current time in one neat line
  if uptime -p >/dev/null 2>&1; then
    up="$(uptime -p | sed 's/^up //')"          # GNU coreutils
  else
    up="$(uptime | awk -F'up |, *[0-9]+ user' '{print $2}')"  # BSD
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
  if ! command -v freenas-update >/dev/null 2>&1; then
    # Run package check in background to avoid blocking shell startup
    {
      if command -v pkg >/dev/null 2>&1; then
        update_available=$( pkg version -v | grep -cF '<' 2>/dev/null );
        if [[ $update_available -gt 0 ]]; then
          echo "📦 ${update_available} Updates available: run 'sysupdate'"
        fi
      fi
    } &
  fi

  # Enable new-mail notification for the session
  export MAIL="/var/mail/$USER"
fi

# ============================================================================
# PLUGIN MANAGEMENT SYSTEM
# ============================================================================

# ZSH Plugin Management System - Fixed and Enhanced
# Shellcheck-clean with proper error handling and features

# Plugin directory configuration
# Set default plugin directory, but use a fallback if the directory doesn't exist or isn't accessible
if [[ -z "$ZSH_PLUGIN_DIR" ]]; then
    if [[ -d "$HOME/.zsh/plugins" ]] && [[ -w "$HOME/.zsh/plugins" ]]; then
        ZSH_PLUGIN_DIR="$HOME/.zsh/plugins"
    elif [[ -d "$HOME/.local/share/zsh/plugins" ]] && [[ -w "$HOME/.local/share/zsh/plugins" ]]; then
        ZSH_PLUGIN_DIR="$HOME/.local/share/zsh/plugins"
    else
        # Create a temporary directory in /tmp that is writable and won't cause errors
        ZSH_PLUGIN_DIR="/tmp/zsh-${USER}-plugins"
        # We'll create this in _ensure_plugin_dir if needed
    fi
fi

# Create plugin directory if it doesn't exist
_ensure_plugin_dir() {
    if [[ ! -d "$ZSH_PLUGIN_DIR" ]]; then
        # Try to create the directory
        mkdir -p "$ZSH_PLUGIN_DIR" 2>/dev/null

        # Check if creation was successful
        if [[ ! -d "$ZSH_PLUGIN_DIR" ]]; then
            # If creation failed, fall back to a temporary directory
            ZSH_PLUGIN_DIR="/tmp/zsh-${USER}-plugins"
            mkdir -p "$ZSH_PLUGIN_DIR" 2>/dev/null

            # If even this fails, use /tmp directly as a last resort
            if [[ ! -d "$ZSH_PLUGIN_DIR" ]]; then
                ZSH_PLUGIN_DIR="/tmp"
            fi
        else
            echo "📁 Created plugin directory: $ZSH_PLUGIN_DIR"
        fi
    fi

    # Verify we have write permissions in the directory
    if [[ ! -w "$ZSH_PLUGIN_DIR" ]]; then
        echo "⚠️ Warning: No write permission in plugin directory: $ZSH_PLUGIN_DIR"
        # Fall back to a temporary directory
        ZSH_PLUGIN_DIR="/tmp/zsh-${USER}-plugins"
        mkdir -p "$ZSH_PLUGIN_DIR" 2>/dev/null
    fi
}

# Plugin loader function with enhanced error handling
load_plugin() {
    local plugin_name="$1"

    if [[ -z "$plugin_name" ]]; then
        echo "❌ Error: No plugin name provided"
        echo "Usage: load_plugin <plugin_name>"
        return 1
    fi

    local plugin_file="$ZSH_PLUGIN_DIR/$plugin_name/$plugin_name.plugin.zsh"

    # Check if plugin directory exists
    if [[ ! -d "$ZSH_PLUGIN_DIR/$plugin_name" ]]; then
        echo "❌ Plugin directory not found: $ZSH_PLUGIN_DIR/$plugin_name"
        return 1
    fi

    # Check if main plugin file exists
    if [[ -f "$plugin_file" ]]; then
        # shellcheck source=/dev/null
        # Disable SC1090 as plugin files are dynamically loaded
        if source "$plugin_file" 2>/dev/null; then
            echo "✅ Loaded plugin: $plugin_name"

            # Track loaded plugins
            if [[ ${#ZSH_LOADED_PLUGINS[@]} -eq 0 ]]; then
                ZSH_LOADED_PLUGINS=("$plugin_name")
            else
                ZSH_LOADED_PLUGINS+=("$plugin_name")
            fi
            return 0
        else
            echo "❌ Error loading plugin: $plugin_name (syntax error or missing dependencies)"
            return 1
        fi
    else
        # Try alternative plugin file names
        local alt_files=(
            "$ZSH_PLUGIN_DIR/$plugin_name/$plugin_name.zsh"
            "$ZSH_PLUGIN_DIR/$plugin_name/init.zsh"
            "$ZSH_PLUGIN_DIR/$plugin_name/$plugin_name.sh"
        )

        local loaded=false
        for alt_file in "${alt_files[@]}"; do
            if [[ -f "$alt_file" ]]; then
                # shellcheck source=/dev/null
                if source "$alt_file" 2>/dev/null; then
                    echo "✅ Loaded plugin: $plugin_name (using $(basename "$alt_file"))"
                    ZSH_LOADED_PLUGINS+=("$plugin_name")
                    loaded=true
                    break
                fi
            fi
        done

        if [[ "$loaded" == false ]]; then
            echo "❌ Plugin file not found: $plugin_name"
            echo "   Searched for:"
            echo "   • $plugin_file"
            for alt_file in "${alt_files[@]}"; do
                echo "   • $alt_file"
            done
            return 1
        fi
    fi
}

# Unload plugin function
unload_plugin() {
    local plugin_name="$1"

    if [[ -z "$plugin_name" ]]; then
        echo "❌ Error: No plugin name provided"
        echo "Usage: unload_plugin <plugin_name>"
        return 1
    fi

    # Check if plugin provides unload function
    local unload_func="${plugin_name}_unload"
    if declare -f "$unload_func" >/dev/null 2>&1; then
        echo "🗑️ Running unload function for $plugin_name"
        "$unload_func"
    fi

    # Remove from loaded plugins list
    if [[ ${#ZSH_LOADED_PLUGINS[@]} -gt 0 ]]; then
        local -a new_plugins
        for loaded_plugin in "${ZSH_LOADED_PLUGINS[@]}"; do
            if [[ "$loaded_plugin" != "$plugin_name" ]]; then
                new_plugins+=("$loaded_plugin")
            fi
        done
        ZSH_LOADED_PLUGINS=("${new_plugins[@]}")
    fi

    echo "✅ Unloaded plugin: $plugin_name"
}

# List available plugins
list_plugins() {
    _ensure_plugin_dir

    echo "📦 ZSH Plugin Status"
    echo "Plugin Directory: $ZSH_PLUGIN_DIR"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

    if [[ ! -d "$ZSH_PLUGIN_DIR" ]]; then
        echo "❌ Plugin directory does not exist"
        return 1
    fi

    local found_plugins=false

    for plugin_dir in "$ZSH_PLUGIN_DIR"/*; do
        if [[ -d "$plugin_dir" ]]; then
            found_plugins=true
            local plugin_name
            plugin_name=$(basename "$plugin_dir")

            # Check if plugin is loaded
            local status="❌ Not loaded"
            if [[ ${#ZSH_LOADED_PLUGINS[@]} -gt 0 ]]; then
                for loaded_plugin in "${ZSH_LOADED_PLUGINS[@]}"; do
                    if [[ "$loaded_plugin" == "$plugin_name" ]]; then
                        status="✅ Loaded"
                        break
                    fi
                done
            fi

            # Check for plugin files
            local main_file="$plugin_dir/$plugin_name.plugin.zsh"
            local file_status="❌ No plugin file"
            if [[ -f "$main_file" ]]; then
                file_status="📄 $plugin_name.plugin.zsh"
            else
                # Check alternatives
                local alt_files=(
                    "$plugin_dir/$plugin_name.zsh"
                    "$plugin_dir/init.zsh"
                    "$plugin_dir/$plugin_name.sh"
                )
                for alt_file in "${alt_files[@]}"; do
                    if [[ -f "$alt_file" ]]; then
                        file_status="📄 $(basename "$alt_file")"
                        break
                    fi
                done
            fi

            printf "%-20s %-15s %s\n" "$plugin_name" "$status" "$file_status"
        fi
    done

    if [[ "$found_plugins" == false ]]; then
        echo "No plugins found in $ZSH_PLUGIN_DIR"
        echo ""
        echo "💡 To install plugins:"
        echo "   mkdir -p $ZSH_PLUGIN_DIR/plugin-name"
        echo "   # Add plugin files to the directory"
        echo "   load_plugin plugin-name"
    fi

    echo ""
    echo "📋 Loaded plugins: ${#ZSH_LOADED_PLUGINS[@]}"
    if [[ ${#ZSH_LOADED_PLUGINS[@]} -gt 0 ]]; then
        for plugin in "${ZSH_LOADED_PLUGINS[@]}"; do
            echo "  • $plugin"
        done
    fi
}

# Reload plugin function
reload_plugin() {
    local plugin_name="$1"

    if [[ -z "$plugin_name" ]]; then
        echo "❌ Error: No plugin name provided"
        echo "Usage: reload_plugin <plugin_name>"
        return 1
    fi

    echo "🔄 Reloading plugin: $plugin_name"
    unload_plugin "$plugin_name" 2>/dev/null
    load_plugin "$plugin_name"
}

# Install plugin from URL (basic implementation)
install_plugin() {
    local plugin_url="$1"
    local plugin_name="$2"

    if [[ -z "$plugin_url" ]]; then
        echo "❌ Error: No plugin URL provided"
        echo "Usage: install_plugin <git_url> [plugin_name]"
        echo "Example: install_plugin https://github.com/user/plugin.git my-plugin"
        return 1
    fi

    _ensure_plugin_dir

    # Extract plugin name from URL if not provided
    if [[ -z "$plugin_name" ]]; then
        plugin_name=$(basename "$plugin_url" .git)
    fi

    local plugin_dir="$ZSH_PLUGIN_DIR/$plugin_name"

    if [[ -d "$plugin_dir" ]]; then
        echo "❌ Plugin already exists: $plugin_name"
        echo "Use 'update_plugin $plugin_name' to update or remove it first"
        return 1
    fi

    if command -v git >/dev/null 2>&1; then
        echo "📥 Installing plugin: $plugin_name"
        echo "From: $plugin_url"

        if git clone "$plugin_url" "$plugin_dir" --depth=1 --quiet; then
            echo "✅ Plugin installed: $plugin_name"
            echo "Load with: load_plugin $plugin_name"
        else
            echo "❌ Failed to install plugin: $plugin_name"
            # Clean up failed installation
            [[ -d "$plugin_dir" ]] && rm -rf "$plugin_dir"
            return 1
        fi
    else
        echo "❌ Git not found. Please install git to use install_plugin"
        return 1
    fi
}

# Update plugin function
update_plugin() {
    local plugin_name="$1"

    if [[ -z "$plugin_name" ]]; then
        echo "❌ Error: No plugin name provided"
        echo "Usage: update_plugin <plugin_name>"
        return 1
    fi

    local plugin_dir="$ZSH_PLUGIN_DIR/$plugin_name"

    if [[ ! -d "$plugin_dir" ]]; then
        echo "❌ Plugin not found: $plugin_name"
        return 1
    fi

    if [[ -d "$plugin_dir/.git" ]]; then
        echo "🔄 Updating plugin: $plugin_name"
        if (cd "$plugin_dir" && git pull --quiet); then
            echo "✅ Plugin updated: $plugin_name"
            echo "Reload with: reload_plugin $plugin_name"
        else
            echo "❌ Failed to update plugin: $plugin_name"
            return 1
        fi
    else
        echo "❌ Plugin $plugin_name is not a git repository"
        echo "Cannot auto-update non-git plugins"
        return 1
    fi
}

# Auto-load plugins from directory (wrapped in function to allow 'local')
_autoload_plugins() {
    _ensure_plugin_dir

    # Check if plugin directory exists
    if [[ ! -d "$ZSH_PLUGIN_DIR" ]]; then
        return 0
    fi

    # Check if plugin directory contains any items before iterating
    if ! compgen -G "$ZSH_PLUGIN_DIR/*" > /dev/null 2>&1; then
        # No plugins found, silently exit
        return 0
    fi

    local loaded_count=0
    local plugin_exists=false

    # Check if any plugin directories exist
    for item in "$ZSH_PLUGIN_DIR"/*; do
        if [[ -d "$item" ]]; then
            plugin_exists=true
            break
        fi
    done

    # If no plugin directories exist, return silently
    if [[ "$plugin_exists" == false ]]; then
        return 0
    fi

    # Now we know we have at least one plugin directory, proceed with loading
    for plugin_dir in "$ZSH_PLUGIN_DIR"/*; do
        if [[ -d "$plugin_dir" ]]; then
            local plugin_name
            plugin_name=$(basename "$plugin_dir")

            # Skip if already loaded
            local already_loaded=false
            if [[ ${#ZSH_LOADED_PLUGINS[@]} -gt 0 ]]; then
                for loaded_plugin in "${ZSH_LOADED_PLUGINS[@]}"; do
                    if [[ "$loaded_plugin" == "$plugin_name" ]]; then
                        already_loaded=true
                        break
                    fi
                done
            fi

            if [[ "$already_loaded" == false ]]; then
                if load_plugin "$plugin_name" >/dev/null 2>&1; then
                    ((loaded_count++))
                fi
            fi
        fi
    done

    if [[ $loaded_count -gt 0 ]]; then
        echo "🔌 Auto-loaded $loaded_count plugin(s)"
    fi
}

# Help function
plugin_help() {
    echo "🔌 ZSH Plugin Management Commands:"
    echo ""
    echo "Plugin Management:"
    echo "  load_plugin <name>        Load a plugin"
    echo "  unload_plugin <name>      Unload a plugin"
    echo "  reload_plugin <name>      Reload a plugin"
    echo "  list_plugins              List all plugins"
    echo ""
    echo "Plugin Installation:"
    echo "  install_plugin <url>      Install plugin from git URL"
    echo "  update_plugin <name>      Update a git-based plugin"
    echo ""
    echo "Examples:"
    echo "  load_plugin zsh-syntax-highlighting"
    echo "  install_plugin https://github.com/zsh-users/zsh-autosuggestions.git"
    echo "  list_plugins"
    echo ""
    echo "Plugin Directory: $ZSH_PLUGIN_DIR"
}

# Initialize plugin system
ZSH_LOADED_PLUGINS=()

# Auto-load plugins on shell startup with error handling
{
    # Attempt to auto-load plugins, but suppress any error messages
    _autoload_plugins
} 2>/dev/null

# ============================================================================
# PERFORMANCE MONITORING
# ============================================================================

# Track command execution time for slow commands
preexec() {
    timer=${timer:-$SECONDS}
}

precmd() {
    if [ "$timer" ]; then
        timer_show=$(($SECONDS - $timer))
        if [[ $timer_show -gt 3 ]]; then
            echo "⏱️  Command took ${timer_show}s"
        fi
        unset timer
    fi
}

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
  benchmark       - Quick system benchmark

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
  weather [city]  - Weather info
  calc [expr]     - Calculator
  genpass [len]   - Password generator
  serve [port]    - HTTP file server
  colortest       - Terminal color test

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
