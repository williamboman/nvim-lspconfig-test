.PHONY: setup test clean

COMMA:=,
PACKPATH=packpath
NVIM_HEADLESS=nvim --headless --noplugin -u "$(shell pwd)/minimal_init.lua"

check_test_var = if [ -z ${TEST} ]; then >&2 echo "must specify \$$TEST"; exit 1; fi

packpath:
	git clone --depth 1 https://github.com/neovim/nvim-lspconfig $(PACKPATH)/pack/dependencies/start/nvim-lspconfig
	git clone --depth 1 https://github.com/nvim-lua/plenary.nvim $(PACKPATH)/pack/dependencies/start/plenary.nvim
	git -C $(PACKPATH)/pack/dependencies/start/plenary.nvim apply "$(shell pwd)/plenary.patch"
	git clone --depth 1 https://github.com/williamboman/nvim-lsp-installer $(PACKPATH)/pack/dependencies/start/nvim-lsp-installer

	cd ./tests/remark_ls/fixtures/example-project-1/ && npm install remark
	cd ./tests/remark_ls/fixtures/example-project-2/ && npm install remark

setup: packpath
	@${check_test_var}
	$(NVIM_HEADLESS) -c "LspInstall --sync $(TEST)" -c "q"

test: packpath
	@mkdir -p "lsp_servers"
	@${check_test_var}
	$(eval TMP_DIR := $(shell mktemp -du))
	@cp -r "./tests/$(TEST)" "$(TMP_DIR)"
	$(NVIM_HEADLESS) \
		-c "cd $(TMP_DIR)" \
		-c "call v:lua.run_tests()"

clean:
	rm -rf $(PACKPATH)
	rm -rf lsp_servers
