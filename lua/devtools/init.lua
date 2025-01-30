local config = require('devtools.config')
local M = {}

local original_notify = vim.notify
local original_print = vim.print

---log file handler
---@type file*|nil
local log_file = nil

---get formatted time string
---@param format "timestamp"|"datetime"|"custom" time format
---@param custom_start string custom start string
---@return string
local function get_time_string(format, custom_start)
  if format == 'custom' then
    return custom_start
  elseif format == 'timestamp' then
    return tostring(os.time())
  else -- datetime
    return tostring(os.date('%Y-%m-%d %H:%M:%S'))
  end
end

---init log file
local function init_log_file()
  local mode = config.rewrite and 'w' or 'a'
  log_file = io.open(config.log_path, mode)
  if not log_file then
    error('无法打开日志文件: ' .. config.log_path)
    return
  end
  original_notify('start log file: ' .. config.log_path)
end

---write log
---@param content string log content
local function write_log(content)
  if not log_file then
    init_log_file()
  end

  local time_str = get_time_string(config.entry.present_start_format, config.entry.custom_start)

  if log_file then
    log_file:write(string.format('[%s] %s\n', time_str, content))
    log_file:flush()
  end
end

---rewrite vim.notify
---@param msg string msg content
---@param level? integer log level
---@param opts? table log options
function M.override_notify(msg, level, opts)
  original_notify(msg, level, opts)

  local level_str = level and string.format('[%s]', vim.log.levels[level]) or ''
  write_log(string.format('%s %s', level_str, msg))
end

---rewrite vim.print
---@param ... any
function M.override_print(...)
  original_print(...)

  local args = { ... }
  local str_args = {}
  for i, v in ipairs(args) do
    str_args[i] = vim.inspect(v)
  end
  write_log(table.concat(str_args, ' '))
end

---@param opts? DevTools.DevToolsConfig
function M.setup(opts)
  config = vim.tbl_deep_extend('force', config, opts or {})

  vim.notify = M.override_notify
  vim.print = M.override_print

  if config.auto_start then
    init_log_file()
  end

  vim.api.nvim_create_autocmd('VimLeavePre', {
    callback = function()
      M.cleanup()
    end,
    group = vim.api.nvim_create_augroup('DevToolsCleanup', { clear = true }),
  })
end

function M.cleanup()
  if log_file then
    log_file:close()
    log_file = nil
  end

  vim.notify = original_notify
  vim.print = original_print
end

return M
