local status_ok, neotest = pcall(require, "neotest")
if not status_ok then
    return
end

local my_utils = require("user.utils")

neotest.setup({
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
            python = my_utils.get_python_path,
        })
    },
})

my_utils.nkeymap("<F3>", function() neotest.summary.toggle() end)
my_utils.nkeymap("<F5>", function() neotest.run.run() end)
my_utils.nkeymap("<F29>", function() neotest.output.open { enter = true } end) -- Ctrl + F5
