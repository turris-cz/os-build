# Common functions for compile_pkgs, generate_lists and generate_medkit scripts
# (C) 2018-2021 CZ.NIC, z.s.p.o.
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
set -eu
shopt -s nullglob
[ -n "${src_dir:-}" ] || {
	echo "${0##*/}: Invalid generate_common.sh usage. Variable src_dir has to be defined!" >&2
	exit 1
}
source "$src_dir/helpers/common.sh"

DEFAULT_UPDATER_VERSION=master
SRC_USIGN="https://git.openwrt.org/project/usign.git^f1f65026a94137c91b5466b149ef3ea3f20091e9"
SRC_UPDATER="https://gitlab.nic.cz/turris/updater/updater.git"

# Git that should be used for commands such as: git commit or git am
_git() {
	git \
		-c "commit.gpgsign=false" \
		-c "user.email=auto-build@example.com" \
		-c "user.name=Turris build system" \
		"$@"
}

# Set build_dir variable to current working directory unless that is the src_dir.
# This also protect against removal of source and thus when build directory is the
# source directory it creates new build subdirectory to be used instead.
# This sets global variable but it makes this important code common for all
# generate scripts.
set_protected_build_dir() {
	local alt="${1:-build}"
	build_dir="$(readlink -f "$(pwd)")"
	if [ "$build_dir" == "$src_dir" ]; then
		# Protect against turris-build repository wipe
		mkdir -p "$alt"
		cd "$alt"
		build_dir="$(pwd)"
	fi
}

# Helper function to locate specific line in feeds.conf
# First argument is feed's VCS. That is in general "src-git-full" for real feeds or
# "#" for non-feed repositories.
# Second argument is feed's name.
# Echoes URL as stored in feeds.conf file
get_feed() {
	local req_vcs="$1"
	local req_name="$2"
	local feed_file="${3:-$src_dir/feeds.conf}"
	while read -r vcs name url rest; do
		if [[ "$vcs" == "$req_vcs" && "$name" == "$req_name" ]]; then
			echo "$url"
			return
		fi
	done < "$feed_file"
}

# Removes optional branch or hash from the end of the url.
# Feed url has to be passed as first argument.
feed_url() {
	echo "${1%[;^]*}"
}

# Removes url from feed url and that way provides only reference
# It provides "master" instead if there was no reference in feed url.
# Feed url has to be provided as first argument.
# The second argument should be 'fetch' in case we want fetched reference.
feed_ref() {
	local url="$1"
	local fetch="${2:-}"
	if [[ "$url" =~ [\;^] ]]; then
		echo "${url##*[;^]}"
	else
		if [[ "$fetch" == "fetch" ]]; then
			echo "FETCH_HEAD"
		else
			echo "HEAD"
		fi
	fi
}

# Checks if feed url reference points to branch or rather to specific commit
# You have to provide feed url as first argument.
feed_ref_is_branch() {
	[[ "$1" == *\;* ]]
}

# Replaces URL in feed's url.
feed_url_replace() {
	local old_url="$1"
	local new="$2"
	if [[ "$old_url" =~ [\;^] ]]; then
		if feed_ref_is_branch "$old_url"; then
			echo "$new;$(feed_ref "$old_url")"
		else
			echo "$new^$(feed_ref "$old_url")"
		fi
	else
		echo "$new"
	fi
}

# Applies patched to git repository.
# First argument is name of patch directory
# Second argument is optional path to repository to apply patches to. By default
# current working directory is used.
patch_repository() {
	local patchdir="$1"
	local repo="${2:-./}"
	(
		cd "$repo"
		for patch in "$src_dir/patches/$patchdir"/*/*.patch; do
			report "Applying patch '$(basename "$patch")' to '${patchdir}'..."
			_git am --whitespace=nowarn --reject "$patch"
		done
	)
}


# Check if git mirror is configured
use_git_mirror() {
	[[ -n "${GIT_MIRROR:-}" ]]
}

# Assembles path to git mirror
# Expects one argument and that tail part of path.
git_mirror_path() {
	echo "$GIT_MIRROR/$1"
}

# Provides URL for mirror or the original depending on mirror configuration.
# The first argument is mirror name
# The second argument is original URL
git_mirror_url() {
	local name="$1"
	local url="$2"
	if use_git_mirror; then
		feed_url_replace "$url" "file://$(git_mirror_path "$name")"
	else
		echo "$url"
	fi
}

# Protect given command operating on mirrors using flock
# This should be always when manipulating with local mirror
# Warning: when mirror is configured this runs command in subshell and thus
# argument should not be a function from this script.
_git_mirror_lock() {
	if use_git_mirror; then
		flock --exclusive "$GIT_MIRROR" "$@"
	else
		"$@"
	fi
}

_updated_mirrors_override=""
declare -A _updated_mirrors

# Update and initialize mirror repository
# First argument is name of repository (used to identify it in mirror directory)
# Second argument is URL to upstream repository (URL not feed's url)
git_mirror_update() {
	use_git_mirror || return 0
	[[ -z "${_updated_mirrors_override}" ]] || return 0
	local repo="$1"
	local url="$2"
	local mirror="$GIT_MIRROR/$repo"
	value_in "$repo" "${!_updated_mirrors[@]}" && return 0
	mkdir -p "$GIT_MIRROR"
	if [ -d "$mirror" ]; then
		_git_mirror_lock "$SHELL" -eus "$mirror" "$url" <<-"EOF"
			git -C "$1" remote set-url origin "$2"
			git -C "$1" remote update --prune
		EOF
	else
		_git_mirror_lock \
			git -C "$GIT_MIRROR" clone --mirror "$url" "$mirror"
	fi
	_updated_mirrors[$repo]="updated"
}

# Update all available mirrors
git_mirror_update_all() {
	use_git_mirror || return 0
	for mirror in "$GIT_MIRROR"/*; do
		_git_mirror_lock \
			git -C "$mirror" remote update --prune
	done
}

# Makes it so all mirrors are considered as updated
set_git_mirrors_updated() {
	_updated_mirrors_override="__override__"
}

# Git puller helper function
# First argument has to be unique name of repository.
# Second argument is URL of feed (that is including optional reference)
# Third argument is local repository directory (in default current one).
git_checkout() (
	local name="$1"
	local url="$2"
	local outdir="${3:-.}"

	mkdir -p "$outdir"
	cd "$outdir"

	local remote_url
	remote_url="$(feed_url "$(git_mirror_url "$name" "$url")")"
	if [ -d .git ]; then
		_git remote set-url origin "$remote_url"
	else
		_git init
		_git remote add origin "$remote_url"
	fi

	if use_git_mirror || feed_ref_is_branch "$url"; then
		git_mirror_update "$name" "$(feed_url "$url")"
		_git_mirror_lock \
			git fetch origin "$(feed_ref "$url")"
	else
		# If we are downloading directly from server we can't fetch specific
		# commit so fetch everything
		_git fetch origin
	fi
	_git checkout -f "$(feed_ref "$url" fetch)"
	_git submodule update --init --recursive
)

# The git_checkout function variant that performs cleanup. The all three arguments
# of git_checkout are required.
# Any additional arguments are file exclusion rules for files to not be removed by
# cleanup.
git_clean_checkout() {
	local outdir="${3:-.}"
	rm -rf "$outdir/.git"
	git_checkout "$@"
	shift 3
	_git -C "$outdir" clean -dff "${@/#/--exclude=}"
	find "$outdir" -name '*.rej' -delete
}

git_remote_hash() {
	local dir="${1:-.}"
	_git -C "$dir" rev-list HEAD | \
		_git -C "$dir" name-rev --stdin --refs='origin/*' | \
		awk '$2 != "" { print $1; exit }'
}

# Provides commit for given branch (or HEAD if empty) for repository in given directory. This
# won't fail if repository does not exist and instead provides dummy hash.
# (Note this hash is also used by git for the same purpose)
git_local_hash() {
	local dir="$1"
	local branch="${2:-HEAD}"
	if [ -d "$dir/.git" ]; then
		_git -C "$dir" rev-parse "$branch"
	else
		echo "0000000000000000000000000000000000000000"
	fi
}

get_usign() {
	local dir=".turris-tools/usign"
	export USIGN="$(pwd)/$dir/usign"
	local orig_commit
	orig_commit="$(git_local_hash "$dir")"
	git_checkout "usign" "$SRC_USIGN" "$dir"
	if [ "$orig_commit" != "$(git_local_hash "$dir")" ] || [ -x "$USIGN" ]; then (
		cd "$dir"
		cmake .
		make
	) fi
}

# Automatically detect updater-ng's version from repository
# This function expects that tag of v* variant exists and that version of package
# is of format *-[09]+
# To be pedantic you should provide target board as second argument but if not
# provided then mox is used.
updater_ng_repodetect() {
	local repo="$1"
	local board="${2:-mox}"
	local version="$(curl "https://repo.turris.cz/$repo/$board/packages/turrispackages/Packages" | \
		awk '/^Package: updater-ng$/,/^$/ { if ($1 == "Version:") { gsub("-.*$","",$2); print $2 } }')"
	if [ -z "$version" ]; then
		warn "Detection of updater-ng version from repository failed. Using $DEFAULT_UPDATER_VERSION instead."
		UPDATER_VERSION="$DEFAULT_UPDATER_VERSION"
	else
		UPDATER_VERSION="v$version"
	fi
}

get_updater_ng() {
	local dir=".turris-tools/updater-ng"
	export PKGUPDATE="$(pwd)/$dir/pkgupdate"
	export PKGTRANSACTION="$(pwd)/$dir/pkgtransaction"
	local orig_commit
	orig_commit="$(git_local_hash "$dir")"
	git_checkout "updater" "$SRC_UPDATER^$UPDATER_VERSION" "$dir"
	if [ "$orig_commit" != "$(git_local_hash "$dir")" ] \
			|| [ ! -x "$PKGUPDATE" ] || [ ! -x "$PKGTRANSACTION" ]; then (
		cd "$dir"
		./bootstrap
		./configure --disable-tests --disable-linters --disable-docs --disable-valgrind
		make
	) fi
}
