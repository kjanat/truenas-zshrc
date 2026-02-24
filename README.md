# truenas-zshrc

ZSH configuration for TrueNAS CORE (FreeBSD-based). Modular setup with ZFS-aware prompt, system monitoring, and FreeBSD-native completions.

## Install

All `lib/*.zsh` modules are auto-inlined into a single file on the [`flat`](https://github.com/kjanat/truenas-zshrc/tree/flat) branch by CI.

### From csh/tcsh (TrueNAS CORE default)

```csh
fetch -qo ~/.zshrc.truenas https://raw.githubusercontent.com/kjanat/truenas-zshrc/flat/truenas.zsh
echo 'source ~/.zshrc.truenas' >> ~/.zshrc
```

### From sh

```sh
fetch -qo ~/.zshrc.truenas https://raw.githubusercontent.com/kjanat/truenas-zshrc/flat/truenas.zsh
echo 'source ~/.zshrc.truenas' >> ~/.zshrc
```

### From zsh

```zsh
fetch -qo ~/.zshrc.truenas https://raw.githubusercontent.com/kjanat/truenas-zshrc/flat/truenas.zsh
echo 'source ~/.zshrc.truenas' >> ~/.zshrc
```

Or auto-update on every shell start (add to `.zshrc`):

```zsh
source <(fetch -qo - https://raw.githubusercontent.com/kjanat/truenas-zshrc/flat/truenas.zsh)
```

### From bash

```bash
curl -fsSLo ~/.zshrc.truenas https://raw.githubusercontent.com/kjanat/truenas-zshrc/flat/truenas.zsh
echo 'source ~/.zshrc.truenas' >> ~/.zshrc
```

### Git clone (any shell)

```sh
git clone https://github.com/kjanat/truenas-zshrc.git ~/.zsh/truenas
echo 'source ~/.zsh/truenas/truenas.zsh' >> ~/.zshrc
```

## Raw URLs

| File                  | URL                                                                                 |
| --------------------- | ----------------------------------------------------------------------------------- |
| `truenas.zsh`         | `https://raw.githubusercontent.com/kjanat/truenas-zshrc/master/truenas.zsh`         |
| `lib/options.zsh`     | `https://raw.githubusercontent.com/kjanat/truenas-zshrc/master/lib/options.zsh`     |
| `lib/aliases.zsh`     | `https://raw.githubusercontent.com/kjanat/truenas-zshrc/master/lib/aliases.zsh`     |
| `lib/history.zsh`     | `https://raw.githubusercontent.com/kjanat/truenas-zshrc/master/lib/history.zsh`     |
| `lib/keybindings.zsh` | `https://raw.githubusercontent.com/kjanat/truenas-zshrc/master/lib/keybindings.zsh` |
| `lib/completion.zsh`  | `https://raw.githubusercontent.com/kjanat/truenas-zshrc/master/lib/completion.zsh`  |
| `lib/prompt.zsh`      | `https://raw.githubusercontent.com/kjanat/truenas-zshrc/master/lib/prompt.zsh`      |
| `lib/functions.zsh`   | `https://raw.githubusercontent.com/kjanat/truenas-zshrc/master/lib/functions.zsh`   |
| `lib/plugins.zsh`     | `https://raw.githubusercontent.com/kjanat/truenas-zshrc/master/lib/plugins.zsh`     |

## Structure

```tree
truenas.zsh          # Entry point (env, PATH, startup banner)
lib/
  options.zsh        # Shell options (auto_cd, globbing, jobs, etc.)
  aliases.zsh        # Aliases (ls, nav, ZFS, network, archives)
  history.zsh        # History config (100k lines, dedup, shared)
  keybindings.zsh    # Emacs-style key bindings
  completion.zsh     # Completion system, SSH hosts, syntax highlighting
  prompt.zsh         # Multi-line prompt with ZFS/load/network indicators
  functions.zsh      # Utility functions (security checks, system info)
  plugins.zsh        # Plugin manager (install/load/update from git)
```

## Features

- ZFS-aware prompt (pool health indicator, scrub status)
- System load/network/battery status in prompt
- SSH host completion from `~/.ssh/config` and `known_hosts`
- FreeBSD-native (LSCOLORS/LS_COLORS conversion)
- Plugin manager with git-based install/update
- 100+ aliases for ZFS, networking, navigation, and system admin
