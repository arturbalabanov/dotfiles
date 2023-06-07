local status_ok, neotest = pcall(require, "neotest")
if not status_ok then
    return
end

local utils = require("user.utils")

neotest.setup({
    adapters = {
        require("neotest-python")({
            runner = "pytest",
            -- Command line arguments for runner
            -- Can also be a function to return dynamic values
            -- args = {"--log-level", "DEBUG"},
            python = utils.get_python_path,
            -- Extra arguments for nvim-dap configuration
            -- See https://github.com/microsoft/debugpy/wiki/Debug-configuration-settings for values
            -- dap = { justMyCode = false },
        })
    },
})

utils.nkeymap("<F3>", function() neotest.summary.toggle() end)
utils.nkeymap("<F5>", function() neotest.run.run() end)
utils.nkeymap("<F29>", function() neotest.output.open { enter = true } end) -- Ctrl + F5
