#!/usr/bin/env bash

# If the message contains "could not", use a warning icon, otherwise use a checkmark
if [[ $1 == *"could not"* ]]; then
    ICON="dialog-error"
    URGENCY="critical"
else
    ICON="emblem-success"
    URGENCY="low"
fi

notify-send "System Init" "$1" --icon=$ICON --urgency=$URGENCY