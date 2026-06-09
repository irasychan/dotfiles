-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua

local autocmd = vim.api.nvim_create_autocmd
local augroup = vim.api.nvim_create_augroup

-- Resize splits if window got resized
autocmd("VimResized", {
	group = augroup("resize_splits", { clear = true }),
	callback = function()
		local current_tab = vim.fn.tabpagenr()
		vim.cmd("tabdo wincmd =")
		vim.cmd("tabnext " .. current_tab)
	end,
})

-- Force fold recompute after the treesitter parser attaches.
-- Without this, opening a JSON/JSONC buffer can leave foldexpr returning 0
-- for every line because the parser wasn't ready when folds were first evaluated.
autocmd("FileType", {
	group = augroup("ts_fold_refresh", { clear = true }),
	pattern = { "json", "jsonc", "json5", "yaml", "toml" },
	callback = function(args)
		vim.schedule(function()
			if vim.api.nvim_buf_is_valid(args.buf) then
				vim.api.nvim_buf_call(args.buf, function()
					if vim.wo.foldmethod == "expr" then
						vim.cmd("silent! normal! zx")
					end
				end)
			end
		end)
	end,
})

-- Go to last location when opening a buffer
autocmd("BufReadPost", {
	group = augroup("last_loc", { clear = true }),
	callback = function(event)
		local exclude = { "gitcommit" }
		local buf = event.buf
		if vim.tbl_contains(exclude, vim.bo[buf].filetype) or vim.b[buf].lazyvim_last_loc then
			return
		end
		vim.b[buf].lazyvim_last_loc = true
		local mark = vim.api.nvim_buf_get_mark(buf, '"')
		local lcount = vim.api.nvim_buf_line_count(buf)
		if mark[1] > 0 and mark[1] <= lcount then
			pcall(vim.api.nvim_win_set_cursor, 0, mark)
		end
	end,
})
