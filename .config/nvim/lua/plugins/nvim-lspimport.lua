return {
    -- TODO: replace with stevanmilic/nvim-lspimport once #7 is merged:
    --       https://github.com/stevanmilic/nvim-lspimport/pull/7
    "arturbalabanov/nvim-lspimport",
    dev = true,
    keys = {
        {
            "<leader>i",
            function()
                require("lspimport").import()
            end,
            desc = "Import symbol under cursor",
        },
    },
}
