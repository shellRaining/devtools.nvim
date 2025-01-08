---@class DevTools.DevToolsConfigStrict
---@field display_mode "float"|"split"|"vsplit" 窗口显示模式
---@field split_size number 分割窗口的大小（百分比）
---@field float DevTools.DevToolsFloatConfig 浮动窗口的设置
---@field keymaps DevTools.DevToolsKeymaps 快捷键设置
---@field auto_scroll boolean 是否自动滚动到底部

---@class (exact) DevTools.DevToolsConfig : DevTools.DevToolsConfigStrict
---@field display_mode? "float"|"split"|"vsplit" 窗口显示模式
---@field split_size? number 分割窗口的大小（百分比）
---@field float? DevTools.DevToolsFloatConfig 浮动窗口的设置
---@field keymaps? DevTools.DevToolsKeymaps 快捷键设置
---@field auto_scroll? boolean 是否自动滚动到底部
---
---@class DevTools.DevToolsFloatConfig
---@field width number 浮动窗口宽度（百分比）
---@field height number 浮动窗口高度（百分比）
---@field border "none"|"single"|"double"|"rounded"|"solid"|"shadow" 边框样式

---@class DevTools.DevToolsKeymaps
---@field toggle string|nil 切换 DevTools 窗口的快捷键

local M = {}

---@type DevTools.DevToolsConfigStrict
M.default_config = {
  display_mode = 'float',
  split_size = 0.3,
  float = {
    width = 0.8,
    height = 0.8,
    border = 'rounded',
  },
  keymaps = {
    toggle = '<F12>',
  },
  auto_scroll = true,
}

return M
