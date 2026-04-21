local my_utils = require("utils")
local markdown_utils = require("utils.markdown")
local treesitter_utils = require("utils.treesitter")

-- TODO: Incorporate this: https://www.reddit.com/r/neovim/comments/1sezoxf/nvimtreesitter_auto_install_parsers/

local ENSURE_INSTALLED = {
    "bash",
    "c",
    "diff",
    "html",
    "javascript",
    "jsdoc",
    "json",
    "jsonc",
    "lua",
    "luadoc",
    "luap",
    "markdown",
    "markdown_inline",
    "printf",
    "python",
    "query",
    "regex",
    "toml",
    "tsx",
    "typescript",
    "vim",
    "vimdoc",
    "xml",
    "yaml",
}

local ts_setup_error = function(err_lines)
    if type(err_lines) == "string" then
        err_lines = { err_lines }
    end

    markdown_utils.notify("nvim-treesitter setup error", err_lines, "error")
end

local ts_text_obj_keymap = function(lhs, keymap_type, func_name, textobj_query)
    local mode, desc

    if keymap_type == "select" then
        mode = { "x", "o" }
        desc = "Select " .. textobj_query
    elseif keymap_type == "move" then
        mode = { "n", "x", "o" }
        desc = func_name .. textobj_query
    else
        markdown_utils.notify("nvim-treesitter-textobjects invalid keymap", { "lhs: " .. lhs }, "error")
        return {}
    end

    return {
        lhs,
        function()
            require("nvim-treesitter-textobjects." .. keymap_type)[func_name](textobj_query, "textobjects")
        end,
        mode = mode,
        desc = desc,
    }
end

return {
    {
        -- Config inspired by LazyVim
        -- ref: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/plugins/treesitter.lua

        "nvim-treesitter/nvim-treesitter",
        branch = "main",
        lazy = false,
        build = function()
            local nvim_treesitter = require("nvim-treesitter")
            if not nvim_treesitter.get_installed then
                ts_setup_error(
                    "Please restart Neovim and run `:TSUpdate` to use the `nvim-treesitter` **main** branch."
                )
                return
            end
            -- make sure we're using the latest treesitter util
            package.loaded["lazyvim.util.treesitter"] = nil
            treesitter_utils.build(function()
                nvim_treesitter.update(nil, { summary = true })
            end)
        end,
        opts_extend = { "ensure_installed" },
        opts = {
            auto_install = true,
            ensure_installed = ENSURE_INSTALLED,
            ignore_install = {
                "ipkg", -- https://github.com/srghma/tree-sitter-ipkg doesn't exist anymore
            },
            sync_install = false, -- install languages synchronously (only applied to `ensure_installed`)
            highlight = { enable = true },
            autopairs = { enable = true },
            context_commentstring = { enable = true, enable_autocmd = false },
            indent = { enable = true },
        },
        config = function(_, opts)
            local nvim_treesitter = require("nvim-treesitter")

            -- TODO: do we need this?
            setmetatable(require("nvim-treesitter.install"), {
                __newindex = function(_, k)
                    if k == "compilers" then
                        vim.schedule(function()
                            ts_setup_error({
                                "Setting custom compilers for `nvim-treesitter` is no longer supported.",
                                "",
                                "For more info, see:",
                                "- [compilers](https://docs.rs/cc/latest/cc/#compile-time-requirements)",
                            })
                        end)
                    end
                end,
            })

            -- some quick sanity checks
            if not nvim_treesitter.get_installed then
                return ts_setup_error("Please use `:Lazy` and update `nvim-treesitter`")
            elseif type(opts.ensure_installed) ~= "table" then
                return ts_setup_error("`nvim-treesitter` opts.ensure_installed must be a table")
            end

            -- setup treesitter
            nvim_treesitter.setup(opts)

            treesitter_utils.get_installed(true) -- initialize the installed langs

            -- install missing parsers
            local install = vim.tbl_filter(function(lang)
                return not treesitter_utils.have(lang)
            end, opts.ensure_installed or {})

            if #install > 0 then
                treesitter_utils.build(function()
                    nvim_treesitter.install(install, { summary = true }):await(function()
                        treesitter_utils.get_installed(true) -- refresh the installed langs
                    end)
                end)
            end

            vim.api.nvim_create_autocmd("FileType", {
                group = vim.api.nvim_create_augroup("lazyvim_treesitter", { clear = true }),
                callback = function(ev)
                    local ft, lang = ev.match, vim.treesitter.language.get_lang(ev.match)
                    if not treesitter_utils.have(ft) then
                        return
                    end

                    ---@param feat string
                    ---@param query string
                    local function enabled(feat, query)
                        local f = opts[feat] or {} ---@type lazyvim.TSFeat
                        return f.enable ~= false
                            and not (type(f.disable) == "table" and vim.tbl_contains(f.disable, lang))
                            and treesitter_utils.have(ft, query)
                    end

                    -- highlighting
                    if enabled("highlight", "highlights") then
                        pcall(vim.treesitter.start, ev.buf)
                    end

                    -- TODO: fucking enable these
                    -- -- indents
                    -- if enabled("indent", "indents") then
                    --     LazyVim.set_default("indentexpr", "v:lua.require('utils.treesitter').indentexpr()")
                    -- end
                    --
                    -- -- folds
                    -- if enabled("folds", "folds") then
                    --     if LazyVim.set_default("foldmethod", "expr") then
                    --         LazyVim.set_default("foldexpr", "v:lua.require('utils.treesitter').foldexpr()")
                    --     end
                    -- end
                end,
            })
        end,
    },
    -- TODO: replace this plugin with mini.ai
    {
        "nvim-treesitter/nvim-treesitter-textobjects",
        branch = "main",
        -- init = function()
        --     -- Disable entire built-in ftplugin mappings to avoid conflicts.
        --     -- See https://github.com/neovim/neovim/tree/master/runtime/ftplugin for built-in ftplugins.
        --     vim.g.no_plugin_maps = true
        -- end,
        opts = {
            select = {
                -- Automatically jump forward to textobj, similar to targets.vim
                lookahead = true,

                selection_modes = {
                    ["@parameter.outer"] = "v", -- charwise
                    ["@function.outer"] = "V", -- linewise
                    ["@function.inner"] = "v", -- charwise
                    ["@block.inner"] = "V", -- linewise
                    ["@block.outer"] = "V", -- linewise
                },
            },
            move = {
                set_jumps = true, -- whether to set jumps in the jumplist
            },
        },
        keys = {
            ts_text_obj_keymap("af", "select", "select_textobject", "@function.outer"),
            ts_text_obj_keymap("if", "select", "select_textobject", "@function.inner"),
            ts_text_obj_keymap("ac", "select", "select_textobject", "@class.outer"),
            ts_text_obj_keymap("ic", "select", "select_textobject", "@class.inner"),
            ts_text_obj_keymap("aB", "select", "select_textobject", "@block.outer"),
            ts_text_obj_keymap("iB", "select", "select_textobject", "@block.inner"),
            ts_text_obj_keymap("]f", "move", "goto_next_start", "@function.outer"),
            ts_text_obj_keymap("]c", "move", "goto_next_start", "@class.outer"),
            ts_text_obj_keymap("]a", "move", "goto_next_start", "@parameter.inner"),
            ts_text_obj_keymap("]F", "move", "goto_next_end", "@function.outer"),
            ts_text_obj_keymap("]C", "move", "goto_next_end", "@class.outer"),
            ts_text_obj_keymap("]A", "move", "goto_next_end", "@parameter.inner"),
            ts_text_obj_keymap("[f", "move", "goto_previous_start", "@function.outer"),
            ts_text_obj_keymap("[c", "move", "goto_previous_start", "@class.outer"),
            ts_text_obj_keymap("[a", "move", "goto_previous_start", "@parameter.inner"),
            ts_text_obj_keymap("[F", "move", "goto_previous_end", "@function.outer"),
            ts_text_obj_keymap("[C", "move", "goto_previous_end", "@class.outer"),
            ts_text_obj_keymap("[A", "move", "goto_previous_end", "@parameter.inner"),
        },
    },
    "RRethy/nvim-treesitter-endwise",
}
