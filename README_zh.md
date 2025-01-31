# devtools.nvim

一个用来提高 debug 体验的插件（也许），能够劫持 `vim.notify` 和 `vim.print` 函数，将输出重定向到一个临时文件中，然后通过外部工具来查看 log

## 动机

在开发 neovim 插件的时候，不可避免的要调试 Lua 代码，我们通常通过 `vim.notify` 或者 `vim.print` 打印关键信息，这样可以解决问题，但有些情况下并不是很好用，比如

1. 在打印 Lua 表时会显得比较局促，查看也很麻烦，经常要使用 `:messages` 命令查看所有的输出
2. 如果使用 `nvim-notify` 或者 `noice.nvim` 来解决第一个问题，在对窗口相关的 bug 进行修复时，经常会因为他们的悬浮窗口导致输出大量的不必要的信息；除此之外，这些展示信息的悬浮窗口一般停留时间有限，有时候还没看完 log 信息就消失了

最开始我的解决方案是通过常驻一个侧边窗口，就像是浏览器的开发者工具一样，将上述的 log 函数劫持，把内容重定向到这个侧边窗口中，最初确实满足了我的需求，但是在学习 `vim.api.nvim_set_decoration_provider` 这个 API 时，我发现了大麻烦，neovim 内所有的有关渲染的东西全部会触发里面的回调函数，导致上面提到的第二个问题再次出现了！

因此，最终的解决方案是将内容重定向到一个临时文件，然后通过外部工具来查看 log，这样不可避免的要使用诸如 `tail` 或者 `lnav` 这样的工具，但是确实能够避免上述的问题

## 配置

`devtools.nvim` 默认有以下配置

```lua
local config = {
  log_path = '/tmp/nvim_logs.log', -- 默认的 log 文件路径
  rewrite = false, -- 是否在每次启动时重写 log 文件
  auto_start = false, -- 是否在启动时自动开始 log
  entry = {
    present_start_format = 'datetime', -- log 条目起始部分的格式，支持 'datetime'，'timestamp' 和 'custom'
    custom_start = '', -- 当 entry.present_start_format 为 'custom' 时，使用这个字段来自定义起始部分
  },
}
```

你可以使用诸如 `lazy.nvim` 等插件管理器来下载这个插件：

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

## 使用

你可以通过 `DevToolsStartLog` 命令来启动日志记录
