echo "🔒 Security Check:"

echo "=== Failed Login Attempts ==="
grep "Failed password" /var/log/auth.log 2>/dev/null | tail -5 || echo "No auth.log found"

echo "=== Open Ports ==="
netstat -4lCna --libxo json \
  | jq -r '["PROTOCOL", "ADDRESS", "PORT", "STATE"], (.statistics.socket[] | select(.["tcp-state"] != null and (if .["tcp-state"] | type == "string" then .["tcp-state"] | contains("LISTEN") else false end)) | [.protocol, .local.address, .local.port, .["tcp-state"]]) | @tsv' \
  | sort -nk3 -k2 -k1 \
  | column -t

echo "=== Root Login Sessions ==="
