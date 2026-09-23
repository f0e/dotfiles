-- colours matching ghostty's "iTerm2 Pastel Dark Background" theme
require('mini.base16').setup({
  palette = {
    base00 = '#000000', -- background
    base01 = '#1c1c1c', -- statusline, cursorline
    base02 = '#303030', -- popups
    base03 = '#767676', -- comments, line numbers
    base04 = '#8f8f8f',
    base05 = '#c7c7c7', -- foreground
    base06 = '#f1f1f1',
    base07 = '#ffffff',
    base08 = '#ff8373', -- red
    base09 = '#ffb473', -- orange (ghostty cursor colour)
    base0A = '#fffdc3', -- yellow
    base0B = '#b4fb73', -- green
    base0C = '#d1d1fe', -- cyan (lavender in this theme)
    base0D = '#a5d5fe', -- blue
    base0E = '#ff90fe', -- magenta
    base0F = '#ffc4be', -- bright red
  },
})
-- use the terminal's own background instead of painting one (including the gutter)
for name, hl in pairs(vim.api.nvim_get_hl(0, {})) do
  local gutter = name:match('^LineNr') or name:match('Sign') or name == 'FoldColumn'
  if hl.bg == 0x000000 or (gutter and hl.bg == 0x1c1c1c) then
    hl.bg = nil
    vim.api.nvim_set_hl(0, name, hl)
  end
end
-- same selection colour as the terminal
vim.api.nvim_set_hl(0, 'Visual', { bg = '#454d96' })
