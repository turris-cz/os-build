ifneq ($(PKG_SOURCE_PROTO),git)
$(error Only supported protocol is git)
endif
ifndef PKG_NAME
$(error You have to define PKG_NAME before pkgauto.mk include)
endif
ifndef PKG_SOURCE_URL
$(error You have to define PKG_SOURCE_URL before pkgauto.mk include)
endif
ifndef PKG_SOURCE_BRANCH
$(error You have to define PKG_SOURCE_BRANCH before pkgauto.mk include)
endif

TMP_REPO_PATH=$(DL_DIR)/pkgauto/$(PKG_NAME)
GIT_ARGS=--git-dir='$(TMP_REPO_PATH)' --bare

$(shell \
	if [ ! -d "$(TMP_REPO_PATH)" ]; then \
		git clone --mirror "$(PKG_SOURCE_URL)" "$(TMP_REPO_PATH)"; \
	else \
		git $(GIT_ARGS) remote update origin
	fi)

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

PKG_SOURCE:=$(PKG_NAME)-$(PKG_SOURCE_VERSION).tar.gz
PKG_SOURCE_SUBDIR:=$(PKG_NAME)
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)
HOST_BUILD_DIR:=$(BUILD_DIR_HOST)/$(PKG_NAME)

undefine TMP_REPO_PATH
undefine GIT_ARGS
