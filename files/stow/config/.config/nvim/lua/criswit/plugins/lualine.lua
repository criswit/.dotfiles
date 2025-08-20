local config = function()
	local lualine = require("lualine")
	local rice_statusline = require("criswit.rice.statusline")
	
	-- Custom color theme for minimalist rice
	local rice_theme = {
		normal = {
			a = { fg = "#0F111A", bg = "#82AAFF", gui = "bold" },
			b = { fg = "#B2CCD6", bg = "#212335" },
			c = { fg = "#B2CCD6", bg = "#1B1E2B" },
		},
		insert = {
			a = { fg = "#0F111A", bg = "#C3E88D", gui = "bold" },
			b = { fg = "#B2CCD6", bg = "#212335" },
			c = { fg = "#B2CCD6", bg = "#1B1E2B" },
		},
		visual = {
			a = { fg = "#0F111A", bg = "#C792EA", gui = "bold" },
			b = { fg = "#B2CCD6", bg = "#212335" },
			c = { fg = "#B2CCD6", bg = "#1B1E2B" },
		},
		replace = {
			a = { fg = "#0F111A", bg = "#FF5370", gui = "bold" },
			b = { fg = "#B2CCD6", bg = "#212335" },
			c = { fg = "#B2CCD6", bg = "#1B1E2B" },
		},
		command = {
			a = { fg = "#0F111A", bg = "#FFCB6B", gui = "bold" },
			b = { fg = "#B2CCD6", bg = "#212335" },
			c = { fg = "#B2CCD6", bg = "#1B1E2B" },
		},
		inactive = {
			a = { fg = "#546E7A", bg = "#212335" },
			b = { fg = "#546E7A", bg = "#212335" },
			c = { fg = "#546E7A", bg = "#1B1E2B" },
		},
	}
	
	lualine.setup({
		options = {
			theme = rice_theme,
			section_separators = { left = "", right = "" },
			component_separators = { left = "│", right = "│" },
			icons_enabled = true,
			globalstatus = true,
			disabled_filetypes = {
				statusline = {},
				winbar = {},
			},
			ignore_focus = {},
			always_divide_middle = true,
			refresh = {
				statusline = 1000,
				tabline = 1000,
				winbar = 1000,
			}
		},
		sections = {
			lualine_a = { 
				{
					"mode",
					fmt = function(str) 
						return str:sub(1,1) 
					end 
				}
			},
			lualine_b = { 
				{
					"branch",
					icons_enabled = true,
					icon = "",
					color = { fg = "#82AAFF" },
				},
				{
					rice_statusline.get_git_diff,
					color = { fg = "#C3E88D" },
					cond = function()
						return rice_statusline.get_git_diff() ~= ""
					end
				},
				{
					"diagnostics",
					sources = { "nvim_diagnostic" },
					symbols = { error = " ", warn = " ", info = " ", hint = " " },
					diagnostics_color = {
						error = { fg = "#FF5370" },
						warn = { fg = "#FFCB6B" },
						info = { fg = "#89DDFF" },
						hint = { fg = "#C3E88D" },
					},
				}
			},
			lualine_c = {
				{
					"filename",
					path = 1,
					shorting_target = 40,
					symbols = {
						modified = " ●",
						readonly = " ",
						unnamed = "[No Name]",
						newfile = " ",
					}
				},
				{
					rice_statusline.get_lsp_status,
					color = { fg = "#89DDFF" },
					cond = function()
						return rice_statusline.get_lsp_status() ~= ""
					end
				}
			},
			lualine_x = {
				{
					rice_statusline.get_macro_recording,
					color = { fg = "#FF5370", gui = "bold" },
					cond = function()
						return rice_statusline.get_macro_recording() ~= ""
					end
				},
				{
					"encoding",
					cond = function()
						return vim.bo.fileencoding ~= "utf-8"
					end
				},
				{
					"fileformat",
					symbols = {
						unix = "LF",
						dos = "CRLF",
						mac = "CR",
					},
					cond = function()
						return vim.bo.fileformat ~= "unix"
					end
				},
				{
					"filetype",
					colored = true,
					icon_only = false,
					icon = { align = "left" },
				}
			},
			lualine_y = { 
				{
					"progress",
					fmt = function()
						return "%P/%L"
					end
				}
			},
			lualine_z = { 
				{
					"location",
					fmt = function()
						return "%l:%c"
					end
				}
			},
		},
		inactive_sections = {
			lualine_a = {},
			lualine_b = {},
			lualine_c = { 
				{ 
					"filename",
					path = 1,
					shorting_target = 40,
					symbols = {
						modified = " ●",
						readonly = " ",
						unnamed = "[No Name]",
					}
				}
			},
			lualine_x = { "location" },
			lualine_y = {},
			lualine_z = {},
		},
		-- Remove tabline since we're using bufferline
		tabline = {},
		winbar = {},
		inactive_winbar = {},
		extensions = { "nvim-tree", "quickfix", "fugitive", "trouble", "toggleterm" },
	})
end

return {
	"nvim-lualine/lualine.nvim",
	config = config,
}