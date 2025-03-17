return {
    "chrisgrieser/nvim-rulebook",
    cmd = "Rulebook",
    opts = function()
        return {
            -- if no diagnostic is found in current line, search this many lines forward
            forwSearchLines = 0,
            ignoreComments = {
                ruff = require("rulebook.data.add-ignore-rule-comment").Ruff,
                mypy = {
                    comment = "# type: ignore[%s]",
                    location = "sameLine",
                    docs =
                    "https://mypy.readthedocs.io/en/stable/type_inference_and_annotations.html#silencing-type-errors",
                    multiRuleIgnore = true,
                },
                bandit = {
                    comment = "# nosec: %s",
                    docs = "https://bandit.readthedocs.io/en/latest/config.html#exclusions",
                    location = "sameLine",
                    multiRuleIgnore = true,
                },
            },
            ruleDocs = {
                mypy = "https://mypy.readthedocs.io/en/stable/error_code_list.html#code-%s",
                bandit = "https://bandit.readthedocs.io/en/latest/plugins/index.html#:~:text=%s"
            }
        }
    end,
    keys = {
        { "<leader>ri", "<cmd>Rulebook ignoreRule<CR>",         desc = "Rulebook: ignore rule" },
        { "<leader>rl", "<cmd>Rulebook lookupRule<CR>",         desc = "Rulebook: lookup rule" },
        { "<leader>ry", "<cmd>Rulebook yankDiagnosticCode<CR>", desc = "Rulebook: yank diagnostic code" },
        { "<leader>rf", "<cmd>Rulebook suppressFormatter<CR>",  desc = "Rulebook: suppress formatter",  mode = { "n", "x" } },
    }
}
