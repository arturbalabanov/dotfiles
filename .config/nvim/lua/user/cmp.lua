local status_ok, cmp = pcall(require, "cmp")
if not status_ok then
    return
end

local has_words_before = function()
    if vim.api.nvim_buf_get_option(0, "buftype") == "prompt" then
        return false
    end

    unpack = unpack or table.unpack
    local line, col = unpack(vim.api.nvim_win_get_cursor(0))

    if col == 0 then
        return false
    end

    return vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
end

local feedkey = function(key, mode)
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(key, true, true, true), mode, true)
end

local luasnip = require("luasnip")
local cmp_context = require('cmp.config.context')

cmp.setup({
    snippet = {
        expand = function(args)
            luasnip.lsp_expand(args.body)
        end,
    },
    window = {
        documentation = cmp.config.window.bordered(),
    },
    formatting = {
        format = require('lspkind').cmp_format({
            mode = 'symbol',
            symbol_map = { Copilot = "" },
        }),
    },
    sorting = {
        comparators = {
            require("copilot_cmp.comparators").prioritize,
            require("copilot_cmp.comparators").score,
            cmp.config.compare.kind,
            cmp.config.compare.exact,
            cmp.config.compare.sort_text,
        },
    },
    mapping = cmp.mapping.preset.insert({
        ['<C-b>'] = cmp.mapping.scroll_docs(-4),
        ['<C-f>'] = cmp.mapping.scroll_docs(4),
        ['<Esc>'] = cmp.mapping.abort(),
        -- If nothing is selected (including preselections) add a newline as usual.
        -- If something has explicitly been selected by the user, select it.
        ["<CR>"] = cmp.mapping({
            i = function(fallback)
                if cmp.visible() and cmp.get_active_entry() then
                    cmp.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = false })
                else
                    fallback()
                end
            end,
            c = function(fallback)
                if cmp.visible() and cmp.get_active_entry() then
                    cmp.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = false })
                else
                    fallback()
                end
            end,
            s = cmp.mapping.confirm({ select = true }),
        }),
        ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
                cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then
                luasnip.expand_or_jump()
            elseif has_words_before() then
                cmp.complete()
            else
                fallback()
            end
        end, { "i", "s" }),

        ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
                cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
                luasnip.jump(-1)
            else
                fallback()
            end
        end, { "i", "s" }),

        ['<C-Space>'] = cmp.mapping(cmp.mapping.complete(), { 'i', 'c' }),
    }),
    sources = cmp.config.sources({
        { name = 'copilot',  group_index = 1 },
        {
            -- {
            --     name = 'luasnip',
            --     -- TODO: Prioritise user snippets over third party ones
            --
            --     -- Disable snippet completion in comments and strings
            --     entry_filter = function(entry, ctx)
            --         return not (
            --             cmp_context.in_treesitter_capture('string')
            --             or cmp_context.in_treesitter_capture('comment')
            --         )
            --     end,
            -- },
            name = 'luasnip',
            group_index = 2
        },
        { name = 'nvim_lsp', group_index = 2 },
        {
            name = 'buffer', -- only enable buffer completion in comments
            entry_filter = function(entry, ctx)
                return cmp_context.in_treesitter_capture('comment')
            end,
            group_index = 3,
        },
    })
})

cmp.setup.cmdline('/', {
    mapping = cmp.mapping.preset.cmdline(),
    sources = {
        { name = 'buffer' },
    },
})

cmp.setup.cmdline(':', {
    mapping = cmp.mapping.preset.cmdline(),
    sources = cmp.config.sources {
        {
            { name = 'path' },
        },
        {
            name = 'cmdline',
            option = {
                ignore_cmds = { 'Man', '!' },
            },
        },
    }
})
