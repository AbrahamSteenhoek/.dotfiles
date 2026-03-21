#!/bin/bash

# Increment/decrement by 5%
inc_dec=5

# Maximum volume allowed (1.0 = 100%, 1.5 = 150%, etc.)
max_vol_limit=1.0

# Function to get current volume as a float
get_vol_float() {
    wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{print $2}'
}

# Function to check if muted
is_muted() {
    wpctl get-volume @DEFAULT_AUDIO_SINK@ | grep -q '\[MUTED\]'
}

current_vol=$(get_vol_float)

case $1 in
    up)
        new_vol=$(awk "BEGIN {print $current_vol + $inc_dec/100}")
        is_over=$(awk "BEGIN {print ($new_vol > $max_vol_limit)}")
        if [ "$is_over" -eq 1 ]; then
            new_vol=$max_vol_limit
        fi
        wpctl set-volume @DEFAULT_AUDIO_SINK@ $new_vol
        ;;
    down)
        new_vol=$(awk "BEGIN {print $current_vol - $inc_dec/100}")
        is_under=$(awk "BEGIN {print ($new_vol < 0)}")
        if [ "$is_under" -eq 1 ]; then
            new_vol=0
        fi
        wpctl set-volume @DEFAULT_AUDIO_SINK@ $new_vol
        ;;
    mute)
        wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
        ;;
esac

# Refresh volume after change
current_vol=$(get_vol_float)
display_vol=$(awk "BEGIN {printf \"%.0f\", $current_vol * 100}")
bar_val=$(awk "BEGIN {printf \"%.0f\", ($current_vol / $max_vol_limit) * 100}")

# Icon logic
if is_muted; then
    icon="audio-volume-muted"
    muted=" [MUTED]"
elif [ "$display_vol" -ge 66 ]; then
    icon="audio-volume-high"
    muted=""
elif [ "$display_vol" -ge 33 ]; then
    icon="audio-volume-medium"
    muted=""
elif [ "$display_vol" -gt 0 ]; then
    icon="audio-volume-low"
    muted=""
else
    icon="audio-volume-muted"
    muted=""
fi

# Notify with dunstify
dunstify -h string:x-dunst-stack-tag:volume \
         -h int:value:"$bar_val" \
         -i "$icon" \
         "Volume: ${display_vol}%${muted}" \
         -a "VolumeController" \
         -t 1500

# Signal i3status to update (non-blocking)
killall -SIGUSR1 i3status 2>/dev/null &
