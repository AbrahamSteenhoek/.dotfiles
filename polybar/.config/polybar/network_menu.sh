#!/bin/bash

wifi_interface=$(ip link | grep -oE "wlp[0-9s]+")

# Scan for networks
/usr/sbin/wpa_cli -i $wifi_interface scan > /dev/null
sleep 2

# Get scan results
scan_results=$(/usr/sbin/wpa_cli -i $wifi_interface scan_results | awk 'NR>2 {print $NF}')

# Choose SSID using rofi
chosen_ssid=$(echo -e "$scan_results" | rofi -dmenu -i -p "Select Wifi" -theme-str 'window { width: 30%; } listview { lines: 10; }')

if [ -n "$chosen_ssid" ]; then
    # Get password using rofi
    password=$(rofi -dmenu -password -p "Password for $chosen_ssid" -theme-str 'window { width: 30%; } listview { lines: 0; }')
    
    if [ -n "$password" ]; then
        # Connect using wpa_cli
        net_id=$(/usr/sbin/wpa_cli -i $wifi_interface add_network | tail -n 1)
        /usr/sbin/wpa_cli -i $wifi_interface set_network $net_id ssid "\"$chosen_ssid\""
        /usr/sbin/wpa_cli -i $wifi_interface set_network $net_id psk "\"$password\""
        /usr/sbin/wpa_cli -i $wifi_interface enable_network $net_id
        /usr/sbin/wpa_cli -i $wifi_interface save_config
        
        dunstify -a "Network" "Connecting to $chosen_ssid..." -t 3000
    fi
fi
