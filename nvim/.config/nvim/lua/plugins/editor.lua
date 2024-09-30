return {
  {
    "nvim-neo-tree/neo-tree.nvim",
    cmd = "Neotree",
    keys = {
      {
        "<leader>n",
        function()
          require("neo-tree.command").execute({ toggle = true })
        end,
        desc = "Toggle Neotree",
      },
      {
        "<leader>e",
        function()
          require("neo-tree.command").execute({ toggle = false, dir = LazyVim.root() })
        end,
        desc = "Focus Neotree (Root Dir)",
      },
      {
        "<leader>E",
        function()
          require("neo-tree.command").execute({ toggle = false, dir = vim.uv.cwd() })
        end,
        desc = "Focus Neotree (Root Dir)",
      },
    },
    opts = {
      filesystem = {
        filtered_items = {
          visible = true,
          hide_dotfiles = false,
          hide_hidden = false,
          always_show = {
            ".gitignored",
          },
        },
      },
    },
  },
}
