---@class DevTools.LogEntryConfig : DevTools.LogEntryConfigStrict
---@field present_start_format? "timestamp"|"datetime"|"custom" start string of log entry, default is datetime, because it's more human-readable
---@field custom_start? string custom start string of log entry, default is empty

---@class DevTools.DevToolsConfig : DevTools.DevToolsConfigStrict
---@field log_path? string path to log file, default is '/tmp/nvim_logs.log'
---@field rewrite? boolean whether to rewrite log file, default is false
---@field auto_start? boolean whether to start logging automatically, default is false
---@field entry? DevTools.LogEntryConfig log entry configuration
