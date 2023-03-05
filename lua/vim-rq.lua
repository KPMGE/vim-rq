-- GET http://localhost:8000/users

local function is_in_visual_line_mode(lt_col, gt_col)
  return lt_col == 0 and gt_col > 1000
end

local function get_visual_selection()
  local bufnr = vim.api.nvim_get_current_buf()
  -- [bufnum, lnum, col, off]
  local _, start_row, start_col, _ = unpack(vim.fn.getpos("'<"))
  -- Get the start and end positions of the visual selection
  local _, end_row, end_col, _ = unpack(vim.fn.getpos("'>"))


  -- Get the lines of text between the start and end positions
  local lines = vim.api.nvim_buf_get_lines(bufnr, start_row - 1, end_row, false)

  -- for key, val in pairs(lines) do
  --   print(key.. " = " ..val)
  -- end

  -- If the selection spans multiple lines, remove any leading or trailing whitespace
  if #lines > 1 and not is_in_visual_line_mode(start_col, end_col) then
    lines[1] = string.sub(lines[1], start_col)
    lines[#lines] = string.sub(lines[#lines], 1, end_col)
  else
    -- If the selection is on a single line, extract only the selected portion
    lines[1] = string.sub(lines[1], start_col, end_col)
  end

  -- Join the lines and return the result
  return table.concat(lines, "\n")
end

function process_selection()
  local bufnr = vim.api.nvim_get_current_buf()
  local text = get_visual_selection()

  local function split(str)
    local result = {}
    for token in string.gmatch(str, "%S+") do
      table.insert(result, token)
    end
    return result
  end

  local function trim(s)
    return s:gsub("^%s+", ""):gsub("%s+$", "")
  end

  local tokens = split(trim(text))
  local http_method = tokens[1]
  local url = tokens[2]

  if http_method == "GET" then
    local command = "curl " ..url .." -s | jq"
    print('COMMAND: ', command)
    local output = vim.fn.system(command)

    local lines = {}
    for line in output:gmatch("[^\n]+") do
      table.insert(lines, line)
    end

    -- create a new buffer with no initial content and wipe the buffer
    local buf = vim.api.nvim_create_buf(false, true)

    -- switch to the current buffer's window
    vim.cmd('wincmd w')

    -- split the window horizontally and display the new buffer
    vim.cmd('vsplit')
    vim.api.nvim_win_set_buf(0, buf)

    -- vim.api.nvim_set_current_buf(buf)
    bufnr = vim.api.nvim_buf_get_number(buf)

    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
    -- set the buffer's filetype to JSON
    vim.api.nvim_buf_set_option(bufnr, "filetype", "json")
  end
end

local function init()
  vim.api.nvim_set_keymap('v', '<leader>k', [[:lua process_selection()<CR>]], { noremap = true })
end

return {
  init = init,
}
