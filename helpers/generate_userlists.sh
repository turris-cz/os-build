#!/bin/sh
set -e

MINIMAL=false
LISTS_DIR=
OUTPUT_PATH=
while [ $# -gt 0 ]; do
	case "$1" in
		-h|--help)
			echo "This script generates updater-ng userlists from Turris OS repository."
			echo "Usage: $0 [OPTION]... OUTPUT_PATH"
			echo
			echo "Options:"
			echo "  --help, -h"
			echo "    Prints this help text."
			echo "  --model (turris|omnia|mox)"
			echo "    Target Turris model."
			echo "  --branch BRANCH"
			echo "    Target branch for which this userlist is generated."
			echo "  --minimal"
			echo "    Generate userlists for minimal branch. (This adds nightly as a fallback branch)"
			echo "  --src PATH"
			echo "    Source directory with list to process"
			exit
			;;
		--model)
			shift
			[ "$1" != "turris" -a "$1" != "omnia" -a "$1" != "mox" ] && {
				echo "Unknown model: $1" >&2
				exit 1
			}
			BOARD="$1"
			;;
		--branch)
			shift
			BRANCH="$1"
			;;
		--minimal)
			MINIMAL=true
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
[ -z "$BOARD" ] && {
	echo "Missing --model option." >&2
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

M4ARGS="--include=$LISTS_DIR -D _INCLUDE_=$LISTS_DIR/ -D _BRANCH_=$BRANCH -D _BOARD_=$BOARD"
$MINIMAL && M4ARGS="$M4ARGS -D _BRANCH_FALLBACK_=nightly"

for f in $(find "$LISTS_DIR" -name '*.lua.m4'); do
	m4 $M4ARGS $f > "$OUTPUT_PATH/$(basename "$f" | sed s/\.m4$//)"
done
for f in $(find "$LISTS_DIR" -name '*.lua'); do
	cp $f "$OUTPUT_PATH/$(basename "$f")"
done
