local virtTextHandler = function(virtText, lnum, endLnum, width, truncate, ctx)
    -- Skip decorators in python (hacky but it works)

    -- TODO: Implement something similar for Justfiles, e.g. this recipe:
    --
    -- # Docstring line 1
    -- # Docstring line 2
    -- [script]
    -- [working-directory: 'some directory']
    -- recipe *args:
    --    echo "do stuff"
    --    echo "do more stuff"
    --
    -- should fold to simply:
    -- recipe *args: 󰁂 2

    if vim.bo[ctx.bufnr].filetype ~= "python" then
        return virtText
    end

    local inMultiLineDecorator = false
    for i = lnum, endLnum do
        local lineVirtText = ctx.get_fold_virt_text(i)

        local firstNonWhitespaceChunk = nil

        for chunkIndex, chunk in ipairs(lineVirtText) do ---@diagnostic disable-line: unused-local
            local chunkText = chunk[1]

            -- if it's only whitespace
            if not chunkText:match("^%s*$") then
                firstNonWhitespaceChunk = chunk
                break
            end
        end

        local firstChar = nil
        if firstNonWhitespaceChunk ~= nil then
            firstChar = firstNonWhitespaceChunk[1]:sub(1, 1)
        end

        if firstChar ~= nil then
            local lastChunk = lineVirtText[#lineVirtText]

            if firstChar == "@" then
                if lastChunk[1] == "(" then
                    inMultiLineDecorator = true
                end
            else
                if not inMultiLineDecorator then
                    virtText = lineVirtText
                    break
                end
            end

            if inMultiLineDecorator then
                -- if #lineVirtText == 1 and lastChunk[1] == ')' then
                if firstChar == ")" then
                    inMultiLineDecorator = false
                end
            end
        end
    end

    -- Add folded lines number
    local newVirtText = {}
    local suffix = (" 󰁂 %d "):format(endLnum - lnum)
    local sufWidth = vim.fn.strdisplaywidth(suffix)
    local targetWidth = width - sufWidth
    local curWidth = 0

    for _, chunk in ipairs(virtText) do
        local chunkText = chunk[1]
        local chunkWidth = vim.fn.strdisplaywidth(chunkText)

        if targetWidth > curWidth + chunkWidth then
            table.insert(newVirtText, chunk)
        else
            chunkText = truncate(chunkText, targetWidth - curWidth)
            local hlGroup = chunk[2]

            table.insert(newVirtText, { chunkText, hlGroup })
            chunkWidth = vim.fn.strdisplaywidth(chunkText)

            -- str width returned from truncate() may less than 2nd argument, need padding
            if curWidth + chunkWidth < targetWidth then
                suffix = suffix .. (" "):rep(targetWidth - curWidth - chunkWidth)
            end

            break
        end

        curWidth = curWidth + chunkWidth
    end

    table.insert(newVirtText, { suffix, "MoreMsg" })

    return newVirtText
end

return {
    "kevinhwang91/nvim-ufo",
    dependencies = { "kevinhwang91/promise-async" },
    init = function()
        vim.o.foldcolumn = "0" -- '1' is not bad
        vim.o.foldlevel = 99 -- Using ufo provider need a large value, feel free to decrease the value
        vim.o.foldlevelstart = 99
        vim.o.foldenable = true
    end,
    lazy = false,
    opts = {
        open_fold_hl_timeout = 0, -- disable highlighting on opening folds
        enable_get_fold_virt_text = true,
        fold_virt_text_handler = virtTextHandler,
        close_fold_kinds_for_ft = {
            zsh = { "marker" },
        },
        provider_selector = function(bufnr, filetype, buftype)
            local folds_per_ft = {
                zsh = "marker",
                python = { "treesitter" },
                lua = { "treesitter" },
                go = { "treesitter" },
                just = { "treesitter" },
                markdown = { "treesitter" },
            }

            return folds_per_ft[filetype] or { "treesitter", "marker" }
        end,
    },
    keys = {
        {
            "zR",
            function()
                require("ufo").openAllFolds()
            end,
            desc = "open all folds",
        },
        {
            "zM",
            function()
                require("ufo").closeAllFolds()
            end,
            desc = "close all folds",
        },
        {
            "zr",
            function()
                require("ufo").openFoldsExceptKinds()
            end,
            desc = "open folds except kinds",
        },
        {
            "zm",
            function()
                require("ufo").closeFoldsWith()
            end,
            desc = "close folds with",
        },
        {
            "<S-Tab>",
            function()
                local winid = require("ufo").peekFoldedLinesUnderCursor()

                if not winid then
                    vim.lsp.buf.hover()
                end
            end,
            desc = "Peek a fold",
        },
        { "<Tab>", "za", desc = "Toggle fold" },
    },
}

-- peek a fold with <Shift+Tab>
