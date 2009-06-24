#!/bin/bash

# 14 64 192 for Launchpad
# 16 24 42 48 (64) 128 256 for Windows

for size in 14 64 192 16 24 42 48 128 256
do
inkscape logo.svg -e logo$size.png -w$size -h$size	
done

# Keep one for the user's guide
cp logo192.png ..

# Make a .ico
icotool -c -o poyta.ico logo16.png logo24.png logo42.png logo48.png logo64.png logo128.png logo256.png

# Make a proper SVG for Gnome icons (useless, but i like to do useless stuff)
inkscape logo.svg -l poyta_icon.svg
