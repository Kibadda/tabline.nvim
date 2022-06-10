local helpers = require "tabline.helpers"

local M = {}

function M.setup(opts)
  opts = opts or {}
  opts = vim.tbl_deep_extend("keep", opts, {
    enable = true,
    shorten = true,
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

    M.highlights = opts.highlights
    M.set_highlights()

    vim.opt.tabline = [[%!luaeval('require("tabline").render_tabline()')]]
  end
end

function M.render_tabline()
  local tabline_string = ""
  local tabline_string_length = 0
  local tabline_max_length = vim.api.nvim_win_get_width(0)

  local buffers = helpers.get_buffers()

  if #buffers > 0 then
    local current_index = helpers.get_current_index(buffers)
    if current_index == nil then
      current_index = math.ceil(#buffers / 2)
    end

    local left = vim.list_slice(buffers, 1, current_index - 1)
    local middle = buffers[current_index]
    local right = vim.list_slice(buffers, current_index + 1, #buffers)

    local i = math.min(#left, #right)

    tabline_string = helpers.get_buffer_string(middle, M.highlights)
    tabline_string_length = middle.string_length

    local rv
    for j = 1, i do
      rv = helpers.add_buffer_on_left(left[#left - j + 1], M.highlights, tabline_string_length, tabline_max_length)
      tabline_string = rv.string .. tabline_string
      tabline_string_length = tabline_string_length + rv.length
      rv = helpers.add_buffer_on_right(right[j], M.highlights, tabline_string_length, tabline_max_length)
      tabline_string = tabline_string .. rv.string
      tabline_string_length = tabline_string_length + rv.length
    end

    if #left > #right then
      for j = #left - i, 1, -1 do
        rv = helpers.add_buffer_on_left(left[j], M.highlights, tabline_string_length, tabline_max_length)
        tabline_string = rv.string .. tabline_string
        tabline_string_length = tabline_string_length + rv.length
      end
    elseif #left < #right then
      for j = i + 1, #right do
        rv = helpers.add_buffer_on_right(right[j], M.highlights, tabline_string_length, tabline_max_length)
        tabline_string = tabline_string .. rv.string
        tabline_string_length = tabline_string_length + rv.length
      end
    end

    return tabline_string .. "%#" .. M.highlights.fill.name .. "#"
  end

  return ""
end

function M.set_keymap(lhs)
  vim.keymap.set("n", lhs, M.toggle_shorten_filepath, { desc = "[Tabline] toggle shorten" })
end

function M.toggle_shorten_filepath()
  vim.g.tabline_shorten_filepath = not vim.g.tabline_shorten_filepath
  vim.cmd [[redrawtabline]]
end

function M.set_highlights()
  local group = vim.api.nvim_create_augroup("TablineHighlightGroup", { clear = true })
  vim.api.nvim_create_autocmd("VimEnter", {
    group = group,
    callback = function()
      vim.cmd(
        "hi "
          .. M.highlights.selected.name
          .. " guibg="
          .. M.highlights.selected.bg
          .. " guifg="
          .. M.highlights.selected.fg
      )
      vim.cmd("hi " .. M.highlights.fill.name .. " guibg=" .. M.highlights.fill.bg .. " guifg=" .. M.highlights.fill.fg)
      vim.cmd(
        "hi " .. M.highlights.other.name .. " guibg=" .. M.highlights.other.bg .. " guifg=" .. M.highlights.other.fg
      )
    end,
  })
end

return M
