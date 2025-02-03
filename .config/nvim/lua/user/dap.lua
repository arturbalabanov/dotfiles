local my_utils = require("user.utils")

local dap = require("dap")
local dap_ui = require("dapui")
local dap_python = require("dap-python")

dap_ui.setup()

dap.listeners.after.event_initialized["dapui_config"] = function()
    dap_ui.open({})
end

dap.listeners.before.event_terminated["dapui_config"] = function()
    dap_ui.close({})
end

dap.listeners.before.event_exited["dapui_config"] = function()
    dap_ui.close({})
end

-- dap.listeners.before.attach.dapui_config = function()
--     dap_ui.open()
-- end
-- dap.listeners.before.launch.dapui_config = function()
--     dap_ui.open()
-- end

-- TODO: Integrate with py_venv
dap_python.setup("uv")

my_utils.nkeymap("<leader>db", dap.toggle_breakpoint, { desc = "Toggle Breakpoint" })
my_utils.nkeymap("<leader>du", function() dap_ui.toggle({}) end, { desc = "Dap UI" })

-- Stolen from LazyVim: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/plugins/extras/dap/core.lua
--
-- { "<leader>d", "", desc = "+debug", mode = {"n", "v"} },
-- { "<leader>dB", function() require("dap").set_breakpoint(vim.fn.input('Breakpoint condition: ')) end, desc = "Breakpoint Condition" },
-- { "<leader>db", function() require("dap").toggle_breakpoint() end, desc = "Toggle Breakpoint" },
-- { "<leader>dc", function() require("dap").continue() end, desc = "Run/Continue" },
-- { "<leader>da", function() require("dap").continue({ before = get_args }) end, desc = "Run with Args" },
-- { "<leader>dC", function() require("dap").run_to_cursor() end, desc = "Run to Cursor" },
-- { "<leader>dg", function() require("dap").goto_() end, desc = "Go to Line (No Execute)" },
-- { "<leader>di", function() require("dap").step_into() end, desc = "Step Into" },
-- { "<leader>dj", function() require("dap").down() end, desc = "Down" },
-- { "<leader>dk", function() require("dap").up() end, desc = "Up" },
-- { "<leader>dl", function() require("dap").run_last() end, desc = "Run Last" },
-- { "<leader>do", function() require("dap").step_out() end, desc = "Step Out" },
-- { "<leader>dO", function() require("dap").step_over() end, desc = "Step Over" },
-- { "<leader>dp", function() require("dap").pause() end, desc = "Pause" },
-- { "<leader>dr", function() require("dap").repl.toggle() end, desc = "Toggle REPL" },
-- { "<leader>ds", function() require("dap").session() end, desc = "Session" },
-- { "<leader>dt", function() require("dap").terminate() end, desc = "Terminate" },
-- { "<leader>dw", function() require("dap.ui.widgets").hover() end, desc = "Widgets" },
--
-- { "<leader>du", function() require("dapui").toggle({ }) end, desc = "Dap UI" },
-- { "<leader>de", function() require("dapui").eval() end, desc = "Eval", mode = {"n", "v"} },
