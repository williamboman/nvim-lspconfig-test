local a = require("plenary.async")
local lspconfig_util = require("lspconfig.util")
local helpers = require("test.helpers")
require("test.extensions")

local it = a.tests.it

describe("taplo", function()
  helpers.setup_server("taplo", {
    root_dir = lspconfig_util.root_pattern("root-dir.marker"),
  })

  it("starts", function()
    vim.api.nvim_command("bufdo bwipeout!")
    vim.api.nvim_command("new | only | find fixtures/example-project-1/myproj/main.toml")
    vim.api.nvim_command("set ft=toml")
    helpers.wait_for_ready_lsp()

    local buf_clients = vim.tbl_values(vim.lsp.buf_get_clients(0))

    assert.equal(1, #buf_clients)
    assert.equal("taplo", buf_clients[1].name)
    assert.equal(1, #buf_clients[1].workspace_folders)
    assert.equal(helpers.resolve_workspace_uri("example-project-1"), buf_clients[1].workspace_folders[1].uri)
    assert.equal(helpers.resolve_workspace_dir("example-project-1"), buf_clients[1].config.root_dir)
    assert.equal(helpers.resolve_workspace_dir("example-project-1"), buf_clients[1].config.cmd_cwd)
    assert.is_truthy(buf_clients[1].initialized)
  end)

  it("works with single file support", function()
    vim.api.nvim_command("bufdo bwipeout!")
    vim.api.nvim_command("new | only | silent edit fixtures/example-project-2/main.toml")
    vim.api.nvim_command("set ft=toml")
    helpers.wait_for_ready_lsp()

    local buf_clients = vim.tbl_values(vim.lsp.buf_get_clients(0))

    assert.equal(1, #buf_clients)
    assert.equal("taplo", buf_clients[1].name)
    assert.is_nil(buf_clients[1].workspace_folders)
    assert.is_nil(buf_clients[1].config.root_dir)
    assert.equal(helpers.resolve_workspace_dir("example-project-2"), buf_clients[1].config.cmd_cwd)
    assert.is_truthy(buf_clients[1].initialized)
  end)
end)
