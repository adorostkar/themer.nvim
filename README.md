# Themer

Themer is an color scheme selector which persists the selection of colorscheme.
The colorscheme is shown in telescope and live preview is given when changing colorschemes.

The selected colorscheme is persisted and loaded with the plugin

## Command

There is only one command

`ThemerSelect` which shows the list of themes with Telescope

## Installation

**Lazy**:

    {
        'adorostkar/themer.nvim',
        opts = {},
        dependencies = {
            'nvim-telescope/telescope.nvim',
        }
    }

## Options

    opts = {
        preview = true, -- preview colorscheme when moving up and down in telescope
        filter_list = {}, -- What color schemes not to show in the list
        telescope = {
            -- options that goes into telescope
        }
    }
