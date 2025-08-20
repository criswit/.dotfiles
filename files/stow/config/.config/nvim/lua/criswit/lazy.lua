local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable", -- latest stable release
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({ { import = "criswit.plugins" }, { import = "criswit.plugins.lsp" } }, {
	-- Performance optimizations for rice setup
	install = {
		missing = true,
		colorscheme = { "material" },
	},
	performance = {
		cache = {
			enabled = true,
		},
		reset_packpath = true, -- reset the package path to improve startup time
		rtp = {
			reset = true, -- reset the runtime path to improve startup time
			---@type string[]
			paths = {}, -- add any custom paths here that you want to include in the rtp
			---@type string[] list any plugins you want to disable here
			disabled_plugins = {
				"gzip",
				"matchit",
				"matchparen",
				"netrwPlugin",
				"tarPlugin",
				"tohtml",
				"tutor",
				"zipPlugin",
			},
		},
	},
	checker = {
		enabled = true,
		notify = false,
		frequency = 3600, -- check for updates every hour
	},
	change_detection = {
		notify = false, -- disable notifications for better rice aesthetics
		enabled = true,
	},
	ui = {
		-- Minimal lazy UI for rice theme
		size = { width = 0.8, height = 0.8 },
		wrap = true,
		border = "rounded",
		backdrop = 60,
		title = "Lazy Package Manager",
		title_pos = "center",
		pills = true,
		icons = {
			cmd = " ",
			config = "",
			event = "",
			ft = " ",
			init = " ",
			import = " ",
			keys = " ",
			lazy = "󰒲 ",
			loaded = "●",
			not_loaded = "○",
			plugin = " ",
			runtime = " ",
			require = "󰢱 ",
			source = " ",
			start = "",
			task = "✔ ",
			list = {
				"●",
				"➜",
				"★",
				"‒",
			},
		},
	},
	-- Debugging options (usually disabled for production)
	debug = false,
})

vim.cmd.colorscheme("material")
