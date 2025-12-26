# iCloud Photo Export

[![Shell Script](https://img.shields.io/badge/Shell-Bash-4EAA25?logo=gnu-bash&logoColor=white)](https://www.gnu.org/software/bash/)
[![Platform](https://img.shields.io/badge/Platform-macOS-000000?logo=apple&logoColor=white)](https://www.apple.com/macos/)
[![iCloud](https://img.shields.io/badge/iCloud-Photos-3693F3?logo=icloud&logoColor=white)](https://www.icloud.com/)
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

**Bulk download and backup iCloud Photos to your Mac.** Export iPhone photos by date, month, or range. Convert HEIC to JPG. Simple CLI wrapper for [icloudpd](https://github.com/icloud-photos-downloader/icloud_photos_downloader).

## How to Download iCloud Photos

```bash
# Download all photos from July 2025
./icloud_photo_export.sh 2025-07 -a your@email.com -o ~/Photos

# Download a date range
./icloud_photo_export.sh 2025-07 --to 2025-09 -a your@email.com -o ~/Photos

# Convert HEIC to JPG
./convert_heic.sh -i ~/Photos/2025-07
```

## Features

| Script | What it does |
|--------|--------------|
| `icloud_photo_export.sh` | Download iCloud Photos by month, day, or date range |
| `convert_heic.sh` | Batch convert HEIC/HEIF to JPG using macOS `sips` |

- **Date-based downloads** — Specify `YYYY-MM` (month) or `YYYY-MM-DD` (day)
- **Range support** — Use `--to` for multi-month or multi-day ranges
- **HEIC to JPG** — Convert iPhone photos to universal JPG format
- **Zero dependencies** — Uses macOS built-in tools + icloudpd
- **Organized output** — Auto-creates folders like `2025-07/` or `2025-07_to_2025-09/`

## Installation

```bash
# Install icloudpd
pip install icloudpd

# Clone and setup
git clone https://github.com/YOUR_USERNAME/icloud-photo-export.git
cd icloud-photo-export
chmod +x *.sh
```

## Photo Export Usage

```bash
./icloud_photo_export.sh <date> -a <email> -o <dir> [OPTIONS]
```

| Option | Description |
|--------|-------------|
| `-a, --account` | Apple ID email (required) |
| `-o, --output` | Output directory (required) |
| `--to <date>` | End date for range downloads |
| `-v, --include-videos` | Include videos and Live Photos |
| `-h, --help` | Show help |

### Examples

```bash
# Single month
./icloud_photo_export.sh 2025-07 -a you@email.com -o ~/Photos

# Single day
./icloud_photo_export.sh 2025-07-15 -a you@email.com -o ~/Photos

# Month range (July-September)
./icloud_photo_export.sh 2025-07 --to 2025-09 -a you@email.com -o ~/Photos

# Include videos
./icloud_photo_export.sh 2025-07 -a you@email.com -o ~/Photos -v
```

## HEIC Converter Usage

```bash
./convert_heic.sh -i <directory> [OPTIONS]
```

| Option | Description |
|--------|-------------|
| `-i, --input-dir` | Directory to scan (required) |
| `-k, --keep-originals` | Don't delete HEIC files after conversion |
| `-d, --dry-run` | Preview without converting |

### Examples

```bash
# Convert and delete originals
./convert_heic.sh -i ~/Photos/2025-07

# Keep originals
./convert_heic.sh -i ~/Photos/2025-07 --keep-originals

# Preview first
./convert_heic.sh -i ~/Photos/2025-07 --dry-run
```

## Authentication

On first run, enter your iCloud password and 2FA code. Sessions are cached in `~/.pyicloud`.

To re-authenticate:
```bash
rm -rf ~/.pyicloud
```

## Troubleshooting

| Problem | Solution |
|---------|----------|
| Session expired | Delete `~/.pyicloud` and re-run |
| No photos found | Verify date range has photos in iCloud |
| Videos not downloading | Add `-v` flag |

## Related

- [icloudpd](https://github.com/icloud-photos-downloader/icloud_photos_downloader) — Underlying download engine
- [pyicloud](https://github.com/picklepete/pyicloud) — Python iCloud API

## License

MIT

---

<sub>**Keywords**: download icloud photos, backup iphone photos to mac, export icloud photos, icloud photo downloader, bulk download icloud, heic to jpg mac, convert heic to jpeg, icloudpd wrapper, apple photos backup, icloud cli tool, macos photo export</sub>
