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
