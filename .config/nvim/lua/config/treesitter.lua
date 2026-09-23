-- use treesitter highlighting where a parser exists (nvim bundles lua, vim, markdown, c, etc)
vim.api.nvim_create_autocmd('FileType', {
  callback = function(ev) pcall(vim.treesitter.start, ev.buf) end,
})
