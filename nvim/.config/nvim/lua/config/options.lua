-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua

local opt = vim.opt

-- General
opt.clipboard = "unnamedplus" -- Sync with system clipboard
opt.mouse = "a" -- Enable mouse mode
opt.undofile = true -- Enable persistent undo
opt.undolevels = 10000

-- UI
opt.number = true -- Print line number
opt.relativenumber = true -- Relative line numbers
opt.cursorline = true -- Enable highlighting of the current line
opt.signcolumn = "yes" -- Always show the signcolumn
opt.termguicolors = true -- True color support
opt.wrap = false -- Disable line wrap

-- Indentation
opt.expandtab = true -- Use spaces instead of tabs
opt.shiftwidth = 2 -- Size of an indent
opt.tabstop = 2 -- Number of spaces tabs count for
opt.smartindent = true -- Insert indents automatically

-- Search
opt.ignorecase = true -- Ignore case
opt.smartcase = true -- Don't ignore case with capitals

-- Splits
opt.splitbelow = true -- Put new windows below current
opt.splitright = true -- Put new windows right of current

-- WSL cursor shape fix
if vim.fn.has("wsl") == 1 then
  vim.g.clipboard = {
    name = "WslClipboard",
    copy = {
      ["+"] = "clip.exe",
      ["*"] = "clip.exe",
    },
    paste = {
      ["+"] = 'powershell.exe -c [Console]::Out.Write($(Get-Clipboard -Raw).tostring().replace("`r", ""))',
      ["*"] = 'powershell.exe -c [Console]::Out.Write($(Get-Clipboard -Raw).tostring().replace("`r", ""))',
    },
    cache_enabled = 0,
  }
end
