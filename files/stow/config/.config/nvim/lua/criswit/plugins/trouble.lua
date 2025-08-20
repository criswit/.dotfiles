return {
	"folke/trouble.nvim",
	cmd = { "Trouble" },
	config = function()
		require("trouble").setup({})
		vim.keymap.set("n", "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", { desc = "Toggle Trouble" })
	end,
}
