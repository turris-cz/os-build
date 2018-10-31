# Autopkg tracking given branch
AUTOPKG_VARIANT:=branch
include $(TOPDIR)/feeds/personal/autopkg-head.mk

ifndef PKG_SOURCE_BRANCH
$(error You have to define PKG_SOURCE_BRANCH before pkgauto.mk include)
endif

PKG_SOURCE_VERSION:=$(shell git $(GIT_ARGS) rev-parse "$(PKG_SOURCE_BRANCH)")
PKG_VERSION:=$(shell git $(GIT_ARGS) describe --abbrev=0 --tags "$(PKG_SOURCE_BRANCH)")

ifeq ($(PKG_VERSION),)
# Count commits since initial commit.
PKG_RELEASE:=$(shell git $(GIT_ARGS) rev-list --count "$(PKG_SOURCE_VERSION)")
# No previous version found (no tag) so we use 9999 instead
PKG_VERSION:=9999
else
# Count commits since last version tag
PKG_RELEASE:=$(shell git $(GIT_ARGS) rev-list --count "$(PKG_VERSION)..$(PKG_SOURCE_VERSION)")
# .9999 is appended to not collide with possible existing package versions in repository
PKG_VERSION:=$(PKG_VERSION:v%=%).9999
endif

include $(TOPDIR)/feeds/personal/autopkg-tail.mk
