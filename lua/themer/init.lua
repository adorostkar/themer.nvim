local M = {}

local filename = vim.fn.stdpath('cache') .. '/themer'

local _color_cache = nil

local function getDefaultOptions()
    return {
        preview = false,
        filter_list = {},
        initial_theme = nil,
        themes = {},
        load_picker = nil,
        telescope = nil,
    }
end

local function writeColorScheme(colorscheme)
    if not colorscheme or colorscheme == '' then
        return false
    end

    vim.fn.mkdir(vim.fn.fnamemodify(filename, ':h'), 'p')
    local ok, result = pcall(vim.fn.writefile, { colorscheme }, filename)
    if not ok or result ~= 0 then
        vim.notify("Themer: Failed to persist colorscheme: " .. tostring(result), vim.log.levels.WARN)
    end
    return ok and result == 0
end

-- Subtract list B from list A
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

local function applyColorScheme(colorscheme)
    if not colorscheme or colorscheme == '' then
        return false
    end

    local ok, err = pcall(vim.cmd.colorscheme, colorscheme)
    if not ok then
        vim.notify("Themer: Failed to load colorscheme '" .. colorscheme .. "': " .. err, vim.log.levels.WARN)
    end
    return ok
end

local function loadColorScheme()
    if vim.fn.filereadable(filename) == 1 then
        local lines = vim.fn.readfile(filename)
        return applyColorScheme(lines[1])
    end
    return false
end

local function isInList(value, list)
    for i, v in ipairs(list) do
        if v == value then
            return i
        end
    end
    return -1
end

function M.getFilteredColorList()
    if not _color_cache then
        _color_cache = vim.fn.getcompletion('', 'color')
    end
    local colors = vim.deepcopy(_color_cache)
    for _, theme in ipairs(M.opts.themes) do
        if isInList(theme, colors) == -1 then
            table.insert(colors, theme)
        end
    end

    if vim.g.colors_name then
        local index = isInList(vim.g.colors_name, colors)
        if index ~= -1 then
            table.remove(colors, index)
            table.insert(colors, 1, vim.g.colors_name)
        end
    end
    return subtract(colors, M.opts.filter_list)
end

function M.setup(opts)
    M.opts = vim.tbl_deep_extend('force', getDefaultOptions(), opts or {})

    if vim.fn.filereadable(filename) == 0 then
        local theme = M.opts.initial_theme or vim.g.colors_name
        writeColorScheme(theme)
    end
    if not loadColorScheme() and applyColorScheme(M.opts.initial_theme) then
        writeColorScheme(M.opts.initial_theme)
    end

    M.opts.filter_list = M.opts.filter_list or {}
    local ccsIndex = isInList(vim.g.colors_name, M.opts.filter_list)
    if ccsIndex ~= -1 then
        vim.notify("Themer: Current colorscheme is in filter list. Ignoring", vim.log.levels.WARN)
        table.remove(M.opts.filter_list, ccsIndex)
    end
end

local function _preview_color()
    if not M.opts.preview then return end
    local action_state = require("telescope.actions.state")
    local selection = action_state.get_selected_entry()
    if selection then
        applyColorScheme(selection.value)
    end
end

function M.select()
    if M.opts.load_picker then
        M.opts.load_picker()
    end

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
            attach_mappings = function(prompt_bufnr, map)
                actions.select_default:replace(
                    function()
                        actions.close(prompt_bufnr)
                        local selection = action_state.get_selected_entry()
                        if selection and applyColorScheme(selection.value) then
                            writeColorScheme(selection.value)
                        end
                    end
                )
                map("i", "<C-t>", function(_)
                    M.opts.preview = not M.opts.preview
                    vim.notify("Changed preview to " .. tostring(M.opts.preview), vim.log.levels.DEBUG)
                    _preview_color()
                end)

                actions.move_selection_next:enhance({
                    post = function()
                        _preview_color()
                    end,
                })
                actions.move_selection_previous:enhance({
                    post = function()
                        _preview_color()
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

    show_telescope(M.opts.telescope or require("telescope.themes").get_dropdown())
end

return M
