#!/bin/bash

# 14 64 192 for Launchpad
# 16 24 32 48 (64) 256 for Windows
# (16) (32) 128 (256) 512 for Mac OS X
# Just SVG for Gnome

for size in 14 64 192 16 24 32 48 256 128 512
do
inkscape logo.svg -e logo$size.png -w$size -h$size	
done

# Keep one for the user's guide
cp logo192.png ..

# Make a .ico
icotool -c -o poyta.ico logo16.png logo24.png logo32.png logo48.png logo64.png logo256.png

# Make a proper SVG for Gnome icons (useless, but i like to do useless stuff)
inkscape logo.svg -l poyta_icon.svg

# Make a .icns by hand with Icon Composer
