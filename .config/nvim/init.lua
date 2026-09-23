-- set before anything maps <leader>
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

require('config.options')
require('config.keymaps')
require('config.plugins') -- install/load plugins; everything below may use them
require('config.colours')
require('config.mini')
require('config.lsp')
require('config.treesitter')
