ifndef AUTOPKG_VARIANT
	$(error "Don't include autopkg-head.mk directly!")
endif

ifndef PKG_NAME
$(error You have to define PKG_NAME before pkgauto.mk include)
endif
ifndef PKG_SOURCE_URL
$(error You have to define PKG_SOURCE_URL before pkgauto.mk include)
endif

TMP_REPO_PATH=$(DL_DIR)/autopkg/$(PKG_NAME)
GIT_ARGS=--git-dir='$(TMP_REPO_PATH)' --bare

# Clone/update git history to bare repository
$(info $(shell \
	if [ ! -d "$(TMP_REPO_PATH)" ]; then \
		git clone --mirror "$(PKG_SOURCE_URL)" "$(TMP_REPO_PATH)"; \
	else \
		git $(GIT_ARGS) remote update origin; \
	fi))
