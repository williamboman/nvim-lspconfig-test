local a = require("plenary.async")
local helpers = require("test.helpers")
require("test.extensions")

local it = a.tests.it

describe("arduino_language_server", function()
  -- Does a `arduino-cli daemon` instance need to be running?
  helpers.setup_server("arduino_language_server", {
    cmd = {
      "arduino-language-server",
      "-cli-config",
      "arduino-cli.yaml",
      "-fqbn",
      "arduino:avr:nano",
    },
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
