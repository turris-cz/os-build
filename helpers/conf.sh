# Turris-build configuration
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
[ -n "${src_dir:-}" ] || {
	echo "${0##*/}: Invalid conf.sh usage. Variable src_dir has to be defined!" >&2
	exit 1
}


# Sets various variables to match the specified target, just a helper
# It is defined here so it can be used from configuration
set_target() {
	report "Setting target as $1"
	case "$1" in
		omnia)
			TARGET_BOARD=omnia
			TARGET_ARCH=armv7l
			;;
		turris1x)
			TARGET_BOARD=turris1x
			TARGET_ARCH=ppcspe
			;;
		mox)
			TARGET_BOARD=mox
			TARGET_ARCH=aarch64
			;;
		*)
			echo "Invalid target board!!! Use -t [turris1x|omnia|mox]!!!"
			exit 1
			;;
	esac
}

# Configuration variables
source "$src_dir/defaults.sh"

BUILD_JOBS="$(nproc)" # Number of jobs to be passed to make calls
SIGN_KEY="" # Path to private signing key
FORCE="" # Force build

GIT_MIRROR="" # Path to git mirror directory
CLONE_DEEP="" # Set this variable to clone OpenWRT tree in full depth not just latest commit
DL_MIRROR="" # Path to downloads mirror directory
CCACHE_HOST_DIR="" # Path to ccache directory for host compilations
CCACHE_TARGET_DIR="" # Path to ccache directory for target compilations

BUILD_ARGS=() # Additional arguments passed to OpenWRT make call (note that this is for all make calls in OpenWRT)

# Load configurations
configs=(
	"${src_dir}"/turris-build.conf
	~/.turris-build
	./turris-build.conf
)
for config in "${configs[@]}"; do
	if [ -f "$config" ]; then
		source "$config"
	fi
done
