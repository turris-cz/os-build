# Common functions for generate_lists and generate_medkit functions
# (C) 2018-2020 CZ.NIC, z.s.p.o.
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
USIGN_VERSION=f1f65026a94137c91b5466b149ef3ea3f20091e9
UPDATER_VERSION=master

SRC_USIGN="https://git.openwrt.org/project/usign.git"
SRC_UPDATER="https://gitlab.nic.cz/turris/updater/updater.git"

# Git puller helper function (git_pull output_path source_url target)
git_get() {
	local REPO="$1"
	local OUTPUT="$2"
	local BRANCH="${3:-master}"
	if [ ! -d "$OUTPUT/.git" ]; then
		mkdir -p "$(dirname "$OUTPUT")"
		git clone "$REPO" "$OUTPUT"
		(
		cd "$OUTPUT"
		git checkout "$BRANCH"
		git submodule update --init --recursive
		git clean -Xdf
		)
		return 1
	else
		(
		cd "$OUTPUT"
		git fetch
		local REF="origin/$BRANCH"
		git show-ref -q "$REF" || REF="$BRANCH" # Is this reference on remote or object
		if ! git diff --quiet HEAD "$REF"; then
			git reset --hard "$REF"
			git submodule update --init --recursive
			git clean -Xdf
			return 1
		fi
		)
	fi
}
# Wget puller helper function (wget_pull output_file source_url)
wget_get() {
	local HREF="$1"
	local OUTPUT="$2"
	if [ ! -e "$OUTPUT" ] || [ $(expr $(date -u +%s) - $(stat -c %Z "$OUTPUT")) -gt 86400 ]; then
		wget "$HREF" -O "$OUTPUT"
	fi
}

get_usign() {
	if ! git_get "$SRC_USIGN" turris-tools/usign "$USIGN_VERSION"; then
		( cd turris-tools/usign && cmake . )
		make -C turris-tools/usign
	fi
	export USIGN="$(pwd)/turris-tools/usign/usign"
}

# Automaticaly detect updater-ng's version from repository
# This function expects that tag of v* variant exists and that version of package
# is of format *-[09]+
# To be pedantic you should provide target board as second argument but if not
# provided then mox is used.
updater_ng_repodetect() {
	local REPO="$1"
	local BOARD="${2:-mox}"
	local VERSION="$(curl "https://repo.turris.cz/$REPO/$BOARD/packages/turrispackages/Packages" | \
		awk '/^Package: updater-ng$/,/^$/ { if ($1 == "Version:") { gsub("-.*$","",$2); print $2 } }')"
	if [ -z "$VERSION" ]; then
		warn "Detection of updater-ng version from repository failed. Using $UPDATER_VERSION instead."
	else
		UPDATER_VERSION="v$VERSION"
	fi
}

get_updater_ng() {
	if ! git_get "$SRC_UPDATER" turris-tools/updater-ng "$UPDATER_VERSION"; then
		(
			cd turris-tools/updater-ng
			./bootstrap
			./configure --disable-tests --disable-linters --disable-docs --disable-valgrind
			make
		)
	fi
	export PKGUPDATE="$PWD/turris-tools/updater-ng/pkgupdate"
	export PKGTRANSACTION="$PWD/turris-tools/updater-ng/pkgtransaction"
}
