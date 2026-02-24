#!/usr/bin/env bash
# Inlines all source "${0:A:h}/lib/*.zsh" directives into a single flat file.
# Usage: scripts/flatten.sh > truenas-flat.zsh
set -euo pipefail

root="$(cd "$(dirname "$0")/.." && pwd)"
entry="$root/truenas.zsh"

while IFS= read -r line; do
	# Match: source "${0:A:h}/lib/something.zsh"
	if [[ "$line" =~ ^source\ \"\$\{0:A:h\}/lib/(.+\.zsh)\"$ ]]; then
		lib_file="$root/lib/${BASH_REMATCH[1]}"
		if [[ -f "$lib_file" ]]; then
			echo ""
			echo "# ======================================== ${BASH_REMATCH[1]} ========================================"
			cat "$lib_file"
		else
			echo "# WARNING: $lib_file not found" >&2
			echo "$line"
		fi
	else
		echo "$line"
	fi
done <"$entry"
