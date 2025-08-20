vim.g.material_style = "darker"
return {
	"marko-cerovac/material.nvim",
	config = function()
		require("material").setup({
			contrast = {
				sidebars = true,
				floating_windows = true,
			},

			plugins = {
				"gitsigns",
				"indent-blankline",
				"nvim-tree",
				"telescope",
				"trouble",
				"which-key",
			},

			high_visibility = {
				darker = true,
			},

			disable_background = false,
			lualine_style = "stealth",
			
			custom_highlights = {
				-- Enhanced Material theme with rice customizations
				Normal = { bg = "#0F111A" },
				NormalFloat = { bg = "#212335" },
				FloatBorder = { fg = "#546E7A", bg = "NONE" },
				WinSeparator = { fg = "#37474F", bg = "NONE" },
				
				-- Bufferline integration
				BufferLineFill = { bg = "#1B1E2B" },
				BufferLineBuffer = { bg = "#1B1E2B", fg = "#B2CCD6" },
				BufferLineBufferSelected = { bg = "#0F111A", fg = "#82AAFF", bold = true },
				
				-- Enhanced popup menus
				Pmenu = { bg = "#212335", fg = "#B2CCD6" },
				PmenuSel = { bg = "#1976D2", fg = "#EEFFFF" },
				
				-- Telescope borderless theme
				TelescopeBorder = { fg = "#0F111A", bg = "#0F111A" },
				TelescopeNormal = { bg = "#0F111A" },
				TelescopePromptBorder = { fg = "#212335", bg = "#212335" },
				TelescopePromptNormal = { bg = "#212335" },
				
				-- nvim-tree borderless
				NvimTreeWinSeparator = { fg = "#0F111A", bg = "#0F111A" },
			},
		})
		
		-- Apply rice module highlights after Material theme setup
		local highlights = require("criswit.rice.highlights")
		highlights.setup_custom_highlights()
		highlights.setup_fillchars()
		highlights.apply_transparency()
	end,
}
