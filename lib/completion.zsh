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
            if [[ "$host_field" == "["* "]:"* ]]; then
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
            if [[ "$host_field" == "["* "]:"* ]]; then
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
                if [[ "$host_field" == "["* "]:"* ]]; then
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
