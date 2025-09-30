#!/bin/bash

# WALLPAPERS PATH
DIR=$HOME/wallpapers

CACHE_DIR="$HOME/.cache/wallpaper-switcher"
THUMBNAIL_WIDTH="250"
THUMBNAIL_HEIGHT="141"

FPS=100
TYPE="grow"
DURATION=3

# wofi window config (in %)
WIDTH=20
HEIGHT=30 CURSOR=$(hyprctl cursorpos | tr -d ' ')  

SWWW_PARAMS="--transition-fps $FPS --transition-type $TYPE --transition-duration $DURATION --transition-pos $CURSOR"
HYPRLOCK_CONF="$HOME/.config/hypr/hyprlock.conf"

PICS=($(ls ${DIR} | grep -e ".jpg$" -e ".jpeg$" -e ".png$" -e ".gif$"))

RANDOM_PIC=${PICS[ $RANDOM % ${#PICS[@]} ]}
RANDOM_PIC_NAME="${#PICS[@]}. random"

mkdir -p "$CACHE_DIR"

generate_thumbnail() {
    local input="$1"
    local output="$2"
    magick "$input" -thumbnail "${THUMBNAIL_WIDTH}x${THUMBNAIL_HEIGHT}^" -gravity center -extent "${THUMBNAIL_WIDTH}x${THUMBNAIL_HEIGHT}" "$output"
}

SHUFFLE_ICON="$CACHE_DIR/shuffle_thumbnail.png"

magick -size "${THUMBNAIL_WIDTH}x${THUMBNAIL_HEIGHT}" xc:#1e1e1e \
    "$HOME/.config/wofi/assets/shuffle.png" -resize "80x80" -gravity center -composite \
    "$SHUFFLE_ICON"

generate_menu() {
    # Add random/shuffle option with a name that sorts first (using ! prefix)
    echo -en "img:$SHUFFLE_ICON\x00info:!Random Wallpaper\x1fRANDOM\n"
    # Then add all wallpapers
    for img in "$DIR"/*.{jpg,jpeg,png}; do
        [[ -f "$img" ]] || continue
        thumbnail="$CACHE_DIR/$(basename "${img%.*}").png"
        if [[ ! -f "$thumbnail" ]] || [[ "$img" -nt "$thumbnail" ]]; then
            generate_thumbnail "$img" "$thumbnail"
        fi
        echo -en "img:$thumbnail\x00info:$(basename "$img")\x1f$img\n"
    done
}

selected=$(generate_menu | wofi --show dmenu \
    --cache-file /dev/null \
    --define "image-size=${THUMBNAIL_WIDTH}x${THUMBNAIL_HEIGHT}" \
    --columns 3 \
    --allow-images \
    --insensitive \
    --sort-order=default \
    --style ~/.config/wofi/wallpaper.css \
    --conf ~/.config/wofi/wallpaper.conf \
)

main() {
    if [ -n "$selected" ]; then
        thumbnail_path="${selected#img:}"

        if [[ "$thumbnail_path" == "$SHUFFLE_ICON" ]]; then
            original_path=$(find "$DIR" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" \) | shuf -n 1)
        else
            original_filename=$(basename "${thumbnail_path%.*}")
            original_path=$(find "$DIR" -maxdepth 1 -type l -name "${original_filename}.*" -exec realpath {} \; | head -n1)
        fi

        if [ -n "$original_path" ]; then
            swww img "$original_path" $SWWW_PARAMS
            sleep 1.5
            ~/.local/bin/wal -n -e -q -i "$original_path"
            cp ~/.cache/wal/colors-hyprland.conf ~/.config/hypr/colors.conf
            cp ~/.cache/wal/colors-waybar.css ~/.config/waybar/colors.css
            cp ~/.cache/wal/colors-waybar.css ~/.config/wofi/colors.css
            ~/.config/waybar/scripts/launch.sh &

            echo "$original_path" > "$HOME/.cache/current_wallpaper"
            sed -i "/^background {/,/^}/{s|^[[:space:]]*path =.*|    path = $original_path|}" "$HYPRLOCK_CONF"
            notify-send "Wallpaper" "Wallpaper has been updated" -i "$original_path"
        else
            notify-send "Wallpaper Error" "Could not find the original wallpaper file."
        fi
    fi
}

if pidof wofi >/dev/null; then
    killall wofi
    exit 0
else
    main
fi
