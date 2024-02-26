# Themer

Themer is an color scheme selector which persists the selection of colorscheme.
The colorscheme is shown in telescope and live preview is given when changing colorschemes.

The selected colorscheme is persisted and loaded with the plugin

## Command

There is only one command

`Themer` which shows the list of themes with Telescope

## Installation

**Lazy**:

    {
        'adorostkar/themer.nvim',
        opts = {},
        priority = 1000,
        lazy = false,
        dependencies = {
            'nvim-telescope/telescope.nvim',
            -- optional, add colorthemes here
        }
    }

## Example

Lazy:

    {
        'adorostkar/themer.nvim',
        opts = { initial_theme = 'tokyonight-night' },
        priority = 1000,
        lazy = false,
        dependencies = {
            'nvim-telescope/telescope.nvim',
            "folke/tokyonight.nvim",
            "navarasu/onedark.nvim",
            "catppuccin/nvim",
        }
    }

## Options

    opts = {
        preview = true,
        filter_list = {},
        initial_theme = nil,
        telescope = {
            -- options that goes into telescope
        }
    }

- **preview** Apply selected colorscheme temporarily when moving up and down in telescope
- **filter_list** is a list of colorschemes to not show in the finder
- **initial_theme** should be the theme you want applied the first time the plugin is run.
    This will not have any effect once the colorscheme is selected from telescope
