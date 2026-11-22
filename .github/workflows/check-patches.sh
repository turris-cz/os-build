#!/bin/bash
# Check that the patches and files of turris-build apply to OpenWrt and its
# feeds for one board, the way compile_pkgs prepares the build tree. OpenWrt
# and the feeds are fetched from their repositories on GitHub, which carry
# the same commits as the mirrors on openwrt.turris.cz.
#
# usage: check-patches.sh BOARD [TURRIS_BUILD_DIR]
set -euo pipefail

board="$1"
src_dir="$(cd "${2:-.}" && pwd)"
work="${WORK_DIR:-${RUNNER_TEMP:-/tmp}/check-patches}/$board"
current=""

group() {
	echo "::group::$*"
}

endgroup() {
	echo "::endgroup::"
}

die() {
	echo "::error::$*"
	exit 1
}

on_exit() {
	if [ "$1" -ne 0 ] && [ -n "$current" ]; then
		echo "::error::The changes of turris-build do not apply to $current for $board, see the last patch above"
	fi
}
trap 'on_exit $?' EXIT

# The repository on GitHub for a mirror on openwrt.turris.cz
github() {
	local path="${1#https://openwrt.turris.cz/}"
	[ "$path" != "$1" ] || return 1
	path="${path%.git}"
	case "$path" in
		openwrt/openwrt)
			echo "https://github.com/openwrt/openwrt.git"
			;;
		feed/*|project/*)
			echo "https://github.com/openwrt/${path#*/}.git"
			;;
		nxhack/*|CESNET/*)
			echo "https://github.com/$path.git"
			;;
		*)
			return 1
			;;
	esac
}

# Fetch the commit or the tip of the branch that feeds.conf names, without
# the history
fetch() {
	local dir="$1" spec="$2" url ref
	url="${spec%%[;^]*}"
	ref="${spec#"$url"}"
	url="$(github "$url")" || die "No repository on GitHub is known for $spec"
	git init -q "$dir"
	case "$ref" in
		"^"*)
			git -C "$dir" fetch -q --depth 1 "$url" "${ref#^}"
			;;
		";"*)
			git -C "$dir" fetch -q --depth 1 "$url" "refs/heads/${ref#;}"
			;;
		*)
			git -C "$dir" fetch -q --depth 1 "$url" HEAD
			;;
	esac
	git -C "$dir" -c advice.detachedHead=false checkout -q FETCH_HEAD
	echo "$(basename "$dir"): $url at $(git -C "$dir" rev-parse --short HEAD)"
}

# Whether turris-build changes the repository of this name at all
changes() {
	local name="$1"
	compgen -G "$src_dir/patches/$name/*/*.patch" >/dev/null \
		|| [ -e "$src_dir/src/clean.list.$name" ] || [ -e "$src_dir/src/$name" ] \
		|| [ -e "$src_dir/src/$board/clean.list.$name" ] || [ -e "$src_dir/src/$board/$name" ]
}

# The removed and the added files, as in patch_openwrt and repatch_feeds of
# compile_pkgs
overlays() {
	local repo="$1" name="$2" overlay
	for overlay in "" "$board/"; do
		if [ -f "$src_dir/src/${overlay}clean.list.$name" ]; then
			echo "src/${overlay}clean.list.$name"
			git -C "$repo" rm -q -r --pathspec-from-file="$src_dir/src/${overlay}clean.list.$name"
		fi
		if [ -d "$src_dir/src/$overlay$name" ]; then
			echo "src/$overlay$name"
			cp -R "$src_dir/src/$overlay$name/." "$repo/"
		fi
	done
}

rm -rf "$work"
mkdir -p "$work/feeds"
cp "$src_dir/feeds.conf" "$work/feeds.conf"
if [ -f "$src_dir/feeds.conf.$board" ]; then
	cat "$src_dir/feeds.conf.$board" >>"$work/feeds.conf"
fi

# patch_repository is the one compile_pkgs uses
# shellcheck source=/dev/null
source "$src_dir/helpers/generate_common.sh"

group "Fetch OpenWrt and the feeds"
openwrt="$(awk '$1 == "#" && $2 == "openwrt" { print $3 }' "$work/feeds.conf")"
[ -n "$openwrt" ] || die "feeds.conf names no OpenWrt repository"
fetch "$work/openwrt" "$openwrt"
names=()
while read -r vcs name spec _; do
	case "$vcs" in
		src-git*)
			;;
		*)
			continue
			;;
	esac
	changes "$name" || continue
	fetch "$work/feeds/$name" "$spec"
	names+=("$name")
done <"$work/feeds.conf"
endgroup

current="OpenWrt"
group "Changes of turris-build for OpenWrt"
patch_repository "openwrt" "$work/openwrt"
patch_repository "$board/openwrt" "$work/openwrt"
overlays "$work/openwrt" "openwrt"
endgroup

for name in "${names[@]}"; do
	current="the feed $name"
	group "Changes of turris-build for the feed $name"
	patch_repository "$name" "$work/feeds/$name"
	overlays "$work/feeds/$name" "$name"
	endgroup
done

current=""
echo "All the changes of turris-build apply for $board"
