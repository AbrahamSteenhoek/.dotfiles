#!/bin/bash

# Get Wi-Fi interface name
wifi_interface=$(ls /sys/class/net | grep -E "^(wlp|wlan)" | head -n 1)

# Get Wi-Fi status
wifi_status="down"
if [ -n "$wifi_interface" ]; then
    if [ "$(cat /sys/class/net/$wifi_interface/operstate 2>/dev/null)" = "up" ]; then
        wifi_status="up"
    fi
fi

# Get Wi-Fi SSID
wifi_name=""
if [ "$wifi_status" = "up" ]; then
    # Try iwctl (iwd)
    if command -v iwctl >/dev/null 2>&1; then
        wifi_name=$(iwctl station "$wifi_interface" show | grep "Connected network" | awk '{print $NF}')
    fi

    # Fallback to iwgetid
    if [ -z "$wifi_name" ]; then
        wifi_name=$(/usr/sbin/iwgetid -r "$wifi_interface" 2>/dev/null)
    fi

    # Fallback to wpa_cli
    if [ -z "$wifi_name" ]; then
        wifi_name=$(/usr/sbin/wpa_cli status -i "$wifi_interface" 2>/dev/null | grep "^ssid=" | cut -d= -f2)
    fi
fi
# Get Ethernet interface name
eth_interface=$(ls /sys/class/net | grep -E "^(enp|eno|eth)" | head -n 1)


# Get Ethernet status
eth_status="down"
if [ -n "$eth_interface" ]; then
    if [ "$(cat /sys/class/net/$eth_interface/operstate 2>/dev/null)" = "up" ]; then
        eth_status="up"
    fi
fi

# Output results
if [ "$eth_status" = "up" ]; then
    echo "Eth: Connected"
elif [ "$wifi_status" = "up" ]; then
    if [ -n "$wifi_name" ]; then
        echo "Wifi: $wifi_name"
    else
        echo "Wifi: Connected"
    fi
else
    echo "Offline"
fi
