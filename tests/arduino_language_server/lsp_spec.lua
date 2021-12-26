local a = require("plenary.async")
local helpers = require("test.helpers")
require("test.extensions")

local it = a.tests.it

describe("arduino_language_server", function()
  local _, arduino_language_server = require("nvim-lsp-installer.servers").get_server("arduino_language_server")
  helpers.setup_server("arduino_language_server", {
    cmd = vim.list_extend(arduino_language_server:get_default_options().cmd, { "-fqbn", "arduino:avr:nano" }),
  })

  it("starts", function()
    vim.api.nvim_command("bufdo bwipeout!")
    vim.api.nvim_command("new | only | silent edit fixtures/example-project-1/main.ino")
    vim.api.nvim_command("set ft=arduino")
    helpers.wait_for_ready_lsp()

    local buf_clients = vim.tbl_values(vim.lsp.buf_get_clients(0))

    assert.equal(1, #buf_clients)
    assert.equal("arduino_language_server", buf_clients[1].name)
    assert.equal(1, #buf_clients[1].workspace_folders)
    assert.equal(helpers.resolve_workspace_uri("example-project-1"), buf_clients[1].workspace_folders[1].uri)
    assert.is_truthy(buf_clients[1].initialized)
  end)
end)
