#!/bin/sh

# Check each expected environment variable and append it to the command if set
[ -n "$BASE_URL" ] && set -- "$@" --base-url "$BASE_URL"
[ -n "$CONFIG" ] && set -- "$@" --config "$CONFIG"
[ -n "$DATE_FORMAT" ] && set -- "$@" --date-format "$DATE_FORMAT"
[ "$DIRS_FIRST" = "true" ] && set -- "$@" --dirs-first
[ -n "$INDEX_FILE" ] && set -- "$@" --index-file "$INDEX_FILE"
[ "$LINK_TO_INDEX" = "true" ] && set -- "$@" --link-to-index
[ -n "$LOG_LEVEL" ] && set -- "$@" --log-level "$LOG_LEVEL"
[ "$MINIFY" = "true" ] && set -- "$@" --minify
[ -n "$NOINDEX_FILES" ] && set -- "$@" --noindex-files "$NOINDEX_FILES"
[ -n "$SKIPINDEX_FILES" ] && set -- "$@" --skipindex-files "$SKIPINDEX_FILES"
[ -n "$ORDER" ] && set -- "$@" --order "$ORDER"
[ "$RECURSIVE" = "true" ] && set -- "$@" --recursive
[ -n "$SKIP" ] && set -- "$@" --skip "$SKIP"
[ -n "$SORT" ] && set -- "$@" --sort "$SORT"
[ -n "$SOURCE" ] && set -- "$@" --source "$SOURCE"
[ -n "$TARGET" ] && set -- "$@" --target "$TARGET"
[ -n "$TEMPLATE" ] && set -- "$@" --template "$TEMPLATE"
[ -n "$THEME" ] && set -- "$@" --theme "$THEME"
[ -n "$TITLE" ] && set -- "$@" --title "$TITLE"

# Execute the constructed command
exec web-indexer "$@"
