local status_ok, neotest = pcall(require, "neotest")
if not status_ok then
    return
end

local my_utils = require("user.utils")
local py_venv = require("user.py_venv")

neotest.setup({
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
            -- Command line arguments for runner
            -- Can also be a function to return dynamic values
            -- args = {"--log-level", "DEBUG"},
            --
            -- Extra arguments for nvim-dap configuration
            -- See https://github.com/microsoft/debugpy/wiki/Debug-configuration-settings for values
            -- dap = { justMyCode = false },

            runner = "pytest",
            python = function(project_root)
                return py_venv.get_project_venv_python_path(project_root, { disable_notifications = true })
            end,
            is_test_file = function(filename)
                if filename:match("/node_modules/") then
                    return false
                end

                return filename:match("test_.*%.py$") or filename:match(".*_test%.py$")
            end,
        })
    },
})

my_utils.nkeymap("<F4>", function() neotest.summary.toggle() end)
my_utils.nkeymap("<F5>", function() neotest.run.run() end)
my_utils.nkeymap("<F29>", function() neotest.output.open { enter = true } end)  -- Ctrl + F5
my_utils.nkeymap("<F17>", function() neotest.run.run({ strategy = "dap" }) end) -- Shift + F5
