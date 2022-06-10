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
        local bufname = ""
        if vim.g.tabline_bufname == "filename" then
          bufname = vim.fn.expand("#" .. number .. ":t")
        elseif vim.g.tabline_bufname == "filepath" then
          bufname = vim.fn.expand("#" .. number)
        elseif vim.g.tabline_bufname == "short_filepath" then
          bufname = M.shorten_filepath(vim.fn.expand("#" .. number))
        end

        local length = string.len(bufname) + string.len(number)
        -- 3: "[" ":" "]"
        length = length + 3

        local modified = vim.fn.getbufinfo(number)[1].changed == 1
        if modified then
          -- 2: " +"
          length = length + 2
        end

        local buffer = {
          number = number,
          current = current_buffer == number,
          bufname = bufname,
          length = length,
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

  local modified = ""
  if buffer.modified then
    modified = " +"
  end

  return highlight .. "[" .. buffer.number .. ":" .. buffer.bufname .. modified .. "]"
end

function M.add_buffer_on_left(buffer, highlights, tabline_string_length, tabline_max_length)
  if tabline_string_length + buffer.length < tabline_max_length then
    return {
      string = M.get_buffer_string(buffer, highlights) .. "%#" .. highlights.fill.name .. "# ",
      length = buffer.length,
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
  if tabline_string_length + buffer.length < tabline_max_length then
    return {
      string = "%#" .. highlights.fill.name .. "# " .. M.get_buffer_string(buffer, highlights),
      length = buffer.length,
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
