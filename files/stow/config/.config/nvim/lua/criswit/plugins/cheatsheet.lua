return {
  "doctorfree/cheatsheet.nvim",
  dependencies = {
    "nvim-telescope/telescope.nvim",
    "nvim-lua/plenary.nvim",
    "nvim-lua/popup.nvim",
  },
  cmd = { "Cheatsheet", "CheatsheetEdit" },
  keys = {
    { "<leader>?", "<cmd>Cheatsheet<CR>", desc = "Open Cheatsheet" },
  },
  config = function()
    require("cheatsheet").setup({
      bundled_cheatsheets = true,
      bundled_plugin_cheatsheets = true,
      include_only_installed_plugins = true,
      telescope_mappings = {
        ["<CR>"] = require("cheatsheet.telescope.actions").select_or_execute,
        ["<A-CR>"] = require("cheatsheet.telescope.actions").select_or_fill_commandline,
      },
    })
  end,
}