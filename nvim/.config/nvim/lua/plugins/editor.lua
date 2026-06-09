-- Editor plugins customization
return {
	-- Snacks: file explorer + disable image (no kitty/ghostty in WSL2)
	{
		"folke/snacks.nvim",
		---@type snacks.Config
		opts = {
			explorer = {
				replace_netrw = true,
			},
			image = { enabled = false },
		},
	},
}
