local M = {}

function M.get_buffers()
  local buffer_numbers = vim.api.nvim_list_bufs()
  local current_buffer = vim.api.nvim_get_current_buf()

  local buffers = {}
  for _, number in ipairs(buffer_numbers) do
    if vim.fn.buflisted(number) == 1 then
      local filepath = vim.fn.expand("#" .. number)
      if filepath == "" then
        filepath = "NO NAME"
      end

      if string.find(filepath, "^term:/") == nil then
        local shorten_filepath = M.shorten_filepath(filepath)
        -- 3: "[" ":" "]"
        local base_string_length = 3 + string.len(number)
        local string_length = base_string_length + string.len(filepath)
        local shorten_string_length = base_string_length + string.len(shorten_filepath)
        local modified = vim.fn.getbufinfo(number)[1].changed == 1

        if modified then
          string_length = string_length + 2
          shorten_string_length = shorten_string_length + 2
        end

        local buffer = {
          number = number,
          current = current_buffer == number,
          filepath = filepath,
          shorten_filepath = shorten_filepath,
          string_length = string_length,
          shorten_string_length = shorten_string_length,
          modified = modified,
        }
        table.insert(buffers, buffer)
      end
    end
  end

  return buffers
end

function M.get_current_index(buffers)
  for i, entry in ipairs(buffers) do
    if entry.current then
      return i
    end
  end
end

function M.get_buffer_string(buffer, highlights)
  local highlight
  if buffer.current then
    highlight = "%#" .. highlights.selected.name .. "#"
  else
    highlight = "%#" .. highlights.other.name .. "#"
  end

  local filepath
  if buffer.current or not vim.g.tabline_shorten_filepath then
    filepath = buffer.filepath
  else
    filepath = buffer.shorten_filepath
  end

  local modified = ""
  if buffer.modified then
    modified = " +"
  end

  return highlight .. "[" .. buffer.number .. ":" .. filepath .. modified .. "]"
end

function M.add_buffer_on_left(buffer, highlights, tabline_string_length, tabline_max_length)
  local string_length
  if vim.g.tabline_shorten_filepath then
    string_length = buffer.shorten_string_length
  else
    string_length = buffer.string_length
  end

  if tabline_string_length + string_length < tabline_max_length then
    return {
      string = M.get_buffer_string(buffer, highlights) .. "%#" .. highlights.fill.name .. "# ",
      length = string_length,
    }
  else
    -- TODO: handle "<<<"
    return {
      string = "",
      length = 0,
    }
  end
end

function M.add_buffer_on_right(buffer, highlights, tabline_string_length, tabline_max_length)
  local string_length
  if vim.g.tabline_shorten_filepath then
    string_length = buffer.shorten_string_length
  else
    string_length = buffer.string_length
  end

  if tabline_string_length + string_length < tabline_max_length then
    return {
      string = "%#" .. highlights.fill.name .. "# " .. M.get_buffer_string(buffer, highlights),
      length = string_length,
    }
  else
    -- TODO: handle ">>>"
    return {
      string = "",
      length = 0,
    }
  end
end

function M.shorten_filepath(filepath)
  local ft = vim.split(filepath, "/")
  local rv = {}

  for i = 1, #ft - 1 do
    table.insert(rv, string.sub(ft[i], 1, 1))
  end

  table.insert(rv, ft[#ft])

  return table.concat(rv, "/")
end

return M
