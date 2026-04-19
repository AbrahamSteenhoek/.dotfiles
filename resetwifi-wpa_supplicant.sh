#!/usr/bin/env bash

echo "--- STARTING DEEP WIFI RESET ---"

echo "1. Killing conflicting services (IWD, wpa_supplicant, DHCP clients)..."
sudo killall -9 iwd wpa_supplicant dhcpcd udhcpc 2>/dev/null

echo "2. Forcing PCI bus rescan to wake up dormant hardware..."
echo 1 | sudo tee /sys/class/pci_bus/0000:00/rescan

echo "3. Reloading iwlwifi kernel modules to clear firmware hangs..."
sudo modprobe -r iwlmvm iwlwifi
sudo modprobe iwlwifi
sleep 2

echo "4. Detecting current wireless interface name..."
INTERFACE=$(ls /sys/class/net | grep '^w' | head -n 1)

if [ -z "$INTERFACE" ]; then
    echo "CRITICAL ERROR: No wireless interface detected after hardware rescan."
    exit 1
fi

echo "   -> Found interface: $INTERFACE"

echo "5. Flushing $INTERFACE and bringing link UP..."
sudo ip link set "$INTERFACE" down
sudo ip addr flush dev "$INTERFACE"
sudo ip link set "$INTERFACE" up

echo "6. Initializing wpa_supplicant handshake for 'SteenBeens'..."
sudo wpa_supplicant -B -i "$INTERFACE" -c /etc/wpa_supplicant/wpa_supplicant.conf

echo "7. Waiting for security negotiation..."
sleep 5

echo "8. Requesting DHCP lease from router..."
sudo dhcpcd "$INTERFACE" || sudo udhcpc -i "$INTERFACE"

echo "--- RESET COMPLETE ---"
echo "Current state of $INTERFACE:"
ip addr show "$INTERFACE" | grep "inet "
