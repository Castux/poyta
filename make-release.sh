#!/bin/bash

# First make sure that you have the Windows binaries in 
# love-0.5-0-win32.zip and luasocket-2.0.2-lua-5.1.2-Win32-vc8.zip

REL=poyta-rel
WIN=poyta-win
LIN=poyta-linux

# Export a release from the bazaar branch
bzr export $REL

# Make the .love is done
cd $REL/src
zip -r poyta.love .
mv poyta.love ..
cd ../..

## WINDOWS

# Get ready our binaries
unzip love-0.5-0-win32.zip
mv love-0.5-0 $WIN

# Make client
cat $WIN/love.exe $REL/poyta.love > $WIN/poyta.exe
rm $WIN/love.exe

# Make server
cp -r $REL/src/common $REL/src/server $WIN/
unzip luasocket-2.0.2-lua-5.1.2-Win32-vc8.zip -d $WIN/server/

echo "CD server
lua5.1.exe servermain.lua 6666" > $WIN/server.bat

# Add doc for the fun of it
cp $REL/User\'s\ guide.htm $REL/logo192.png $WIN/

# And icon (still needs manual resource replacement)
cp $REL/icon/poyta.ico $WIN/

## LINUX

mkdir $LIN

# Client
cat `which love` $REL/poyta.love > $LIN/poyta
chmod u+x $LIN/poyta

# Server
cp -r $REL/src/common $REL/src/server $LIN/

echo "cd server
lua servermain.lua 6666" > $LIN/server.sh
chmod u+x $LIN/server.sh

# Doc
cp $REL/User\'s\ guide.htm $REL/logo192.png $LIN/

# Icon (not sure how usefull that is... make a full .desktop?)
cp $REL/icon/poyta_icon.svg $LIN/
