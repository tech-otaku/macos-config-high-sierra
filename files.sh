#shopt -s nullglob

for f in /Volumes/steve/TM\ Restore\ 2018-04-04/{..?,.[!.],}*; do
	NAME=$(basename -- "$f")
	#if [ ! "$NAME" == . || ! "$NAME" == .. ]; then
		echo "$f"
	#fi
done

#for d in /Volumes/steve/TM\ Restore\ 2018-04-04/*; do
	#echo "$d"
#done

#shopt -u nullglob