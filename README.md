# iCloud Photo Export

[![Shell Script](https://img.shields.io/badge/Shell-Bash-4EAA25?logo=gnu-bash&logoColor=white)](https://www.gnu.org/software/bash/)
[![Platform](https://img.shields.io/badge/Platform-macOS-000000?logo=apple&logoColor=white)](https://www.apple.com/macos/)
[![iCloud](https://img.shields.io/badge/iCloud-Photos-3693F3?logo=icloud&logoColor=white)](https://www.icloud.com/)
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

A command-line tool to **bulk download iCloud Photos** by date, month, or date range. Wrapper around [icloudpd](https://github.com/icloud-photos-downloader/icloud_photos_downloader) with an intuitive interface and automatic date handling.

## Features

### Photo Export (`icloud_photo_export.sh`)
- **Download by month** — `2025-07` downloads all photos from July 2025
- **Download by day** — `2025-07-15` downloads photos from a specific day
- **Download date ranges** — `2025-07 --to 2025-09` downloads July through September
- **Auto-detection** — Format determines mode (no subcommands needed)
- **Organized output** — Automatic folder structure by date/range
- **Videos optional** — Skip videos by default, include with `-v` flag

### HEIC Converter (`convert_heic.sh`)
- **Recursive conversion** — Finds all HEIC/HEIF files in a directory tree
- **Zero dependencies** — Uses macOS built-in `sips`
- **Auto-cleanup** — Deletes originals after conversion (optional)
- **Dry-run mode** — Preview what would be converted
- **Skip existing** — Won't overwrite existing JPG files

### Both Scripts
- **Colorized output** — Professional CLI with configuration summary
- **Validation** — Input checking with clear error messages

## Installation

### Prerequisites

1. **macOS** (uses BSD `date` command)
2. **Python 3** with pip
3. **icloudpd** installed globally:

```bash
pip install icloudpd
```

### Setup

```bash
git clone https://github.com/YOUR_USERNAME/icloud-photo-export.git
cd icloud-photo-export
chmod +x icloud_photo_export.sh convert_heic.sh
```

## Usage

```bash
./icloud_photo_export.sh <date> -a <email> -o <dir> [OPTIONS]
```

### Date Formats

| Format | Mode | Example |
|--------|------|---------|
| `YYYY-MM` | Entire month | `2025-07` |
| `YYYY-MM-DD` | Single day | `2025-07-15` |

### Required

| Option | Description |
|--------|-------------|
| `-a, --account <email>` | Apple ID / iCloud email address |
| `-o, --output <dir>` | Base output directory |

### Options

| Option | Description |
|--------|-------------|
| `--to <date>` | End date for range (same format as start) |
| `-v, --include-videos` | Include videos and Live Photos (default: photos only) |
| `-h, --help` | Show help message |

### Examples

```bash
# Download all photos from July 2025
./icloud_photo_export.sh 2025-07 -a your@email.com -o ~/Photos

# Download photos from a specific day
./icloud_photo_export.sh 2025-07-15 -a your@email.com -o ~/Photos

# Download July through September 2025
./icloud_photo_export.sh 2025-07 --to 2025-09 -a your@email.com -o ~/Photos

# Include videos and Live Photos
./icloud_photo_export.sh 2025-07 -a your@email.com -o ~/Photos -v
```

---

## HEIC Converter

Convert HEIC/HEIF files to JPG format.

### Usage

```bash
./convert_heic.sh --input-dir <directory> [OPTIONS]
```

### Options

| Option | Description |
|--------|-------------|
| `-i, --input-dir <dir>` | Directory to recursively search (required) |
| `-k, --keep-originals` | Keep original HEIC files after conversion |
| `-d, --dry-run` | Preview what would be converted |
| `-h, --help` | Show help message |

### Examples

```bash
# Convert all HEIC files, delete originals
./convert_heic.sh --input-dir ~/Photos/2025-07

# Convert but keep original HEIC files
./convert_heic.sh -i ~/Photos/2025-07 --keep-originals

# Preview what would be converted
./convert_heic.sh -i ~/Photos --dry-run
```

### Workflow

Typical workflow after downloading from iCloud:

```bash
# 1. Download photos
./icloud_photo_export.sh 2025-07 -a your@email.com -o ~/Photos

# 2. Convert HEIC to JPG
./convert_heic.sh -i ~/Photos/2025-07
```

---

## Output Structure

Photos are organized into date-based folders:

```
~/Dropbox/iphotos/
├── 2025-07/                    # Single month
├── 2025-07-15/                 # Single day
├── 2025-07_to_2025-09/         # Month range
└── 2025-07-01_to_2025-07-15/   # Day range
```

## Authentication

On first run, you'll be prompted for:

1. **iCloud password** — Enter your Apple ID password
2. **2FA code** — Enter the code sent to your trusted devices

Session tokens are cached in `~/.pyicloud` for subsequent runs (typically valid for several weeks).

### Auth-only mode

To authenticate without downloading:

```bash
icloudpd --auth-only --username your@email.com
```

## Configuration

Default settings (edit in script):

```bash
EMAIL="craigtrim@gmail.com"           # Your Apple ID
BASE_DIR="$HOME/Dropbox/iphotos"      # Default output directory
INCLUDE_VIDEOS=false                   # Skip videos by default
```

## How It Works

This script wraps [icloudpd](https://github.com/icloud-photos-downloader/icloud_photos_downloader) and:

1. Parses your date input to determine download mode
2. Calculates the exact date range (including month boundaries)
3. Creates an organized output folder
4. Calls `icloudpd` with the appropriate `--skip-created-before` and `--skip-created-after` flags

## Troubleshooting

### "Session expired" or authentication errors

Delete the cached session and re-authenticate:

```bash
rm -rf ~/.pyicloud
./icloud_photo_export.sh 2025-07
```

### "No photos found"

- Verify the date range contains photos in your iCloud library
- Check that your iCloud Photos sync is enabled
- Try running `icloudpd --list-albums --username your@email.com` to verify access

### Videos not downloading

Add the `-v` or `--include-videos` flag:

```bash
./icloud_photo_export.sh 2025-07 -v
```

## Related Projects

- [icloudpd](https://github.com/icloud-photos-downloader/icloud_photos_downloader) — The underlying download tool
- [pyicloud](https://github.com/picklepete/pyicloud) — Python iCloud API library

## License

MIT License - see [LICENSE](LICENSE) for details.

---

**Keywords**: icloud photos download, icloud backup, apple photos export, icloud photo downloader, bulk download icloud, icloud cli, macos photo backup, icloudpd wrapper
