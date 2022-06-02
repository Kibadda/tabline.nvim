local helpers = require "tabline.helpers"

local M = {}

function M.setup(opts)
  opts = vim.tbl_deep_extend("keep", opts, {
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
  })

  if opts.enable then
    vim.g.tabline_shorten_filepath = opts.shorten

    if opts.keymap ~= nil then
      M.set_keymap(opts.keymap)
    end

    M.set_highlights(opts.highlights)

    vim.opt.tabline = [[%!v:lua.require("tabline").render_tabline()]]
  end
end

TabLineString = ""
TabLineStringLength = 0
TabLineMaxLength = 0
function M.render_tabline(opts)
  TabLineString = ""
  TabLineStringLength = 0
  TabLineMaxLength = vim.api.nvim_win_get_width(0)

  local buffers = helpers.get_buffers()

  if #buffers > 0 then
    local current_index = helpers.get_current_index()
    if current_index == nil then
      current_index = math.ceil(#buffers / 2)
    end

    local left = vim.list_slice(buffers, 1, current_index - 1)
    local middle = buffers[current_index]
    local right = vim.list_slice(buffers, current_index + 1, #buffers)

    local i = math.min(#left, #right)

    TabLineString = helpers.get_buffer_string(middle, opts)
    TabLineStringLength = middle.strlen

    for j = 1, i do
      helpers.add_buffer_on_left(left[#left - j + 1], opts)
      helpers.add_buffer_on_right(right[j], opts)
    end

    if #left > #right then
      for j = #left - i, 1, -1 do
        helpers.add_buffer_on_left(left[j], opts)
      end
    elseif #left < #right then
      for j = i + 1, #right do
        helpers.add_buffer_on_right(right[j], opts)
      end
    end

    return TabLineString .. "%#" .. opts.highlights.fill.name .. "#"
  end
end

function M.set_keymap(lhs)
  vim.keymap.set("n", lhs, M.toggle_shorten_filepath)
end

function M.toggle_shorten_filepath()
  vim.g.tabline_shorten_filepath = not vim.g.tabline_shorten_filepath
  vim.cmd [[redrawtabline]]
end

function M.set_highlights(highlights)
  vim.cmd(
    "hi " .. highlights.selected.name .. " guibg=" .. highlights.selected.bg .. " guifg=" .. highlights.selected.fg
  )
  vim.cmd("hi " .. highlights.fill.name .. " guibg=" .. highlights.fill.bg .. " guifg=" .. highlights.fill.fg)
  vim.cmd("hi " .. highlights.other.name .. " guibg=" .. highlights.other.bg .. " guifg=" .. highlights.other.fg)
end

return M
