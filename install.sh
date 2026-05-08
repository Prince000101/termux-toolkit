#!/bin/bash

CYAN='\033[1;36m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
RED='\033[1;31m'
NC='\033[0m'

echo -e "${CYAN}=========================================================${NC}"
echo -e "${GREEN}       Termux Media Toolkit - Complete Installation       ${NC}"
echo -e "${CYAN}=========================================================${NC}"

# 1. Update and Upgrade
echo -e "\n${YELLOW}[1/8] Updating packages...${NC}"
pkg update -y && pkg upgrade -y

# 2. Grant Storage Permission
echo -e "\n${YELLOW}[2/8] Requesting storage permission...${NC}"
termux-setup-storage

# 3. Install Base Dependencies
echo -e "\n${YELLOW}[3/8] Installing base dependencies...${NC}"
pkg install -y python ffmpeg aria2 nodejs fzf

# 4. Install Python Tools
echo -e "\n${YELLOW}[4/8] Installing Python packages (yt-dlp, spotdl)...${NC}"
pip install yt-dlp 2>/dev/null && echo -e "${GREEN}  yt-dlp installed${NC}" || echo -e "${RED}  yt-dlp failed${NC}"

pip install spotdl 2>/dev/null && echo -e "${GREEN}  spotdl installed${NC}" || {
    echo -e "${YELLOW}  Trying spotdl Termux script...${NC}"
    curl -L https://raw.githubusercontent.com/spotDL/spotify-downloader/master/scripts/termux.sh 2>/dev/null | sh 2>/dev/null
    pip install spotdl 2>/dev/null && echo -e "${GREEN}  spotdl installed${NC}" || echo -e "${RED}  spotdl failed (install later: pip install spotdl)${NC}"
}

# 5. Install Termux-Specific Tools
echo -e "\n${YELLOW}[5/8] Installing Termux tools (ani-cli)...${NC}"
pkg install -y ani-cli 2>/dev/null && echo -e "${GREEN}  ani-cli installed${NC}" || echo -e "${RED}  ani-cli not found (install later: pkg install ani-cli)${NC}"

# 6. Install Toolkit Scripts
echo -e "\n${YELLOW}[6/8] Installing toolkit scripts...${NC}"
SCRIPT_DIR="./scripts"
SCRIPTS="vtool vall tsopt tani ttget thelp"

# Remove any old-format scripts that might exist
for old in ytool yall yspot ymusic yani yanime tget ymovie; do
    rm -f "$PREFIX/bin/$old" 2>/dev/null
done

for script in $SCRIPTS; do
    if [ -f "$SCRIPT_DIR/$script" ]; then
        cp "$SCRIPT_DIR/$script" "$PREFIX/bin/$script"
        chmod +x "$PREFIX/bin/$script"
        echo -e "${GREEN}  $script installed${NC}"
    else
        echo -e "${RED}  $SCRIPT_DIR/$script not found, skipping${NC}"
    fi
done

# 7. Setup Aliases
echo -e "\n${YELLOW}[7/8] Setting up shell aliases...${NC}"
BASHRC="$HOME/.bashrc"
touch "$BASHRC"

sed -i '/# Termux Media Toolkit Aliases/,/^$/d' "$BASHRC"
sed -i '/alias ytvideo=/d' "$BASHRC"
sed -i '/alias ytmp3=/d' "$BASHRC"
sed -i '/alias ytlist=/d' "$BASHRC"

cat <<'EOF' >> "$BASHRC"

# Termux Media Toolkit Aliases
alias ytvideo='yt-dlp -f "bestvideo[ext=mp4]+bestaudio[ext=m4a]/best[ext=mp4]/best"'
alias ytmp3='yt-dlp -x --audio-format mp3 --audio-quality 0'
alias ytlist='yt-dlp -x --audio-format mp3 --yes-playlist'
EOF

echo -e "${GREEN}  Aliases added to ~/.bashrc${NC}"

# 8. Done
echo -e "\n${CYAN}=========================================================${NC}"
echo -e "${GREEN}            Installation Complete!                       ${NC}"
echo -e "${CYAN}=========================================================${NC}"
echo ""
echo -e "${YELLOW}Available Commands:${NC}"
echo ""
echo -e "  ${GREEN}vtool${NC}       Video downloader         (YouTube, any site)"
echo -e "  ${GREEN}vall${NC}        Universal quick download  (paste any URL)"
echo -e "  ${GREEN}tsopt${NC}       Spotify music downloader  (tracks/albums/playlists)"
echo -e "  ${GREEN}tani${NC}        Anime downloader/streamer (ani-cli)"
echo -e "  ${GREEN}ttget${NC}       Movie torrent downloader  (YTS + aria2)"
echo -e "  ${GREEN}thelp${NC}       Show this help overview"
echo ""
echo -e "${YELLOW}Quick Aliases:${NC}"
echo -e "  ${GREEN}ytvideo${NC} <URL>    Download best MP4"
echo -e "  ${GREEN}ytmp3${NC} <URL>      Download best MP3"
echo -e "  ${GREEN}ytlist${NC} <URL>     Download playlist as MP3s"
echo ""
echo -e "${YELLOW}All commands support -h or --help for detailed usage.${NC}"
echo ""
echo -e "${YELLOW}IMPORTANT:${NC} Restart Termux or run ${CYAN}source ~/.bashrc${NC}"
echo -e ""
echo -e "${GREEN}Happy downloading!${NC}"
