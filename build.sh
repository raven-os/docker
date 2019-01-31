#!/usr/bin/env bash

set -e -u

declare script_dir="$(realpath $(dirname $0))"
declare build="$script_dir/build"

# Tests if a given command exists. Exit otherwise.
function test_command() {
    if ! which $1 > /dev/null 2>&1; then
        echo "The \"$1\" command is missing but is required by this script."
        echo "Please install the required packages and make sure your \$PATH is valid."
        exit 1
    fi
}

function main() {
	if [[ $# -ne 1 ]]; then
		echo "Usage: $0 <image name>"
		exit 1
	fi

	test_command "nest"
	test_command "docker"

	# Remove previous attempt
	rm -rf "$build"

	# Install the filesystem and essential binaries
	yes | nest --chroot="$build" pull
	yes | nest --chroot="$build" install corefs
	yes | nest --chroot="$build" install essentials

	# Build and wrap the image
	docker build -t "$1" .

	echo
	echo "Done! You can now pull the \"$1\" image."
}

main $@
