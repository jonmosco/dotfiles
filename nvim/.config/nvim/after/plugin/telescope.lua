local builtin = require('telescope.builtin')

-- Sole owner of the <leader>f* pickers; core/remap.lua used to set ff/fg/fb/fh
-- as <cmd>Telescope ...<cr> strings too, which this file then overwrote.
vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = 'Find files' })
vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = 'Live grep' })
vim.keymap.set('n', '<leader>fb', builtin.buffers, { desc = 'Buffers' })
vim.keymap.set('n', '<leader>fh', builtin.help_tags, { desc = 'Help tags' })
vim.keymap.set('n', '<C-p>', builtin.git_files, {})
vim.keymap.set('n', '<leader>ps', function()
    builtin.grep_string({ search = vim.fn.input("Grep > ") })
end)
vim.keymap.set('n', '<leader>pws', function()
    builtin.grep_string({ search = vim.fn.expand("<cword>") })
end)
vim.keymap.set('n', '<leader>vh', builtin.help_tags, {})

require("telescope").load_extension("ui-select")
