-- Rice module initialization
-- This module handles all the visual enhancements for the minimalist rice theme

local M = {}

-- Initialize rice components
function M.setup()
	-- Apply highlights and visual enhancements
	local highlights = require("criswit.rice.highlights")
	highlights.setup_custom_highlights()
	highlights.setup_fillchars()
	highlights.apply_transparency()
	
	-- Set up additional visual enhancements that need to be applied after all plugins load
	vim.api.nvim_create_autocmd("VimEnter", {
		callback = function()
			-- Ensure our custom highlights are applied after all plugins load
			highlights.setup_custom_highlights()
		end,
	})
	
	-- Auto-refresh highlights when colorscheme changes
	vim.api.nvim_create_autocmd("ColorScheme", {
		callback = function()
			-- Re-apply our custom highlights after colorscheme changes
			vim.defer_fn(function()
				highlights.setup_custom_highlights()
			end, 100)
		end,
	})
end

return M