-- ref: https://github.com/KostkaBrukowa/nvim-config/blob/master/lua/dupa/definitions_or_references/entries.lua
local function lsp_refs_in_telescope(result)
    local entry_display = require("telescope.pickers.entry_display")
    local make_entry = require("telescope.make_entry")

    local cwd = vim.loop.cwd()

    local function make_telescope_entries_from()
        local configuration = {
            { max_width = 40 },
            {},
        }

        local displayer = entry_display.create({ separator = " ", items = configuration })

        local make_display = function(entry)
            local rel_filename = require("plenary.path"):new(entry.filename):make_relative(cwd)
            local trimmed_text = entry.text:gsub("^%s*(.-)%s*$", "%1")

            return displayer({
                { rel_filename, "TelescopeResultsIdentifier" },
                { trimmed_text },
            })
        end

        return function(entry)
            local rel_filename = require("plenary.path"):new(entry.filename):make_relative(cwd)

            return make_entry.set_default_entry_mt({
                value = entry,
                ordinal = rel_filename .. " " .. entry.text,
                display = make_display,

                bufnr = entry.bufnr,
                filename = entry.filename,
                lnum = entry.lnum,
                col = entry.col - 1,
                text = entry.text,
                start = entry.start,
                finish = entry.finish,
            }, {})
        end
    end

    require("telescope.pickers")
        .new({}, {
            prompt_title = "LSP References",
            finder = require("telescope.finders").new_table({
                results = vim.lsp.util.locations_to_items(result, "utf-16"),
                entry_maker = make_telescope_entries_from(),
            }),
            sorter = require("telescope.config").values.generic_sorter({}),
            previewer = require("telescope.config").values.qflist_previewer({}),
            layout_strategy = "vertical",
            initial_mode = "normal",
            wrap_results = false,
        })
        :find()
end

return {
    "KostkaBrukowa/definition-or-references.nvim",
    dependencies = { "nvim-telescope/telescope.nvim" },
    opts = {
        debug = false,
        include_implementations = true,
        on_references_result = lsp_refs_in_telescope,
    },
    keys = {
        { "gd", function() require("definition-or-references").definition_or_references() end, desc = "Go To definition or references" },
    },
}
