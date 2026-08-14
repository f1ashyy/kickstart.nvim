-- UndoTree
vim.g.undotree_SetFocusWhenToggle = 1

vim.opt.undofile = true
vim.opt.undodir = vim.fn.stdpath 'data' .. '/undo'

vim.keymap.set('n', '<leader>u', '<cmd>UndotreeToggle<CR>', {
  desc = 'Toggle UndoTree',
})
