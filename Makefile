.PHONY: setup test clean

COMMA:=,
PACKPATH=packpath
NVIM_HEADLESS=nvim --headless --noplugin -u "$(shell pwd)/minimal_init.lua"

check_test_var = if [ -z ${TEST} ]; then >&2 echo "must specify \$$TEST"; exit 1; fi

packpath:
	git clone --depth 1 https://github.com/neovim/nvim-lspconfig $(PACKPATH)/pack/dependencies/start/nvim-lspconfig
	git clone --depth 1 https://github.com/williamboman/plenary.nvim $(PACKPATH)/pack/dependencies/start/plenary.nvim
	git -C $(PACKPATH)/pack/dependencies/start/plenary.nvim fetch origin timeout-param
	git -C $(PACKPATH)/pack/dependencies/start/plenary.nvim checkout FETCH_HEAD
	git clone --depth 1 https://github.com/williamboman/nvim-lsp-installer $(PACKPATH)/pack/dependencies/start/nvim-lsp-installer

setup: packpath
	@${check_test_var}
	$(NVIM_HEADLESS) -c "LspInstall --sync $(TEST)" -c "q"

test: packpath
	@${check_test_var}
	$(eval TMP_DIR := $(shell mktemp -du))
	@cp -r "./tests/$(TEST)" "$(TMP_DIR)"
	$(NVIM_HEADLESS) \
		-c "cd $(TMP_DIR)" \
		-c "lua require('plenary.test_harness').test_directory('.', {minimal_init='$(shell pwd)/minimal_init.lua'$(COMMA)sequential=true$(COMMA)timeout=600000})"

clean:
	rm -rf $(PACKPATH)
