local M = {}

local function getOpts()
    local themes = require("telescope.themes")
    return {
        preview = true,
        filter_list = {},
        telescope = themes.get_dropdown(),
    }
end

local filename = vim.fn.stdpath('cache') .. '/themer.lua'
local function setColorScheme()
    local chunk, _ = loadfile(filename)
    if chunk then
        local N = chunk()
        N.setColor()
    end
end

function M.setup(opts)
    M.opts = vim.tbl_extend('force', getOpts(), opts)
    if vim.fn.filereadable(filename) then
        vim.notify('Themer: Found file' .. filename, vim.log.levels.DEBUG)
        setColorScheme()
    end
end

local function write_to_file(colorscheme)
    -- vim.notify("vim.fn.execute('colorscheme " .. colorscheme .. "')")
    local file = io.open(filename, 'w')
    io.output(file)
    io.write('local M = {}\n')
    io.write('function M.setColor()\n')
    io.write("vim.fn.execute('colorscheme " .. colorscheme .. "')\n")
    io.write('end\n')
    io.write('return M\n')
    io.close(file)
end

local function subtract(A, B)
    local hash = {}
    for _, v in ipairs(B) do
        hash[v] = true
    end
    local res = {}
    for _, v in ipairs(A) do
        if not hash[v] then
            table.insert(res, v)
        end
    end
    return res
end

function M.select()
    local show_telescope = function(opts)
        local pickers = require("telescope.pickers")
        local finders = require("telescope.finders")
        local actions = require("telescope.actions")
        local action_state = require("telescope.actions.state")
        local conf = require("telescope.config").values
        local colors = vim.fn.getcompletion('', 'color')
        colors = subtract(colors, M.opts.filter_list)

        pickers.new(opts, {
            prompt_title = "Colorschemes",
            finder = finders.new_table {
                results = colors,
            },
            sorter = conf.generic_sorter(opts),
            attach_mappings = function(prompt_bufnr, _)
                actions.select_default:replace(
                    function() -- default action is yank
                        actions.close(prompt_bufnr)
                        local selection = action_state.get_selected_entry()
                        write_to_file(selection.value)
                        vim.fn.execute('colorscheme ' .. selection.value)
                    end
                )

                -- Only set the rest of actions if preview is true.
                -- These actions are only relevant if the preview is true
                if not M.opts.preview then
                    return true
                end

                actions.move_selection_next:enhance({
                    post = function()
                        local selection = action_state.get_selected_entry(prompt_bufnr)
                        vim.fn.execute('colorscheme ' .. selection.value)
                    end,
                })
                actions.move_selection_previous:enhance({
                    post = function()
                        local selection = action_state.get_selected_entry(prompt_bufnr)
                        vim.fn.execute('colorscheme ' .. selection.value)
                    end,
                })
                actions.close:enhance({
                    post = function()
                        setColorScheme()
                    end,
                })

                return true
            end,
        }):find()
    end

    -- to execute the function
    show_telescope(M.opts.telescope)
end

return M

