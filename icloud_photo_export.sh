#!/bin/bash

# icloud_photo_export.sh
# A wrapper script for icloudpd to download photos by date/month/range

set -e

# ============================================================================
# COLORS
# ============================================================================
BOLD='\033[1m'
DIM='\033[2m'
RESET='\033[0m'
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[0;37m'

# Bold variants
BRED='\033[1;31m'
BGREEN='\033[1;32m'
BYELLOW='\033[1;33m'
BBLUE='\033[1;34m'
BMAGENTA='\033[1;35m'
BCYAN='\033[1;36m'
BWHITE='\033[1;37m'

# ============================================================================
# DEFAULTS
# ============================================================================
EMAIL=""
INCLUDE_VIDEOS=false
BASE_DIR=""
END_DATE=""

# ============================================================================
# FUNCTIONS
# ============================================================================
print_header() {
    echo -e "${BCYAN}"
    echo "╔═══════════════════════════════════════════════════════════════════╗"
    echo "║                    iCloud Photo Export Tool                       ║"
    echo "╚═══════════════════════════════════════════════════════════════════╝"
    echo -e "${RESET}"
}

print_help() {
    print_header

    echo -e "${BWHITE}DESCRIPTION${RESET}"
    echo -e "  A convenience wrapper around ${CYAN}icloudpd${RESET} for downloading iCloud photos"
    echo -e "  by day, month, or date range. Auto-detects mode from date format."
    echo ""

    echo -e "${BWHITE}USAGE${RESET}"
    echo -e "  ${GREEN}./icloud_photo_export.sh${RESET} ${YELLOW}<date>${RESET} ${YELLOW}-a <email>${RESET} ${YELLOW}-o <dir>${RESET} [OPTIONS]"
    echo ""

    echo -e "${BWHITE}DATE FORMATS${RESET}"
    echo -e "  ${YELLOW}YYYY-MM${RESET}                   Download entire month"
    echo -e "  ${YELLOW}YYYY-MM-DD${RESET}                Download single day"
    echo ""

    echo -e "${BWHITE}REQUIRED${RESET}"
    echo -e "  ${GREEN}-a, --account${RESET} ${YELLOW}<email>${RESET}     Apple ID / iCloud email address"
    echo -e "  ${GREEN}-o, --output${RESET} ${YELLOW}<dir>${RESET}        Base output directory"
    echo ""

    echo -e "${BWHITE}OPTIONS${RESET}"
    echo -e "  ${GREEN}--to${RESET} ${YELLOW}<date>${RESET}               End date for range (same format as start)"
    echo -e "                            ${DIM}Creates a range from start to end date${RESET}"
    echo ""
    echo -e "  ${GREEN}-v, --include-videos${RESET}      Include videos in download"
    echo -e "                            ${DIM}Default: photos only (skips .MOV and Live Photos)${RESET}"
    echo ""
    echo -e "  ${GREEN}-h, --help${RESET}                Show this help message"
    echo ""

    echo -e "${BWHITE}EXAMPLES${RESET}"
    echo -e "  ${DIM}# Download photos from July 2025${RESET}"
    echo -e "  ${GREEN}./icloud_photo_export.sh 2025-07 -a your@email.com -o ~/Photos${RESET}"
    echo ""
    echo -e "  ${DIM}# Download photos from a specific day${RESET}"
    echo -e "  ${GREEN}./icloud_photo_export.sh 2025-07-15 -a your@email.com -o ~/Photos${RESET}"
    echo ""
    echo -e "  ${DIM}# Download a range of months (July - September 2025)${RESET}"
    echo -e "  ${GREEN}./icloud_photo_export.sh 2025-07 --to 2025-09 -a your@email.com -o ~/Photos${RESET}"
    echo ""
    echo -e "  ${DIM}# Include videos and Live Photos${RESET}"
    echo -e "  ${GREEN}./icloud_photo_export.sh 2025-07 -a your@email.com -o ~/Photos -v${RESET}"
    echo ""

    echo -e "${BWHITE}OUTPUT STRUCTURE${RESET}"
    echo -e "  Single month:  ${CYAN}<base_dir>/YYYY-MM/${RESET}"
    echo -e "  Single day:    ${CYAN}<base_dir>/YYYY-MM-DD/${RESET}"
    echo -e "  Range:         ${CYAN}<base_dir>/YYYY-MM_to_YYYY-MM/${RESET}"
    echo ""

    echo -e "${BWHITE}AUTHENTICATION${RESET}"
    echo -e "  On first run, you will be prompted for:"
    echo -e "    ${YELLOW}1.${RESET} iCloud password"
    echo -e "    ${YELLOW}2.${RESET} Two-factor authentication code"
    echo -e "  Session is cached in ${CYAN}~/.pyicloud${RESET} for subsequent runs."
    echo ""

    echo -e "${BWHITE}UNDERLYING TOOL${RESET}"
    echo -e "  This script wraps ${CYAN}icloudpd${RESET} (iCloud Photos Downloader)"
    echo -e "  For advanced options, run: ${GREEN}icloudpd --help${RESET}"
    echo ""
}

print_config() {
    echo -e "${BCYAN}┌─────────────────────────────────────────────────────────────────────┐${RESET}"
    echo -e "${BCYAN}│${RESET}                      ${BWHITE}Configuration Summary${RESET}                        ${BCYAN}│${RESET}"
    echo -e "${BCYAN}├─────────────────────────────────────────────────────────────────────┤${RESET}"
    echo -e "${BCYAN}│${RESET}                                                                     ${BCYAN}│${RESET}"
    echo -e "${BCYAN}│${RESET}  ${BWHITE}Account${RESET}         ${CYAN}${EMAIL}${RESET}                          ${BCYAN}│${RESET}"
    echo -e "${BCYAN}│${RESET}  ${BWHITE}Mode${RESET}            ${BMAGENTA}${MODE}${RESET}"
    printf "${BCYAN}│${RESET}%-70s${BCYAN}│${RESET}\n" ""
    echo -e "${BCYAN}│${RESET}  ${BWHITE}Date Range${RESET}      ${WHITE}${FROM_DATE}${RESET} → ${WHITE}${TO_DATE}${RESET}"
    printf "${BCYAN}│${RESET}%-70s${BCYAN}│${RESET}\n" ""
    echo -e "${BCYAN}│${RESET}  ${BWHITE}Output${RESET}          ${CYAN}${OUTPUT_DIR}${RESET}"
    printf "${BCYAN}│${RESET}%-70s${BCYAN}│${RESET}\n" ""
    echo -e "${BCYAN}│${RESET}                                                                     ${BCYAN}│${RESET}"

    # Videos status
    if [ "$INCLUDE_VIDEOS" = true ]; then
        echo -e "${BCYAN}│${RESET}  ${BWHITE}Videos${RESET}          ${BGREEN}● ENABLED${RESET}  (includes Live Photo .MOV files)      ${BCYAN}│${RESET}"
    else
        echo -e "${BCYAN}│${RESET}  ${BWHITE}Videos${RESET}          ${RED}○ DISABLED${RESET} (skipping .MOV and Live Photos)       ${BCYAN}│${RESET}"
    fi

    echo -e "${BCYAN}│${RESET}                                                                     ${BCYAN}│${RESET}"
    echo -e "${BCYAN}└─────────────────────────────────────────────────────────────────────┘${RESET}"
    echo ""
}

prompt_continue() {
    echo -e "${DIM}Review the configuration above.${RESET}"
    echo ""
    echo -e -n "${BYELLOW}▶ Press ENTER to start download, or Ctrl+C to cancel...${RESET} "
    read -r
    echo ""
}

print_starting() {
    echo -e "${BGREEN}▶ Starting download...${RESET}"
    echo ""
}

print_error() {
    echo -e "${BRED}✖ Error:${RESET} $1" >&2
}

# Detect date format and return type: "month" or "day"
detect_date_type() {
    local date_str="$1"
    if [[ "$date_str" =~ ^[0-9]{4}-[0-9]{2}$ ]]; then
        echo "month"
    elif [[ "$date_str" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]; then
        echo "day"
    else
        echo "invalid"
    fi
}

# Validate a date string
validate_date() {
    local date_str="$1"
    local date_type="$2"

    if [ "$date_type" = "month" ]; then
        local year="${date_str:0:4}"
        local month="${date_str:5:2}"

        if ! [[ "$year" =~ ^[0-9]{4}$ ]] || [ "$year" -lt 1900 ] || [ "$year" -gt 2100 ]; then
            print_error "Invalid year in '$date_str'"
            return 1
        fi
        if ! [[ "$month" =~ ^[0-9]{2}$ ]] || [ "$month" -lt 1 ] || [ "$month" -gt 12 ]; then
            print_error "Invalid month in '$date_str' (must be 01-12)"
            return 1
        fi
    elif [ "$date_type" = "day" ]; then
        # Use date command to validate
        if ! date -j -f "%Y-%m-%d" "$date_str" "+%Y-%m-%d" >/dev/null 2>&1; then
            print_error "Invalid date '$date_str'"
            return 1
        fi
    fi
    return 0
}

# Get the first day of a month (YYYY-MM -> YYYY-MM-01)
get_month_start() {
    echo "${1}-01"
}

# Get the last day of a month (YYYY-MM -> YYYY-MM-DD)
get_month_end() {
    local first_day="${1}-01"
    date -v1d -v+1m -v-1d -j -f "%Y-%m-%d" "$first_day" "+%Y-%m-%d"
}

# ============================================================================
# ARGUMENT PARSING
# ============================================================================
POSITIONAL=()
while [[ $# -gt 0 ]]; do
    case $1 in
        --account|-a)
            EMAIL="$2"
            shift 2
            ;;
        --include-videos|-v)
            INCLUDE_VIDEOS=true
            shift
            ;;
        --output|-o)
            BASE_DIR="$2"
            shift 2
            ;;
        --to)
            END_DATE="$2"
            shift 2
            ;;
        --help|-h)
            print_help
            exit 0
            ;;
        *)
            POSITIONAL+=("$1")
            shift
            ;;
    esac
done

# ============================================================================
# VALIDATION
# ============================================================================
if [ ${#POSITIONAL[@]} -lt 1 ]; then
    print_help
    exit 1
fi

if [ -z "$EMAIL" ]; then
    print_error "Account is required. Use ${CYAN}--account${RESET} or ${CYAN}-a${RESET} to specify your Apple ID."
    echo ""
    echo -e "Example: ${GREEN}./icloud_photo_export.sh 2025-07 -a your@email.com -o ~/Photos${RESET}"
    exit 1
fi

if [ -z "$BASE_DIR" ]; then
    print_error "Output directory is required. Use ${CYAN}--output${RESET} or ${CYAN}-o${RESET} to specify."
    echo ""
    echo -e "Example: ${GREEN}./icloud_photo_export.sh 2025-07 -a your@email.com -o ~/Photos${RESET}"
    exit 1
fi

# Expand ~ if present
BASE_DIR="${BASE_DIR/#\~/$HOME}"

START_DATE="${POSITIONAL[0]}"
START_TYPE=$(detect_date_type "$START_DATE")

if [ "$START_TYPE" = "invalid" ]; then
    print_error "Invalid date format '$START_DATE'. Use YYYY-MM or YYYY-MM-DD"
    exit 1
fi

validate_date "$START_DATE" "$START_TYPE" || exit 1

# Handle --to if provided
if [ -n "$END_DATE" ]; then
    END_TYPE=$(detect_date_type "$END_DATE")

    if [ "$END_TYPE" = "invalid" ]; then
        print_error "Invalid end date format '$END_DATE'. Use YYYY-MM or YYYY-MM-DD"
        exit 1
    fi

    if [ "$START_TYPE" != "$END_TYPE" ]; then
        print_error "Start and end dates must use the same format (both YYYY-MM or both YYYY-MM-DD)"
        exit 1
    fi

    validate_date "$END_DATE" "$END_TYPE" || exit 1
fi

# ============================================================================
# DATE CALCULATION
# ============================================================================
if [ "$START_TYPE" = "month" ]; then
    if [ -n "$END_DATE" ]; then
        # Month range
        MODE="MONTH RANGE"
        FROM_DATE=$(get_month_start "$START_DATE")
        TO_DATE=$(get_month_end "$END_DATE")
        FOLDER_NAME="${START_DATE}_to_${END_DATE}"
    else
        # Single month
        MODE="SINGLE MONTH"
        FROM_DATE=$(get_month_start "$START_DATE")
        TO_DATE=$(get_month_end "$START_DATE")
        FOLDER_NAME="$START_DATE"
    fi
else
    if [ -n "$END_DATE" ]; then
        # Day range
        MODE="DAY RANGE"
        FROM_DATE="$START_DATE"
        TO_DATE="$END_DATE"
        FOLDER_NAME="${START_DATE}_to_${END_DATE}"
    else
        # Single day
        MODE="SINGLE DAY"
        FROM_DATE="$START_DATE"
        TO_DATE="$START_DATE"
        FOLDER_NAME="$START_DATE"
    fi
fi

# ============================================================================
# OUTPUT SETUP
# ============================================================================
OUTPUT_DIR="${BASE_DIR}/${FOLDER_NAME}"
mkdir -p "$OUTPUT_DIR"

# ============================================================================
# DISPLAY CONFIG & EXECUTE
# ============================================================================
print_header
print_config
prompt_continue
print_starting

# Build optional flags
OPTIONAL_FLAGS=""
if [ "$INCLUDE_VIDEOS" = false ]; then
    OPTIONAL_FLAGS="--skip-videos --skip-live-photos"
fi

# Execute icloudpd
icloudpd --directory "$OUTPUT_DIR" \
    --skip-created-before "$FROM_DATE" \
    --skip-created-after "$TO_DATE" \
    --username "$EMAIL" \
    $OPTIONAL_FLAGS
