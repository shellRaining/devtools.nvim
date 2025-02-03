# devtools.nvim

A plugin designed to enhance the debugging experience (perhaps), capable of hijacking the `vim.notify` and `vim.print` functions, redirecting their output to a temporary file, and then viewing the logs through external tools.

## Motivation

When developing Neovim plugins, debugging Lua code is inevitable. We typically use `vim.notify` or `vim.print` to print key information, which can solve the problem, but in some cases, it's not very convenient. For example:

1. When printing Lua tables, the output can appear cramped and is often cumbersome to view, requiring the use of the `:messages` command to see all the output.
2. If using `nvim-notify` or `noice.nvim` to address the first issue, when fixing window-related bugs, their floating windows often cause a flood of unnecessary information. Additionally, these floating windows that display information usually have a limited display time, and sometimes the log information disappears before you can finish reading it.

Initially, my solution was to have a persistent side window, similar to a browser's developer tools, hijack the aforementioned log functions, and redirect the content to this side window. This initially met my needs, but while learning the `vim.api.nvim_set_decoration_provider` API, I encountered an issue. Everything related to rendering in Neovim triggers the callback function within it, causing the second problem mentioned above to reappear!

Therefore, the final solution is to redirect the content to a temporary file and view the logs through external tools. This inevitably requires the use of tools like `tail` or `lnav`, but it effectively avoids the aforementioned issues.

## Configuration

`devtools.nvim` has the following default configuration:

```lua
local config = {
  -- Default log file path
  log_path = '/tmp/nvim_logs.log',
  -- Default log file path for the log file that is currently being written
  rewrite = false,
  -- Whether to automatically start logging on startup
  auto_start = false,
  entry = {
    -- Format of the log entry's start part, supports 'datetime', 'timestamp', and 'custom'
    present_start_format = 'datetime',
    -- When entry.present_start_format is 'custom', use this field to customize the start part
    custom_start = '',
  },
}
```

You can use plugin managers like `lazy.nvim` to download this plugin:

```lua
{
  "shellRaining/devtools.nvim",
  ---@module 'devtools'
  ---@type DevTools.DevToolsConfig
  opts = {
    -- add any options here
  },
}
```

## Usage

You can use the `DevToolsStartLog` command to start logging, `DevtoolsClearLog` to clear the log file
