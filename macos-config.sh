#!/usr/bin/env bash


# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# NOTES
# 1. Adapted from macos.sh @ https://mths.be/macos
# 2. The domain NSGlobalDomain is synonymous with the domain .GlobalPreferences
# 3. USAGE: bash "/Volumes/Install macOS High Sierra/macOS Configuration/macos-config.sh"
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

# Do not run this script as root
if [[ $EUID -eq 0 ]]; then
    clear
    echo -ne '\007'
    echo "ERROR: This script must NOT be run as root" 1>&2
    sudo -k
    exit 1
fi

# AppleScript to check if GUI Scripting is enabled. Will rightly fail for new macOS installations.
# If called by `Script Editor` then `Script Editor` must be checked in System Preferences > Security & Privacy > Privacy > Accessibility
# If called by `Terminal` (this case) then `Terminal` must be checked in System Preferences > Security & Privacy > Privacy > Accessibility
# If called by `iTerm` then `iTerm` must be checked in System Preferences > Security & Privacy > Privacy > Accessibility
osascript <<EOD
    # check to see if assistive devices is enabled
	tell application "System Events"
		set UI_enabled to UI elements enabled
	end tell
	if UI_enabled is false then
		tell application "System Preferences"
			activate
			set current pane to pane id "com.apple.preference.security"
			reveal anchor "Privacy_Assistive" of pane id "com.apple.preference.security"
			display dialog "This script utilizes the built-in Graphical User Interface Scripting architecture of macOS which is currently disabled." & return & return & "You can enable GUI Scripting by checking  \"Script Editor\", \"Terminal\" and/or \"iTerm\" in System Preferences > Security & Privacy > Privacy > Accessibility." with icon 1 buttons {"Cancel"} default button 1 giving up after 200
		end tell
	end if
    #tell application "Terminal" to activate
EOD

EXITCODE=$?

# If GUI Scripting is not enabled, the AppleScript above exits with a code of 1 and we do not want to continue
if [[ $EXITCODE -eq 1 ]]; then
    echo -ne '\007'
    clear
    echo "ERROR: AppleScript has cancelled this bash script"
    exit 1
fi

# Everything's OK so far. Let's continue....

# Absolute path to this script, e.g. /home/user/bin/foo.sh
#SCRIPT=$(readlink -f "$0")	# `-f` option for `readlink` doesn't work on macOS
# Absolute path this script is in, thus /home/user/bin
SCRIPTPATH=$(dirname "$0")

# Close any open System Preferences panes, to prevent them from overriding
# settings we’re about to change
osascript -e 'tell application "System Preferences" to quit'

# Ask for the administrator password upfront
sudo -v

# Keep-alive: update existing `sudo` time stamp until `.macos` has finished or `sudo -k`
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

# Some settings are dependant on the computer model. MODEL_NAME is used to decide which settings are appropriate.
MODEL_NAME=`system_profiler SPHardwareDataType | awk '/Model Name/ {print tolower($3)}'`
echo "Model Name is $MODEL_NAME"


# System Preferences > General > Sidebar icon size:
# Small [1] / Medium [2] / Large [3]
defaults write NSGlobalDomain NSTableViewDefaultSizeMode -int 1


# System Preferences > Desktop & Screen Saver > Screen Saver > Start after:
# Never [0] / 1 Minute [60] / 2 Minutes [120] / 5 Minutes [300] / 10 Minutes [600] / 20 Minutes [1200] / 30 Minutes [1800] / 1 Hour [3600]
defaults -currentHost write com.apple.screensaver idleTime -int 0


# System Preferences > Dock > Size:
# Small[ 16] --> Large [128]
defaults write com.apple.dock tilesize -float 16

# System Preferences > Dock > Magnification:
# Checked [true] / Unchecked [false]
defaults write com.apple.dock magnification -bool true

# System Preferences > Dock > Magnification:
# Small [16] --> Large [128]
defaults write com.apple.dock largesize -float 128

# System Preferences > Dock > Position on screen:
# Left ["left"] / Bottom ["bottom"] / Right ["right"]
defaults write com.apple.dock orientation -string "bottom"

# System Preferences > Dock > Minimize windows using:
# Genie effect ["genie"] / Scale effect ["scale"]
defaults write com.apple.dock mineffect -string "genie"

# System Preferences > Dock > Prefer tabs when opening documents:
# Always ["always"] / In Full Screen Only ["fullscreen"] / Manually ["manual"]
defaults write NSGlobalDomain AppleWindowTabbingMode -string "fullscreen"

# System Preferences > Dock > Double click a window's title bar to
# minimize ["Minimize"] / zoom ["Maximize"]
defaults write NSGlobalDomain AppleActionOnDoubleClick -string "Maximize"

# System Preferences > Dock > Minimize windows into application item
# Checked [true] / Unchecked [false]
defaults write com.apple.dock minimize-to-application -bool false

# System Preferences > Dock > Animate opening applications
# Checked [true] / Unchecked [false]
defaults write com.apple.dock launchanim -bool true

# System Preferences > Dock > Autmatically hide and show the Dock
# Checked [true] / Unchecked [false]
defaults write com.apple.dock autohide -bool true

# System Preferences > Dock > Show indicators for open applications
# Checked [true] / Unchecked [false]
defaults write com.apple.dock show-process-indicators -bool true

# Enable highlight hover effect for the grid view of a stack (Dock)
defaults write com.apple.dock mouse-over-hilite-stack -bool true



if [ "$MODEL_NAME" == "imac" ]; then

    # System Preferences > Energy Saver > Turn display off after:
    # 1 min [1] --> 3 hrs [180], Never [0]
    sudo pmset -c displaysleep 1

    # System Preferences > Energy Saver > Prevent computer from sleeping automatically when the display is off
    # Checked [0] / Unchecked [1] (Yes. When this option is checked `sleep` = 0)
    sudo pmset -c sleep 0

    # System Preferences > Energy Saver > Put hard disks to sleep when possible
    # Checked [1] / Unchecked [0]
    sudo pmset -c disksleep 0

    # System Preferences > Energy Saver > Wake for network access
    # Checked [1] / Unchecked [0]
    sudo pmset -c womp 0

    # System Preferences > Energy Saver > Start up automatically after power failure
    # Checked [1] / Unchecked [0]
    sudo pmset -c autorestart 0

    # System Preferences > Energy Saver > Enable Power Nap
    # Checked [1] / Unchecked [0]
    sudo pmset -c powernap 0

elif [ "$MODEL_NAME" == "macbook" ]; then

    # Battery Settings [-b]

    # System Preferences > Energy Saver > Battery > Turn display off after:
    # 1 min [1] --> 3 hrs [180], Never [0]
    sudo pmset -b displaysleep 1

    # System Preferences > Energy Saver > Battery > Put hard disks to sleep when possible
    # Checked [1] / Unchecked [0]
    sudo pmset -b disksleep 0

    # System Preferences > Energy Saver > Battery > Slightly dim the display while on battery power
    # Checked [1] / Unchecked [0]
    sudo pmset -b lessbright 1

    # System Preferences > Energy Saver > Battery > Enable Power Nap while on battery power
    # Checked [1] / Unchecked [0]
    sudo pmset -b powernap 0


    # Power Adapter Settings [-c]

    # System Preferences > Energy Saver > Power Adapter > Turn display off after:
    # 1 min [1] --> 3 hrs [180], Never [0]
    sudo pmset -c displaysleep 1

    # System Preferences > Energy Saver > Power Adapter > Prevent computer from sleeping automatically when the display is off
    # Checked [0] / Unchecked [1] (Yes. When this option is checked `sleep` = 0)
    sudo pmset -c sleep 0

    # System Preferences > Energy Saver > Power Adapter > Put hard disks to sleep when possible
    # Checked [1] / Unchecked [0]
    sudo pmset -c disksleep 0

    # System Preferences > Energy Saver > Power Adapter > Wake for Wi-Fi network access
    # Checked [1] / Unchecked [0]
    sudo pmset -c womp 0

    # System Preferences > Energy Saver > Power Adapter > Enable Power Nap while plugged into a power adapter
    # Checked [1] / Unchecked [0]
    sudo pmset -c powernap 0

fi


# System Preferences > Sharing > Computer Name:
if [ "$MODEL_NAME" == "imac" ]; then
    sudo scutil --set ComputerName "Steve’s iMac 27\" 5K"   # 0x5374657665277320694d61632032372220354b in Hex
    sudo scutil --set HostName "Steves-iMac-27-5K"          # 0x5374657665732d694d61632d32372d354b in Hex
    sudo scutil --set LocalHostName "Steves-iMac-27-5K"     # 0x5374657665732d694d61632d32372d354b in Hex
# `NetBIOSName` is currently set automatically to `IMAC-1C061E`. Do not overwrite it.
    #sudo defaults write /Library/Preferences/SystemConfiguration/com.apple.smb.server NetBIOSName -string "0x6D746873"
# 'ServerDescription' is currently set automatically to `Steve's iMac 27" 5K`. Do not overwrite it.
    #sudo defaults write /Library/Preferences/SystemConfiguration/com.apple.smb.server ServerDescription -string "0x6D746873"

elif [ "$MODEL_NAME" == "macbook" ]; then
    sudo scutil --set ComputerName "Steve’s MacBook Pro"    # 0x53746576652773204d6163426f6f6b2050726f in Hex
    sudo scutil --set HostName "Steves-MacBook-Pro"         # 0x5374657665732d4d6163426f6f6b2d50726f in Hex
    sudo scutil --set LocalHostName "Steves-MacBook-Pro"    # 0x5374657665732d4d6163426f6f6b2d50726f in Hex
# NetBIOSName is currently set automatically to `Steves MBP`.Do not overwrite it.
    #sudo defaults write /Library/Preferences/SystemConfiguration/com.apple.smb.server NetBIOSName -string "0x6D746873"
# 'ServerDescription' is currently set automatically to `Steve’s MacBook Pro`. Do not overwrite it.
    #sudo defaults write /Library/Preferences/SystemConfiguration/com.apple.smb.server ServerDescription -string "0x6D746873"
fi


# System Preferences > Keyboard > Text > Use smart quotes and dashes
# Checked [true] / Unchecked [false]
defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false


# System Preferences > Mouse > Scroll direction: Natural
# Checked [true] / Unchecked [false]
defaults write NSGlobalDomain com.apple.swipescrolldirection -bool false


# System Preferences > Date & Time > Time options:
# Digital [false] / Analog [true]
defaults write com.apple.menuextra.clock IsAnalog -bool false

# System Preferences > Date & Time > Flash the time separators
# Checked [true] / Unchecked [false]
defaults write com.apple.menuextra.clock FlashDateSeparators -bool false

# System Preferences > Date & Time > Use a 24-hour clock - Checked [HH:mm]
# System Preferences > Date & Time > Show the day of the week - Checked [EEE]
# System Preferences > Date & Time > Show date - Checked [d MMM]
# This is combination 25. See https://codepad.co/snippet/v5lCBcXj for all valid combinations.
defaults write com.apple.menuextra.clock DateFormat -string "EEE d MMM HH:mm"



# Delete `persistent-others` key from com.apple.dock.plist. For fresh installs this should only contain data on the Downloads folder and will be added back to the Dock below exactly the same except `showas` is changed from `1` [Fan] to `2` [Grid]
/usr/libexec/PlistBuddy -c "Delete :persistent-others" ~/Library/Preferences/com.apple.dock.plist

# Add Downloads folder [back] to Dock and display in grid view
defaults write com.apple.dock persistent-others -array-add '<dict><key>GUID</key><integer>3485233380</integer><key>tile-data</key><dict><key>arrangement</key><integer>2</integer><key>book</key><data>Ym9vazADAAAAAAQQMAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAALAIAAAUAAAABAQAAVXNlcnMAAAAFAAAAAQEAAHN0ZXZlAAAACQAAAAEBAABEb3dubG9hZHMAAAAMAAAAAQYAAAQAAAAUAAAAJAAAAAgAAAAEAwAAqxsGAAAAAAAIAAAABAMAAAmPBgAAAAAACAAAAAQDAABCxw0AAAAAAAwAAAABBgAATAAAAFwAAABsAAAACAAAAAAEAABBvMrETAAAABgAAAABAgAAAgAAAAAAAAAPAAAAAAAAAAAAAAAAAAAACAAAAAQDAAABAAAAAAAAAAQAAAADAwAA9QEAAAgAAAABCQAAZmlsZTovLy8MAAAAAQEAAE1hY2ludG9zaCBIRAgAAAAEAwAAAAAcru0AAAAIAAAAAAQAAEG/iMbSAAAAJAAAAAEBAABCOUU2M0Y4MC0yNTUzLTNGMzctOTkzMy00MDJBNUUzMkZGNUQYAAAAAQIAAIEAAAABAAAA7xMAAAEAAAAAAAAAAAAAAAEAAAABAQAALwAAAAAAAAABBQAAoQAAAAECAAAyYjlmYzI4ZWM2NjU1NWVhN2YyNGRmMDQ4ODJkMDJmOGExYThhOWNiOzAwMDAwMDAwOzAwMDAwMDAwOzAwMDAwMDAwMDAwMDAwMjA7Y29tLmFwcGxlLmFwcC1zYW5kYm94LnJlYWQtd3JpdGU7MDE7MDEwMDAwMDg7MDAwMDAwMDAwMDBkYzc0MjsvdXNlcnMvc3RldmUvZG93bmxvYWRzAAAAAMwAAAD+////AQAAAAAAAAAQAAAABBAAADgAAAAAAAAABRAAAHwAAAAAAAAAEBAAAKAAAAAAAAAAQBAAAJAAAAAAAAAAAiAAAGwBAAAAAAAABSAAANwAAAAAAAAAECAAAOwAAAAAAAAAESAAACABAAAAAAAAEiAAAAABAAAAAAAAEyAAABABAAAAAAAAICAAAEwBAAAAAAAAMCAAAHgBAAAAAAAAAcAAAMAAAAAAAAAAEcAAABQAAAAAAAAAEsAAANAAAAAAAAAAgPAAAIABAAAAAAAA</data><key>displayas</key><integer>1</integer><key>file-data</key><dict><key>_CFURLString</key><string>file:///Users/steve/Downloads/</string><key>_CFURLStringType</key><integer>15</integer></dict><key>file-label</key><string>Downloads</string><key>file-mod-date</key><integer>3587709744</integer><key>file-type</key><integer>2</integer><key>parent-mod-date</key><integer>3587709747</integer><key>preferreditemsize</key><integer>-1</integer><key>showas</key><integer>2</integer></dict><key>tile-type</key><string>directory-tile</string></dict>'

# Add Utilities folder to Dock and display in grid view
defaults write com.apple.dock persistent-others -array-add '<dict><key>GUID</key><integer>1129841173</integer><key>tile-data</key><dict><key>arrangement</key><integer>1</integer><key>book</key><data>Ym9va9gCAAAAAAQQMAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA7AEAAAwAAAABAQAAQXBwbGljYXRpb25zCQAAAAEBAABVdGlsaXRpZXMAAAAIAAAAAQYAAAQAAAAYAAAACAAAAAQDAABNAQAAAAAAAAgAAAAEAwAA0JoAAAAAAAAIAAAAAQYAADwAAABMAAAACAAAAAAEAABBv4NcGwAAABgAAAABAgAAAgAAAAAAAAAPAAAAAAAAAAAAAAAAAAAAAAAAAAEFAAAIAAAAAQkAAGZpbGU6Ly8vDAAAAAEBAABNYWNpbnRvc2ggSEQIAAAABAMAAAAAHK7tAAAACAAAAAAEAABBv4jG0gAAACQAAAABAQAAQjlFNjNGODAtMjU1My0zRjM3LTk5MzMtNDAyQTVFMzJGRjVEGAAAAAECAACBAAAAAQAAAO8TAAABAAAAAAAAAAAAAAABAAAAAQEAAC8AAACiAAAAAQIAADEwZjU2ZThlYzgyZThkMWY1NTE4ZTM3NzZlYmFiMjQzYmUxZjM1ODA7MDAwMDAwMDA7MDAwMDAwMDA7MDAwMDAwMDAwMDAwMDAyMDtjb20uYXBwbGUuYXBwLXNhbmRib3gucmVhZC13cml0ZTswMTswMTAwMDAwODswMDAwMDAwMDAwMDA5YWQwOy9hcHBsaWNhdGlvbnMvdXRpbGl0aWVzAAAAtAAAAP7///8BAAAAAAAAAA4AAAAEEAAALAAAAAAAAAAFEAAAXAAAAAAAAAAQEAAAfAAAAAAAAABAEAAAbAAAAAAAAAACIAAANAEAAAAAAAAFIAAApAAAAAAAAAAQIAAAtAAAAAAAAAARIAAA6AAAAAAAAAASIAAAyAAAAAAAAAATIAAA2AAAAAAAAAAgIAAAFAEAAAAAAAAwIAAAnAAAAAAAAAAB0AAAnAAAAAAAAACA8AAAQAEAAAAAAAA=</data><key>displayas</key><integer>1</integer><key>file-data</key><dict><key>_CFURLString</key><string>file:///Applications/Utilities/</string><key>_CFURLStringType</key><integer>15</integer></dict><key>file-label</key><string>Utilities</string><key>file-mod-date</key><integer>3587710135</integer><key>file-type</key><integer>2</integer><key>parent-mod-date</key><integer>3587714112</integer><key>preferreditemsize</key><integer>-1</integer><key>showas</key><integer>2</integer></dict><key>tile-type</key><string>directory-tile</string></dict>'

# Add Applications folder to Dock and display in grid view
defaults write com.apple.dock persistent-others -array-add '<dict><key>GUID</key><integer>1631236773</integer><key>tile-data</key><dict><key>arrangement</key><integer>1</integer><key>book</key><data>Ym9va6ACAAAAAAQQMAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAtAEAAAwAAAABAQAAQXBwbGljYXRpb25zBAAAAAEGAAAEAAAACAAAAAQDAABNAQAAAAAAAAQAAAABBgAAJAAAAAgAAAAABAAAQb+DXDEAAAAYAAAAAQIAAAIAAAAAAAAADwAAAAAAAAAAAAAAAAAAAAAAAAABBQAACAAAAAEJAABmaWxlOi8vLwwAAAABAQAATWFjaW50b3NoIEhECAAAAAQDAAAAAByu7QAAAAgAAAAABAAAQb+IxtIAAAAkAAAAAQEAAEI5RTYzRjgwLTI1NTMtM0YzNy05OTMzLTQwMkE1RTMyRkY1RBgAAAABAgAAgQAAAAEAAADvEwAAAQAAAAAAAAAAAAAAAQAAAAEBAAAvAAAAmAAAAAECAAA1YTA1MjIzYzA5YzEzNTg1ZWI5YTU2Y2QyZGM3NDI1YzVjYzkwN2ExOzAwMDAwMDAwOzAwMDAwMDAwOzAwMDAwMDAwMDAwMDAwMjA7Y29tLmFwcGxlLmFwcC1zYW5kYm94LnJlYWQtd3JpdGU7MDE7MDEwMDAwMDg7MDAwMDAwMDAwMDAwMDE0ZDsvYXBwbGljYXRpb25zALQAAAD+////AQAAAAAAAAAOAAAABBAAABgAAAAAAAAABRAAADQAAAAAAAAAEBAAAFAAAAAAAAAAQBAAAEAAAAAAAAAAAiAAAAgBAAAAAAAABSAAAHgAAAAAAAAAECAAAIgAAAAAAAAAESAAALwAAAAAAAAAEiAAAJwAAAAAAAAAEyAAAKwAAAAAAAAAICAAAOgAAAAAAAAAMCAAAHAAAAAAAAAAAdAAAHAAAAAAAAAAgPAAABQBAAAAAAAA</data><key>displayas</key><integer>1</integer><key>file-data</key><dict><key>_CFURLString</key><string>file:///Applications/</string><key>_CFURLStringType</key><integer>15</integer></dict><key>file-label</key><string>Applications</string><key>file-mod-date</key><integer>3589443377</integer><key>file-type</key><integer>2</integer><key>parent-mod-date</key><integer>3589376025</integer><key>preferreditemsize</key><integer>-1</integer><key>showas</key><integer>0</integer></dict><key>tile-type</key><string>directory-tile</string></dict>'

# Add Recent Applications to Dock and display in grid view
# Recent Applications = <key>list-type</key><integer>1</integer>
# Icon size = <key>preferreditemsize</key><integer>-1</integer>
# View content as Grid = <key>viewas</key><integer>2</integer>
defaults write com.apple.dock persistent-others -array-add '<dict><key>tile-data</key><dict><key>list-type</key><integer>1</integer><key>preferreditemsize</key><integer>-1</integer><key>viewas</key><integer>2</integer></dict><key>tile-type</key><string>recents-tile</string></dict>'

# Add Recent Documents to Dock and display in grid view
# Recent Documents = <key>list-type</key><integer>2</integer>
# Icon size = <key>preferreditemsize</key><integer>-1</integer>
# View content as Grid = <key>viewas</key><integer>2</integer>
defaults write com.apple.dock persistent-others -array-add '<dict><key>tile-data</key><dict><key>list-type</key><integer>2</integer><key>preferreditemsize</key><integer>-1</integer><key>viewas</key><integer>2</integer></dict><key>tile-type</key><string>recents-tile</string></dict>'


# Save screenshots to /Users/steve/Dropbox/Screen Captures. OK if this location doesn't exist yet.
defaults write com.apple.screencapture location -string "${HOME}/Box Sync/Screen Captures"

# Save screenshots in PNG format (other options: BMP, GIF, JPG, PDF, TIFF)
defaults write com.apple.screencapture type -string "png"

# Disable shadow in screenshots
defaults write com.apple.screencapture disable-shadow -bool true


# Finder > Preferences... > General > Show these items on the desktop: Hard disks
# Checked [true] / Unchecked [false]
defaults write com.apple.finder ShowHardDrivesOnDesktop -bool true

# Finder > Preferences... > General > Show these items on the desktop: External disks
# Checked [true] / Unchecked [false]
defaults write com.apple.finder ShowExternalHardDrivesOnDesktop -bool true

# Finder > Preferences... > General > Show these items on the desktop: CDs, DVDs, and iPods
# Checked [true] / Unchecked [false]
defaults write com.apple.finder ShowRemovableMediaOnDesktop -bool true

# Finder > Preferences... > General > Show these items on the desktop: Connected servers
# Checked [true] / Unchecked [false]
defaults write com.apple.finder ShowMountedServersOnDesktop -bool true

# Finder > Preferences... > General > New Finder windows show: (Both `NewWindowTarget` and the correct corresponding `NewWindowTargetPath` have to be set. <computer name> has no corresponding `NewWindowTargetPath` )
# <computer name> [PfCm] / Macintosh HD [PfVo] / steve [PfHm] / Desktop [PfDe] / Documents [PfDo] / iCloud Drive [PfID] / Recents [PfAF] / Other [PfLo]
defaults write com.apple.finder NewWindowTarget -string "PfHm"
# <computer name> <None> / Macintosh HD [file:///] / steve [file:///Users/steve/] / Desktop [file:///Users/steve/Desktop/] / Documents [file:///Users/steve/Documents/] / iCloud Drive [file:///Users/steve/Library/Mobile%20Documents/com~apple~CloudDocs/] / Recents [file:///System/Library/CoreServices/Finder.app/Contents/Resources/MyLibraries/myDocuments.cannedSearch] / Other [file:///<path>/]
defaults write com.apple.finder NewWindowTargetPath -string "file:///Users/steve/"

# Finder > Preferences... > General > Open folders in tabs instead of new windows
# Checked [true] / Unchecked [false]
defaults write com.apple.finder FinderSpawnTab -bool false

# Finder > Preferences... > Advanced > Show all file name extensions
# Checked [true] / Unchecked [false]
defaults write NSGlobalDomain AppleShowAllExtensions -bool true

# Finder > Preferences... > Advanced > Show warning before changing an extension
# Checked [true] / Unchecked [false]
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool true

# Finder > Preferences... > Advanced > Show warning before removing iCloud Drive
# Checked [true] / Unchecked [false]
defaults write com.apple.finder FXEnableRemoveFromICloudDriveWarning -bool true

# Finder > Preferences... > Advanced > Show warning before emptying the Trash
# Checked [true] / Unchecked [false]
defaults write com.apple.finder WarnOnEmptyTrash -bool true

# Finder > Preferences... > Advanced > Remove items from the Trash after 30 days
# Checked [true] / Unchecked [false]
defaults write com.apple.finder FXRemoveOldTrashItems -bool false

# Finder > Preferences... > Advanced > Keep folders on top when sorting by name
# Checked [true] / Unchecked [false]
defaults write com.apple.finder _FXSortFoldersFirst -bool false

# Finder > Preferences... > Advanced > When performing a search:
# Search This Mac ["SCev"] / Search the Current Folder ["SCcf"] / Use the Previous Search Scope ["SCsp"]
defaults write com.apple.finder FXDefaultSearchScope -string "SCev"

# Finder > View > Hide Tab Bar
defaults write com.apple.finder ShowTabView -bool false

# Finder > View > Show Path Bar
defaults write com.apple.finder ShowPathbar -bool true

# Finder > View > Show Status Bar
defaults write com.apple.finder ShowStatusBar -bool true

# Finder > View > Show Sidebar
defaults write com.apple.finder ShowSidebar -bool true

# Finder > View > Show Preview
defaults write com.apple.finder ShowPreviewPane -bool true

# Show full POSIX path as Finder window title
defaults write com.apple.finder _FXShowPosixPathInTitle -bool true

# Show the ~/Library folder IMPORTANT: No longer works with High Sierra
#chflags nohidden ~/Library

# Show the /Volumes folder
sudo chflags nohidden /Volumes

# Set icon size
if [ "$MODEL_NAME" == "imac" ]; then
    /usr/libexec/PlistBuddy -c "Set :DesktopViewSettings:IconViewSettings:iconSize 64" ~/Library/Preferences/com.apple.finder.plist
    /usr/libexec/PlistBuddy -c "Set :FK_StandardViewSettings:IconViewSettings:iconSize 64" ~/Library/Preferences/com.apple.finder.plist
    /usr/libexec/PlistBuddy -c "Set :StandardViewSettings:IconViewSettings:iconSize 64" ~/Library/Preferences/com.apple.finder.plist
elif [ "$MODEL_NAME" == "macbook" ]; then
    /usr/libexec/PlistBuddy -c "Set :DesktopViewSettings:IconViewSettings:iconSize 52" ~/Library/Preferences/com.apple.finder.plist
    /usr/libexec/PlistBuddy -c "Set :FK_StandardViewSettings:IconViewSettings:iconSize 52" ~/Library/Preferences/com.apple.finder.plist
    /usr/libexec/PlistBuddy -c "Set :StandardViewSettings:IconViewSettings:iconSize 52" ~/Library/Preferences/com.apple.finder.plist
fi

# Set grid spacing
if [ "$MODEL_NAME" == "imac" ]; then
/usr/libexec/PlistBuddy -c "Set :DesktopViewSettings:IconViewSettings:gridSpacing 62" ~/Library/Preferences/com.apple.finder.plist
elif [ "$MODEL_NAME" == "macbook" ]; then
/usr/libexec/PlistBuddy -c "Set :DesktopViewSettings:IconViewSettings:gridSpacing 67" ~/Library/Preferences/com.apple.finder.plist
fi
/usr/libexec/PlistBuddy -c "Set :FK_StandardViewSettings:IconViewSettings:gridSpacing 54" ~/Library/Preferences/com.apple.finder.plist
/usr/libexec/PlistBuddy -c "Set :StandardViewSettings:IconViewSettings:gridSpacing 54" ~/Library/Preferences/com.apple.finder.plist

# Set text size
if [ "$MODEL_NAME" == "imac" ]; then
/usr/libexec/PlistBuddy -c "Set :DesktopViewSettings:IconViewSettings:textSize 12" ~/Library/Preferences/com.apple.finder.plist
elif [ "$MODEL_NAME" == "macbook" ]; then
/usr/libexec/PlistBuddy -c "Set :DesktopViewSettings:IconViewSettings:textSize 11" ~/Library/Preferences/com.apple.finder.plist
fi
/usr/libexec/PlistBuddy -c "Set :FK_StandardViewSettings:IconViewSettings:textSize 12" ~/Library/Preferences/com.apple.finder.plist
/usr/libexec/PlistBuddy -c "Set :StandardViewSettings:IconViewSettings:textSize 12" ~/Library/Preferences/com.apple.finder.plist

# Set label position
/usr/libexec/PlistBuddy -c "Set :DesktopViewSettings:IconViewSettings:labelOnBottom true" ~/Library/Preferences/com.apple.finder.plist
/usr/libexec/PlistBuddy -c "Set :FK_StandardViewSettings:IconViewSettings:labelOnBottom true" ~/Library/Preferences/com.apple.finder.plist
/usr/libexec/PlistBuddy -c "Set :StandardViewSettings:IconViewSettings:labelOnBottom true" ~/Library/Preferences/com.apple.finder.plist

# Set item info
/usr/libexec/PlistBuddy -c "Set :DesktopViewSettings:IconViewSettings:showItemInfo false" ~/Library/Preferences/com.apple.finder.plist
/usr/libexec/PlistBuddy -c "Set :FK_StandardViewSettings:IconViewSettings:showItemInfo false" ~/Library/Preferences/com.apple.finder.plist
/usr/libexec/PlistBuddy -c "Set :StandardViewSettings:IconViewSettings:showItemInfo false" ~/Library/Preferences/com.apple.finder.plist

# Set icon preview
/usr/libexec/PlistBuddy -c "Set :DesktopViewSettings:IconViewSettings:showIconPreview false" ~/Library/Preferences/com.apple.finder.plist
/usr/libexec/PlistBuddy -c "Set :FK_StandardViewSettings:IconViewSettings:showIconPreview true" ~/Library/Preferences/com.apple.finder.plist
/usr/libexec/PlistBuddy -c "Set :StandardViewSettings:IconViewSettings:showIconPreview true" ~/Library/Preferences/com.apple.finder.plist

# Set arrange by
/usr/libexec/PlistBuddy -c "Set :DesktopViewSettings:IconViewSettings:arrangeBy grid" ~/Library/Preferences/com.apple.finder.plist
/usr/libexec/PlistBuddy -c "Set :FK_StandardViewSettings:IconViewSettings:arrangeBy none" ~/Library/Preferences/com.apple.finder.plist
/usr/libexec/PlistBuddy -c "Set :StandardViewSettings:IconViewSettings:arrangeBy none" ~/Library/Preferences/com.apple.finder.plist

# Use column view in all Finder windows by default
# Icon ["icnv"] / List ["Nlsv"] / Column ["clmv"] / Cover Flow ["Flwv]
defaults write com.apple.finder FXPreferredViewStyle -string "clmv"


# Menu bar extras
tempfile="menubar.tmp"

/usr/libexec/PlistBuddy -c "Print" ~/Library/Preferences/com.apple.systemuiserver.plist | grep CoreServices | sed 's/ *\/System\/Library\/CoreServices\/Menu\ Extras\///g' > $tempfile

i=0
while read x; do
    menuextras[$i]=$x
    #echo "${menuextras[$i]}"
    ((i++))
done < "$tempfile"
#echo "${menuextras[@]}"
#echo "${menuextras[0]}"1


/usr/libexec/PlistBuddy -c "Print" ~/Library/Preferences/com.apple.systemuiserver.plist | grep "NSStatusItem Visible" | sed 's/ *NSStatusItem\ Visible\ com\.apple\.//g' | sed 's/ = .*//g'> $tempfile

#cat $tempfile

i=0
while read x; do
	if [ ! "$x" == "NSStatusItem Visible Siri" ]; then
        nsstatusitems[$i]="$x"
    #echo "${nsstatusitems[$i]}"
    ((i++))
fi
done < "$tempfile"
#echo "${nsstatusitems[@]}"
#echo "${nsstatusitems[0]}"1

rm $tempfile

# Delete keys
for x in "${nsstatusitems[@]}"; do
    #echo "$x"
	/usr/libexec/PlistBuddy -c "Delete NSStatusItem\ Visible\ com.apple.${x}" ~/Library/Preferences/com.apple.systemuiserver.plist
done

/usr/libexec/PlistBuddy -c "Delete menuExtras" ~/Library/Preferences/com.apple.systemuiserver.plist


# These menu extras should appear in the menubar. Add them to the current items if they don't yet exist.
if [ "$MODEL_NAME" == "imac" ]; then
    menuextras_add=('AirPort.menu' 'Bluetooth.menu' 'Clock.menu' 'Script Menu.menu' 'TextInput.menu' 'TimeMachine.menu' 'User.menu' 'Volume.menu' 'VPN.menu')
    nsstatusitems_add=('menuextra.airport' 'menuextra.bluetooth' 'menuextra.clock' 'menuextra.scriptmenu' 'menuextra.textinput' 'menuextra.TimeMachine' 'menuextra.appleuser' 'menuextra.volume' 'menuextra.vpn')
elif [ "$MODEL_NAME" == "macbook" ]; then
    menuextras_add=('AirPort.menu' 'Battery.menu' 'Bluetooth.menu' 'Clock.menu' 'TextInput.menu' 'TimeMachine.menu' 'User.menu' 'Volume.menu')
    nsstatusitems_add=('menuextra.airport' 'menuextra.battery' 'menuextra.bluetooth' 'menuextra.clock' 'menuextra.textinput' 'menuextra.TimeMachine' 'menuextra.appleuser' 'menuextra.volume')
fi

#echo "${menuextras_add[@]}"

#echo "${menuextras[@]}"
for x in "${menuextras_add[@]}"
do
	if [[ ! "${menuextras[@]}" =~ "${x}" ]]; then
	       menuextras=("${menuextras[@]}" "${x}")
	fi
done
#echo "${menuextras[@]}"

#echo "${nsstatusitems_add[@]}"

#echo "${nsstatusitems[@]}"
for x in "${nsstatusitems_add[@]}"
do
	if [[ ! "${nsstatusitems[@]}" =~ "${x}" ]]; then
	       nsstatusitems=("${nsstatusitems[@]}" "${x}")
	fi
done
#echo "${nsstatusitems[@]}"


# Add keys to preferences file
/usr/libexec/PlistBuddy -c "Add menuExtras array" ~/Library/Preferences/com.apple.systemuiserver.plist

for x in "${menuextras[@]}"
do
    /usr/libexec/PlistBuddy -c "Add :menuExtras: string /System/Library/CoreServices/Menu\ Extras/${x}" ~/Library/Preferences/com.apple.systemuiserver.plist
done

for x in "${nsstatusitems[@]}"
do
    /usr/libexec/PlistBuddy -c "Add NSStatusItem\ Visible\ com.apple.${x} bool true" ~/Library/Preferences/com.apple.systemuiserver.plist
done



###############################################################################
# Kill affected applications                                                  #
###############################################################################

for app in "cfprefsd" \
    "Dock" \
	"Finder" \
	"SystemUIServer"; do
	killall "${app}" &> /dev/null
done

# Revoke sudo privileges
sudo -k

# Change the user's (steve) photo
# Source: https://www.jamf.com/jamf-nation/discussions/4332/how-to-change-local-user-account-picture-through-command-terminal & https://discussions.apple.com/thread/7596877
#mkdir -p /Users/steve/Documents/Login\ Photos/My\ Photos && cp /Volumes/Install\ macOS\ High\ Sierra/macOS\ Configuration/Scripts/steve-colour.jpg /Users/steve/Documents/Login\ Photos/My\ Photos
echo "0x0A 0x5C 0x3A 0x2C dsRecTypeStandard:Users 5 dsAttrTypeStandard:RecordName dsAttrTypeStandard:UniqueID dsAttrTypeStandard:PrimaryGroupID dsAttrTypeStandard:GeneratedUID externalbinary:dsAttrTypeStandard:JPEGPhoto" > ~/Desktop/userphoto.txt
echo $USER:$UID:$(id -g):$(dscl . -read /Users/$USER GeneratedUID | cut -d' ' -f2):"$SCRIPTPATH"/Photos/steve-colour.jpg >> ~/Desktop/userphoto.txt
dscl . -delete /Users/$USER JPEGPhoto
dsimport ~/Desktop/userphoto.txt /Local/Default M -u steve
rm ~/Desktop/userphoto.txt

#exit 1

# Execute the AppleScript configuration script
osascript "$SCRIPTPATH"/Scripts/Config\ All.scpt

echo ""
echo "FINISHED. Note that some of these changes require a logout/restart to take effect."
echo ""
