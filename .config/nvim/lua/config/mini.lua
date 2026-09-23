require('mini.icons').setup() -- needs a nerd font (GeistMono NF)
require('mini.statusline').setup()
require('mini.pairs').setup()
require('mini.surround').setup() -- sa/sd/sr to add/delete/replace surroundings
require('mini.ai').setup() -- extra text objects, e.g. va) / cin"
require('mini.git').setup()
require('mini.diff').setup() -- git change signs in the gutter
require('mini.files').setup()
require('mini.pick').setup()
require('mini.extra').setup()

-- show pending keymaps after pressing leader, g, z, etc
local clue = require('mini.clue')
clue.setup({
  triggers = {
    { mode = 'n', keys = '<Leader>' },
    { mode = 'x', keys = '<Leader>' },
    { mode = 'n', keys = 'g' },
    { mode = 'x', keys = 'g' },
    { mode = 'n', keys = 'z' },
    { mode = 'n', keys = '<C-w>' },
    { mode = 'n', keys = '[' },
    { mode = 'n', keys = ']' },
    { mode = 'n', keys = '"' },
    { mode = 'n', keys = "'" },
    { mode = 'n', keys = '`' },
  },
  clues = {
    clue.gen_clues.builtin_completion(),
    clue.gen_clues.g(),
    clue.gen_clues.marks(),
    clue.gen_clues.registers(),
    clue.gen_clues.windows(),
    clue.gen_clues.z(),
  },
  window = { delay = 300 },
})

local pick = require('mini.pick').builtin
local extra = require('mini.extra').pickers
vim.keymap.set('n', '<leader>e', function() MiniFiles.open(vim.api.nvim_buf_get_name(0)) end, { desc = 'file explorer' })
vim.keymap.set('n', '<leader>f', pick.files, { desc = 'find files' })
vim.keymap.set('n', '<leader>/', pick.grep_live, { desc = 'grep' })
vim.keymap.set('n', '<leader>b', pick.buffers, { desc = 'buffers' })
vim.keymap.set('n', '<leader>h', pick.help, { desc = 'help' })
vim.keymap.set('n', '<leader>r', pick.resume, { desc = 'resume last picker' })
vim.keymap.set('n', '<leader>o', extra.oldfiles, { desc = 'recent files' })
vim.keymap.set('n', '<leader>d', extra.diagnostic, { desc = 'diagnostics' })
vim.keymap.set('n', '<leader>s', function() extra.lsp({ scope = 'document_symbol' }) end, { desc = 'symbols' })
