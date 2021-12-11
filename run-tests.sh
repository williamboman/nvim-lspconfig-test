#!/usr/bin/env bash

set -euo pipefail

FAILED_SERVERS=()
function failure {
  FAILED_SERVERS+=("$1")
}

echo "Running tests..."
echo

for server in angularls ansiblels arduino_language_server bashls bicep clangd clojure_lsp cmake codeqlls csharp_ls cssls dartls denols diagnosticls dockerls dotls efm elixirls elmls ember emmet_ls erlangls esbonio eslint fortls fsautocomplete gopls graphql groovyls hls html intelephense jdtls jedi_language_server jsonls jsonnet_ls kotlin_language_server lemminx ltex ocamlls omnisharp phpactor powershell_es prismals puppet purescriptls pylsp pyright quick_lint_js rescriptls rome rust_analyzer serve_d solang solargraph sorbet spectral sqlls sqls stylelint_lsp sumneko_lua svelte tailwindcss terraformls texlab tflint tsserver vala_ls vimls volar vuels yamlls zls; do
  TEST=$server make setup || failure $server
  TEST=$server make test || failure $server
done

echo
echo "----------------"
echo "Tests complete"
echo "----------------"
echo

# Get length of FAILED_SERVERS and exit if its more than one
if [ ${#FAILED_SERVERS[@]} -gt 0 ]; then
  >&2 echo "One or more servers failed: ${FAILED_SERVERS[@]}"
  exit 1
fi

echo "All servers passed!"

exit 0
