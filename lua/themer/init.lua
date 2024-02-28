local M = {}

local filename = vim.fn.stdpath('cache') .. '/themer.lua'

-- Default options
local function getDefaultOptions()
    local themes = require("telescope.themes")
    return {
        preview = true,
        filter_list = {},
        initial_theme = nil,
        telescope = themes.get_dropdown(),
    }
end

-- Persist the current colorscheme into a lua file
local function writeColorScheme(colorscheme)
    local file = io.open(filename, 'w')
    io.output(file)
    io.write('local M = {}\n')
    io.write('function M.setColor()\n')
    io.write("vim.fn.execute('colorscheme " .. colorscheme .. "')\n")
    io.write('end\n')
    io.write('return M\n')
    io.close(file)
end

-- Substract list one from list two
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


-- Set colorscheme of nvim
local function loadColorScheme()
    local chunk, _ = loadfile(filename)
    if chunk then
        local N = chunk()
        N.setColor()
    end
end

local function isInList(value, list)
    for i, v in ipairs(list) do
        if v == value then
            return i
        end
    end
    return -1
end

-- Return filtered colorscheme
function M.getFilteredColorList()
        local colors = vim.fn.getcompletion('', 'color')
        local index = isInList(vim.g.colors_name, colors)
        if index ~= -1 then
            table.remove(colors, index)
            table.insert(colors, 1, vim.g.colors_name)
        end
        return subtract(colors, M.opts.filter_list)
end

function M.setup(opts)
    M.opts = vim.tbl_extend('force', getDefaultOptions(), opts)
    if vim.fn.filereadable(filename) ~= 0 then
        print('Themer: Found file' .. filename)
    elseif M.opts.initial_theme ~= nil then
        print('here')
        writeColorScheme(M.opts.initial_theme)
    end
    M.opts.filter_list = M.opts.filter_list or {}
    local ccsIndex = isInList(vim.g.colors_name, M.opts.filter_list)
    if  ccsIndex > 0 then
        vim.notify("Themer: Current colorscheme is in filter list. Ignoring", vim.log.levels.WARN)
        table.remove(M.opts.filter_list, ccsIndex)
    end

    loadColorScheme()
end

function M.select()
    local show_telescope = function(opts)
        local pickers = require("telescope.pickers")
        local finders = require("telescope.finders")
        local actions = require("telescope.actions")
        local action_state = require("telescope.actions.state")
        local conf = require("telescope.config").values

        pickers.new(opts, {
            prompt_title = "Colorschemes",
            finder = finders.new_table {
                results = M.getFilteredColorList(),
            },
            sorter = conf.generic_sorter(opts),
            attach_mappings = function(prompt_bufnr, _)
                actions.select_default:replace(
                    function() -- default action is yank
                        actions.close(prompt_bufnr)
                        local selection = action_state.get_selected_entry()
                        writeColorScheme(selection.value)
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
                        loadColorScheme()
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

