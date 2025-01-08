local M = {}

---@class DevToolsState
---@field buf integer|nil
---@field win integer|nil
---@field messages DevToolsMessage[]

---@class DevToolsMessage
---@field content any
---@field type string
---@field timestamp number

---@type DevToolsState
M.state = {
  buf = nil,
  win = nil,
  messages = {},
}

-- 创建或获取 DevTools buffer
---@return integer
function M.get_buffer()
  if M.state.buf and vim.api.nvim_buf_is_valid(M.state.buf) then
    return M.state.buf
  end

  M.state.buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_set_option_value('buftype', 'nofile', { buf = M.state.buf })
  vim.api.nvim_set_option_value('bufhidden', 'hide', { buf = M.state.buf })
  vim.api.nvim_set_option_value('swapfile', false, { buf = M.state.buf })
  vim.api.nvim_buf_set_name(M.state.buf, 'DevTools')
  return M.state.buf
end

---@param config DevTools.DevToolsConfigStrict
function M.create_split_window(config)
  local buf = M.get_buffer()
  local cmd = config.display_mode == 'split' and 'split' or 'vsplit'

  vim.cmd(cmd)
  local size = math.floor((cmd == 'split' and vim.o.lines or vim.o.columns) * config.split_size)
  vim.cmd(size .. 'wincmd ' .. (cmd == 'split' and '_' or '|'))

  local win = vim.api.nvim_get_current_win()
  vim.api.nvim_win_set_buf(win, buf)
  M.state.win = win

  M.setup_window_options(win)
  return win
end

---@param config DevTools.DevToolsConfigStrict
function M.create_float_window(config)
  local width = math.floor(vim.o.columns * config.float.width)
  local height = math.floor(vim.o.lines * config.float.height)
  local opts = {
    relative = 'editor',
    width = width,
    height = height,
    col = math.floor((vim.o.columns - width) / 2),
    row = math.floor((vim.o.lines - height) / 2),
    style = 'minimal',
    border = config.float.border,
  }

  local buf = M.get_buffer()
  M.state.win = vim.api.nvim_open_win(buf, true, opts)
  M.setup_window_options(M.state.win)
  return M.state.win
end

---@param win integer
function M.setup_window_options(win)
  vim.api.nvim_set_option_value('number', false, { win = win })
  vim.api.nvim_set_option_value('relativenumber', false, { win = win })
  vim.api.nvim_set_option_value('wrap', true, { win = win })
end

---@param config DevTools.DevToolsConfigStrict
function M.update_content(config)
  if not M.state.buf then
    return
  end

  ---@param value any
  ---@return string
  local function format_content(value)
    -- 如果是简单的数组且只有一个元素，直接返回该元素
    if type(value) == 'table' then
      local count = 0
      local single_value
      local is_array = true

      for k, v in pairs(value) do
        count = count + 1
        if type(k) ~= 'number' then
          is_array = false
        end
        single_value = v
        if count > 1 then
          break
        end
      end

      if count == 1 and is_array then
        return vim.inspect(single_value)
      end
    end

    return vim.inspect(value)
  end

  local lines = {}
  for _, msg in ipairs(M.state.messages) do
    -- 使用消息中存储的时间戳
    local timestamp = os.date('%H:%M:%S', msg.timestamp)
    -- 添加消息头
    table.insert(lines, string.format('[%s] %s:', timestamp, msg.type))
    -- 将内容按行分割并添加缩进
    local content = format_content(msg.content)
    for line in content:gmatch('[^\r\n]+') do
      table.insert(lines, '    ' .. line)
    end
    -- 添加一个空行作为消息间的分隔
    table.insert(lines, '')
  end

  vim.api.nvim_buf_set_lines(M.state.buf, 0, -1, false, lines)

  if config.auto_scroll and M.state.win and vim.api.nvim_win_is_valid(M.state.win) then
    vim.api.nvim_win_set_cursor(M.state.win, { #lines, 0 })
  end
end

return M
