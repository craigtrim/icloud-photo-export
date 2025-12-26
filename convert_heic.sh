#!/bin/bash

# convert_heic.sh
# Recursively converts HEIC files to JPG using macOS sips

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
CYAN='\033[0;36m'
WHITE='\033[0;37m'

BRED='\033[1;31m'
BGREEN='\033[1;32m'
BYELLOW='\033[1;33m'
BCYAN='\033[1;36m'
BWHITE='\033[1;37m'
BMAGENTA='\033[1;35m'

# ============================================================================
# DEFAULTS
# ============================================================================
INPUT_DIR=""
KEEP_ORIGINALS=false
DRY_RUN=false

# ============================================================================
# FUNCTIONS
# ============================================================================
print_header() {
    echo -e "${BCYAN}"
    echo "╔═══════════════════════════════════════════════════════════════════╗"
    echo "║                      HEIC to JPG Converter                        ║"
    echo "╚═══════════════════════════════════════════════════════════════════╝"
    echo -e "${RESET}"
}

print_help() {
    print_header

    echo -e "${BWHITE}DESCRIPTION${RESET}"
    echo -e "  Recursively converts HEIC/HEIF files to JPG format using macOS ${CYAN}sips${RESET}."
    echo -e "  By default, original HEIC files are deleted after successful conversion."
    echo ""

    echo -e "${BWHITE}USAGE${RESET}"
    echo -e "  ${GREEN}./convert_heic.sh${RESET} ${YELLOW}--input-dir <directory>${RESET} [OPTIONS]"
    echo ""

    echo -e "${BWHITE}REQUIRED${RESET}"
    echo -e "  ${GREEN}-i, --input-dir${RESET} ${YELLOW}<dir>${RESET}     Directory to recursively search for HEIC files"
    echo ""

    echo -e "${BWHITE}OPTIONS${RESET}"
    echo -e "  ${GREEN}-k, --keep-originals${RESET}     Keep original HEIC files after conversion"
    echo -e "                            ${DIM}Default: delete originals after conversion${RESET}"
    echo ""
    echo -e "  ${GREEN}-d, --dry-run${RESET}            Show what would be converted without doing it"
    echo ""
    echo -e "  ${GREEN}-h, --help${RESET}               Show this help message"
    echo ""

    echo -e "${BWHITE}EXAMPLES${RESET}"
    echo -e "  ${DIM}# Convert all HEIC files, delete originals${RESET}"
    echo -e "  ${GREEN}./convert_heic.sh --input-dir ~/Photos/2025-07${RESET}"
    echo ""
    echo -e "  ${DIM}# Convert but keep original HEIC files${RESET}"
    echo -e "  ${GREEN}./convert_heic.sh -i ~/Photos/2025-07 --keep-originals${RESET}"
    echo ""
    echo -e "  ${DIM}# Preview what would be converted${RESET}"
    echo -e "  ${GREEN}./convert_heic.sh -i ~/Photos --dry-run${RESET}"
    echo ""

    echo -e "${BWHITE}OUTPUT${RESET}"
    echo -e "  JPG files are created in the same directory as the source HEIC."
    echo -e "  Example: ${DIM}photo.HEIC${RESET} → ${CYAN}photo.jpg${RESET}"
    echo ""

    echo -e "${BWHITE}REQUIREMENTS${RESET}"
    echo -e "  macOS with ${CYAN}sips${RESET} (built-in, no installation needed)"
    echo ""
}

print_config() {
    echo -e "${BCYAN}┌─────────────────────────────────────────────────────────────────────┐${RESET}"
    echo -e "${BCYAN}│${RESET}                      ${BWHITE}Configuration Summary${RESET}                        ${BCYAN}│${RESET}"
    echo -e "${BCYAN}├─────────────────────────────────────────────────────────────────────┤${RESET}"
    echo -e "${BCYAN}│${RESET}                                                                     ${BCYAN}│${RESET}"
    echo -e "${BCYAN}│${RESET}  ${BWHITE}Input Directory${RESET}   ${CYAN}${INPUT_DIR}${RESET}"
    printf "${BCYAN}│${RESET}%-70s${BCYAN}│${RESET}\n" ""
    echo -e "${BCYAN}│${RESET}  ${BWHITE}Files Found${RESET}        ${BYELLOW}${FILE_COUNT}${RESET} HEIC file(s)"
    printf "${BCYAN}│${RESET}%-70s${BCYAN}│${RESET}\n" ""
    echo -e "${BCYAN}│${RESET}                                                                     ${BCYAN}│${RESET}"

    # Keep originals status
    if [ "$KEEP_ORIGINALS" = true ]; then
        echo -e "${BCYAN}│${RESET}  ${BWHITE}Originals${RESET}         ${BGREEN}● KEEP${RESET}                                         ${BCYAN}│${RESET}"
    else
        echo -e "${BCYAN}│${RESET}  ${BWHITE}Originals${RESET}         ${RED}○ DELETE${RESET} after conversion                      ${BCYAN}│${RESET}"
    fi

    # Dry run status
    if [ "$DRY_RUN" = true ]; then
        echo -e "${BCYAN}│${RESET}  ${BWHITE}Mode${RESET}              ${BYELLOW}● DRY RUN${RESET} (no changes will be made)            ${BCYAN}│${RESET}"
    fi

    echo -e "${BCYAN}│${RESET}                                                                     ${BCYAN}│${RESET}"
    echo -e "${BCYAN}└─────────────────────────────────────────────────────────────────────┘${RESET}"
    echo ""
}

print_error() {
    echo -e "${BRED}✖ Error:${RESET} $1" >&2
}

print_success() {
    echo -e "${GREEN}✔${RESET} $1"
}

print_skip() {
    echo -e "${YELLOW}⊘${RESET} $1"
}

print_delete() {
    echo -e "${RED}✖${RESET} $1"
}

print_info() {
    echo -e "${CYAN}ℹ${RESET} $1"
}

# ============================================================================
# ARGUMENT PARSING
# ============================================================================
while [[ $# -gt 0 ]]; do
    case $1 in
        --input-dir|-i)
            INPUT_DIR="$2"
            shift 2
            ;;
        --keep-originals|-k)
            KEEP_ORIGINALS=true
            shift
            ;;
        --dry-run|-d)
            DRY_RUN=true
            shift
            ;;
        --help|-h)
            print_help
            exit 0
            ;;
        *)
            print_error "Unknown option: $1"
            echo "Use --help for usage information."
            exit 1
            ;;
    esac
done

# ============================================================================
# VALIDATION
# ============================================================================
if [ -z "$INPUT_DIR" ]; then
    print_help
    exit 1
fi

# Expand ~ if present
INPUT_DIR="${INPUT_DIR/#\~/$HOME}"

if [ ! -d "$INPUT_DIR" ]; then
    print_error "Directory not found: $INPUT_DIR"
    exit 1
fi

# ============================================================================
# FIND FILES
# ============================================================================
# Find all HEIC/HEIF files (case insensitive)
HEIC_FILES=()
while IFS= read -r -d '' file; do
    HEIC_FILES+=("$file")
done < <(find "$INPUT_DIR" -type f \( -iname "*.heic" -o -iname "*.heif" \) -print0 2>/dev/null)

FILE_COUNT=${#HEIC_FILES[@]}

# ============================================================================
# DISPLAY CONFIG
# ============================================================================
print_header
print_config

if [ "$FILE_COUNT" -eq 0 ]; then
    print_info "No HEIC/HEIF files found in $INPUT_DIR"
    exit 0
fi

# ============================================================================
# CONVERT FILES
# ============================================================================
if [ "$DRY_RUN" = true ]; then
    echo -e "${BYELLOW}▶ Dry run mode - showing what would happen:${RESET}"
    echo ""
else
    echo -e "${BGREEN}▶ Starting conversion...${RESET}"
    echo ""
fi

CONVERTED=0
FAILED=0
SKIPPED=0

for heic_file in "${HEIC_FILES[@]}"; do
    # Get the directory and filename
    dir=$(dirname "$heic_file")
    filename=$(basename "$heic_file")
    name="${filename%.*}"
    jpg_file="${dir}/${name}.jpg"

    # Check if JPG already exists
    if [ -f "$jpg_file" ]; then
        print_skip "Already exists: ${jpg_file}"
        ((SKIPPED++))
        continue
    fi

    if [ "$DRY_RUN" = true ]; then
        echo -e "  ${DIM}Would convert:${RESET} $heic_file"
        echo -e "  ${DIM}          to:${RESET} $jpg_file"
        if [ "$KEEP_ORIGINALS" = false ]; then
            echo -e "  ${DIM}      delete:${RESET} $heic_file"
        fi
        echo ""
        ((CONVERTED++))
    else
        # Convert using sips
        if sips -s format jpeg "$heic_file" --out "$jpg_file" >/dev/null 2>&1; then
            print_success "Converted: ${name}.jpg"
            ((CONVERTED++))

            # Delete original if not keeping
            if [ "$KEEP_ORIGINALS" = false ]; then
                rm "$heic_file"
                print_delete "Deleted: ${filename}"
            fi
        else
            print_error "Failed to convert: $heic_file"
            ((FAILED++))
        fi
    fi
done

# ============================================================================
# SUMMARY
# ============================================================================
echo ""
echo -e "${BCYAN}┌─────────────────────────────────────────────────────────────────────┐${RESET}"
echo -e "${BCYAN}│${RESET}                          ${BWHITE}Summary${RESET}                                   ${BCYAN}│${RESET}"
echo -e "${BCYAN}├─────────────────────────────────────────────────────────────────────┤${RESET}"
echo -e "${BCYAN}│${RESET}                                                                     ${BCYAN}│${RESET}"

if [ "$DRY_RUN" = true ]; then
    echo -e "${BCYAN}│${RESET}  ${BWHITE}Would convert${RESET}     ${BGREEN}${CONVERTED}${RESET} file(s)                                     ${BCYAN}│${RESET}"
else
    echo -e "${BCYAN}│${RESET}  ${BWHITE}Converted${RESET}         ${BGREEN}${CONVERTED}${RESET} file(s)                                     ${BCYAN}│${RESET}"
fi

if [ "$SKIPPED" -gt 0 ]; then
    echo -e "${BCYAN}│${RESET}  ${BWHITE}Skipped${RESET}           ${YELLOW}${SKIPPED}${RESET} file(s) (JPG already exists)                ${BCYAN}│${RESET}"
fi

if [ "$FAILED" -gt 0 ]; then
    echo -e "${BCYAN}│${RESET}  ${BWHITE}Failed${RESET}            ${RED}${FAILED}${RESET} file(s)                                      ${BCYAN}│${RESET}"
fi

echo -e "${BCYAN}│${RESET}                                                                     ${BCYAN}│${RESET}"
echo -e "${BCYAN}└─────────────────────────────────────────────────────────────────────┘${RESET}"
