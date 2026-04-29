#!/usr/bin/env bash

# Function for hydration and mindfulness
remember-to-breathe-notify() {
    while true; do
        # Sleep first so it doesn't trigger immediately on boot/script start
        sleep 3600s 
        
        notify-send "Self-Care Reminder" \
            "<b>An hour has elapsed.</b>\n<i>Drink some water, take a deep breath.</i>" \
            --icon=hint \
            --urgency=low \
            --category="health.reminder"
    done
}

# Function for fortunes
daily-fortune-notify() {
    while true; do
        notify-send "Daily Wisdom" "<i>$(fortune | head -n 2)</i>" --icon=dialog-information
        sleep 1800s 
    done
}

# Function for updates
daily-update-notify() {
    while true; do
        update_count=$(yay -Qu | wc -l)

        if [ "$update_count" -gt 0 ]; then
            action=$(notify-send "System Updates" \
                "<b>$update_count</b> packages can be updated." \
                --icon=system-software-update \
                --action="soft=Soft Update" \
                --action="hard=Hard Update")

            case "$action" in
                "soft")
                    kitty -e bash -c "yay -S --needed $(yay -Quq); exec bash"
                    ;;
                "hard")
                    kitty -e bash -c "yay -Syyu; exec bash"
                    ;;
            esac
        fi
        sleep 3600s
    done
}

# File to track snooze state
SNOOZE_FILE="/tmp/usage_monitor_snooze"

# Notify me of excessive cpu usage
check-usage() {
    while true; do
        # Check if snooze is active
        if [ -f "$SNOOZE_FILE" ]; then
            snooze_time=$(cat "$SNOOZE_FILE")
            current_time=$(date +%s)
            
            if [ "$current_time" -lt "$snooze_time" ]; then
                sleep 60
                continue
            else
                rm "$SNOOZE_FILE"
            fi
        fi

        # 1. Get CPU usage (total)
        cpu_usage=$(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100 - $1}')
        cpu_int=${cpu_usage%.*}

        # 2. Get GPU usage (Example for AMD/Intel via sysfs, adjust for NVIDIA if needed)
        # For NVIDIA, use: nvidia-smi --query-gpu=utilization.gpu --format=csv,noheader,nounits
        gpu_usage=$(cat /sys/class/drm/card0/device/gpu_busy_percent 2>/dev/null || echo 0)

        msg=""
        if [ "$cpu_int" -gt 70 ]; then
            culprit=$(ps -eo pcpu,comm --sort=-pcpu | head -n 2 | tail -n 1)
            msg="High CPU Usage: ${cpu_int}% (Top: $culprit)"
        fi

        if [ "$gpu_usage" -gt 70 ]; then
            msg="${msg}\nHigh GPU Usage: ${gpu_usage}%"
        fi

        if [ -n "$msg" ]; then
            action=$(notify-send "System Alert" "$msg" \
                --icon=dialog-warning \
                --urgency=critical \
                --action="dismiss=Dismiss (30m)" \
                --action="ignore=Close")

            if [ "$action" == "dismiss" ]; then
                # Set snooze for 1800 seconds (30 mins)
                echo $(( $(date +%s) + 1800 )) > "$SNOOZE_FILE"
            fi
        fi

        sleep 10 # Check every 10 seconds normally
    done
}

# Notifications Services
daily-fortune-notify & 
daily-update-notify &
check-usage &
remember-to-breathe-notify &

# Notify User of effective service
notify-send "System Init" "Notification services loaded" --icon=emblem-success

wait # Wait to keep the parent process alive
