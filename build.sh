#!/bin/bash

reldir() {
	# both $1 and $2 are absolute paths beginning with /
	# returns relative path to $2/$target from $1/$source
	source=$1
	target=$2

	common_part=$source # for now
	result="" # for now

	while [[ "${target#$common_part}" == "${target}" ]]; do
	    # no match, means that candidate common part is not correct
	    # go up one level (reduce common part)
	    common_part="$(dirname $common_part)"
	    # and record that we went back, with correct / handling
	    if [[ -z $result ]]; then
	        result=".."
	    else
	        result="../$result"
	    fi
	done

	if [[ $common_part == "/" ]]; then
	    # special case for root (no common path)
	    result="$result/"
	fi

	# since we now have identified the common part,
	# compute the non-common part
	forward_part="${target#$common_part}"

	# and now stick all parts together
	if [[ -n $result ]] && [[ -n $forward_part ]]; then
	    result="$result$forward_part"
	elif [[ -n $forward_part ]]; then
	    # extra slash removal
	    result="${forward_part:1}"
	fi

	echo $result
}

copy_flt() {
	filter="$3"
	source="$1"
	target="$2"

	find "$source" -type "d" | while read i; do mkdir -p "$target/$(reldir $source $i)"; done
	find "$source" -name "$filter" -type "f" | while read i; do cp "$i" "$target/$(reldir $source $i)"; done
}

if [ ! -e builds ]; then
	mkdir builds
fi

if [ -e tmp]; then
	rm -rf tmp
fi
mkdir tmp

# Root path
workspace=$(pwd)

echo Workspace: $workspace

# Copy over
copy_flt "." "tmp" "*.json"
copy_flt "." "tmp" "*.wav"
copy_flt "." "tmp" "*.lua"
copy_flt "." "tmp" "*.mp3"
copy_flt "." "tmp" "*.jpg"
copy_flt "." "tmp" "*.png"
copy_flt "." "tmp" "*.txt"

# Compile LUA files
pushd lua
mkdir ../tmp/lua
find . -type d | while read absfile; do
	file="lua/$absfile"
	echo "Creating $file..."
	mkdir "../tmp/$file"
)
find . -type f -name '*.lua' | while read absfile; do
	file="lua/$absfile"
	echo "Compiling $file..."
	luac52 -o "../tmp/$file" "$absfile" || (
		echo "Could not compile $file, only copying..."
		cp "$absfile" "../tmp/$file"
	)
)
popd

# Create the GMA file
gmad create -folder "tmp" -out "builds/disguiser_swep.gma"

# Clean up
rm -rf tmp
