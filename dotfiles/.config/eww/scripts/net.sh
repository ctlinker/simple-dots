#!/usr/bin/env sh

# Change 'wlan0' to your actual interface (check with 'ip link')
INTERFACE="wlan0"

get_bytes() {
    grep "$INTERFACE" /proc/net/dev | awk '{print $2, $10}'
}

# Read initial values
read -r old_rx old_tx << EOF
$(get_bytes)
EOF

sleep 1

# Read new values
read -r new_rx new_tx << EOF
$(get_bytes)
EOF

# Calculate KiB/s
rx_speed=$(( (new_rx - old_rx) / 1024 ))
tx_speed=$(( (new_tx - old_tx) / 1024 ))

# Format for Eww JSON
printf '{"rx": "%d", "tx": "%d"}\n' "$rx_speed" "$tx_speed"