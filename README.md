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

![screenshot](/tabline.png?raw=true)

## Configuration

These are the default options: (which can be overwritten individually)
```lua
local opts = {
  enable = true,
  bufname = "filename",
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

#### Bufname
Name for buffer. Options:
 - `"filename"`: display only the filename
 - `"filepath"`: display filename with filepath in cwd
 - `"short_filepath"`: display filename with shortened filepath in cwd

#### Keymap
Left hand side for the keymap to cycle `bufname`. \
To prevent this plugin to set a keybinding, set this to `nil`.
You can set the keybinding as follows:
```lua
vim.keymap.set("n", "<LEADER>tt", require("tabline").cycle_bufname)
```

#### Highlights
These settings can be overwritten to either change the highlight group name or the colors of the highlight group.

# License
MIT License
