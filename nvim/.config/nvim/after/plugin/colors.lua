-- require('neo_sola'navarasu/onedark.nvim'rized').set()

require('colorbuddy').setup()

-- require('neosolarized').setup({
--     comment_italics = true,
--     background_set = false,
-- })

-- vim.api.nvim_set_hl(0, 'CursorLineNr', { fg = '#b58900'} )

-- vim.cmd[[colorscheme nord]]

-- vim.g.nord_disable_background = true

-- Load the colorscheme
-- require('nord').set()


require('onedark').setup  {
    -- Main options --
    style = 'cool', -- Default theme style. Choose between 'dark', 'darker', 'cool', 'deep', 'warm', 'warmer' and 'light'
    transparent = true,
}
require('onedark').load()
