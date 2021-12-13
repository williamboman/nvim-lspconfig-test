local a = require("plenary.async")
local lspconfig_util = require("lspconfig.util")

local M = {}

---@alias Response any

---@param pos table @The {line, col} tuple to set the cursor to before executing the request.
---@param method string @The LSP method to request.
---@return nil|Response[] @A non-empty list of responses, or nil.
function M.try_lsp_req(pos, method)
  vim.api.nvim_win_set_cursor(0, pos)
  local params = vim.lsp.util.make_position_params()

  a.util.sleep(1000) -- TODO: fixme
  local result = a.lsp.buf_request_all(0, method, params)

  if result == nil then
    return nil
  end

  if not vim.tbl_islist(result) then
    result = { result }
  end

  if vim.tbl_isempty(result) then
    return nil
  end

  return result
end

function M.wait_for_ready_lsp()
  local is_ready = false

  repeat
    is_ready = vim.lsp.buf.server_ready()
    if not is_ready then
      a.util.sleep(50)
    end
  until is_ready
end

---@param response Response|nil
---@return string|nil
function M.hover_parser(response)
  if not response.result.contents then
    return nil
  end
  local markdown_lines = vim.lsp.util.convert_input_to_markdown_lines(response.result.contents)
  return table.concat(markdown_lines, "\n")
end

---@param server_name string
---@param opts table
function M.setup_server(server_name, opts)
  local ok, server = require("nvim-lsp-installer.servers").get_server(server_name)
  if not ok then
    error("Could not find server: " .. server_name)
  end
  server:setup(opts)
end

function M.resolve_workspace_dir(workspace_dir)
  return lspconfig_util.path.join(vim.loop.cwd(), "fixtures", workspace_dir)
end

function M.resolve_workspace_uri(workspace_dir)
  return vim.uri_from_fname(M.resolve_workspace_dir(workspace_dir))
end


return M
