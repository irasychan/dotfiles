-- Editor plugins customization
return {
	-- Neo-tree: show hidden files by default
	{
		"nvim-neo-tree/neo-tree.nvim",
		opts = {
			filesystem = {
				filtered_items = {
					visible = true, -- Show hidden files
					hide_dotfiles = false,
					hide_gitignored = false,
					hide_by_name = {
						".git",
						".DS_Store",
					},
				},
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
