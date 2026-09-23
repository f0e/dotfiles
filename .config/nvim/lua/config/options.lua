vim.o.number = true
vim.o.relativenumber = true
vim.o.mouse = 'a'
vim.o.showmode = false -- already shown in the statusline
vim.o.breakindent = true
vim.o.undofile = true -- keep undo history across sessions
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.signcolumn = 'yes' -- stop text shifting when git/lsp signs appear
vim.o.updatetime = 250
vim.o.timeoutlen = 300
vim.o.splitright = true
vim.o.splitbelow = true
vim.o.inccommand = 'split' -- live preview of :s substitutions
vim.o.cursorline = true
vim.o.scrolloff = 8
vim.o.confirm = true -- ask to save instead of failing on :q with unsaved changes
vim.o.expandtab = true
vim.o.shiftwidth = 2
vim.o.tabstop = 2
vim.o.completeopt = 'menuone,noselect,popup,fuzzy'
vim.o.winborder = 'rounded'

-- share clipboard with macos (deferred since it slows startup)
vim.schedule(function() vim.o.clipboard = 'unnamedplus' end)
