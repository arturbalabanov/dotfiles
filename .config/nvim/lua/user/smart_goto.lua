-- TODO: the idea is to make a super custom and smart "go to defintion" which will first try to
--       execute custom checks like these ones here and fallback to the LSP's go to defintion (or rather
--       go to defintion or reference as per the plugin i'm using). Actuallly, it would be good to take a
--       look at that plugin for inspiration on how to implement this. Anyway, eventually this keymap will be
--       removed and i'll use the regular "go to defintion" one, i.e. gd

-- TODO: add a timeout (either general or per rule) in case the search takes too long or (more likely) there
--       is a bug and we're stuck in in infinate loop. but keep the whole thing blocking, not worth the effort otherwise

local M = {}

local function is_valid_python_identifier(str)
    return string.match(str, "^[A-Za-z_][A-Za-z0-9_]*$") ~= nil
end

local error = function(msg_fmt, ...)
    local msg = msg_fmt:format(...)
    vim.notify(msg, vim.log.levels.ERROR, { title = "Smart GoTo error" })
end

local function treesitter_get_ancestor(node, ancestor_type)
    local current_node = node

    while current_node do
        if current_node:type() == ancestor_type then
            return current_node
        end
        current_node = current_node:parent()
    end

    return nil
end

local function get_python_class_name_under_cursor(winnr)
    local bufnr = vim.api.nvim_win_get_buf(winnr)
    local cursor_pos = vim.api.nvim_win_get_cursor(winnr)

    local cursor_node = vim.treesitter.get_node({ bufnr = bufnr, pos = cursor_pos })
    local class_node = treesitter_get_ancestor(cursor_node, "class_definition")

    if class_node == nil then
        return nil
    end

    -- In Python grammar, the first child is 'class', second is the name
    local name_node = class_node:child(1)
    return vim.treesitter.get_node_text(name_node, bufnr)
end

local function try_go_to_textual_binding(winnr, action_name)
    local bufnr = vim.api.nvim_win_get_buf(winnr)

    local expected_action_name = string.match(action_name, "^action_([A-Za-z_][A-Za-z0-9_]*)$")
    if expected_action_name == nil then
        error("identifier is not a valid action name (must start with `action_`): `%s`", action_name)
        return nil
    end

    local parser = vim.treesitter.get_parser(bufnr, "python")

    if parser == nil then
        error("treesitter cannot parse the current file")
        return nil
    end

    local tree = parser:parse()[1]
    local root = tree:root()

    local python_class_name = get_python_class_name_under_cursor(winnr)

    if python_class_name == nil then
        error("word under cursor does not refer to a method name: `%s`", action_name)
        return nil
    end

    -- TODO: in this case: instead of querying the whole file, query only the class?
    local query = vim.treesitter.query.parse(
        "python",
        ([[
          (
            (class_definition
            name: (identifier) @_class_name
            body: (
              (block
                (expression_statement
                  (assignment
                    left: (identifier) @_class_var_name
                    right: (list
                        (call
                          function: (identifier) @_callable_name
                          arguments: (
                            argument_list [
                              (string (string_content) @match)
                            ]
                          )
                        )
                      )
                    )
                  )
                )
              )
            )
            (#eq? @_class_var_name "BINDINGS")
            (#eq? @_callable_name "Binding")
            (#eq? @_class_name "%s")
            (#eq? @match "%s")
          )
        ]]):format(python_class_name, expected_action_name)
    )

    local results = {}

    for id, node, metadata in query:iter_captures(root, bufnr, 0, -1) do
        local name = query.captures[id]

        if name == "match" then
            local start_row, start_col, end_row, end_col = node:range()
            local result = {
                start = { row = start_row + 1, col = start_col },
                stop = { row = end_row + 1, col = end_col },
            }

            table.insert(results, result)
        end
    end

    return results
end

M.smart_goto = function()
    local winnr = vim.api.nvim_get_current_win()
    local bufnr = vim.api.nvim_win_get_buf(winnr)
    local filetype = vim.api.nvim_get_option_value("filetype", { buf = bufnr })

    if filetype ~= "python" then
        error("only python files are supported for now, current filetype: %s", filetype)
        return
    end

    if require("vim.treesitter.highlighter").active[bufnr] == nil then
        error("treesitter is not (yet) active for the current buffer")
        return
    end

    local word_under_cursor = vim.fn.expand("<cword>")

    if not is_valid_python_identifier(word_under_cursor) then
        error("word under the cursor is not a valid python identifier: `%s`", word_under_cursor)
        return
    end

    -- TODO: if multiple rules match possibly merge the results?
    local results = try_go_to_textual_binding(winnr, word_under_cursor)

    if results == nil or vim.tbl_isempty(results) then
        error("no custom source was found for word under cursor: `%s`", word_under_cursor)
        return
    end

    -- TODO: if multiple matches, open telescope picker for them :)
    if #results > 1 then
        error("multiple possible results found for word under cursor: `%s`", word_under_cursor)
        return
    end

    local result = results[1] -- remember than in lua arrays start from 1 >:(
    local jump_pos = { result.start.row, result.start.col }

    -- Save current position to jumplist
    vim.cmd("normal! m'")
    vim.api.nvim_win_set_cursor(winnr, jump_pos)
end

return M
