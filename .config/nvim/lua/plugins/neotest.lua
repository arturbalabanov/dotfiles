local my_utils = require("utils")

return {
    "nvim-neotest/neotest",
    dependencies = {
        "nvim-neotest/nvim-nio",
        "nvim-lua/plenary.nvim",
        "nvim-treesitter/nvim-treesitter",
        "antoinemadec/FixCursorHold.nvim",
        "nvim-neotest/neotest-python",
    },
    opts = function()
        return {
            icons = {
                failed = "",
                passed = "",
                running = "",
                skipped = "ﰸ",
                unknown = "",
            },
            summary = {
                animated = true,
                enabled = true,
                expand_errors = true,
                follow = true,
                mappings = {
                    attach = "a",
                    clear_marked = "M",
                    clear_target = "T",
                    debug = "d",
                    debug_marked = "D",
                    expand = { "<CR>", "<2-LeftMouse>" },
                    expand_all = "e",
                    jumpto = "i",
                    mark = "m",
                    next_failed = "J",
                    output = "o",
                    prev_failed = "K",
                    run = "r",
                    run_marked = "R",
                    short = "O",
                    stop = "c",
                    target = "t",
                    watch = "w"
                },
                open = "botright vsplit | vertical resize 50"
            },
            adapters = {
                require("neotest-python")({
                    runner = "pytest",
                    args = { "-vvv", "--no-cov" },
                    python = function(project_root)
                        return require("auto-venv").get_project_venv_python_path(
                            project_root,
                            { disable_notifications = true }
                        )
                    end,
                    is_test_file = function(filename)
                        if filename:match("/node_modules/") then
                            return false
                        end

                        return filename:match("test_.*%.py$") or filename:match(".*_test%.py$")
                    end,
                })
            },
        }
    end,
    keys = {
        { "<F4>",  function() require("neotest").summary.toggle() end,              desc = "Neotest: Toggle summary pannel" },
        { "<F5>",  function() require("neotest").run.run() end,                     desc = "Neotest: Run test under cursor" },
        -- Ctrl + F5
        { "<F29>", function() require("neotest").output.open { enter = true } end,  desc = "Neotest: Open test output" },
        -- Shift + F5
        { "<F17>", function() require("neotest").run.run({ strategy = "dap" }) end, desc = "Neotest: Run test with DAP" },
    }
}
