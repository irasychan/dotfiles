-- Clojure: restrict Conjure to Clojure filetypes only
-- Workaround for LazyVim clojure extra leaking keymaps to all buffers
-- See: docs/lazyvim-conjure-keymap-leak.md
return {
	{
		"Olical/conjure",
		event = {},
		ft = { "clojure", "edn" },
		config = function()
			require("conjure.main").main()
		end,
		init = function()
			vim.g["conjure#filetypes"] = { "clojure", "edn" }
		end,
	},
}
