local my_utils = require("user.utils")
local rulebook = require('rulebook')
local builtin_ignore_comments = require("rulebook.data.add-ignore-rule-comment")

rulebook.setup {
    -- if no diagnostic is found in current line, search this many lines forward
    forwSearchLines = 0,
    ignoreComments = {
        ruff = builtin_ignore_comments.Ruff,
        mypy = {
            comment = "# type: ignore[%s]",
            location = "sameLine",
            docs = "https://mypy.readthedocs.io/en/stable/type_inference_and_annotations.html#silencing-type-errors",
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


my_utils.nkeymap("<leader>ri", rulebook.ignoreRule)
my_utils.nkeymap("<leader>rl", rulebook.lookupRule)
my_utils.nkeymap("<leader>ry", rulebook.yankDiagnosticCode)
my_utils.keymap({ "n", "x" }, "<leader>rf", rulebook.suppressFormatter)
