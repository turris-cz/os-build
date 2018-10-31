# Autopkg tracking latest version tag
AUTOPKG_VARIANT:=tag
include $(TOPDIR)/feeds/personal/autopkg-head.mk

ifeq ($(PKG_SOURCE_ALL_TAGS),y)
PKG_SOURCE_VERSION:=$(shell git $(GIT_ARGS) tag | sort -V | tail -1)
PKG_VERSION:=$(PKG_SOURCE_VERSION)
else
PKG_SOURCE_VERSION:=$(shell git $(GIT_ARGS) tag | grep '^v' | sort -V | tail -1)
PKG_VERSION:=$(subst v%,%,$(PKG_SOURCE_VERSION))
endif

include $(TOPDIR)/feeds/personal/autopkg-tail.mk
