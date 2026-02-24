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
