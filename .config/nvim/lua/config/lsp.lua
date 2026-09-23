-- know about the vim global when editing this config
vim.lsp.config('lua_ls', {
  settings = { Lua = { runtime = { version = 'LuaJIT' }, workspace = { library = { vim.env.VIMRUNTIME } } } },
})

-- enable any server that's installed (built-in maps: grn rename, gra action, grr refs, gri impl, K hover)
for _, server in ipairs({ 'lua_ls', 'ts_ls', 'pyright', 'rust_analyzer', 'gopls', 'clangd', 'bashls' }) do
  local cmd = vim.lsp.config[server] and vim.lsp.config[server].cmd
  if type(cmd) == 'table' and vim.fn.executable(cmd[1]) == 1 then vim.lsp.enable(server) end
end

vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(ev)
    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    if client and client:supports_method('textDocument/completion') then
      vim.lsp.completion.enable(true, client.id, ev.buf, { autotrigger = true })
    end
  end,
})

vim.diagnostic.config({ virtual_text = true, severity_sort = true })
