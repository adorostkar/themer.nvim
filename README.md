# Themer

Themer is an color scheme selector which persists the selection of colorscheme.
The colorscheme is shown in telescope and live preview is given when changing colorschemes.

The selected colorscheme is persisted and loaded with the plugin

Telescope and unselected colorscheme plugins can remain lazy. Use `load_picker`
to load Telescope immediately before the selector opens and list lazy
colorschemes in `themes` so they appear in the picker.

## Command

There is only one command

`Themer` which shows the list of themes with Telescope

## Installation

**Lazy**:

    {
        'adorostkar/themer.nvim',
        opts = {
            load_picker = function()
                require('lazy').load({ plugins = { 'telescope.nvim' } })
            end,
        },
        priority = 1000,
        lazy = false,
    }

## Example

Lazy:

    {
        'adorostkar/themer.nvim',
        opts = {
            initial_theme = 'tokyonight-night',
            themes = { 'tokyonight-night', 'onedark', 'catppuccin' },
            load_picker = function()
                require('lazy').load({ plugins = { 'telescope.nvim' } })
            end,
        },
        priority = 1000,
        lazy = false,
    },
    { 'nvim-telescope/telescope.nvim', lazy = true },
    { 'folke/tokyonight.nvim', lazy = true },
    { 'navarasu/onedark.nvim', lazy = true },
    { 'catppuccin/nvim', name = 'catppuccin', lazy = true },

## Options

    opts = {
        preview = false,
        filter_list = {},
        initial_theme = nil,
        themes = {},
        load_picker = nil,
        telescope = {
            -- options that goes into telescope
        }
    }

- **preview** Apply selected colorscheme temporarily when moving up and down in telescope
- **filter_list** is a list of colorschemes to not show in the finder
- **initial_theme** should be the theme you want applied the first time the plugin is run.
    This will not have any effect once the colorscheme is selected from telescope
- **themes** lists colorschemes that are installed but not yet on the runtime path.
- **load_picker** is called before Telescope is required, allowing plugin managers to load it on demand.

## Key binding
`<C-t>` Toggle live preview
