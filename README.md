# Themer

Themer is an color scheme selector which persists the selection of colorscheme.
The colorscheme is shown in telescope and live preview is given when changing colorschemes.

The selected colorscheme is persisted and loaded with the plugin

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
        preview = true,
        telescope = {
            -- options that goes into telescope
        }
    }
