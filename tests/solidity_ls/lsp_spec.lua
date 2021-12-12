local a = require("plenary.async")
local helpers = require("test.helpers")
require("test.extensions")

local it = a.tests.it

describe("solidity_ls", function()
  local workspace_dir = helpers.resolve_workspace_dir("example-project-1")

  helpers.setup_server("solidity_ls", {
    root_dir = function()
      return workspace_dir
    end,
  })

  it("starts", function()
    vim.api.nvim_command("bufdo bwipeout!")
    vim.api.nvim_command("new | only | silent edit fixtures/example-project-1/Main.sol")
    vim.api.nvim_command("set ft=solidity")
    helpers.wait_for_ready_lsp()

    local buf_clients = vim.lsp.buf_get_clients()

    assert.equal(1, #buf_clients)
    assert.equal("solidity_ls", buf_clients[1].name)
    assert.equal(1, #buf_clients[1].workspace_folders)
    assert.equal(helpers.resolve_workspace_uri("example-project-1"), buf_clients[1].workspace_folders[1].uri)
    assert.is_truthy(buf_clients[1].initialized)
  end)
end)
