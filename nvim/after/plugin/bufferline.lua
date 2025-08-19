vim.opt.termguicolors = true

-- local highlights = require("nord").bufferline.highlights({
--     italic = true,
--     bold = true,
--     fill = "#181c24"
-- })

require('bufferline').setup{
    options = {
        -- separator_style = "slant",
        indicator = {
            style = "icon"
        },
        -- highlights = highlights,
    }
}
