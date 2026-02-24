# ============================================================================
# ZSH OPTIONS - ALL THE POWER
# ============================================================================

# Directory navigation
setopt AUTO_CD              # cd by typing directory name
setopt AUTO_PUSHD           # Push old directory onto stack
setopt PUSHD_IGNORE_DUPS    # Don't push duplicates
setopt PUSHD_MINUS  # Exchange + and - for pushd
setopt CD_ABLE_VARS # Try expanding as variable
setopt PUSHD_SILENT # Don't print stack after pushd/popd

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
