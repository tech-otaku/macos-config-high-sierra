shopt -s nullglob
shopt -u dotglob

SOURCE=/Volumes/steve/TM\ Restore\ 2018-04-04
i=0
# Remaining files/folders on source
for f in "$SOURCE"/{..?,.[!.],}*; do
	#echo "$f"
	NAME=$(basename -- "$f")
	if [ ! -f "/Users/steve/$NAME" ]; then		# file doesn't exist on target
		read -p "Move the file $f to /Users/steve/$NAME (Y/n)? " MOVE
		if [[ $MOVE =~ [A-Z] && $MOVE == "Y" ]]; then
			echo "Testing $f to /Users/steve/$NAME"
			if [ -f "$f" ]; then
				move_directory_entry "F" "$f" "/Users/steve/$NAME"
			elif [ -d "$f" ]; then
				move_directory_entry "D" "$f" "/Users/steve/$NAME"
			fi
		fi
		unset MOVE
	fi
	((i++))
	echo $i
done

shopt -u nullglob
shopt -s dotglob