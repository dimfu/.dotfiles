#!/bin/bash

# WALLPAPERS PATH
DIR=$HOME/Pictures/Wallpapers

# Transition config (type swww img --help for more settings
FPS=60
TYPE="grow"
DURATION=3

# wofi window config (in %)
WIDTH=20
HEIGHT=30

CURSOR=$(hyprctl cursorpos | tr -d ' ')  

SWWW_PARAMS="--transition-fps $FPS --transition-type $TYPE --transition-duration $DURATION  --transition-pos $CURSOR"
HYPRLOCK_CONF="$HOME/.config/hypr/hyprlock.conf"

PICS=($(ls ${DIR} | grep -e ".jpg$" -e ".jpeg$" -e ".png$" -e ".gif$"))

RANDOM_PIC=${PICS[ $RANDOM % ${#PICS[@]} ]}
RANDOM_PIC_NAME="${#PICS[@]}. random"


# WOFI STYLES
CONFIG="$HOME/.config/wofi/config"
STYLE="$HOME/.config/wofi/style.css"
COLORS="$HOME/.config/wofi/colors"

# to check if swaybg is running

if [[ $(pidof swaybg) ]]; then
  pkill swaybg
fi

## Wofi Command
wofi_command="wofi --show dmenu \
			--prompt choose...
			--conf $CONFIG --style $STYLE --color $COLORS \
			--width=$WIDTH% --height=$HEIGHT% \
			--cache-file=/dev/null \
			--hide-scroll --no-actions \
			--matching=fuzzy \
                        --allow-images"

menu(){
    # Here we are looping in the PICS array that is composed of all images in the $DIR
    # folder 
    for i in ${!PICS[@]}; do
        # keeping the .gif to make sue you know it is animated
        if [[ -z $(echo ${PICS[$i]} | grep .gif$) ]]; then
            printf "$i. $(echo ${PICS[$i]} | cut -d. -f1)\n" # n°. <name_of_file_without_identifier>
        else
            printf "$i. ${PICS[$i]}\n"
        fi
    done

    printf "$RANDOM_PIC_NAME"
}

swww query || swww-daemon

main() {
    choice="$(menu | ${wofi_command})"

    if [[ -z "$choice" ]]; then return; fi

    if [[ "$choice" = "$RANDOM_PIC_NAME" ]]; then
      swww img "${DIR}/${RANDOM_PIC}" $SWWW_PARAMS
      return
    fi

    pic_index="$(echo "$choice" | cut -d. -f1)"
    pic_dir="${DIR}/${PICS[$pic_index]}"

    notify-send -i "$pic_dir" "New Wallpaper $pic_dir"

    swww img "$pic_dir" $SWWW_PARAMS
    sleep 1.5
    wal -n -e -q -i "$pic_dir"
    cp ~/.cache/wal/colors-hyprland.conf ~/.config/hypr/colors.conf
    cp ~/.cache/wal/colors-waybar.css ~/.config/waybar/colors.css
    cp ~/.cache/wal/colors-waybar.css ~/.config/wofi/colors.css
    ~/.config/waybar/scripts/launch.sh &

    # update hyprlock wallpaper source
    sed -i "/^background {/,/^}/{s|^[[:space:]]*path =.*|    path = $pic_dir|}" "$HYPRLOCK_CONF"
}

# Check if wofi is already running
if pidof wofi >/dev/null; then
    killall wofi
    exit 0
else
    main
fi

# Uncomment to launch something if a choice was made 
# if [[ -n "$choice" ]]; then
    # Restart Waybar
# fi
