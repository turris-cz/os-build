#!/bin/bash
# Turris medkit generator script
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
set -eu

src_dir="$(dirname "$(readlink -f "${0%/*}")")"
. "$src_dir/helpers/common.sh"
. "$src_dir/helpers/generate_common.sh"

. "$src_dir/defaults.sh"
export BOOTSTRAP_BOARD=
export BRANCH="$PUBLISH_BRANCH"
export BOOTSTRAP_UPDATER_BRANCH=
export BOOTSTRAP_L10N=cs,de
export BOOTSTRAP_PKGLISTS=
export BOOTSTRAP_DRIVERS=
export BOOTSTRAP_CONTRACT=
export UPDATER_SCRIPT=
export OVERLAY=
export OUTPUT=
export BOOTSTRAP_TESTKEY=

export TURRIS_BUILD_DIR="$src_dir"

default_output_ext=""

## Parse arguments ##
while [ $# -gt 0 ]; do
	case "$1" in
		-h|--help)
			echo "This script generates Turris medkit using updater-ng."
			echo "Usage: $0 [OPTION].. [OUTPUT]"
			echo
			echo "Generated medkit is written to file at path OUTPUT. If no OUTPUT"
			echo "is specified then the default format for used board is used."
			echo "Warning: This script generates a lot of stuff to current working"
			echo "directory. It is suggested to use some empty one not your home."
			echo "Options:"
			echo "  --target, -t BOARD"
			echo "    Set given board as target for generated medkit. In default"
			echo "    if this options is not specified omnia is used. Allowed"
			echo "    values are: turris1x, omnia, mox"
			echo "  --branch, -b BRANCH"
			echo "    Set given branch as source for packages used to generate "
			echo "    this medkit. If this option is not set then '$PUBLISH_BRANCH' is used."
			echo "    Note that this does not sets that branch to updater-ng"
			echo "    configuration. You have to use --updater-branch for that."
			echo "  --updater-branch BRANCH"
			echo "    Set target branch inside medkit for updater-ng."
			# TODO maybe add version specification for future out of build use.
			echo "  --localization, -l LOCALIZATION,.."
			echo "    After this argument a list of language codes to be added to"
			echo "    medkit should be specified. Language codes should be"
			echo "    separated by comma. In default cs,de is used."
			echo "  --lists, -p PKGLIST,.."
			echo "    What lists should be added to medkit. In default no"
			echo "    additional lists will be added. Multiple lists can be"
			echo "    specified by separating them by commas. Options for them"
			echo "    can be specified in parentheses and divided by pipe. Note"
			echo "    that lists are included in medkit but not configured. This"
			echo "    means that they will be removed with first update. To"
			echo "    prevent this you have to include our own"
			echo "    /etc/config/pkglists in overlay."
			echo "  --drivers, -d DRIVER,.."
			echo "    What additional drivers should be included in medkit. Format"
			echo "    is CLASS:FLAG where CLASS is either 'pci' or 'usb'. Multiple"
			echo "    drivers can be specified by separating them by commas. This"
			echo "    affects only medkit. Unnecessary drivers are removed with"
			echo "    first system update."
			echo "  --contract CONTRACT"
			echo "    Build medkit for router under CONTRACT."
			echo "  --updater-script FILE"
			echo "    Run file as updater's script. It is executed after primary"
			echo "    entry script of this tool."
			echo "  --overlay PATH"
			echo "    This allows you to overwrite or add some files to medkit."
			echo "    PATH is expected to be directory and whole content is copied"
			echo "    to newly generated root. This is handy if you want to change"
			echo "    some default settings for example."
			echo "  --help, -h"
			echo "    Print this text and exit."
			exit 0
			;;
		--target|-t)
			shift
			BOOTSTRAP_BOARD="$1"
			;;
		--branch|-b)
			shift
			BRANCH="$1"
			;;
		--updater-branch)
			shift
			BOOTSTRAP_UPDATER_BRANCH="$1"
			BOOTSTRAP_TESTKEY=y
			;;
		--localization|-l)
			shift
			BOOTSTRAP_L10N="$1"
			;;
		--lists|-p)
			shift
			BOOTSTRAP_PKGLISTS="$1"
			;;
		--drivers|-d)
			shift
			DRIVERS_DRIVERS="$1"
			;;
		--contract)
			[ -z "$CONTRACT" ] || die "--contract can be specified only once"
			shift
			BOOTSTRAP_CONTRACT="$1"
			default_output_ext="-contract-$1"
			;;
		--updater-script)
			shift
			UPDATER_SCRIPT="$1"
			;;
		--overlay)
			shift
			OVERLAY="$1"
			;;
		*)
			[ -z "$OUTPUT" ] || die "Unknown option: $1"
			OUTPUT="$1"
			;;
	esac
	shift
done

[ -n "$BOOTSTRAP_BOARD" ] || die "You have to specify target Turris router."
[ -n "$OUTPUT" ] || \
	OUTPUT="$BOOTSTRAP_BOARD-medkit$default_output_ext.tar.gz"
OUTPUT="$(readlink -f "$OUTPUT")"

updater_ng_repodetect "$BRANCH" "$BOOTSTRAP_BOARD"
get_updater_ng

## Generate root ##
exec fakeroot -- /bin/bash -s <<EOF
set -e

mkdir -p root
## Create base filesystem for updater
ln -sf tmp root/var
# Create lock required by updater
mkdir -p root/tmp/lock
# Create opkg status file and info file
mkdir -p root/usr/lib/opkg/info
touch root/usr/lib/opkg/status

## Run updater it self
"\$PKGUPDATE" \
	-R "$(pwd)"/root --out-of-root --batch \
	"file://\$TURRIS_BUILD_DIR/helpers/medkit-updater-ng.lua"

## Overlay user's files
if [ -n "\$OVERLAY" ]; then
	cp -a "\$OVERLAY/." root/
fi

## Root cleanups
rm -f root/var/lock/opkg.lock
rm -f root/usr/share/updater/flags
rm -rf root/usr/share/updater/unpacked
rm -rf root/var/opkg-collided

## Tar root
(
cd root
# Create archive
tar -czf "\$OUTPUT" .
)

## Cleanup
rm -rf root
EOF
