vim.o.display = "lastline" -- Avoid neovim/neovim#11362
vim.o.directory = ""

local __file__ = debug.getinfo(1).source:match("@(.*)$")
local root_dir = vim.fn.fnamemodify(__file__, ":p:h")
vim.opt.runtimepath:append(root_dir)

local packpath = root_dir .. "/packpath"
vim.opt.packpath = packpath
vim.cmd("packloadall")

require("nvim-lsp-installer").settings({
  install_root_dir = root_dir .. "/lsp_servers",
})

function _G.run_tests()
  require("plenary.test_harness").test_directory(".", {
    minimal_init = __file__,
    sequential = true,
    timeout = 60000,
  })
end
