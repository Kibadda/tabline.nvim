# tabline.nvim

## Installation
Install with your favorite plugin manager. \
e.g. [packer.nvim](https://github.com/wbthomason/packer.nvim)
```lua
use {
  "Kibadda/tabline.nvim",
  config = function()
    require("tabline").setup {}
  end),
}
```

## Configuration

These are the default options: (which can be overwritten individually)
```lua
local opts = {
  enable = true,
  shorten = false,
  keymap = "<LEADER>tt",
  highlights = {
    selected = {
      name = "TabLineSel",
      bg = "#3a3a3a",
      fg = "#99cc99",
    },
    fill = {
      name = "TabLineFill",
      bg = "#262626",
      fg = "#c0c0c0",
    },
    other = {
      name = "TabLine",
      bg = "#262626",
      fg = "#c0c0c0",
    },
  },
}
```

#### Enable
Setting this to `false` disables this whole plugin.

#### Shorten
Setting this to `true` shortens filepaths.

#### Keymap
Left hand side for the keymap to toggle `shorten`. \
To prevent this plugin to set a keybinding, set this to `nil`.
You can set the keybinding as follows:
```lua
vim.keymap.set("n", "<LEADER>tt", require("tabline").toggle_shorten_filepath)
```

#### Highlights
These settings can be overwritten to either change the highlight group name or the colors of the highlight group.

# License
MIT License
