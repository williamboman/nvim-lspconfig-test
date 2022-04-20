local a = require("plenary.async")
local util = require("lspconfig.util")
local helpers = require("test.helpers")
require("test.extensions")

local it = a.tests.it

describe("mm0_ls", function()
  helpers.setup_server("mm0_ls", {
    root_dir = util.root_pattern("root-marker"),
  })

  it("starts", function()
    vim.api.nvim_command("bufdo bwipeout!")
    vim.api.nvim_command("new | only | silent edit fixtures/example-project-1/src/main.mm")
    vim.api.nvim_command("set ft=metamath-zero")
    helpers.wait_for_ready_lsp()

    local buf_clients = vim.tbl_values(vim.lsp.buf_get_clients(0))

    assert.equal(1, #buf_clients)
    assert.equal("mm0_ls", buf_clients[1].name)
    assert.equal(1, #buf_clients[1].workspace_folders)
    assert.equal(helpers.resolve_workspace_uri("example-project-1"), buf_clients[1].workspace_folders[1].uri)
    assert.is_truthy(buf_clients[1].initialized)
  end)
end)
