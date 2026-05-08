#!/bin/bash

CYAN='\033[1;36m'; GREEN='\033[1;32m'; YELLOW='\033[1;33m'; RED='\033[1;31m'; NC='\033[0m'

echo -e "${CYAN}=========================================================${NC}"
echo -e "${GREEN}       Termux Media Toolkit - Upgrade                    ${NC}"
echo -e "${CYAN}=========================================================${NC}"
echo ""

ERRORS=0
UPDATED=()
STASHED=false

# ─── [1] Verify Environment ──────────────────────────────────────────────────

echo -e "${YELLOW}[1/6]${NC} Verifying environment..."

if ! command -v git &>/dev/null; then
  echo -e "${RED}  git is not installed.${NC}"
  echo -e "${YELLOW}  Install: pkg install git${NC}"
  exit 1
fi

if [ ! -d ".git" ]; then
  echo -e "${RED}  Not a git repository. Run this from inside the termux-toolkit folder.${NC}"
  exit 1
fi

if ! git remote -v | grep -q "origin"; then
  echo -e "${RED}  No remote 'origin' configured. Cannot pull updates.${NC}"
  exit 1
fi

if [ -z "$PREFIX" ]; then
  echo -e "${YELLOW}  PREFIX not set. Assuming Termux default: /data/data/com.termux/files/usr${NC}"
  PREFIX="/data/data/com.termux/files/usr"
fi

echo -e "${GREEN}  Environment OK${NC}"

# ─── [2] Stash local changes ─────────────────────────────────────────────────

echo -e "\n${YELLOW}[2/6]${NC} Checking for local changes..."

if ! git diff --quiet || ! git diff --cached --quiet; then
  echo -e "${YELLOW}  Local changes detected. Stashing temporarily...${NC}"
  git stash push -m "upgrade.sh auto-stash" 2>/dev/null
  STASHED=true
  echo -e "${GREEN}  Stashed.${NC}"
else
  echo -e "${GREEN}  No local changes.${NC}"
fi

# ─── [3] Pull latest code ────────────────────────────────────────────────────

echo -e "\n${YELLOW}[3/6]${NC} Pulling latest code from GitHub..."

PULL_OUTPUT=$(git pull origin main 2>&1)
PULL_EXIT=$?

if [ $PULL_EXIT -ne 0 ]; then
  echo -e "${RED}  git pull failed.${NC}"
  if echo "$PULL_OUTPUT" | grep -qi "could not resolve\|Connection refused\|Network is unreachable\|timeout"; then
    echo -e "${YELLOW}  No internet connection. Working with local files only.${NC}"
  elif echo "$PULL_OUTPUT" | grep -qi "conflict"; then
    echo -e "${RED}  Merge conflict detected. Resolve manually, then re-run.${NC}"
    exit 1
  else
    echo -e "${RED}  $PULL_OUTPUT${NC}"
    ERRORS=1
  fi
elif echo "$PULL_OUTPUT" | grep -qi "Already up[ -]to[ -]date"; then
  echo -e "${GREEN}  Already on the latest version.${NC}"
else
  echo -e "${GREEN}  Pulled latest changes.${NC}"
fi

# ─── [4] Update scripts (checksum diff) ──────────────────────────────────────

echo -e "\n${YELLOW}[4/6]${NC} Updating toolkit scripts..."

SCRIPT_DIR="./scripts"
BIN_DIR="$PREFIX/bin"
SCRIPTS="vtool vall tsopt tani ttget thelp"

for script in $SCRIPTS; do
  local_path="$SCRIPT_DIR/$script"
  bin_path="$BIN_DIR/$script"

  if [ ! -f "$local_path" ]; then
    echo -e "${RED}  $local_path not found in repo, skipping${NC}"
    continue
  fi

  if [ ! -f "$bin_path" ]; then
    echo -e "${YELLOW}  $script not installed. Installing...${NC}"
    cp "$local_path" "$bin_path" 2>/dev/null && chmod +x "$bin_path"
    echo -e "${GREEN}  $script installed${NC}"
    UPDATED+=("$script")
    continue
  fi

  local_hash=$(sha256sum "$local_path" | awk '{print $1}')
  bin_hash=$(sha256sum "$bin_path" | awk '{print $1}')

  if [ "$local_hash" != "$bin_hash" ]; then
    echo -e "${YELLOW}  $script has updates. Copying...${NC}"
    cp "$local_path" "$bin_path" && chmod +x "$bin_path"
    echo -e "${GREEN}  $script updated${NC}"
    UPDATED+=("$script")
  else
    echo -e "${GREEN}  $script up to date${NC}"
  fi
done

# ─── [5] Update aliases ──────────────────────────────────────────────────────

echo -e "\n${YELLOW}[5/6]${NC} Checking shell aliases..."

BASHRC="$HOME/.bashrc"
ALIAS_MARKER="# Termux Media Toolkit Aliases"
UPDATE_ALIASES=false

if [ -f "$BASHRC" ] && grep -q "$ALIAS_MARKER" "$BASHRC"; then
  echo -e "${GREEN}  Aliases already present${NC}"
else
  UPDATE_ALIASES=true
fi

if $UPDATE_ALIASES; then
  sed -i '/# Termux Media Toolkit Aliases/,/^$/d' "$BASHRC" 2>/dev/null
  sed -i '/alias ytvideo=/d' "$BASHRC" 2>/dev/null
  sed -i '/alias ytmp3=/d' "$BASHRC" 2>/dev/null
  sed -i '/alias ytlist=/d' "$BASHRC" 2>/dev/null

  cat <<'EOF' >> "$BASHRC"

# Termux Media Toolkit Aliases
alias ytvideo='yt-dlp -f "bestvideo[ext=mp4]+bestaudio[ext=m4a]/best[ext=mp4]/best"'
alias ytmp3='yt-dlp -x --audio-format mp3 --audio-quality 0'
alias ytlist='yt-dlp -x --audio-format mp3 --yes-playlist'
EOF
  echo -e "${GREEN}  Aliases added to ~/.bashrc${NC}"
fi

# ─── [6] Verify dependencies ────────────────────────────────────────────────

echo -e "\n${YELLOW}[6/6]${NC} Verifying dependencies..."
DEPS="python pip curl ffmpeg aria2"
MISSING=()
for dep in $DEPS; do
  if ! command -v "$dep" &>/dev/null; then
    MISSING+=("$dep")
  fi
done

if [ ${#MISSING[@]} -gt 0 ]; then
  echo -e "${YELLOW}  Missing tools: ${MISSING[*]}${NC}"
  echo -e "${YELLOW}  Install with: pkg install ${MISSING[*]}${NC}"
else
  echo -e "${GREEN}  All required tools present${NC}"
fi

# ─── Re-apply stash ─────────────────────────────────────────────────────────

if $STASHED; then
  echo ""
  echo -e "${YELLOW}Re-applying local changes...${NC}"
  if git stash pop 2>/dev/null; then
    echo -e "${GREEN}  Local changes restored.${NC}"
  else
    echo -e "${RED}  Merge conflict when restoring. Resolve with: git stash pop${NC}"
    ERRORS=1
  fi
fi

# ─── Done ────────────────────────────────────────────────────────────────────

echo ""
echo -e "${CYAN}=========================================================${NC}"

if [ $ERRORS -eq 0 ] && [ ${#UPDATED[@]} -eq 0 ]; then
  echo -e "${GREEN}            Everything is up to date!${NC}"
elif [ $ERRORS -eq 0 ] && [ ${#UPDATED[@]} -gt 0 ]; then
  echo -e "${GREEN}            Upgrade Complete!                           ${NC}"
else
  echo -e "${YELLOW}            Upgrade finished with warnings              ${NC}"
fi

echo -e "${CYAN}=========================================================${NC}"
echo ""

if [ ${#UPDATED[@]} -gt 0 ]; then
  echo -e "${GREEN}  Updated:${NC} ${UPDATED[*]}"
fi

if [ ${#MISSING[@]} -gt 0 ]; then
  echo -e "${YELLOW}  Missing deps:${NC} ${MISSING[*]}"
  echo -e "${YELLOW}  Install: pkg install ${MISSING[*]}${NC}"
fi

echo ""
echo -e "${YELLOW}  Run 'source ~/.bashrc' to reload aliases.${NC}"
echo ""
echo -e "${GREEN}Run 'thelp' to see all commands.${NC}"
