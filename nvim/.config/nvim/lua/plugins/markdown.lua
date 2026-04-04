-- Markdown formatting via conform.nvim
return {
	{
		"stevearc/conform.nvim",
		opts = {
			formatters_by_ft = {
				markdown = { "mdformat" },
			},
		},
	},
}
