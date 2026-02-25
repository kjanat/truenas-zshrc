# ============================================================================
# This file is AUTO-GENERATED — do not edit.
# Source: https://github.com/kjanat/truenas-zshrc
# Install: fetch -qo ~/.zshrc.truenas <raw URL of this file>
# ============================================================================
#!/usr/bin/env zsh
# ============================================================================
# ULTIMATE TrueNAS ZSH Configuration
# ============================================================================

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


# ======================================== options.zsh ========================================
# ============================================================================
# ZSH OPTIONS - ALL THE POWER
# ============================================================================

# Directory navigation
setopt AUTO_CD           # cd by typing directory name
setopt AUTO_PUSHD        # Push old directory onto stack
setopt PUSHD_IGNORE_DUPS # Don't push duplicates
setopt PUSHD_MINUS       # Exchange + and - for pushd
setopt CD_ABLE_VARS      # Try expanding as variable
setopt PUSHD_SILENT      # Don't print stack after pushd/popd

# Globbing and expansion
setopt EXTENDED_GLOB     # Extended globbing
setopt NO_CASE_GLOB      # Case insensitive globbing
setopt NUMERIC_GLOB_SORT # Sort numerically
setopt GLOB_DOTS         # Include dotfiles
setopt MARK_DIRS         # Mark directories with /
setopt GLOB_COMPLETE     # Complete globs
setopt BAD_PATTERN       # Error on bad pattern

# Completion
setopt AUTO_LIST         # List choices on ambiguous completion
setopt AUTO_MENU         # Show menu on successive tab
setopt AUTO_PARAM_SLASH  # Add slash after directory completion
setopt COMPLETE_IN_WORD  # Complete from both ends
setopt ALWAYS_TO_END     # Move cursor to end
setopt PATH_DIRS         # Perform path search on commands with slashes
setopt AUTO_REMOVE_SLASH # Remove trailing slash

# Job control
setopt LONG_LIST_JOBS # List jobs in long format
setopt AUTO_RESUME    # Resume jobs with their name
setopt NOTIFY         # Report status immediately
setopt CHECK_JOBS     # Check jobs on exit
setopt HUP            # Send HUP to jobs on shell exit
setopt BG_NICE        # Background jobs at lower priority

# Input/Output
setopt CORRECT              # Try to correct spelling
setopt CORRECT_ALL          # Try to correct all arguments
setopt FLOW_CONTROL         # Enable flow control
setopt IGNORE_EOF           # Don't exit on EOF
setopt INTERACTIVE_COMMENTS # Allow comments in interactive mode
setopt HASH_CMDS            # Hash commands for faster lookup
setopt HASH_DIRS            # Hash directories

# Prompting
setopt PROMPT_SUBST      # Parameter expansion in prompts
setopt TRANSIENT_RPROMPT # Remove right prompt from previous lines

# Scripts and functions
setopt MULTIOS     # Multiple redirections
setopt SHORT_LOOPS # Allow short loop syntax

# Don't beep!
unsetopt BEEP
unsetopt HIST_BEEP
unsetopt LIST_BEEP

# ======================================== aliases.zsh ========================================
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
alias lr='ls -R'    # recursive
alias lt='ls -ltrh' # sort by date
alias lk='ls -lSrh' # sort by size
# alias lx='ls -lXBh'    # GNU only, not available on FreeBSD
alias lc='ls -ltcrh'     # sort by change time
alias lu='ls -lturh'     # sort by access time
alias lm='ls -al | more' # pipe through more
alias tree='tree -C 2>/dev/null || find . -type d | sed -e "s/[^-][^\]*\//  |/g" -e "s/|\([^ ]\)/|-\1/"'

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
psg() { ps -aux | grep -v "grep" | grep -i -- "$@"; }
# alias psg='ps -aux | grep -v grep | grep --color=auto -i'

# alias top='htop 2>/dev/null || top'
alias iotop='iotop 2>/dev/null || command iostat'
alias nethogs='nethogs 2>/dev/null || echo "nethogs not installed"'

# Network aliases
alias myip='curl -s ifconfig.me; echo'
alias myipv4="curl -s ipv4.icanhazip.com"
alias myipv6="curl -s ipv6.icanhazip.com"
alias localip="ifconfig | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1'"
# alias speedtest='curl -s .../speedtest.py | python'  # disabled: supply-chain risk, python may not exist
alias netports="sockstat -46lsc | sed -n '1p'; sockstat -46Llsc | sed '1d' | sort -uk6 -k2 -k5 -k7 | column -t"
listening() {
	echo "SERVICE      PROTOCOL  PORT   ADDRESS"
	sockstat -46lLs | awk '
		/LISTEN/ && NR > 1 {
			port = $6; gsub(/:.*/, "", port)
			printf "%-12s %-9s %-6s %s\n", $2, $5, port, $6
		}
	' | sort -k3 -n | uniq
}
alias tcpdump='sudo tcpdump -nn -tttt'

# TrueNAS power aliases
alias pools='zpool list -o name,size,allocated,free,capacity,health'
alias datasets='zfs list -o name,used,avail,refer,mountpoint'
alias snapshots='zfs list -t snapshot -o name,used,refer,creation'
alias scrub='zpool scrub'
alias scrubstatus='zpool status | grep scrub' # -x or not?
alias ziostat='zpool iostat 1 5'
alias services='service -e'
alias servicestatus='service -l'
alias jails='jls -v'
alias plugins='iocage list'
alias logs='tail -f /var/log/messages'
alias syslog='less /var/log/messages'
alias dmesg='dmesg | less -R'
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

# Quick shortcuts
alias q='exit'
alias x='exit'
alias :q='exit'
alias bashrc='$EDITOR ~/.bashrc'
alias path='print -l ${(s/:/)PATH}'
alias now='date +"%T"'
alias nowtime=now
alias nowdate='date +"%d-%m-%Y"'

# ======================================== history.zsh ========================================
# ============================================================================
# HISTORY CONFIGURATION - MAXIMUM POWER
# ============================================================================

HISTSIZE=100000
SAVEHIST=100000
HISTFILE=~/.zsh_history

# All the history options
setopt EXTENDED_HISTORY       # Write timestamps to history
setopt HIST_EXPIRE_DUPS_FIRST # Expire duplicates first
setopt HIST_FIND_NO_DUPS      # Don't display duplicates during search
setopt HIST_IGNORE_DUPS       # Don't record duplicates
setopt HIST_IGNORE_ALL_DUPS   # Delete old duplicates
setopt HIST_IGNORE_SPACE      # Don't record commands starting with space
setopt HIST_SAVE_NO_DUPS      # Don't save duplicates
setopt HIST_VERIFY            # Show expanded history before executing
setopt SHARE_HISTORY          # Share history between sessions
setopt APPEND_HISTORY         # Append to history
setopt INC_APPEND_HISTORY     # Write immediately
setopt HIST_REDUCE_BLANKS     # Remove extra blanks
setopt HIST_NO_STORE          # Don't store history commands

# ======================================== keybindings.zsh ========================================
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

# ======================================== completion.zsh ========================================
# ============================================================================
# COMPLETION SYSTEM - ULTRA ADVANCED
# ============================================================================

# Completion caching
zstyle ':completion::complete:*' use-cache on
zstyle ':completion::complete:*' cache-path ~/.zsh/cache

# Enhanced completion settings
zstyle ':completion:*' auto-description 'specify: %d'
zstyle ':completion:*' completer _expand _complete _correct _approximate
zstyle ':completion:*' format 'Completing %d'
zstyle ':completion:*' group-name ''
zstyle ':completion:*' menu select=2
# Colorize completions using default `ls` colors.
zstyle ':completion:*' list-colors ''

# Function to convert LSCOLORS (FreeBSD/macOS) to LS_COLORS (GNU/Linux) format
# Interactive converter: https://kjanat.github.io/lscolors/
convert_lscolors_to_ls_colors() {
    local lscolors="$1"
    local ls_colors=""

    # LSCOLORS format: pairs of foreground/background colors for each file type
    # Order: directory, symlink, socket, pipe, executable, block special, char special,
    #        executable with setuid, executable with setgid, directory writable by others with sticky,
    #        directory writable by others without sticky
    local file_types=("di" "ln" "so" "pi" "ex" "bd" "cd" "su" "sg" "tw" "ow")

    # Convert LSCOLORS color codes to ANSI codes
    local color_map=("a:30" "b:31" "c:32" "d:33" "e:34" "f:35" "g:36" "h:37" "A:1;30" "B:1;31" "C:1;32" "D:1;33" "E:1;34" "F:1;35" "G:1;36" "H:1;37" "x:0")

    for ((i=0; i<${#file_types[@]} && i*2+1<${#lscolors}; i++)); do
        local fg_char="${lscolors:$((i*2)):1}"
        local bg_char="${lscolors:$((i*2+1)):1}"
        local fg_code=""
        local bg_code=""

        # Find foreground color
        for color in "${color_map[@]}"; do
            if [[ "${color%%:*}" == "$fg_char" ]]; then
                fg_code="${color##*:}"
                break
            fi
        done

        # Find background color
        for color in "${color_map[@]}"; do
            if [[ "${color%%:*}" == "$bg_char" ]]; then
                bg_code="${color##*:}"
                # Convert to background code (add 10 to single digit, handle bold)
                if [[ "$bg_code" =~ ^[0-9]+$ ]]; then
                    bg_code="$(( bg_code + 10 ))"
                elif [[ "$bg_code" == 1\;* ]]; then
                    local bg_num="${bg_code##*;}"
                    bg_code="1;$(( bg_num + 10 ))"
                fi
                break
            fi
        done

        # Build LS_COLORS entry
        if [[ -n "$fg_code" && "$bg_char" != "x" ]]; then
            if [[ -n "$bg_code" && "$bg_char" != "x" ]]; then
                ls_colors="${ls_colors}${file_types[i]}=${fg_code};${bg_code}:"
            else
                ls_colors="${ls_colors}${file_types[i]}=${fg_code}:"
            fi
        fi
    done

    echo "${ls_colors%:}"  # Remove trailing colon
}

# Use LS_COLORS if available, convert LSCOLORS if available, with fallback for portability
if [[ -n "$LS_COLORS" ]]; then
    # ZSH-specific parameter expansion to split LS_COLORS by colons
    zstyle ':completion:*' list-colors "${(@s/:/)LS_COLORS}"
    zstyle ':completion:*:default' list-colors "${(@s/:/)LS_COLORS}"
elif [[ -n "$LSCOLORS" ]]; then
    # FreeBSD/TrueNAS uses LSCOLORS - convert to LS_COLORS format
    converted_colors=$(convert_lscolors_to_ls_colors "$LSCOLORS")
    if [[ -n "$converted_colors" ]]; then
        zstyle ':completion:*' list-colors "${(@s/:/)converted_colors}"
        zstyle ':completion:*:default' list-colors "${(@s/:/)converted_colors}"
    else
        # Fallback if conversion fails
        zstyle ':completion:*' list-colors 'di=34:ln=35:so=32:pi=33:ex=31:bd=34;46:cd=34;43:su=0;41:sg=0;46:tw=0;42:ow=0;43:'
    fi
else
    # Fallback to default colors if neither LS_COLORS nor LSCOLORS is set
    zstyle ':completion:*' list-colors 'di=34:ln=35:so=32:pi=33:ex=31:bd=34;46:cd=34;43:su=0;41:sg=0;46:tw=0;42:ow=0;43:'
fi
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
            if [[ "$host_field" == [[]*[]]:* ]]; then
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
            if [[ "$host_field" == [[]*[]]:* ]]; then
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
        zstyle ':completion:*:(ssh|scp|rsync|slogin|sftp):*:hosts-domain' ignored-patterns '<->.<->.<->.<->' '^[[-:alnum:]]##(.[-[:alnum:]]##)##' '*@*'
        zstyle ':completion:*:(ssh|scp|rsync|slogin|sftp):*:hosts-ipaddr' ignored-patterns '^(<->.<->.<->.<->|(|::)([[:xdigit:].]##:(#c,2))##(|%*))' '127.0.0.<->' '255.255.255.255' '::1' 'fe80::*'

        printf "\033[2mSSH completion loaded %d hosts\033[0m\n" ${#h[@]}
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
                if [[ "$host_field" == [[]*[]]:* ]]; then
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

# Load bash completion compatibility
autoload -U +X bashcompinit && bashcompinit

# Custom completion functions
_zfs_completion() {
    local -a datasets
    datasets=("${(@f)$(zfs list -H -o name 2>/dev/null)}")
    compadd "${datasets[@]}"
}
compdef _zfs_completion zfs

_zpool_completion() {
    local -a pools
    pools=("${(@f)$(zpool list -H -o name 2>/dev/null)}")
    compadd "${pools[@]}"
}
compdef _zpool_completion zpool

# ======================================== prompt.zsh ========================================
# ============================================================================
# PROMPT WITH STATUS INDICATORS
# ============================================================================

autoload -U colors && colors
autoload -Uz vcs_info
autoload -Uz add-zsh-hook

# Git status with detailed info
zstyle ':vcs_info:git:*' formats ' %F{yellow}⎇ %b%f%c%u'
zstyle ':vcs_info:git:*' actionformats ' %F{yellow}⎇ %b%f %F{red}(%a)%f%c%u'
zstyle ':vcs_info:git:*' stagedstr ' %F{green}●%f'
zstyle ':vcs_info:git:*' unstagedstr ' %F{red}●%f'
zstyle ':vcs_info:*' check-for-changes true
zstyle ':vcs_info:*' enable git

# System load indicator
_prompt_get_load() {
	local load load_int
	load=$(uptime | awk -F 'load averages: ' '{print $2}' | awk '{print $1}' | sed 's/,//')
	load_int=${load%.*}
	if [[ $load_int -gt 2 ]]; then
		printf "\033[31m⚠ %s\033[0m\n" "$load"
	elif [[ $load_int -gt 1 ]]; then
		printf "\033[33m⚡ %s\033[0m\n" "$load"
	else
		printf "\033[32m✓ %s\033[0m\n" "$load"
	fi
}

# ZFS pool health indicator
_prompt_get_zfs() {
	local zfs_status_count
	zfs_status_count=$(zpool status -x 2>/dev/null | grep -v "errors: No known data errors\|all pools are healthy" | grep -icE "(errors|degraded|offline|repaired|unrecoverable)")
	if [[ $zfs_status_count -gt 0 ]]; then
		echo "%F{red}⚠  ZFS%f"
	else
		echo "%F{green}✓ ZFS%f"
	fi
}

# Battery status (ACPI on FreeBSD)
_prompt_get_battery() {
	if command -v acpiconf >/dev/null 2>&1; then
		local battery
		battery=$(acpiconf -i 0 2>/dev/null | awk '/Remaining capacity:/ {gsub(/%/, "", $3); print $3}')
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

# Precmd hook (uses add-zsh-hook to avoid clobbering other hooks)
_truenas_precmd() {
	vcs_info
	typeset -g _load_info="$(_prompt_get_load)"
	typeset -g _zfs_info="$(_prompt_get_zfs)"
	typeset -g _battery_info="$(_prompt_get_battery)"
}
add-zsh-hook precmd _truenas_precmd

# Multi-line prompt
PROMPT='%F{cyan}╭─[%f%F{green}%n@%m%f%F{cyan}]─[%f%F{blue}%~%f%F{cyan}]${vcs_info_msg_0_}─[%f${_load_info}%F{cyan}]─[%f${_zfs_info}%F{cyan}]${_battery_info:+─[}${_battery_info}${_battery_info:+]}
%F{cyan}╰─%f%(?.%F{green}➤%f.%F{red}➤%f) '

# Right prompt with time, exit code, and job count
RPROMPT='%(1j.%F{magenta}⚙ %j%f .)%(?..%F{red}✗ %?%f )%F{cyan}⌚ %D{%H:%M:%S}%f'

# ======================================== functions.zsh ========================================
# ============================================================================
# FUNCTIONS
# ============================================================================

# Named directory hashes
hash -d freenas=/mnt/PoolONE/FreeNAS
hash -d pools=/mnt
hash -d logs=/var/log
hash -d etc=/etc

# FreeBSD memory info (aliased as 'free')
freebsd_meminfo() {
	local physmem
	physmem=$(sysctl -n hw.physmem 2>/dev/null) || return 1
	local pagesize active inactive wired cached free_pages
	pagesize=$(sysctl -n hw.pagesize)
	active=$(sysctl -n vm.stats.vm.v_active_count)
	inactive=$(sysctl -n vm.stats.vm.v_inactive_count)
	wired=$(sysctl -n vm.stats.vm.v_wire_count)
	cached=$(sysctl -n vm.stats.vm.v_cache_count 2>/dev/null || echo 0)
	free_pages=$(sysctl -n vm.stats.vm.v_free_count)

	printf "%-12s %s\n" "Total:" "$((physmem / 1024 / 1024)) MB"
	printf "%-12s %s\n" "Active:" "$((active * pagesize / 1024 / 1024)) MB"
	printf "%-12s %s\n" "Inactive:" "$((inactive * pagesize / 1024 / 1024)) MB"
	printf "%-12s %s\n" "Wired:" "$((wired * pagesize / 1024 / 1024)) MB"
	printf "%-12s %s\n" "Cached:" "$((cached * pagesize / 1024 / 1024)) MB"
	printf "%-12s %s\n" "Free:" "$((free_pages * pagesize / 1024 / 1024)) MB"
}

# ZFS pool status (called from startup banner)
get_zfs_status() {
	if ! command -v zpool >/dev/null 2>&1; then
		return 0
	fi
	local pool_count
	pool_count=$(zpool list -H -o name 2>/dev/null | wc -l | tr -d ' ')
	if [[ $pool_count -eq 0 ]]; then
		return 0
	fi
	local unhealthy
	unhealthy=$(zpool list -H -o name,health 2>/dev/null | grep -v ONLINE)
	if [[ -n "$unhealthy" ]]; then
		echo "⚠️  ZFS pools need attention:"
		echo "$unhealthy" | while IFS=$'\t' read -r name health; do
			printf "   %s: %s\n" "$name" "$health"
		done
	else
		printf "✅ %d ZFS pool(s) healthy\n" "$pool_count"
	fi
}

# Extract any archive
extract() {
	if [[ -z "$1" ]]; then
		echo "Usage: extract <file>"
		return 1
	fi
	if [[ ! -f "$1" ]]; then
		echo "'$1' is not a file"
		return 1
	fi
	case "$1" in
	*.tar.bz2) tar xjf "$1" ;;
	*.tar.gz) tar xzf "$1" ;;
	*.tar.xz) tar xJf "$1" ;;
	*.bz2) bunzip2 "$1" ;;
	*.gz) gunzip "$1" ;;
	*.tar) tar xf "$1" ;;
	*.tbz2) tar xjf "$1" ;;
	*.tgz) tar xzf "$1" ;;
	*.zip) unzip "$1" ;;
	*.Z) uncompress "$1" ;;
	*.7z) 7z x "$1" ;;
	*.xz) xz -d "$1" ;;
	*)
		echo "Cannot extract '$1'"
		return 1
		;;
	esac
}

# Quick backup
backup() {
	if [[ -z "$1" ]]; then
		echo "Usage: backup <file>"
		return 1
	fi
	cp -a "$1" "${1}.bak.$(date +%Y%m%d%H%M%S)"
}

# Find files by name
ff() { find . -type f -iname "*${1}*" 2>/dev/null; }

# Find files by content
ftext() { grep -rn --color=auto "$1" . 2>/dev/null; }

# Simple calculator
calc() { python3 -c "print($*)" 2>/dev/null || awk "BEGIN{print $*}"; }

# Password generator
genpass() {
	local len="${1:-20}"
	LC_ALL=C tr -dc 'A-Za-z0-9!@#$%^&*' </dev/urandom | head -c "$len"
	echo
}

# Simple HTTP file server
serve() {
	local port="${1:-8000}"
	python3 -m http.server "$port" 2>/dev/null || {
		echo "python3 not found; install with: pkg install python3"
		return 1
	}
}

# ======================================== plugins.zsh ========================================
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

			printf "% -20s % -15s %s\n" "$plugin_name" "$status" "$file_status"
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
	if [[ -z "$ZSH_PLUGIN_DIR"/*(N[1]) ]]; then
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
	} &

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

