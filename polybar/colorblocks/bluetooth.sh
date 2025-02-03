#!/bin/bash

# Иконки для разных состояний
ICON_ON="%{F#2193ff}%{F-}"
ICON_OFF="%{F#666}%{F-}"

toggle_bluetooth() {
    if bluetoothctl show | grep -q "Powered: yes"; then
        bluetoothctl power off
    else
        bluetoothctl power on
    fi
}

show_menu() {
    devices=$(bluetoothctl devices | awk '{print $3 " " substr($0, index($0,$3))}')
    selected=$(echo -e "Включить\nВыключить\n$devices" | rofi -dmenu -p "Bluetooth")
    
    case $selected in
        "Включить") bluetoothctl power on ;;
        "Выключить") bluetoothctl power off ;;
        *) 
            mac=$(bluetoothctl devices | grep "$selected" | awk '{print $2}')
            if [ -n "$mac" ]; then
                bluetoothctl connect "$mac"
            fi
            ;;
    esac
}

case "$1" in
    --toggle)
        toggle_bluetooth
        ;;
    --menu)
        show_menu
        ;;
    *)
        if bluetoothctl show | grep -q "Powered: yes"; then
            echo "$ICON_ON"
        else
            echo "$ICON_OFF"
        fi
        ;;
esac
