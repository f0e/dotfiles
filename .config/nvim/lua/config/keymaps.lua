vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')
vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'exit terminal mode' })

vim.keymap.set('n', '<C-h>', '<C-w>h', { desc = 'focus left window' })
vim.keymap.set('n', '<C-j>', '<C-w>j', { desc = 'focus lower window' })
vim.keymap.set('n', '<C-k>', '<C-w>k', { desc = 'focus upper window' })
vim.keymap.set('n', '<C-l>', '<C-w>l', { desc = 'focus right window' })

-- briefly highlight yanked text
vim.api.nvim_create_autocmd('TextYankPost', {
  callback = function() vim.hl.on_yank() end,
})
