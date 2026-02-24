# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/),
and this project adheres to [Semantic Versioning](https://semver.org/).

## [Unreleased]

### Added

- `get_zfs_status` function for startup ZFS health check
- `freebsd_meminfo` function backing `free` alias
- `extract`, `backup`, `ff`, `ftext`, `calc`, `genpass`, `serve` utility functions
- Named directory hashes (`~freenas`, `~pools`, `~logs`, `~etc`)
- `listening` as a proper function with correct awk quoting
- `concurrency` control to CI workflow to prevent race conditions
- `fpath` setup for `/usr/local/share/zsh/site-functions` before `compinit`

### Changed

- CI workflow uses `popsiclestick/gist-sync-action@v1.2.0` instead of manual gist push
- CI captures `SOURCE_SHA`/`SOURCE_MSG` via `$GITHUB_ENV` before branch switch
- CI `secrets` context in step `if:` replaced with job-level `env` (GitHub Actions requirement)
- CI flat-branch README uses `fetch` instead of `curl` (FreeBSD-native)
- `iostat` alias renamed to `ziostat` to avoid shadowing system `iostat(8)`
- `iotop` fallback uses `command iostat` to bypass alias resolution
- Prompt uses `add-zsh-hook precmd` instead of overriding `precmd()` directly
- Prompt functions prefixed with `_prompt_` to avoid namespace collisions
- `help()` trimmed to only list commands that actually exist
- `path` alias uses `print -l ${(s/:/)PATH}` (ZSH-native) instead of `echo -e`
- `myip` alias avoids printf format string injection
- LSCOLORS converter arithmetic fixed (`bg_code` extraction uses proper parameter expansion)
- SSH known_hosts parser no longer appends trailing space to hostnames
- Startup banner uptime/time emoji labels swapped to match actual values

### Removed

- Blocking `ping` call from prompt `precmd` (froze shell when offline)
- Redundant `compinit` call in `completion.zsh` (already cached in `truenas.zsh`)
- `GREP_OPTIONS` export (deprecated, nonfunctional on FreeBSD)
- `LESSOPEN`/`LESSCLOSE` exports (reference `/usr/bin/lesspipe` which doesn't exist on FreeBSD)
- Dead `uptime -p` GNU branch (never runs on FreeBSD)
- `ls -lXBh` alias (GNU-only flags, errors on FreeBSD)
- `speedtest` alias (supply-chain risk: pipes remote code into `python`)
- Duplicate `rm`/`cp`/`mv`/`ln` alias definitions
- Portable SSH completion function and dead `else` branch (ZSH always has `$ZSH_VERSION`)
- Manual gist push step from CI workflow (replaced by action)

### Fixed

- `lib/functions.zsh` was a broken 12-line fragment executing bare commands on every `source`
- `mapfile` (bash-only) in ZFS/zpool completion replaced with ZSH parameter expansion
- `compgen` (bash-only) in plugin auto-loader replaced with ZSH glob qualifier
- `dmesg` alias used `--color=always` (Linux-only, errors on FreeBSD)
- `listening` alias had broken triple-quote awk and shell-expanded `$` variables
- Prompt battery bracket was never closed when battery info was present
- `fpath` was modified after `compinit`, so additional completions never loaded

### Security

- Plugin directory `/tmp` fallback now checked: `compgen` removal fixes silent bypass of auto-load guard

[Unreleased]: https://github.com/kjanat/truenas-zshrc/compare/66c1fcb...HEAD
