# Termux Media Toolkit

A set of tools for downloading media on Android via Termux. Wraps `yt-dlp`, `spotDL`, `ani-cli`, and `aria2` into simple commands.

## Tools

| Command | What it does | Engine |
|---------|-------------|--------|
| `vtool` | Video/YouTube downloader — menu, quick mode, playlists | yt-dlp |
| `vall` | Universal quick downloader — paste any URL, auto-downloads | yt-dlp + spotDL |
| `tsopt` | Spotify music downloader — tracks, albums, playlists | spotDL |
| `tani` | Anime downloader & streamer — search, batch download | ani-cli |
| `ttget` | Movie torrent downloader — search YTS, pick quality | aria2 |
| `thelp` | Show toolkit overview and help | — |

### Quick Aliases

| Alias | What it does |
|-------|-------------|
| `ytvideo <URL>` | Download best MP4 video |
| `ytmp3 <URL>` | Download best MP3 audio |
| `ytlist <URL>` | Download playlist as MP3s |

## Installation

```bash
bash install.sh
```

Then reload aliases:
```bash
source ~/.bashrc
```

## Usage

### vtool — Video / YouTube Downloader

```
vtool                         Interactive menu
vtool <URL>                   Download best video directly
vtool -h                      Show detailed help
```

Menu options:
1. Download best video (MP4)
2. Download audio only (MP3)
3. Download entire playlist (audio)
4. List all resolutions, then pick format ID
5. Quick loop mode — paste URLs one after another
6. Exit

### vall — Universal Quick Downloader

Paste any URL and it auto-downloads. Detects Spotify automatically.

```
vall
URL: https://youtube.com/watch?v=...
-> Downloading best video...
Done
URL: https://open.spotify.com/track/...
-> Spotify detected, using spotDL...
Done
URL: [blank]
Goodbye!
```

```
vall <URL>                    Download single URL and exit
vall -h                       Show detailed help
```

### tsopt — Spotify Music Downloader

```
tsopt                         Interactive menu
tsopt <URL>                   Download track/album/playlist directly
tsopt -h                      Show detailed help
```

Downloads songs from Spotify by finding matching audio on YouTube,
then embeds full metadata: title, artist, album art, and lyrics.

### tani — Anime Downloader & Streamer

```
tani                          Interactive search
tani "one piece"              Search and play
tani -d "naruto"              Search and download
tani -c                       Continue from history
tani -h                       Show detailed help
```

Batch download episodes:
```
tani "one piece" -d -e 1-100
```

### ttget — Movie Torrent Downloader

```
ttget                         Interactive search
ttget "inception"             Search and download directly
ttget -h                      Show detailed help
```

Searches YTS for movies. Pick a movie, pick a quality (720p, 1080p),
and it downloads via aria2 magnet link.

### thelp — Toolkit Help

```
thelp                         Show all commands, usage, and info
```

## Download Locations

| Command | Save path |
|---------|-----------|
| `vtool`, `vall`, `ttget` | `~/storage/downloads/` |
| `tsopt` | `~/storage/downloads/Music/` |
| `tani` | `~/storage/downloads/Anime/` |

## Requirements

- Android 7+
- Termux (F-Droid version recommended)
- Storage permission
- Internet connection

## Troubleshooting

| Problem | Solution |
|---------|----------|
| `ttget` timeout | ISP blocks YTS. Use a VPN or Cloudflare WARP. |
| `tsopt` fails | Reinstall: `pip install spotdl` |
| `vtool` fails | Update: `pip install --upgrade yt-dlp` |
| `tani` no valid sources | Use download instead: `tani -d "name"` |
| Aliases not working | Run: `source ~/.bashrc` |
| Permission denied | Run: `termux-setup-storage` |

## Contact Developer

For questions, suggestions, or issues:

- **GitHub**: [pricne/termux-toolkit](https://github.com/pricne/termux-toolkit)
- **LinkedIn**: [Profile](https://www.linkedin.com/in/prince-kumar-41659823b)

---

*Built for simplicity. No developer knowledge required.*
