#!/bin/bash

# Get the default sink ID
default_sink_id=$(wpctl status | sed -n '/Sinks:/,/Sources:/p' | grep -E '^\s*\*.*[0-9]+\.' | grep -oE "[0-9]+" | head -n 1)

# Get the list of all sinks
# 1. Get the Sinks section
# 2. Filter for lines containing sink IDs
# 3. Clean up leading spaces and dots
all_sinks=$(wpctl status | sed -n '/Sinks:/,/Sources:/p' | grep -E '[0-9]+\.' | sed 's/^[[:space:]]*//')

# Prepare the final list for rofi
final_list=""

# First, find and format the selected sink
selected_sink_line=$(echo "$all_sinks" | grep -E "^(\*)?[[:space:]]*$default_sink_id\.")
if [ -n "$selected_sink_line" ]; then
    # Remove the '*' if it exists and add the [SELECTED] label
    clean_selected=$(echo "$selected_sink_line" | sed 's/^\*//; s/^[[:space:]]*//')
    final_list="$clean_selected [SELECTED]"
fi

# Then, add all other sinks
while IFS= read -r line; do
    # Skip the selected sink (we already added it)
    id=$(echo "$line" | grep -oE "[0-9]+" | head -n 1)
    if [ "$id" != "$default_sink_id" ]; then
        clean_line=$(echo "$line" | sed 's/^\*//; s/^[[:space:]]*//')
        final_list="$final_list\n$clean_line"
    fi
done <<< "$all_sinks"

# Pass the list to rofi
selected=$(echo -e "$final_list" | rofi -dmenu -i -p "󰓃 Audio Output" -theme-str 'window { width: 50%; } listview { lines: 10; }')

# If the user made a selection
if [ -n "$selected" ]; then
    # Extract the ID from the selected line
    id=$(echo "$selected" | grep -oE "[0-9]+" | head -n 1)
    
    # Set the default sink
    wpctl set-default "$id"
    
    # Send a notification
    device_name=$(echo "$selected" | sed 's/^[0-9.]*[[:space:]]*//; s/\[vol:.*//; s/\[SELECTED\]//')
    dunstify -a "System" -i audio-speakers "Output Switched" "$device_name" -t 2000
fi
