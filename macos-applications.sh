#!/usr/bin/env bash

SOURCE=$1   # e.g. "/TM Restore 2018-03-14/Users/steve"

if [ ! -d "$SOURCE" ]; then
    clear
  	echo "ERROR: The source directory '${SOURCE}' doesn't exist."
    exit 1
fi

TARGET="/Users/steve"

# Some settings are dependant on the computer model. MODEL_NAME is used to decide which settings are appropriate.
MODEL_NAME=`system_profiler SPHardwareDataType | awk '/Model Name/ {print tolower($3)}'`

HOSTNAME=`scutil --get HostName | awk '{print tolower($1)}'`

# Include .hidden files
shopt -s dotglob

# User Launch Agents:
# Housekeep
if [ -f "/Users/steve/Dropbox/BASH Scripts/housekeep.rb" ]; then
    if [ -f "/Users/steve/Dropbox/housekeep-$HOSTNAME.log" ]; then
        mv "$SOURCE"/steve/Library/LaunchAgents/com.steve.housekeep.box-sync.plist "$TARGET"/Library/LaunchAgents/com.steve.housekeep.box-sync.plist
        if [ $? == 0 ]; then launchctl load "$TARGET"/Library/LaunchAgents/com.steve.housekeep.box-sync.plist; fi

        mv "$SOURCE"/steve/Library/LaunchAgents/com.steve.housekeep.desktop-filing.plist "$TARGET"/Library/LaunchAgents/com.steve.housekeep.desktop-filing.plist
        if [ $? == 0 ]; then launchctl load "$TARGET"/Library/LaunchAgents/com.steve.housekeep.desktop-filing.plist; fi

        mv "$SOURCE"/steve/Library/LaunchAgents/com.steve.housekeep.downloads.plist "$TARGET"/Library/LaunchAgents/com.steve.housekeep.downloads.plist
        if [ $? == 0 ]; then launchctl load "$TARGET"/Library/LaunchAgents/com.steve.housekeep.downloads.plist; fi
    fi
fi

# Services
rm -rf $TARGET/Library/Services
mkdir -p $TARGET/Library/Services
mv $SOURCE/steve/Library/Services/* $TARGET/Library/Services

# Airmail 3
rm -rf $TARGET/Library/Services/Group\ Containers/2E337YPCZY.airmail
mkdir -p $TARGET/Library/Group\ Containers/2E337YPCZY.airmail
mv $SOURCE/steve/Library/Group\ Containers/2E337YPCZY.airmail/* $TARGET/Library/Group\ Containers/2E337YPCZY.airmail
mv $SOURCE/steve/Library/Preferences/it.bloop.airmail2.plist $TARGET/Library/Preferences/it.bloop.airmail2.plist



# Exclude .hidden files
shopt -u dotglob
