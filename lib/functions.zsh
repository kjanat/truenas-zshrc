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

	printf "%-12s %s\n" "Total:" "$(( physmem / 1024 / 1024 )) MB"
	printf "%-12s %s\n" "Active:" "$(( active * pagesize / 1024 / 1024 )) MB"
	printf "%-12s %s\n" "Inactive:" "$(( inactive * pagesize / 1024 / 1024 )) MB"
	printf "%-12s %s\n" "Wired:" "$(( wired * pagesize / 1024 / 1024 )) MB"
	printf "%-12s %s\n" "Cached:" "$(( cached * pagesize / 1024 / 1024 )) MB"
	printf "%-12s %s\n" "Free:" "$(( free_pages * pagesize / 1024 / 1024 )) MB"
}

# ZFS pool status (called from startup banner)
get_zfs_status() {
	if ! command -v zpool > /dev/null 2>&1; then
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
		*.tar.gz)  tar xzf "$1" ;;
		*.tar.xz)  tar xJf "$1" ;;
		*.bz2)     bunzip2 "$1" ;;
		*.gz)      gunzip "$1" ;;
		*.tar)     tar xf "$1" ;;
		*.tbz2)    tar xjf "$1" ;;
		*.tgz)     tar xzf "$1" ;;
		*.zip)     unzip "$1" ;;
		*.Z)       uncompress "$1" ;;
		*.7z)      7z x "$1" ;;
		*.xz)      xz -d "$1" ;;
		*) echo "Cannot extract '$1'" ; return 1 ;;
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
	LC_ALL=C tr -dc 'A-Za-z0-9!@#$%^&*' < /dev/urandom | head -c "$len"
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
