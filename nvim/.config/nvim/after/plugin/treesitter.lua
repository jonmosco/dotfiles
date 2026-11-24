vim.treesitter.language.register("bash", "zsh")

-- .tf files get filetype "terraform", which does not resolve to any parser,
-- so the installed hcl parser went unused. Map it explicitly.
vim.treesitter.language.register("hcl", "terraform")

-- nvim-treesitter's main branch does not enable highlighting ("These are not
-- automatically enabled" in its README); Neovim only wires it up for its own
-- bundled parsers (c, lua, markdown, query, vim, vimdoc). Without this, every
-- parser installed by the :TSUpdate build step (go, python, bash, rust, yaml,
-- hcl, json, typescript, cpp) fell back to regex syntax.
--
-- start() resolves filetype to language itself, including sh -> bash and the
-- zsh registration above, and turns regex syntax off when it takes over. The
-- pcall leaves filetypes with no parser (text, helm) on regex highlighting.
vim.api.nvim_create_autocmd("FileType", {
    group = vim.api.nvim_create_augroup("treesitter_highlight", { clear = true }),
    callback = function(ev)
        pcall(vim.treesitter.start, ev.buf)
    end,
})
