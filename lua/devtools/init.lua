local config = require('devtools.config')
local window = require('devtools.window')

local M = {}

-- 存储原始函数
local original = {
  notify = vim.notify,
  notify_once = vim.notify_once,
  print = vim.print,
}

---@type DevTools.DevToolsConfigStrict
local current_config = config.default_config

local function intercept_message(content, type)
  table.insert(window.state.messages, {
    content = content,
    type = type,
    timestamp = os.time(),
  })
  window.update_content(current_config)
end

local function setup_interceptors()
  -- 重写通知函数
  local notify = function(msg, level, opts)
    intercept_message(msg, 'notify')
    return original.notify(msg, level, opts)
  end

  local notify_once = function(msg, level, opts)
    intercept_message(msg, 'notify_once')
    return original.notify_once(msg, level, opts)
  end

  local print = function(...)
    local args = { ... }
    intercept_message(args, 'print')
    return original.print(...)
  end

  vim.notify = notify
  vim.notify_once = notify_once
  vim.print = print
end

local function create_window()
  local win
  if current_config.display_mode == 'float' then
    win = window.create_float_window(current_config)
  else
    win = window.create_split_window(current_config)
  end

  -- 创建窗口后开始拦截
  setup_interceptors()
  return win
end

local function restore_original()
  vim.notify = original.notify
  vim.notify_once = original.notify_once
  vim.print = original.print
end

---@param user_config? DevTools.DevToolsConfig
function M.setup(user_config)
  current_config = vim.tbl_deep_extend('force', config.default_config, user_config or {})

  -- 添加命令
  vim.api.nvim_create_user_command('DevToolsToggle', function()
    if window.state.win and vim.api.nvim_win_is_valid(window.state.win) then
      vim.api.nvim_win_close(window.state.win, true)
      window.state.win = nil
      -- 恢复原始函数
      restore_original()
    else
      create_window()
    end
  end, {})

  vim.api.nvim_create_user_command('DevToolsClear', function()
    window.state.messages = {}
    window.update_content(current_config)
  end, {})

  -- 设置快捷键
  if current_config.keymaps.toggle then
    vim.keymap.set('n', current_config.keymaps.toggle, ':DevToolsToggle<CR>', { silent = true })
  end

  setup_interceptors()
end

function M.teardown()
  restore_original()
end

return M
