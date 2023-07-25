-- An extension to ansible-vim to include more filetypes
local my_utils = require("user.utils")

my_utils.set_filetype(
    "yaml.ansible",
    { "*/playbooks/*.yml", "*/playbooks/*.yaml", }
)
