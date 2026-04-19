#!/usr/bin/env bash

echo "--- STARTING DEEP IWD WIFI RESET ---"

echo "1. Killing all networking conflicts..."
# We kill wpa_supplicant specifically to let IWD take total control
sudo killall -9 iwd wpa_supplicant dhcpcd udhcpc 2>/dev/null

echo "2. Forcing PCI bus rescan for the Intel wireless card..."
echo 1 | sudo tee /sys/class/pci_bus/0000:00/rescan

echo "3. Reloading iwlwifi modules to clear firmware lockups..."
sudo modprobe -r iwlmvm iwlwifi
sudo modprobe iwlwifi
sleep 2

echo "4. Detecting current wireless interface name..."
INTERFACE=$(ls /sys/class/net | grep '^w' | head -n 1)

if [ -z "$INTERFACE" ]; then
    echo "CRITICAL ERROR: No wireless interface detected."
    exit 1
fi
echo "   -> Found interface: $INTERFACE"

echo "5. Bringing $INTERFACE up and starting IWD daemon..."
sudo ip link set "$INTERFACE" up
sudo systemctl start iwd

echo "6. Triggering IWD connection to 'SteenBeens'..."
# This uses the non-interactive iwctl command to connect
sudo iwctl station "$INTERFACE" connect SteenBeens

echo "7. Waiting for IWD to finalize association..."
sleep 4

echo "8. Requesting DHCP lease for the new link..."
sudo dhcpcd "$INTERFACE" || sudo udhcpc -i "$INTERFACE"

echo "--- RESET COMPLETE ---"
echo "Connection Status:"
iwctl station "$INTERFACE" show | grep -E "State|Connected network"
ip addr show "$INTERFACE" | grep "inet "
