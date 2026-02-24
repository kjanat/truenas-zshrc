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
alias lr='ls -R'         # recursive
alias lt='ls -ltrh'      # sort by date
alias lk='ls -lSrh'      # sort by size
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
