#!/usr/bin/env sh

APP_DESKTOP_DIRS="/usr/share/applications /usr/local/share/applications $HOME/.local/share/applications"
# Define the raw source list here
ICON_RAW_LIST="/usr/share/icons /usr/share/pixmaps $HOME/.local/share/icons"
VALID_ICON_SOURCE_DIRS=""

is_valid_desktop_file() {
    local file="$1"
    local de="${XDG_CURRENT_DESKTOP:-unknown}"

    [ -f "$file" ] && [ -r "$file" ] || return 1

    local type nodisplay hidden only not

    while IFS='=' read -r key value; do
        case "$key" in
            Type) type="$value" ;;
            NoDisplay) nodisplay="$value" ;;
            Hidden) hidden="$value" ;;
            OnlyShowIn) only="$value" ;;
            NotShowIn) not="$value" ;;
        esac
    done < "$file"

    [ "$type" = "Application" ] || return 1
    [ "$nodisplay" = "true" ] && return 1
    [ "$hidden" = "true" ] && return 1

    case "$only" in
        *"$de"*) : ;;
        "") : ;;
        *) return 1 ;;
    esac

    case "$not" in
        *"$de"*) return 1 ;;
    esac

    return 0
}

get_app_list() {
    local result=""
    for path in $APP_DESKTOP_DIRS; do
        [ -d "$path" ] || continue
        for app_path in "$path"/*.desktop; do
            is_valid_desktop_file "$app_path" || continue
            result="$result $app_path"
        done
    done
    echo "$result"
}

get_icon_for_app() {
    app_path="$1"
    icon_name=$(grep -Po '(?<=Icon=).*' "$app_path" | head -n 1)

    # Only build the valid list once
    if [ -z "$VALID_ICON_SOURCE_DIRS" ]; then
        for d in $ICON_RAW_LIST; do
            [ -d "$d" ] && VALID_ICON_SOURCE_DIRS="$VALID_ICON_SOURCE_DIRS $d"
        done
    fi

    # If no icon name found in desktop file, return empty
    [ -z "$icon_name" ] && return

    # find will now correctly see multiple directory arguments
    find $VALID_ICON_SOURCE_DIRS -name "$icon_name*" -print -quit 2>/dev/null
}

format_app_to_json() {
    # Using printf for JSON is safer to handle special characters/newlines
    cat << EOF
{
    "name": "$(basename "$3" .desktop)",
    "icon_path": "$2",
    "desktop_path": "$3"
}
EOF
}

main() {
    apps=$(get_app_list)
    first=true

    # Start the JSON array
    printf "["
    for app in $apps; do
        icon=$(get_icon_for_app "$app")

        if [ "$first" = true ]; then
            first=false
        else
            printf ","
        fi

        # Use -c with jq if you have it to minify, or just print compact
        format_app_to_json "$app" "$icon" "$app"
    done
    printf "]"
}

main
