local cmp = require('cmp')

cmp.setup({
    snippet = {
        expand = function(args)
            require('luasnip').lsp_expand(args.body)
        end,
    },
    window = {
        completion = cmp.config.window.bordered(),
        documentation = cmp.config.window.bordered(),
    },
    mapping = cmp.mapping.preset.insert({
        ['<C-p>'] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Select }),
        ['<C-n>'] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Select }),
        ['<C-y>'] = cmp.mapping.confirm({ select = true }),
        ['<C-Space>'] = cmp.mapping.complete(),
    }),
    formatting = {
        format = function(entry, vim_item)
            local source_names = {
                nvim_lsp = "[LSP]",
                luasnip = "[Snip]",
                buffer = "[Buf]",
                path = "[Path]",
                cmdline = "[Cmd]",
            }
            vim_item.menu = source_names[entry.source.name] or ""
            return vim_item
        end,
    },
    sources = cmp.config.sources({
        { name = 'nvim_lsp' },
        { name = 'luasnip' },
        { name = 'path' },
    }, {
        { name = 'buffer' },
    }),
})

cmp.setup.cmdline(':', {
    mapping = cmp.mapping.preset.cmdline(),
    formatting = {
        fields = { "abbr" },
    },
    sources = cmp.config.sources({
        { name = 'path' },
    }, {
        { name = 'cmdline' },
    }),
})
