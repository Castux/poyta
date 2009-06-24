#!/bin/bash

# First make sure that you have the Windows binaries in 
# love-0.5-0-win32.zip and luasocket-2.0.2-lua-5.1.2-Win32-vc8.zip

REL=poyta-rel
WIN=poyta-win
LIN=poyta-linux
MAC=poyta-mac

# Export a release from the bazaar branch
bzr export $REL

# Make the .love
cd $REL/src
zip -qr poyta.love .
mv poyta.love ..
cd ../..

## WINDOWS

# Get ready our binaries
unzip -q love-0.5-0-win32.zip
mv love-0.5-0 $WIN

# Make client
cat $WIN/love.exe $REL/poyta.love > $WIN/poyta.exe
rm $WIN/love.exe

# Make server
cp -r $REL/src/common $REL/src/server $WIN/
unzip -q luasocket-2.0.2-lua-5.1.2-Win32-vc8.zip -d $WIN/server/

echo "CD server
lua5.1.exe servermain.lua 6666" > $WIN/server.bat

# Add doc for the fun of it
cp $REL/User\'s\ guide.htm $REL/logo192.png $WIN/

# And icon (still needs manual resource replacement)
cp $REL/icon/poyta.ico $WIN/
echo $WIN: Need to replace the icon manually


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


## MAC OS X
# This is the über cheat. We make the app look like data
# and the .love look like the app, so users can double click it.
# (instead of dragging the .love on love.app)

mkdir $MAC

# Server
cp -r $REL/src/common $REL/src/server $MAC/

unzip -q luasocket-mac-build.zip
cp -r luasocket-mac-build/build/* $MAC/server/
echo "cd server
./lua5.1 servermain.lua 6666" > $MAC/server.sh
chmod u+x $MAC/server.sh

rm -r luasocket-mac-build

# Client: symlinks die somewhere in the process. Do it by hand.
cp $REL/icon/poyta.icns $MAC
cp $REL/poyta.love $MAC
echo $MAC: Need to build bundle manually.

# Doc
cp $REL/User\'s\ guide.htm $REL/logo192.png $MAC/
