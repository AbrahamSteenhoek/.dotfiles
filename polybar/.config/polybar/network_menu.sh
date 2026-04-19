#!/bin/bash

# Debug notification
dunstify -t 1000 "Network Menu" "Launching..."

# Get the Wi-Fi interface
wifi_interface=$(ls /sys/class/net | grep -E "^(wlp|wlan)" | head -n 1)

# Function to run iwctl
run_iwctl() {
    iwctl "$@"
}

# Scan for networks
run_iwctl station "$wifi_interface" scan
sleep 1

# Get scan results and format them
scan_results=$(run_iwctl station "$wifi_interface" get-networks | awk 'NR>4 {
    ssid=""; for(i=1; i<=NF-2; i++) ssid=(ssid $i " ");
    sub(/ $/, "", ssid);
    if (ssid != "") print ssid " (" $(NF-1) ")"
}' | sort -u)

if [ -z "$scan_results" ]; then
    dunstify -u critical "Network" "No networks found. Ensure Wi-Fi is on."
    exit 1
fi

# Choose SSID using rofi
chosen_line=$(echo -e "$scan_results" | rofi -dmenu -i -p "Select Wifi" -theme-str 'window { width: 40%; } listview { lines: 15; }')

if [ -n "$chosen_line" ]; then
    chosen_ssid=$(echo "$chosen_line" | sed 's/ (.*)$//')
    
    # Get password using rofi
    password=$(rofi -dmenu -password -p "Password for $chosen_ssid" -theme-str 'window { width: 30%; } listview { lines: 0; }')
    
    if [ -n "$password" ]; then
        # Connect using iwctl
        if iwctl station "$wifi_interface" connect "$chosen_ssid" --passphrase "$password"; then
             dunstify -a "Network" "Connecting to $chosen_ssid..." -t 5000
        else
             dunstify -u critical "Network" "Failed to connect to $chosen_ssid"
        fi
    fi
fi
