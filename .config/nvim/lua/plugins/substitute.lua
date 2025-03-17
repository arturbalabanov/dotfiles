return {
    "gbprod/substitute.nvim",
    opts = {
        on_substitute = nil,
        yank_substituted_text = false,
        highlight_substituted_text = {
            enabled = true,
            timer = 500,
        },
        range = {
            prefix = "s",
            prompt_current_text = false,
            confirm = false,
            complete_word = false,
            motion1 = false,
            motion2 = false,
            suffix = "",
        },
        exchange = {
            motion = false,
            use_esc_to_cancel = true,
        },
    },
    keys = {
        -- TODO: Start using these once you resolve mapping conflicts with mini.surround
        -- {"s",  function () require("substitute").operator() end},
        -- {"ss", function () require("substitute").line() end},
        -- {"S",  function () require("substitute").eol() end},
        -- {"s",  function () require("substitute").visual() end, mode = "x"},

        { "X",  function() require("substitute.exchange").operator() end },
        { "XX", function() require("substitute.exchange").line() end },
        { "X",  function() require("substitute.exchange").visual() end,  mode = "x" },
        { "Xc", function() require("substitute.exchange").cancel() end },
    }
}
