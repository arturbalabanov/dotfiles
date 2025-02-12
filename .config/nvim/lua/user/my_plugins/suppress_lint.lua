local my_utils = require("user.utils")

local M = {
    formats_per_source = {
        ruff = {
            with_code = "noqa: %s",
            without_code = "noqa",
        },
        mypy = {
            with_code = "type: ignore[%s]",
            without_code = "type: ignore",
        },
        bandit = {
            with_code = "nosec %s",
            without_code = "nosec",
        },
        flake8 = {
            with_code = "noqa: %s",
            without_code = "noqa",
        }
    },
    source_aliases = {
        ["Lua Diagnostics."] = "lua_ls",
        ["Lua Syntax Check."] = "lua_ls",
    },
}

local function get_supported_sources()
    return vim.tbl_keys(M.formats_per_source)
end

local function get_diagnostics_on_line(bufnr, lnum)
    local supported_sources = get_supported_sources()

    return vim.tbl_filter(
        function(diagnostic)
            return vim.tbl_contains(supported_sources, diagnostic.source)
        end,
        vim.diagnostic.get(bufnr, { lnum = lnum })
    )
end

local function format_diagnostic_suppress_text(diagnostic)
    -- TODO: Add rules to add multiple suppresses, e.g. noqa F123,E432,
    --       possibly if there is already another suppress from a different source

    local source_formats = M.formats_per_source[diagnostic.source]

    if source_formats == nil then
        return nil
    end

    local source_format
    if diagnostic.code == nil or diagnostic.code == vim.NIL then
        source_format = source_formats.without_code
    else
        source_format = source_formats.with_code
    end

    return string.format(source_format, diagnostic.code)
end

local function add_suppress_diagnostics(diagnostic, bufnr, lnum)
    local suppress_diagnostic_string = format_diagnostic_suppress_text(diagnostic)

    if suppress_diagnostic_string == nil then
        vim.notify(string.format("Suppress diagnostic: unsupported source: %s", diagnostic.source), vim.log.levels.ERROR)
        return
    end

    local comment_string = vim.api.nvim_buf_get_option(bufnr, 'commentstring')
    local comment_to_add = string.format("  %s", comment_string:format(format_diagnostic_suppress_text(diagnostic)))
    local end_of_line_col = vim.fn.col('$')

    local text_edit = {
        range = {
            start = { line = lnum, character = end_of_line_col },
            ["end"] = { line = lnum, character = end_of_line_col + string.len(comment_to_add) },
        },
        newText = comment_to_add:format(suppress_diagnostic_string),
    }

    vim.lsp.util.apply_text_edits({ text_edit }, bufnr, "utf-8")
end

local function format_diagnostic(diagnostic)
    local severity = vim.diagnostic.severity

    -- TODO: Add a colour to the sign, that's the texthl property (instead of text)
    local sign_per_severity = {
        [severity.ERROR] = vim.fn.sign_getdefined("DiagnosticSignError")[1],
        [severity.WARN] = vim.fn.sign_getdefined("DiagnosticSignWarn")[1],
        [severity.INFO] = vim.fn.sign_getdefined("DiagnosticSignInfo")[1],
        [severity.HINT] = vim.fn.sign_getdefined("DiagnosticSignHint")[1],
    }

    local fallback_sign = { text = "?", texthl = "" }
    local sign
    if diagnostic.severity == nil then
        sign = fallback_sign
    else
        sign = sign_per_severity[diagnostic.severity] or fallback_sign
    end

    local source = M.source_aliases[diagnostic.source] or diagnostic.source

    return string.format("%s %s %s %s", sign.text, source, diagnostic.code, diagnostic.message)
end

M.suppress_current_line_lint = function()
    vim.schedule(function()
        local bufnr = vim.api.nvim_get_current_buf()
        local winnr = vim.api.nvim_get_current_win()
        local linenr, _ = unpack(vim.api.nvim_win_get_cursor(winnr))
        local diagnostics = get_diagnostics_on_line(bufnr, linenr - 1)

        if vim.tbl_isempty(diagnostics) then
            vim.notify("No suppressable linting errors found for the current lint")
            return
        end

        if #diagnostics == 1 then
            add_suppress_diagnostics(diagnostics[1], bufnr, linenr - 1)
            return
        end

        vim.ui.select(
            diagnostics,
            {
                prompt = "Select which linting error to suppress",
                format_item = format_diagnostic,
            },
            function(diagnostic, _)
                if diagnostic == nil then
                    return
                end

                add_suppress_diagnostics(diagnostic, bufnr, linenr - 1)
            end
        )
    end)
end

my_utils.nkeymap('<leader>s', M.suppress_current_line_lint)


-- Experiments to try to support appending to existing suppreses, i.e. noqa: F123 -> noqa: F123,E432
-- Cases to consider:
--
-- 1. Adding noqa:E432 with existing noqa
--      Before: |  # noqa: F123
--      After:  |  # noqa: F123,E432
-- 2. Adding noqa:E432 with existing `type: ignore` after
--      Before: |  # noqa: F123  # type: ignore
--      After:  |  # noqa: F123,E432  # type: ignore
-- 3. Adding noqa:E432 with existing `type: ignore` before
--      Before: |  # type: ignore  # noqa: F123
--      After:  |  # type: ignore  # noqa: F123,E432
-- 4. Adding type: ignore[unused_import] to existing type: ignore[unused_variable]
--      Before: |  # type: ignore[unused_variable]  # noqa: F123
--      After:  |  # type: ignore[unused_variable,unused_import]  # noqa: F123
-- {{{
local function parse_existing_suppresses(bufnr, lnum)
    local filetype = vim.api.nvim_buf_get_option(bufnr, "filetype")
    local query = vim.treesitter.query.parse(filetype, [[
        (((comment)+ @comment)
         (#any-match? @comment "noqa"))
    ]])
    local tree = vim.treesitter.get_parser():parse()[1]
    for id, node, metadata in query:iter_captures(tree:root(), bufnr, lnum, lnum + 1) do
        -- Print the node name and source text.
        vim.notify(vim.inspect({ node:type(), vim.treesitter.get_node_text(node, bufnr), metadata }))
    end
end
my_utils.nkeymap('<leader>q', function()
    local bufnr = vim.api.nvim_get_current_buf()
    local winnr = vim.api.nvim_get_current_win()
    local linenr, _ = unpack(vim.api.nvim_win_get_cursor(winnr))
    parse_existing_suppresses(bufnr, linenr - 1)
end)
-- }}}

return M
