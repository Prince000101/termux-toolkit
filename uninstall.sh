#!/bin/bash

echo "Uninstalling Termux Media Toolkit..."

# Remove scripts
rm -f $PREFIX/bin/vtool $PREFIX/bin/vall $PREFIX/bin/tsopt $PREFIX/bin/tani $PREFIX/bin/ttget $PREFIX/bin/thelp

# Remove aliases
sed -i '/# Termux Media Toolkit Aliases/,/^$/d' ~/.bashrc 2>/dev/null
sed -i '/alias ytvideo=/d' ~/.bashrc 2>/dev/null
sed -i '/alias ytmp3=/d' ~/.bashrc 2>/dev/null
sed -i '/alias ytlist=/d' ~/.bashrc 2>/dev/null

# Remove pip packages
pip uninstall yt-dlp spotdl -y 2>/dev/null

# Remove pkg packages
pkg remove python ffmpeg aria2 nodejs fzf ani-cli -y 2>/dev/null

# Remove folder
cd "$HOME" && rm -rf "$(dirname "$(readlink -f "$0")")" 2>/dev/null

echo "Done. Run 'source ~/.bashrc' or restart Termux."
