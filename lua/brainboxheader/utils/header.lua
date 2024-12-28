---@tag brainboxheader.header

---@brief [[
---
---This module manages the header.
---
---@brief ]]

local M = {}
local config = require "brainboxheader.config"
local git = require "brainboxheader.utils.git"

---Get username.
---@return string|nil
function M.user()
  return vim.g.user or (config.opts.git.enabled and git.user()) or config.opts.user
end

---Get email.
---@return string|nil
function M.email()
  return vim.g.mail or (config.opts.git.enabled and git.email()) or config.opts.mail
end

---Get left and right comment symbols from the buffer.
---@return string, string
function M.comment_symbols()
  local str = vim.api.nvim_buf_get_option(0, "commentstring")

  if vim.tbl_contains({ "c", "cc", "cpp", "cxx", "tpp" }, vim.bo.filetype) then
    str = "/* %s */"
  end

  -- Checks the buffer has a valid commentstring.
  if str:find "%%s" then
    local left, right = str:match "(.*)%%s(.*)"

    if right == "" then
      right = left
    end

    return vim.trim(left), vim.trim(right)
  end

  return "#", "#" -- Default comment symbols.
end

---Generate a formatted text line for the header.
---@param text string: The text to include in the line.
---@param ascii string: The ASCII art for the line.
---@return string: The formatted header line.
function M.gen_line(text, ascii)
  local max_length = config.opts.length - config.opts.margin * 2 - #ascii

  text = (text):sub(1, max_length)

  local left, right = M.comment_symbols()
  local left_margin = (" "):rep(config.opts.margin - #left)
  local right_margin = (" "):rep(config.opts.margin - #right)
  local spaces = (" "):rep(max_length - #text)

  return left .. left_margin .. text .. spaces .. ascii .. right_margin .. right
end

---Generate a complete header.
---@return table: A table ontaining all lines of header.
function M.gen_header()
  local ascii = config.opts.asciiart
  local left, right = M.comment_symbols()
  local fill_line = left .. " " .. string.rep("*", config.opts.length - #left - #right - 2) .. " " .. right
  local empty_line = M.gen_line("", "")
  local date = os.date "%Y/%m/%d %H:%M:%S"

  -- Create the header by iterating over the ASCII art array
  local header_lines = {
    fill_line,
    empty_line,
  }

  -- Loop through each line of ASCII art
  for i = 1, #ascii do
    if i == #ascii - 4 then
      -- Insert user info at the first line
      table.insert(header_lines, M.gen_line("By: " .. M.user() .. " <" .. M.email() .. ">", ascii[i]))
    elseif i == #ascii - 3 then
      table.insert(header_lines, M.gen_line("From BrainBox Interactive, " .. os.date "%Y" .. ".", ascii[i]))
    elseif i == #ascii - 1 then
      -- Insert creation info at the second-to-last line
      table.insert(header_lines, M.gen_line("Created: " .. date .. " by " .. M.user(), ascii[i]))
    elseif i == #ascii then
      -- Insert update info at the last line
      table.insert(header_lines, M.gen_line("Updated: " .. date .. " by " .. M.user(), ascii[i]))
    else
      -- Insert regular ASCII art lines
      table.insert(header_lines, M.gen_line("", ascii[i]))
    end
  end
  
  table.insert(header_lines, empty_line)
  table.insert(header_lines, fill_line)

  return header_lines
end


---Checks if there is a valid header in the current buffer.
---@param header table: The header to compare with the contents of the existing buffer.
---@return boolean: `true` if the header exists, `false` otherwise.
function M.has_header(header)
  local lines = vim.api.nvim_buf_get_lines(0, 0, 11, false)

  -- Immutable lines that are used for checking.
  for _, v in pairs { 1, 2, 3, 10, 11 } do
    if header[v] ~= lines[v] then
      return false
    end
  end

  return true
end

---Insert a header into the current buffer.
---@param header table: The header to insert.
function M.insert_header(header)
  if not vim.api.nvim_buf_get_option(0, "modifiable") then
    vim.notify("The current buffer cannot be modified.", vim.log.levels.WARN, { title = "42 Header" })
    return
  end
  -- If the first line is not empty, the blank line will be added after the header.
  if vim.api.nvim_buf_get_lines(0, 0, 1, false)[1] ~= "" then
    table.insert(header, "")
  end

  vim.api.nvim_buf_set_lines(0, 0, 0, false, header)
end

---Update an existing header in the current buffer.
---@param header table: Header to override the current one.
function M.update_header(header)
  local immutable = { 6, 8 }

  -- Copies immutable lines from existing header to updated header.
  for _, value in ipairs(immutable) do
    header[value] = vim.api.nvim_buf_get_lines(0, value - 1, value, false)[1]
  end

  vim.api.nvim_buf_set_lines(0, 0, 11, false, header)
end

---Inserts or updates the header in the current buffer.
function M.BoxHeader()
  local header = M.gen_header()
  if not M.has_header(header) then
    M.insert_header(header)
  else
    M.update_header(header)
  end
end

return M
