#!/bin/bash
# Turris OS script verifying new release
# (C) 2019 CZ.NIC, z.s.p.o.
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
set -e

# TODO:
# * Do we want to verify medkit somehow?

# Constants
REPO="https://repo.turris.cz"
BOARDS=('mox' 'omnia' 'turris1x') # Note that first board in this is considered as primary (authoritative) one
DEFAULT_VERIFY_BRANCH="hbk"
DEFAULT_RELEASE_BRANCH="hbs"


COLOR_RED="\033[0;31m"
COLOR_GREEN="\033[0;32m"
COLOR_ORANGE="\033[0;33m"
COLOR_OFF="\033[0m"
info() {
	printf "%s\n" "$@" >&2
}
warning() {
	if [ -t 2 ]; then
		echo -e "${COLOR_ORANGE}$*${COLOR_OFF}" >&2
	else
		echo -e "WARNING: $*" >&2
	fi
}
error() {
	if [ -t 2 ]; then
		echo -e "${COLOR_RED}$*${COLOR_OFF}" >&2
	else
		echo -e "ERROR: $*" >&2
	fi
}
fail() {
	error "$@"
	exit 1
}
ask() {
	echo -e "${COLOR_GREEN}$*${COLOR_OFF}" >&2
	local answer
	read -r -p "Write upper case yes to continue: " answer
	[ "$answer" = "YES" ] || return 1
}

FETCH_DIR=
cleanup() {
	[ -d "$FETCH_DIR" ] && rm -rf "$FETCH_DIR"
	return 0
}
trap cleanup EXIT TERM INT QUIT ABRT

# Fetch all files we need from repository
fetch_files() {
	local branch="$1"
	FETCH_DIR="$(mktemp -d)"
	GIT_HASH_LISTS="$FETCH_DIR/git-hash-lists"
	GIT_HASH_PACKAGES="$FETCH_DIR/git-hash-packages"
	TOS_VERSION="$FETCH_DIR/tos-version"
	local release_date_raw="$(curl -s --head "$REPO/$branch/mox/packages/git-hash.sig" | sed -n 's/^Last-Modified: //p')"
	RELEASE_DATE="$(date --iso-8601=second -d "$release_date_raw")"

	for board in "${BOARDS[@]}"; do
		curl -s "$REPO/$branch/$board/lists/turris-version" >"$TOS_VERSION-$board"
		curl -s "$REPO/$branch/$board/lists/git-hash" >"$GIT_HASH_LISTS-$board"
		curl -s "$REPO/$branch/$board/packages/git-hash" >"$GIT_HASH_PACKAGES-$board"
	done
}

# Get git hash from git-hash file on REPO
# Expected arguments are: BOARD FEED
git_hash() {
	awk -v feed="$2:" '$2 == feed { print $3; exit }' "$GIT_HASH_PACKAGES-$1"
}

# Get turris-build hash
tb_hash() {
	local ec=0
	local p_hash l_hash b_hash
	for board in "${BOARDS[@]}"; do
		l_hash="$(cat "$GIT_HASH_LISTS-$board")"
		b_hash="$(git_hash "$board" "turris-build")"
		[ -n "$p_hash" ] || p_hash="$b_hash" # First board is considered primary and packages are authoritative
		[ "$p_hash" = "$b_hash" ] || {
			error "Turris build used to generate packages is not same as for ${BOARDS[0]} board: $board ($b_hash / $p_hash)"
			ec=1
		}
		[ "$b_hash" = "$l_hash" ] || {
			error "Turris build used to generate lists is not same as for packages for board: $board ($l_hash / $b_hash)"
			ec=1
		}
	done
	echo "$p_hash"
	return $ec
}

# Get hash for openwrt
owrt_hash() {
	local ec=0
	local p_hash t_hash
	for board in "${BOARDS[@]}"; do
		t_hash="$(git_hash "$board" openwrt)"
		[ -n "$p_hash" ] || p_hash="$t_hash" # first board is primary one
		[ "$p_hash" = "$t_hash" ] || {
			error "Different OpenWRT commit build for board: $board ($t_hash / $p_hash)"
			ec=1
		}
	done
	echo "$p_hash"
	return $ec
}

# This function sets dictionary FEEDS by collecting all feeds in git-hash
# Caller should define associative array FEEDS
feeds() {
	local ec=0
	for board in "${BOARDS[@]}"; do
		local lines feed hsh
		lines="$(sed -En 's|^ \* feeds/([^:]+): ([^\s]+)|\1 \2|p' "$GIT_HASH_PACKAGES-$board")"
		while read -r feed hsh; do
			if [[ -v "FEEDS[$feed]" ]]; then
				[ "$hsh" = "${FEEDS["$feed"]}" ] || {
					error "Different feed ($feed) commit compiled for $board (${FEEDS["$feed"]} / $hsh)"
					ec=1
				}
			else
				FEEDS["$feed"]="$hsh"
			fi
		done <<<"$lines"
	done
	return $ec
}

# Sets given hash as a feed target
# Arguments: FEED HASH
feeds_conf_set() {
	awk -v feed="$1" -v hash="$2" \
		'$2 == feed { gsub("[;^].*$", "", $3); gsub("$", "^" hash) } { print $0 }' \
		./feeds.conf > feeds.conf.new
	mv ./feeds.conf.new ./feeds.conf
}

check_for_turris_build_root() {
	[ -e .git -a -f ./feeds.conf ] || \
		fail "This has to be run from turris-build root"
}

##########
verify() {
	local branch="$1"
	local ec=0
	declare -A FEEDS
	fetch_files "$branch"

	tb_hash >/dev/null || ec=$?
	owrt_hash >/dev/null || ec=$?
	feeds || ec=$?
	[ "$ec" = 0 ] && info "No problems detected in branch: $branch"
	return $ec
}

_release_git() {
	GIT_COMMITTER_DATE="$RELEASE_DATE" GIT_AUTHOR_DATE="$RELEASE_DATE" git "$@"
}

##########
release() {
	local branch="$1"
	local tversion target_hsh owrt_hsh
	declare -A FEEDS
	fetch_files "$branch"

	tversion="$(cat "$TOS_VERSION-${BOARDS[0]}")"
	target_hsh="$(tb_hash)" || ask "turris-build hashes do not match. Planning to use: $target_hsh"
	owrt_hsh="$(owrt_hash)" || ask "openwrt hashes do not match. Planning to use: $owrt_hsh"
	feeds || ask "feed hashes do not match. Please review difference."

	check_for_turris_build_root
	local tag="v$tversion"
	git rev-parse "$tag" &>/dev/null && \
		fail "Tag for version $tag exists."

	git checkout "$target_hsh"
	feeds_conf_set openwrt "$owrt_hsh"
	for feed in "${!FEEDS[@]}"; do
		feeds_conf_set "$feed" "${FEEDS["$feed"]}"
	done
	git add ./feeds.conf
	_release_git commit -m "Turris OS $tversion" --date="$RELEASE_DATE" -m "$(./helpers/turris-version.sh news)"
	_release_git tag -s -m "Turris OS $tversion release" -m "$(./helpers/turris-version.sh news)" "v$tversion"

	info "Tag $tag was created. Review changes and push it with: git push --tags origin"
}

##################################################################################
print_help() {
	echo "Usage: $0 [OPTION].. [MODE [BRANCH]]"
	echo "Turris OS new releases managing tool."
	echo
	echo "Options:"
	echo "  -v  Run script with verbose output"
	echo "  -h  Print this help text"
	echo "Modes:"
	echo "  verify"
	echo "    Run script in verify mode where BRANCH (in default $DEFAULT_VERIFY_BRANCH) is checked"
	echo "    for possible release problems. This is default."
	echo "  release"
	echo "    Create new commit and tag for release to BRANCH (in default $DEFAULT_RELEASE_BRANCH)"
	echo
	echo "Example usage:"
	echo "  Verify branch to be released: $0 verify"
	echo "  Commit and tag new release: $0 release"
}

while getopts ':hd' OPT; do
    case "$OPT" in
        h)
            print_help
            exit 0
            ;;
        d)
            set -x
            ;;
        \?)
            error "Illegal option '-$OPTARG'"
            exit 1
            ;;
    esac
done
shift $(( OPTIND-1 ))

[ $# -le 2 ] || fail "Provided too many arguments. See help \`-h\`"

case "${1:-verify}" in
	verify)
		verify "${2:-${DEFAULT_VERIFY_BRANCH}}"
		;;
	release)
		release "${2:-${DEFAULT_RELEASE_BRANCH}}"
		;;
	*)
		fail "Invalid mode: $1"
		;;
esac
