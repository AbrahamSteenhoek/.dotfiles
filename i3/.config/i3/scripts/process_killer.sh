#!/bin/bash

# Get the top 15 processes by CPU usage
# Format: PID, CPU%, MEM%, COMMAND
# 1. ps aux: list all processes
# 2. --sort=-%cpu: sort by CPU usage descending
# 3. head -n 16: get header + top 15
# 4. awk: format into a nice table for rofi
processes=$(ps aux --sort=-%cpu | head -n 16 | awk 'NR>1 {printf "%-7s | %-5s | %-5s | %s\n", $2, $3"%", $4"%", $11}')

# Pass the list to rofi
# Header explains the columns
selected=$(echo -e "$processes" | rofi -dmenu -i -p "󰆚 Kill Process" -mesg "PID     | CPU   | MEM   | COMMAND" -theme-str 'window { width: 60%; } listview { lines: 15; }' -font "JetBrainsMono Nerd Font 10")

# If the user made a selection
if [ -n "$selected" ]; then
    # Extract the PID (the first column)
    pid=$(echo "$selected" | awk '{print $1}')
    
    # Get the process name for the notification
    name=$(echo "$selected" | awk '{print $NF}' | xargs basename)
    
    # Kill the process
    if kill "$pid"; then
        dunstify -u critical -a "System" -i process-stop "Process Killed" "Terminated $name (PID: $pid)" -t 2000
    else
        # If standard kill fails, offer a warning
        dunstify -u critical -a "System" -i dialog-error "Failed to Kill" "Could not terminate $name (PID: $pid)" -t 2000
    fi
fi
