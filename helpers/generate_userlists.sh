#!/bin/sh
set -e

LISTS_DIR=
OUTPUT_PATH=
FALLBACK=
while [ $# -gt 0 ]; do
	case "$1" in
		-h|--help)
			echo "This script generates updater-ng userlists from Turris OS repository."
			echo "Usage: $0 [OPTION]... OUTPUT_PATH"
			echo
			echo "Options:"
			echo "  --help, -h"
			echo "    Prints this help text."
			echo "  --branch BRANCH"
			echo "    Target branch for which this userlist is generated."
			echo "  --minimal BRANCH"
			echo "    Generate userlists for minimal branch. (This adds BRANCH as a fallback branch)"
			echo "  --src PATH"
			echo "    Source directory with list to process"
			exit
			;;
		--branch)
			shift
			BRANCH="$1"
			;;
		--minimal)
			shift
			FALLBACK="$1"
			;;
		--src)
			shift
			LISTS_DIR="$1"
			;;
		*)
			if [ -z "$OUTPUT_PATH" ]; then
				OUTPUT_PATH="$1"
			else
				echo "Unknown option: $1"
				exit 1
			fi
			;;
	esac
	shift
done

[ -z "$OUTPUT_PATH" ] && {
	echo "You have to specify output path." >&2
	exit 1
}
[ -z "$BRANCH" ] && {
	echo "Missing --branch option." >&2
	exit 1
}
[ -d "$LISTS_DIR" ] || {
	echo "Valid --src directory has to be specified" >&2
	exit 1
}
[ -f Makefile -a -f feeds.conf ] || {
	echo "This script has to be run in OpenWRT build directory" >&2
	exit 1
}

mkdir -p $OUTPUT_PATH

M4ARGS="--include=$LISTS_DIR -D _INCLUDE_=$LISTS_DIR/ -D _BRANCH_=$BRANCH"
[ -z "$FALLBACK" ] || M4ARGS="$M4ARGS -D _BRANCH_FALLBACK_=$FALLBACK"

for f in $(find "$LISTS_DIR" -name '*.lua.m4'); do
	m4 $M4ARGS $f > "$OUTPUT_PATH/$(basename "$f" | sed s/\.m4$//)"
done
for f in $(find "$LISTS_DIR" -name '*.lua'); do
	cp $f "$OUTPUT_PATH/$(basename "$f")"
done
