-- Editor plugins customization
return {
	-- Snacks: file explorer
	{
		"folke/snacks.nvim",
		opts = {
			explorer = {
				replace_netrw = true,
			},
		},
	},

	-- Telescope: show hidden files
	{
		"nvim-telescope/telescope.nvim",
		opts = {
			defaults = {
				file_ignore_patterns = { ".git/" },
			},
			pickers = {
				find_files = {
					hidden = true,
				},
			},
		},
	},
}
