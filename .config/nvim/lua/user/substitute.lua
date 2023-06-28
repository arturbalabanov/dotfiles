local my_utils = require("user.utils")

local substitute = my_utils.opt_require("substitute")
if substitute == nil then
    return
end

local exchange = require("substitute.exchange")

substitute.setup {
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
}

my_utils.nkeymap("s", substitute.operator)
my_utils.nkeymap("ss", substitute.line)
my_utils.xkeymap("S", substitute.eol)
my_utils.nkeymap("s", substitute.visual)

my_utils.nkeymap("X", exchange.operator)
my_utils.nkeymap("XX", exchange.line)
my_utils.xkeymap("X", exchange.visual)
my_utils.nkeymap("Xc", exchange.cancel)
