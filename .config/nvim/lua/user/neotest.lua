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
        })
    },
})

my_utils.nkeymap("<F4>", function() neotest.summary.toggle() end)
my_utils.nkeymap("<F5>", function() neotest.run.run() end)
my_utils.nkeymap("<F29>", function() neotest.output.open { enter = true } end) -- Ctrl + F5
