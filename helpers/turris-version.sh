#!/bin/bash
# Turris OS version handling script
# (C) 2018 CZ.NIC, z.s.p.o.
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

news_file="$(dirname "$(dirname "$(readlink -f "$0")")")/NEWS"

get_version() {
	# If first grep fails - version is not first non-empty, add 999 to the end
	# Be aware that Condition in if also outputs the results
	if ! grep . "$news_file" | head -n 1 | grep '^[0-9.]\+$'; then
		echo "$(grep '^[0-9.]\+$' "$news_dir" | head -n 1).999"
	fi
}

gen_package() {
	version="$(get_version)"
	mkdir -p "$output"
	cd "$output"
	# If top of the NEWS is not a version number, find previous one and add 99
	# Also try to figure out where are the actual NEWS for this version
	if expr "$version" : '999$' > /dev/null; then
		start=1
		end="$(grep -n '^[0-9.]\+$' "$news_file" | sed -n '1 s|:.*||p')"
		end=$((end - 1))
	else
		start="$(grep -n '^[0-9.]\+$' "$news_file" | sed -n '1 s|:.*||p')"
		start=$((start + 1))
		end="$(grep -n '^[0-9.]\+$' "$news_file" | sed -n '2 s|:.*||p')"
		[ -n "$end" ] || end="\$"
	fi
	# Generate package
	cat > Makefile << EOF
#
## Copyright (C) $(date +%Y) CZ.NIC z.s.p.o. (http://www.nic.cz/)
#
## This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
# #
#
include \$(TOPDIR)/rules.mk

PKG_NAME:=turris-version
PKG_VERSION:=$version

PKG_MAINTAINER:=CZ.NIC <packaging@nic.cz>

include \$(INCLUDE_DIR)/package.mk

define Package/turris-version
	TITLE:=turris-version
endef

define Build/Prepare
endef

define Build/Compile
endef

define Package/turris-version/postinst
#!/bin/sh
# Danger: spaces are not ordinary spaces, but special unicode ones
[ -n "\$\$IPKG_INSTROOT" ] || {
create_notification -s news "$(sed -n "$start,$end p" "$news_file" | sed '/^$/d;s/^[[:blank:]]*\*[[:blank:]]*/ • /')"
}
endef

define Package/turris-version/install
	\$(INSTALL_DIR) \$(1)/etc
	echo \$(PKG_VERSION) > \$(1)/etc/turris-version
endef

\$(eval \$(call BuildPackage,turris-version))
EOF
}

output=.
operation=
while [ $# -gt 0 ]; do
	case "$1" in
		-h|--help)
			echo "Turris version from NEWS file."
			echo "Usage: $0 [OPTION].. OPERATION"
			echo
			echo "Operations:"
			echo "  version"
			echo "    Prints version parsed from NEWS file. This is default operation."
			echo "  package"
			echo "    Generate turris-version package from NEWS file."
			echo
			echo "Options:"
			echo "  --output PATH"
			echo "    Path used as output for package command."
			echo "  --help, -h"
			echo "    Print this help text."
			exit 0
			;;
		--output)
			shift
			output="$1"
			;;
		version|package)
			operation="$1"
			;;
		*)
			echo "Unknown argument: $1" >&2
			exit 1
			;;
	esac
	shift
done
[ -n "$operation" ] || operation=version
[ -f "$news_file" ] || {
	echo "Error: NEWS file not located!" >&2
	exit 1
}

case "$operation" in
	version)
		get_version
		;;
	package)
		gen_package
		;;
esac
