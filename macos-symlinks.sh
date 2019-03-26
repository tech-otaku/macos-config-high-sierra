#!/usr/bin/env bash

create_symbolic_link() {

	SOURCE=$1
	TARGET=$2
	
	echo "${SOURCE}"
	echo "${TARGET}"

	if [ -d "${SOURCE}" ]; then
		if [ -L "${TARGET}" ]; then
			# Removes the symbolic link with the same name as the target if it exists first
			unlink "${TARGET}"
		elif [ -d "${TARGET}" ]; then
			# Removes the existing directory with the same name as the target if it exists first
			rm -rf "${TARGET}"
		fi
		# Creates the symbolic link
		ln -s "${SOURCE}" "${TARGET}"
		echo "Symbolic link '${TARGET}' created."
	else
		echo "ERROR: Source '${SOURCE}' does not exist."
	fi
}	

#create_symbolic_link "/Users/steve/SymLink Test" "/Users/steve/Desktop/SymLink Test"
create_symbolic_link "/Users/steve/Dropbox/BBEdit" "/Users/steve/Library/Application Support/BBEdit"
create_symbolic_link "/Users/steve/Dropbox/Scripts" "/Users/steve/Library/Scripts"
create_symbolic_link "/Users/steve/Dropbox/iTunes/Scripts" "/Users/steve/Library/iTunes/Scripts"