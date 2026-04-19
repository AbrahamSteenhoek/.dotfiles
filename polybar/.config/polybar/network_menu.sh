#!/bin/bash

# Debug notification
dunstify -t 1000 "Network Menu" "Launching..."

# Get the Wi-Fi interface
wifi_interface=$(ls /sys/class/net | grep -E "^(wlp|wlan)" | head -n 1)


# Function to run wpa_cli (NO SUDO NEEDED NOW)
run_wpa() {
    /usr/sbin/wpa_cli -i "$wifi_interface" "$@"
}

# Scan for networks
run_wpa scan > /dev/null
sleep 2

# Get scan results and format them
scan_results=$(run_wpa scan_results | awk 'NR>2 {
    ssid=""; for(i=5; i<=NF; i++) ssid=(ssid $i " ");
    sub(/ $/, "", ssid);
    if (ssid != "") print ssid " (" $3 " dBm)"
}' | sort -u)

if [ -z "$scan_results" ]; then
    dunstify -u critical "Network" "No networks found. Ensure Wi-Fi is on."
    exit 1
fi

# Choose SSID using rofi
chosen_line=$(echo -e "$scan_results" | rofi -dmenu -i -p "Select Wifi" -theme-str 'window { width: 40%; } listview { lines: 15; }')

if [ -n "$chosen_line" ]; then
    chosen_ssid=$(echo "$chosen_line" | sed 's/ (.* dBm)$//')
    
    # Get password using rofi
    password=$(rofi -dmenu -password -p "Password for $chosen_ssid" -theme-str 'window { width: 30%; } listview { lines: 0; }')
    
    if [ -n "$password" ]; then
        # Add network and set credentials
        net_id=$(run_wpa add_network | tail -n 1)
        run_wpa set_network "$net_id" ssid "\"$chosen_ssid\""
        run_wpa set_network "$net_id" psk "\"$password\""
        run_wpa enable_network "$net_id"
        run_wpa select_network "$net_id"
        run_wpa save_config
        
        dunstify -a "Network" "Connecting to $chosen_ssid..." -t 5000
    fi
fi
