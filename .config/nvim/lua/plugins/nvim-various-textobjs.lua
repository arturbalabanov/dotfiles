-- ref: https://github.com/chrisgrieser/nvim-various-textobjs?tab=readme-ov-file#list-of-text-objects

return {
    "chrisgrieser/nvim-various-textobjs",
    keys = {
        {
            "ii",
            function() require("various-textobjs").indentation("inner", "inner") end,
            mode = { "o", "x" },
            desc = "inner indentation textobj",
        },
        {
            'ai',
            function() require("various-textobjs").indentation("outer", "outer") end,
            mode = { "o", "x" },
            desc = "outer indentation textobj",
        },
    },
}
